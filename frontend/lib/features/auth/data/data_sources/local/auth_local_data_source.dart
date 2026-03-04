import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../models/user_model.dart';

abstract class AuthLocalDataSource {
  Future<void> saveUser(UserModel user);
  Future<UserModel?> getUser();
  Future<void> clearUser();
}

class AuthLocalDataSourceImpl implements AuthLocalDataSource {
  final SharedPreferences _prefs;
  static const String _userKey = 'cached_user';

  AuthLocalDataSourceImpl(this._prefs);

  @override
  Future<void> saveUser(UserModel user) async {
    await _prefs.setString(_userKey, jsonEncode(user.toJson()));
  }

  @override
  Future<UserModel?> getUser() async {
    final jsonString = _prefs.getString(_userKey);
    if (jsonString == null) return null;
    return UserModel.fromJson(jsonDecode(jsonString) as Map<String, dynamic>);
  }

  @override
  Future<void> clearUser() async {
    await _prefs.remove(_userKey);
  }
}
