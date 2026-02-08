import 'package:shared_preferences/shared_preferences.dart';

class RestrictionStore {
  static const _key = 'user_restrictions';

  Future<List<String>> loadRestrictions() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList(_key) ?? [];
  }

  Future<void> saveRestrictions(List<String> restrictions) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_key, restrictions);
  }
}
