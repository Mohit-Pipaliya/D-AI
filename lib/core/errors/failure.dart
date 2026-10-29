import 'package:equatable/equatable.dart';

/// Failure types used with the Either pattern in use cases.
///
/// Each [Failure] carries a user-visible [message] and optional
/// developer-facing [details].
sealed class Failure extends Equatable {
  /// Creates a [Failure].
  const Failure({required this.message, this.details});

  /// User-friendly error message (safe to display in UI).
  final String message;

  /// Developer-facing details for logging (never shown to users).
  final String? details;

  @override
  List<Object?> get props => [message, details];
}

/// A failure originating from the network layer.
class NetworkFailure extends Failure {
  /// Creates a [NetworkFailure].
  const NetworkFailure({required super.message, super.details});
}

/// A failure originating from the backend server.
class ServerFailure extends Failure {
  /// Creates a [ServerFailure] with an HTTP [statusCode].
  const ServerFailure({
    required super.message,
    required this.statusCode,
    super.details,
  });

  /// HTTP status code that caused the failure.
  final int statusCode;

  @override
  List<Object?> get props => [message, details, statusCode];
}

/// A failure originating from authentication or authorisation.
class AuthFailure extends Failure {
  /// Creates an [AuthFailure].
  const AuthFailure({required super.message, super.details});
}

/// A failure originating from local storage.
class StorageFailure extends Failure {
  /// Creates a [StorageFailure].
  const StorageFailure({required super.message, super.details});
}

/// A failure caused by invalid input or business-rule violation.
class ValidationFailure extends Failure {
  /// Creates a [ValidationFailure].
  const ValidationFailure({required super.message, super.details});
}

/// A generic catch-all failure for unexpected errors.
class UnexpectedFailure extends Failure {
  /// Creates an [UnexpectedFailure].
  const UnexpectedFailure({required super.message, super.details});
}
