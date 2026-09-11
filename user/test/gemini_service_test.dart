import 'package:flutter_test/flutter_test.dart';
import 'package:smartbuk/config/gemini_config.dart';
import 'package:smartbuk/services/gemini_service.dart';

void main() {
  group('Gemini Configuration & Service Tests', () {
    test('GeminiConfig.apiKey is loaded and not empty', () {
      expect(GeminiConfig.apiKey.isNotEmpty, isTrue);
      expect(GeminiConfig.apiKey.length, greaterThan(10));
    });

    test('GeminiService hasValidApiKey returns true directly without manual input', () async {
      final gemini = GeminiService();
      final hasKey = await gemini.hasValidApiKey();
      expect(hasKey, isTrue);
    });

    test('GeminiService resolveApiKey resolves .env key directly', () async {
      final gemini = GeminiService();
      final key = await gemini.resolveApiKey();
      expect(key, equals(GeminiConfig.apiKey));
    });
  });
}
