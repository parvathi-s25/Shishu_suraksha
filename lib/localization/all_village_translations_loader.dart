import 'dart:convert';
import 'package:flutter/services.dart';

/// Complete village translations for all 110 villages in all 11 languages
/// This class loads village translations from JSON and provides lookup methods
class AllVillageTranslations {
  static Map<String, Map<String, String>>? _translations;
  
  // Language code mappings
  static const Map<String, String> _languageCodes = {
    'English': 'en',
    'తెలుగు': 'te',
    'हिंदी': 'hi',
    'தமிழ்': 'ta',
    'ಕನ್ನಡ': 'kn',
    'മലയാളം': 'ml',
    'ગુજરાતી': 'gu',
    'मराठী': 'mr',
    'বাংলা': 'bn',
    'ਪੰਜਾਬੀ': 'pa',
    'ଓଡ଼ିଆ': 'or',
  };

  /// Initialize translations from JSON file
  static Future<void> init() async {
    if (_translations != null) return;
    
    try {
      final jsonString = await rootBundle.loadString('lib/localization/all_village_translations.json');
      final jsonData = json.decode(jsonString) as Map<String, dynamic>;
      
      _translations = {};
      jsonData.forEach((key, value) {
        _translations![key] = Map<String, String>.from(value as Map);
      });
    } catch (e) {
      print('Error loading village translations: $e');
      _translations = {};
    }
  }

  /// Get translated village name
  /// [language] - Full language name (e.g., 'English', 'తెలుగు', 'हिंदी')
  /// [villageKey] - English village name (key)
  static String get(String language, String villageKey) {
    if (_translations == null) {
      print('Warning: AllVillageTranslations not initialized. Call init() first.');
      return villageKey;
    }
    
    final langCode = _languageCodes[language] ?? 'en';
    return _translations![villageKey]?[langCode] ?? villageKey;
  }

  /// Get all translations for a village
  static Map<String, String>? getAllTranslations(String villageKey) {
    return _translations?[villageKey];
  }

  /// Check if translations are loaded
  static bool get isInitialized => _translations != null;
}
