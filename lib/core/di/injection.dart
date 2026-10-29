import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../network/api_client.dart';
import '../network/sse_client.dart';
import '../storage/local_storage.dart';

/// Provider for the platform secure storage instance.
final flutterSecureStorageProvider = Provider<FlutterSecureStorage>((ref) {
  return const FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
    mOptions: MacOsOptions(accessibility: KeychainAccessibility.first_unlock),
  );
});

/// Provider for the secure storage wrapper.
final secureStorageProvider = Provider<SecureStorage>((ref) {
  final storage = ref.watch(flutterSecureStorageProvider);
  return SecureStorageImpl(storage);
});

/// Provider for managing auth tokens.
final authTokenStorageProvider = Provider<AuthTokenStorage>((ref) {
  final secureStorage = ref.watch(secureStorageProvider);
  return AuthTokenStorage(secureStorage);
});

/// Provider for the singleton [ApiClient].
final apiClientProvider = Provider<ApiClient>((ref) {
  final storage = ref.watch(secureStorageProvider);
  return ApiClient(storage: storage);
});

/// Provider for the streaming [SseClient].
final sseClientProvider = Provider<SseClient>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return SseClient(apiClient.dio);
});

