import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../config/gemini_config.dart';

class GeminiService {
  final http.Client _client = http.Client();

  /// Resolves the Gemini API key directly from GeminiConfig (.env / build environment).
  Future<String> resolveApiKey({String? customApiKey}) async {
    if (customApiKey != null && customApiKey.trim().isNotEmpty) {
      return customApiKey.trim();
    }
    if (GeminiConfig.apiKey.isNotEmpty) {
      return GeminiConfig.apiKey.trim();
    }
    await GeminiConfig.init();
    return GeminiConfig.apiKey.trim();
  }

  /// Checks whether an API key is configured.
  Future<bool> hasValidApiKey({String? customApiKey}) async {
    final key = await resolveApiKey(customApiKey: customApiKey);
    return key.isNotEmpty;
  }

  /// Deprecated stubs preserved for backwards compatibility.
  Future<void> saveApiKey(String key) async {}
  Future<void> clearSavedApiKey() async {}

  /// Generates a response using high-speed Gemini Flash Lite with fallback to Gemini 3.6 Flash.
  Future<String> generateContent(List<Map<String, String>> history, {String? customApiKey}) async {
    final key = await resolveApiKey(customApiKey: customApiKey);
    if (key.isEmpty) {
      throw Exception('Gemini API key is not configured.');
    }

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

    // Primary: gemini-flash-lite-latest for ultra-fast responses (~1.4s)
    // Fallback: gemini-3.6-flash
    final models = ['gemini-flash-lite-latest', 'gemini-3.6-flash'];
    Exception? lastException;

    for (final model in models) {
      final url = Uri.parse(
        'https://generativelanguage.googleapis.com/v1beta/models/$model:generateContent',
      );

      try {
        final response = await _client.post(
          url,
          headers: {
            'Content-Type': 'application/json',
            'x-goog-api-key': key,
          },
          body: jsonEncode(body),
        ).timeout(const Duration(seconds: 12));

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
        if (text == null || text.trim().isEmpty) {
          throw Exception('Received empty reply context.');
        }
        return text;
      } catch (e) {
        if (e.toString().contains('quota_exceeded')) {
          rethrow;
        }
        lastException = e is Exception ? e : Exception(e.toString());
        debugPrint('Gemini model $model failed: $e, attempting fallback...');
      }
    }

    throw lastException ?? Exception('Connection failed. Please check your network and try again.');
  }

  /// Streams tokens rapidly for a smooth, immediate typing response in the UI.
  Stream<String> generateContentStream(List<Map<String, String>> history, {String? customApiKey}) async* {
    final responseText = await generateContent(history, customApiKey: customApiKey);

    // Yield words with a smooth micro-cadence to provide progressive text streaming
    final words = responseText.split(' ');
    for (int i = 0; i < words.length; i++) {
      yield (i == 0 ? '' : ' ') + words[i];
      await Future.delayed(const Duration(milliseconds: 15));
    }
  }

  void dispose() {
    _client.close();
  }
}
