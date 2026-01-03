import 'package:shared_preferences/shared_preferences.dart';
import '../../core/constants/app_constants.dart';

class TokenService {
  static SharedPreferences? _prefs;

  static Future<void> _initPrefs() async {
    _prefs ??= await SharedPreferences.getInstance();
  }

  static Future<bool> saveToken(String token) async {
    await _initPrefs();
    final success = await _prefs!.setString(AppConstants.tokenKey, token);
    if (success) {
      await _prefs!.setInt(AppConstants.tokenSavedAtKey, DateTime.now().millisecondsSinceEpoch);
    }
    return success;
  }

  static Future<String?> getToken() async {
    await _initPrefs();
    return _prefs!.getString(AppConstants.tokenKey);
  }

  static Future<bool> hasToken() async {
    final token = await getToken();
    return token != null && token.isNotEmpty;
  }

  static Future<bool> isTokenExpired() async {
    await _initPrefs();
    final savedAt = _prefs!.getInt(AppConstants.tokenSavedAtKey);
    
    if (savedAt == null) {
      return true;
    }
    
    final savedDate = DateTime.fromMillisecondsSinceEpoch(savedAt);
    final now = DateTime.now();
    final difference = now.difference(savedDate);

    return difference.inDays >= 7;
  }

  static Future<bool> clearTokenSavedAt() async {
    await _initPrefs();
    return await _prefs!.remove(AppConstants.tokenSavedAtKey);
  }

  static Future<bool> deleteToken() async {
    await _initPrefs();
    final tokenDeleted = await _prefs!.remove(AppConstants.tokenKey);
    await clearTokenSavedAt();
    return tokenDeleted;
  }
}

