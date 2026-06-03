import 'package:shared_preferences/shared_preferences.dart';

class SessionManager {
  static const _tokenKey = 'auth_token';
  static const _userIdKey = 'user_id';

  final SharedPreferences prefs;

  SessionManager({required this.prefs});

  String? get token => prefs.getString(_tokenKey);
  int? get userId => prefs.getInt(_userIdKey);

  Future<void> saveToken(String token) async {
    await prefs.setString(_tokenKey, token);
  }

  Future<void> saveUserId(int userId) async {
    await prefs.setInt(_userIdKey, userId);
  }

  Future<void> clear() async {
    await prefs.remove(_tokenKey);
    await prefs.remove(_userIdKey);
  }
}
