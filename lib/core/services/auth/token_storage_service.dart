import 'package:shared_preferences/shared_preferences.dart';

import '../../constants/constants.dart';

class TokenStorageService {
  final SharedPreferences _sharedPreferences;

  TokenStorageService(this._sharedPreferences);

  String? get accessToken => _sharedPreferences.getString(Constants.accessTokenKey);

  String? get refreshToken => _sharedPreferences.getString(Constants.refreshTokenKey);

  Future<void> saveTokens({required String accessToken, required String refreshToken}) async {
    await _sharedPreferences.setString(Constants.accessTokenKey, accessToken);
    await _sharedPreferences.setString(Constants.refreshTokenKey, refreshToken);
  }

  Future<void> clear() async {
    await _sharedPreferences.remove(Constants.accessTokenKey);
    await _sharedPreferences.remove(Constants.refreshTokenKey);
  }
}
