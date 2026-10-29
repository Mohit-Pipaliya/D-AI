import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../config/app_constants.dart';
import '../errors/app_exception.dart';
import '../utils/logger.dart';

/// Contract for persistent secure storage.
abstract interface class SecureStorage {
  Future<String?> read(String key);
  Future<void> write(String key, String value);
  Future<void> delete(String key);
  Future<void> deleteAll();
}

/// Alias for LocalStorage interface.
typedef LocalStorage = SecureStorage;

/// Secure storage implementation backed by OS Keychain / Keystore.
class SecureStorageImpl implements SecureStorage {
  const SecureStorageImpl(this._storage);

  final FlutterSecureStorage _storage;

  @override
  Future<String?> read(String key) async {
    try {
      return await _storage.read(key: key);
    } catch (e, st) {
      AppLogger.e('Failed to read secure key: $key', error: e, stackTrace: st);
      throw StorageException('Failed to read secure key: $key', cause: e);
    }
  }

  @override
  Future<void> write(String key, String value) async {
    try {
      await _storage.write(key: key, value: value);
    } catch (e, st) {
      AppLogger.e('Failed to write secure key: $key', error: e, stackTrace: st);
      throw StorageException('Failed to write secure key: $key', cause: e);
    }
  }

  @override
  Future<void> delete(String key) async {
    try {
      await _storage.delete(key: key);
    } catch (e, st) {
      AppLogger.e('Failed to delete secure key: $key',
          error: e, stackTrace: st);
      throw StorageException('Failed to delete secure key: $key', cause: e);
    }
  }

  @override
  Future<void> deleteAll() async {
    try {
      await _storage.deleteAll();
    } catch (e, st) {
      AppLogger.e('Failed to clear secure storage', error: e, stackTrace: st);
      throw StorageException('Failed to clear secure storage', cause: e);
    }
  }
}

/// Helper for managing auth tokens in secure storage.
class AuthTokenStorage {
  const AuthTokenStorage(this._secureStorage);

  final SecureStorage _secureStorage;

  Future<String?> getAccessToken() =>
      _secureStorage.read(AppConstants.keyAccessToken);

  Future<void> saveAccessToken(String token) =>
      _secureStorage.write(AppConstants.keyAccessToken, token);

  Future<String?> getRefreshToken() =>
      _secureStorage.read(AppConstants.keyRefreshToken);

  Future<void> saveRefreshToken(String token) =>
      _secureStorage.write(AppConstants.keyRefreshToken, token);

  Future<void> clearTokens() async {
    await _secureStorage.delete(AppConstants.keyAccessToken);
    await _secureStorage.delete(AppConstants.keyRefreshToken);
  }
}
