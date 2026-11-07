import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../../core/constants/api_endpoints.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/network/api_client.dart';
import '../../../core/utils/logger.dart';

class AuthRepository {
  final ApiClient _apiClient;
  static const _storage = FlutterSecureStorage();

  AuthRepository(this._apiClient);

  Future<bool> login(String email, String password) async {
    try {
      final res = await _apiClient.post(
        ApiEndpoints.authLogin,
        data: {
          'email': email.trim(),
          'password': password,
        },
      );
      if (res.statusCode == 200 && res.data != null) {
        final data = res.data as Map<String, dynamic>;
        final access = data['access_token'] as String?;
        final refresh = data['refresh_token'] as String?;
        if (access != null) {
          await _storage.write(
              key: AppConstants.prefKeyAccessToken, value: access);
        }
        if (refresh != null) {
          await _storage.write(
              key: AppConstants.prefKeyRefreshToken, value: refresh);
        }
        return true;
      }
      return false;
    } catch (e) {
      AppLogger.e('Login failed', e);
      return false;
    }
  }

  Future<bool> register(
    String email,
    String password,
    String fullName, {
    String? phone,
    String languagePreference = 'ml',
  }) async {
    try {
      final res = await _apiClient.post(
        ApiEndpoints.authRegister,
        data: {
          'email': email.trim(),
          'password': password,
          'full_name': fullName.trim(),
          'phone': phone?.isNotEmpty == true ? phone : null,
          'language_preference': languagePreference,
        },
      );
      if (res.statusCode == 201 && res.data != null) {
        final data = res.data as Map<String, dynamic>;
        final tokens = data['tokens'] as Map<String, dynamic>?;
        if (tokens != null) {
          final access = tokens['access_token'] as String?;
          final refresh = tokens['refresh_token'] as String?;
          if (access != null) {
            await _storage.write(
                key: AppConstants.prefKeyAccessToken, value: access);
          }
          if (refresh != null) {
            await _storage.write(
                key: AppConstants.prefKeyRefreshToken, value: refresh);
          }
        }
        return true;
      }
      return false;
    } catch (e) {
      AppLogger.e('Registration failed', e);
      return false;
    }
  }

  Future<void> logout() async {
    try {
      await _apiClient.post(ApiEndpoints.authLogout);
    } catch (e) {
      AppLogger.w('Logout API call failed, clearing local tokens: $e');
    }
    await _storage.delete(key: AppConstants.prefKeyAccessToken);
    await _storage.delete(key: AppConstants.prefKeyRefreshToken);
  }

  Future<bool> checkAuthStatus() async {
    final token = await _storage.read(key: AppConstants.prefKeyAccessToken);
    return token != null && token.isNotEmpty;
  }
}
