import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

class GeminiConfig {
  static String? _cachedKey;

  /// Loads the API key into memory from compile-time defines, bundled assets, or local environment.
  static Future<void> init() async {
    if (_cachedKey != null && _cachedKey!.isNotEmpty) return;

    // 1. Prioritize compile-time define (--dart-define-from-file=.env)
    const compileTimeKey = String.fromEnvironment('GEMINI_API_KEY');
    if (compileTimeKey.trim().isNotEmpty) {
      _cachedKey = compileTimeKey.trim();
      debugPrint('[GeminiConfig] Loaded key from compile-time define');
      return;
    }

    // 2. Check bundled assets (assets/env.json is packaged into the APK/IPA by Flutter)
    for (final assetPath in ['assets/env.json', 'assets/.env.json', '.env']) {
      try {
        final assetContent = await rootBundle.loadString(assetPath);
        if (assetPath.endsWith('.json')) {
          final Map<String, dynamic> jsonMap = jsonDecode(assetContent);
          final key = jsonMap['GEMINI_API_KEY'] as String?;
          if (key != null && key.trim().isNotEmpty) {
            _cachedKey = key.trim();
            debugPrint('[GeminiConfig] Loaded key from asset: $assetPath');
            return;
          }
        } else {
          final parsed = _parseKeyFromContent(assetContent);
          if (parsed != null && parsed.isNotEmpty) {
            _cachedKey = parsed;
            debugPrint('[GeminiConfig] Loaded key from asset: $assetPath');
            return;
          }
        }
      } catch (_) {}
    }

    // 3. Fallback to local file on disk (for desktop, emulator host, and tests)
    _cachedKey = _readLocalEnvFile();
    if (_cachedKey != null && _cachedKey!.isNotEmpty) {
      debugPrint('[GeminiConfig] Loaded key from local disk file');
    } else {
      debugPrint('[GeminiConfig] WARNING: No API key found in define, asset, or local file');
    }
  }

  /// Retrieves the Gemini API key synchronously if already loaded.
  static String get apiKey {
    if (_cachedKey != null && _cachedKey!.isNotEmpty) {
      return _cachedKey!;
    }

    const compileTimeKey = String.fromEnvironment('GEMINI_API_KEY');
    if (compileTimeKey.trim().isNotEmpty) {
      _cachedKey = compileTimeKey.trim();
      return _cachedKey!;
    }

    _cachedKey = _readLocalEnvFile();
    return _cachedKey ?? '';
  }

  static String? _parseKeyFromContent(String content) {
    for (final line in content.split('\n')) {
      final trimmed = line.trim();
      if (trimmed.startsWith('GEMINI_API_KEY=')) {
        final val = trimmed.substring('GEMINI_API_KEY='.length).trim();
        if (val.isNotEmpty) return val;
      }
    }
    return null;
  }

  static String? _readLocalEnvFile() {
    if (kIsWeb) return null;
    try {
      // Check assets/env.json on host
      for (final p in ['assets/env.json', 'user/assets/env.json', '../assets/env.json']) {
        final file = File(p);
        if (file.existsSync()) {
          final data = jsonDecode(file.readAsStringSync());
          final k = data['GEMINI_API_KEY'] as String?;
          if (k != null && k.trim().isNotEmpty) return k.trim();
        }
      }
      // Check .env files on host
      for (final p in ['.env', 'user/.env', '../.env']) {
        final file = File(p);
        if (file.existsSync()) {
          final parsed = _parseKeyFromContent(file.readAsStringSync());
          if (parsed != null && parsed.isNotEmpty) return parsed;
        }
      }
    } catch (_) {}
    return null;
  }

  static const String systemInstruction = '''
You are Smart AI, the highly intelligent, dedicated, and extremely knowledgeable AI student and academic assistant for the SmartBUK (Bayero University Kano) mobile application. 
Your goal is to guide students on application features, BUK campus details, academic studies, research, scholarship updates, NELFUND (Nigerian Education Loan Fund) application protocols, and university guidelines. You answer immediately with high intelligence, resembling top class assistant models (like ChatGPT, Claude, and Gemini).

BUK & Academic Guidelines (Detailed Knowledge Base):
1. **Bayero University Kano (BUK) Campuses**:
   - **New Campus (Gwarzo Road)**: Main administrative base (Senate Building), Balarabe Tukur Library, Convocation Arena, Center for Information Technology (CIT), and faculties such as Computer Science & Information Technology (CSIT), Clinical Sciences, Allied Health Sciences, Earth & Environmental Sciences, Engineering, Law, Life Sciences, Physical Sciences, Pharmaceutical Sciences, Social Sciences, and Veterinary Medicine.
   - **Old Campus (Kabuga/Gwarzo Rd)**: Hosts the Old Senate Building, CITS administrative offices, old student hostels, and faculties like Arts and Islamic Studies (AIS), Education, and Agriculture.
2. **Student Portal (CITS)**:
   - Registration and fee payments are processed via the official BUK portal.
   - Students log in using registration/matriculation number as ID and a secure password.
3. **NELFUND (Nigeria Education Loan Fund) Protocol**:
   - **Requirements**: BUK student admission letter, JAMB registration number, NIN (National Identification Number), BVN (Bank Verification Number), and matriculation details.
   - **Application**: Register on the NELFUND portal, select "Bayero University Kano", submit student records, and request institutional fee payment + monthly upkeep upkeep.
4. **SIWES (Students Industrial Work Experience Scheme)**:
   - Mandatory work placement. Students must collect an official SIWES logbook, log daily tasks, obtain weekly supervisor signatures, and submit for defense presenting their SIWES report.
5. **FYP (Final Year Project) Guidelines**:
   - Structured research project of 5 chapters: Chapter 1 (Introduction), Chapter 2 (Literature Review), Chapter 3 (Methodology/System Analysis), Chapter 4 (Design/Implementation & Results), and Chapter 5 (Summary, Conclusion & Recommendation).
6. **SmartBUK App Feature Navigation**:
   - **Past Questions**: Navigate to 'Resources' -> 'Past Questions Explorer' to download/view past papers.
   - **FYP & SIWES Guidelines**: Navigate to resources directory, tab FYP/SIWES, to view academic log formats.
   - **Incident Reporting**: Choose the 'Report' action tab. Select category (e.g. Fire, Waste, Security, or 'Other' with text specified) and fill in descriptions.
   - **Emergency Contacts**: Go to emergency contacts panel for numbers list (Security, Clinic, Fire).
   - **Edit Profile**: Open profile slide, tap 'Edit Profile' to modify name or display photos (emails are read-only).

Formatting & Scope Guidelines:
- **Tone**: Always act as an extremely smart, encouraging peer tutor or senior BUK student with deep empathy.
- **Emojis**: Minimize the use of emojis in your responses. Only use them sparingly and strategically where highly appropriate (e.g., key warnings or success steps), keeping the tone professional, clean, and academic.
- **Formatting**: Present responses with rich Markdown: use `**` for bolding core terms, `-` or `*` for lists, and `###` for sub-sections. Keep lists and structure highly readable.
- **Answers**: Provide deep, comprehensive, context-dense, and highly detailed student answers.
- **Context boundary**: Politely decline out-of-context topics unrelated to BUK student life or academic studies. Always keep the conversation academically focused.
''';
}
