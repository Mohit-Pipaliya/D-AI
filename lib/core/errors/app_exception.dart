/// Typed exception hierarchy for the D application.
///
/// All feature-layer exceptions extend [AppException] so they can
/// be caught uniformly and mapped to user-visible messages.
sealed class AppException implements Exception {
  /// Creates an [AppException] with a human-readable [message]
  /// and an optional [cause].
  const AppException(this.message, {this.cause});

  /// Human-readable error description (never contains PII).
  final String message;

  /// Optional underlying exception or error object.
  final Object? cause;

  @override
  String toString() => message;
}

/// Thrown when a network request fails (timeout, DNS, etc.).
class NetworkException extends AppException {
  /// Creates a [NetworkException].
  const NetworkException(super.message, {this.statusCode, super.cause});

  /// Optional HTTP status code if available.
  final int? statusCode;
}

/// Thrown when the backend returns an unexpected HTTP status.
class ServerException extends AppException {
  /// Creates a [ServerException] with the HTTP [statusCode].
  const ServerException(
    super.message, {
    required this.statusCode,
    super.cause,
  });

  /// HTTP status code returned by the server.
  final int statusCode;
}

/// Thrown when authentication or authorisation fails.
class AuthException extends AppException {
  /// Creates an [AuthException].
  const AuthException(super.message, {super.cause});
}

/// Thrown when local storage operations fail.
class StorageException extends AppException {
  /// Creates a [StorageException].
  const StorageException(super.message, {super.cause});
}

/// Thrown when input validation fails.
class ValidationException extends AppException {
  /// Creates a [ValidationException].
  const ValidationException(super.message, {super.cause});
}

/// Thrown when a required platform capability is unavailable
/// (e.g. permission denied).
class PlatformException extends AppException {
  /// Creates a [PlatformException].
  const PlatformException(super.message, {super.cause});
}
