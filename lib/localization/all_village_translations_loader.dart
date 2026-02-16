class AllVillageTranslations {
  static Future<void> init() async {
    // enhanced - load from assets if needed
  }
  
  static String get(String lang, String key) {
    return key;
  }

  // placeholder loader
  static Map<String, Map<String, String>> load() => {};
}
