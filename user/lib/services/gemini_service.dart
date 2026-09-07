import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../config/gemini_config.dart';

class GeminiService {
  final http.Client _client = http.Client();
  static const String _prefApiKeyKey = 'smartbuk_gemini_api_key';

  /// Resolves the Gemini API key in order of precedence:
  /// 1. Explicit [customApiKey] parameter (if provided)
  /// 2. Compile-time --dart-define=GEMINI_API_KEY or .env
  /// 3. Locally stored key in SharedPreferences (set via app UI)
  Future<String> resolveApiKey({String? customApiKey}) async {
    if (customApiKey != null && customApiKey.trim().isNotEmpty) {
      return customApiKey.trim();
    }
    if (GeminiConfig.apiKey.trim().isNotEmpty) {
      return GeminiConfig.apiKey.trim();
    }
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedKey = prefs.getString(_prefApiKeyKey)?.trim();
      if (savedKey != null && savedKey.isNotEmpty) {
        return savedKey;
      }
    } catch (e) {
      debugPrint('Error reading Gemini API key from preferences: $e');
    }
    return '';
  }

  /// Checks whether an API key is available via environment or local preferences.
  Future<bool> hasValidApiKey({String? customApiKey}) async {
    final key = await resolveApiKey(customApiKey: customApiKey);
    return key.isNotEmpty;
  }

  /// Saves a user-provided Gemini API key to local SharedPreferences.
  Future<void> saveApiKey(String key) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_prefApiKeyKey, key.trim());
  }

  /// Removes any locally saved Gemini API key.
  Future<void> clearSavedApiKey() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_prefApiKeyKey);
  }

  /// Generates a response from Gemini 2.5 Flash.
  /// Alternates messages in [history]: role can be 'user' or 'model'.
  Future<String> generateContent(List<Map<String, String>> history, {String? customApiKey}) async {
    final key = await resolveApiKey(customApiKey: customApiKey);
    if (key.isEmpty) {
      throw Exception('Gemini API key is not configured. Please supply a valid key.');
    }

    final url = Uri.parse(
      'https://generativelanguage.googleapis.com/v1beta/models/gemini-3.6-flash:generateContent',
    );

    final contents = history.map((msg) {
      final role = msg['role'] == 'user' ? 'user' : 'model';
      return {
        'role': role,
        'parts': [
          {'text': msg['content'] ?? ''}
        ]
      };
    }).toList();

    final body = {
      'contents': contents,
      'systemInstruction': {
        'parts': [
          {'text': GeminiConfig.systemInstruction}
        ]
      },
      'generationConfig': {
        'temperature': 0.7,
        'topK': 40,
        'topP': 0.95,
        'maxOutputTokens': 2048,
      }
    };

    try {
      final response = await _client.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'x-goog-api-key': key,
        },
        body: jsonEncode(body),
      );

      if (response.statusCode == 429) {
        throw Exception('quota_exceeded');
      }

      if (response.statusCode != 200) {
        final errBody = jsonDecode(response.body);
        final errMsg = errBody['error']?['message'] ?? 'Failed to communicate with AI service.';
        throw Exception(errMsg);
      }

      final data = jsonDecode(response.body);
      final text = data['candidates']?[0]?['content']?['parts']?[0]?['text'] as String?;
      if (text == null) {
        throw Exception('Received empty reply context.');
      }
      return text;
    } catch (e) {
      if (e.toString().contains('quota_exceeded')) {
        rethrow;
      }
      throw Exception('Connection failed. Please check your network and try again.');
    }
  }

  /// Streams chunks of text from Gemini 2.5 Flash API.
  Stream<String> generateContentStream(List<Map<String, String>> history, {String? customApiKey}) async* {
    final key = await resolveApiKey(customApiKey: customApiKey);
    if (key.isEmpty) {
      throw Exception('Gemini API key is not configured. Please supply a valid key.');
    }

    final url = Uri.parse(
      'https://generativelanguage.googleapis.com/v1beta/models/gemini-3.6-flash:streamGenerateContent',
    );

    final contents = history.map((msg) {
      final role = msg['role'] == 'user' ? 'user' : 'model';
      return {
        'role': role,
        'parts': [
          {'text': msg['content'] ?? ''}
        ]
      };
    }).toList();

    final body = {
      'contents': contents,
      'systemInstruction': {
        'parts': [
          {'text': GeminiConfig.systemInstruction}
        ]
      },
      'generationConfig': {
        'temperature': 0.7,
      }
    };

    final request = http.Request('POST', url)
      ..headers['Content-Type'] = 'application/json'
      ..headers['x-goog-api-key'] = key
      ..body = jsonEncode(body);

    try {
      final responseStream = await _client.send(request);

      if (responseStream.statusCode == 429) {
        throw Exception('quota_exceeded');
      }

      if (responseStream.statusCode != 200) {
        final errText = await responseStream.stream.bytesToString();
        throw Exception('API status ${responseStream.statusCode}: $errText');
      }

      var buffer = '';
      int depth = 0;
      int objectStart = -1;
      bool inString = false;
      bool escaped = false;

      await for (final chunk in responseStream.stream.transform(utf8.decoder)) {
        buffer += chunk;
        
        int i = 0;
        while (i < buffer.length) {
          final char = buffer[i];
          if (escaped) {
            escaped = false;
            i++;
            continue;
          }
          if (char == '\\') {
            escaped = true;
            i++;
            continue;
          }
          if (char == '"') {
            inString = !inString;
            i++;
            continue;
          }
          
          if (!inString) {
            if (char == '{') {
              if (depth == 0) {
                objectStart = i;
              }
              depth++;
            } else if (char == '}') {
              depth--;
              if (depth == 0 && objectStart != -1) {
                final objectStr = buffer.substring(objectStart, i + 1);
                try {
                  final parsed = jsonDecode(objectStr);
                  
                  // Check if chunk contains a top level error
                  if (parsed['error'] != null) {
                    final errMsg = parsed['error']?['message'] ?? 'Streaming error';
                    throw Exception(errMsg);
                  }
                  
                  final text = parsed['candidates']?[0]?['content']?['parts']?[0]?['text'] as String?;
                  if (text != null && text.isNotEmpty) {
                    yield text;
                  }
                } catch (e) {
                  if (e.toString().contains('quota_exceeded')) {
                    rethrow;
                  }
                  debugPrint('Failed to parse brace-enclosed JSON chunk: $e');
                }
                
                // Truncate buffer including processed object
                buffer = buffer.substring(i + 1);
                i = -1; // resets to 0 after i++
                objectStart = -1;
                depth = 0;
              }
            }
          }
          i++;
        }
      }
    } catch (e) {
      if (e.toString().contains('quota_exceeded')) {
        rethrow;
      }
      throw Exception('Streaming failure: $e');
    }
  }

  void dispose() {
    _client.close();
  }
}
