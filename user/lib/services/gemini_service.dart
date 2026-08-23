import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/gemini_config.dart';

class GeminiService {
  final http.Client _client = http.Client();

  /// Generates a response from Gemini 2.5 Flash.
  /// Alternates messages in [history]: role can be 'user' or 'model'.
  Future<String> generateContent(List<Map<String, String>> history, {String? customApiKey}) async {
    final key = (customApiKey != null && customApiKey.isNotEmpty) ? customApiKey : GeminiConfig.apiKey;
    if (key.isEmpty) {
      throw Exception('Gemini API key is not configured. Please supply a valid key.');
    }

    final url = Uri.parse(
      'https://generativelanguage.googleapis.com/v1beta/models/gemini-2.5-flash:generateContent?key=$key',
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
        headers: {'Content-Type': 'application/json'},
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
    final key = (customApiKey != null && customApiKey.isNotEmpty) ? customApiKey : GeminiConfig.apiKey;
    if (key.isEmpty) {
      throw Exception('Gemini API key is not configured. Please supply a valid key.');
    }

    final url = Uri.parse(
      'https://generativelanguage.googleapis.com/v1beta/models/gemini-2.5-flash:streamGenerateContent?key=$key',
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
      ..body = jsonEncode(body);

    try {
      final responseStream = await _client.send(request);

      if (responseStream.statusCode == 429) {
        throw Exception('quota_exceeded');
      }

      if (responseStream.statusCode != 200) {
        final errText = await responseStream.stream.bytesToString();
        try {
          final errBody = jsonDecode(errText);
          throw Exception(errBody['error']?['message'] ?? 'API failed.');
        } catch (_) {
          throw Exception('Failed to connect to Gemini services.');
        }
      }

      // Convert chunked JSON array parsing format:
      // The stream yields objects in JSON format, usually starting with `[\n` and separated by `,\n`
      // To parse it reliably, we parse line arrays and buffer text.
      var buffer = '';
      await for (final chunk in responseStream.stream.transform(utf8.decoder)) {
        buffer += chunk;
        
        // Match JSON structures: we can scan for "text" : "..." tags inside candidated payload units
        // Or decode complete JSON objects separated by boundaries
        // Let's use a simpler and highly robust stream parser.
        // We know stream yields objects like:
        // {
        //   "candidates": [{"content": {"parts": [{"text": "hello"}]}}]
        // }
        // Each JSON response is bracketed or comes separated in JSON array.
        // We can split the stream buffer by newlines or regex to extract parts, or parse objects.
        // The most robust way is to parse lines, remove leading comma or brackets:
        final lines = buffer.split('\n');
        buffer = lines.removeLast(); // Keep incomplete lines in buffer

        for (var line in lines) {
          line = line.trim();
          if (line.startsWith('[')) line = line.substring(1);
          if (line.endsWith(']')) line = line.substring(0, line.length - 1);
          if (line.startsWith(',')) line = line.substring(1);
          line = line.trim();

          if (line.isEmpty) continue;

          try {
            final parsed = jsonDecode(line);
            final text = parsed['candidates']?[0]?['content']?['parts']?[0]?['text'] as String?;
            if (text != null && text.isNotEmpty) {
              yield text;
            }
          } catch (_) {
            // Wait for full buffer line if json parsing failed
            buffer = line + '\n' + buffer;
          }
        }
      }

      // Flush final buffer content
      if (buffer.isNotEmpty) {
        var line = buffer.trim();
        if (line.startsWith('[')) line = line.substring(1);
        if (line.endsWith(']')) line = line.substring(0, line.length - 1);
        if (line.startsWith(',')) line = line.substring(1);
        line = line.trim();
        try {
          final parsed = jsonDecode(line);
          final text = parsed['candidates']?[0]?['content']?['parts']?[0]?['text'] as String?;
          if (text != null && text.isNotEmpty) {
            yield text;
          }
        } catch (_) {}
      }
    } catch (e) {
      if (e.toString().contains('quota_exceeded')) {
        rethrow;
      }
      throw Exception('Streaming failure. Connection lost.');
    }
  }

  void dispose() {
    _client.close();
  }
}
