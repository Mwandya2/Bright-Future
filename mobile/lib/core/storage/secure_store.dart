import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Keychain / Keystore backed storage for the JWT and anything else that must
/// never land in plain SharedPreferences.
class SecureStore {
  SecureStore({FlutterSecureStorage? storage})
      : _storage = storage ??
            const FlutterSecureStorage(
              // flutter_secure_storage 10 dropped `encryptedSharedPreferences`:
              // the default AndroidOptions now always uses the Keystore with
              // AES-GCM data encryption and RSA-OAEP key wrapping, which is
              // what that flag used to opt into.
              aOptions: AndroidOptions(),
              iOptions: IOSOptions(
                accessibility: KeychainAccessibility.first_unlock,
              ),
            );

  final FlutterSecureStorage _storage;

  static const String _kToken = 'bf_auth_token';
  static const String _kUserJson = 'bf_auth_user';

  Future<String?> readToken() async {
    try {
      return await _storage.read(key: _kToken);
    } catch (_) {
      return null;
    }
  }

  Future<void> writeToken(String token) async {
    try {
      await _storage.write(key: _kToken, value: token);
    } catch (_) {
      // Storage unavailable (e.g. locked keychain) - fail soft.
    }
  }

  Future<String?> readUserJson() async {
    try {
      return await _storage.read(key: _kUserJson);
    } catch (_) {
      return null;
    }
  }

  Future<void> writeUserJson(String json) async {
    try {
      await _storage.write(key: _kUserJson, value: json);
    } catch (_) {}
  }

  Future<void> clear() async {
    try {
      await _storage.delete(key: _kToken);
      await _storage.delete(key: _kUserJson);
    } catch (_) {}
  }
}
