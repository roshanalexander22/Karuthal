import 'package:equatable/equatable.dart';

/// Base class for all network-related exceptions thrown by [ApiClient].
///
/// Extend this class to represent specific HTTP error categories.
/// Each subclass carries a human-readable [message] suitable for display.
class NetworkException extends Equatable implements Exception {
  const NetworkException({
    required this.message,
    this.statusCode,
  });

  /// User-facing error message (may be translated before display).
  final String message;

  /// HTTP status code, if applicable.
  final int? statusCode;

  @override
  List<Object?> get props => [message, statusCode];

  @override
  String toString() => 'NetworkException($statusCode): $message';
}

// ── Specific exception types ───────────────────────────────────────────────────

/// Thrown when the server returns HTTP 401 (Unauthorized).
///
/// Signals that the user's session has expired and they should re-login.
class UnauthorizedException extends NetworkException {
  const UnauthorizedException({
    String? message,
  }) : super(
          message: message ?? 'Session expired. Please log in again.',
          statusCode: 401,
        );
}

/// Thrown when the server returns HTTP 403 (Forbidden).
///
/// The user is authenticated but lacks permission for the resource.
class ForbiddenException extends NetworkException {
  const ForbiddenException({
    String? message,
  }) : super(
          message: message ?? 'You do not have permission to perform this action.',
          statusCode: 403,
        );
}

/// Thrown when the server returns HTTP 404 (Not Found).
class NotFoundException extends NetworkException {
  const NotFoundException({
    String? message,
  }) : super(
          message: message ?? 'The requested resource was not found.',
          statusCode: 404,
        );
}

/// Thrown when the server returns HTTP 422 (Unprocessable Entity).
///
/// [errors] contains a map of field names to their validation error messages.
class ValidationException extends NetworkException {
  const ValidationException({
    String? message,
    this.errors,
  }) : super(
          message: message ?? 'Please check the information entered.',
          statusCode: 422,
        );

  /// Field-level validation errors returned by the backend.
  ///
  /// Example: `{'email': ['Enter a valid email address.']}`
  final Map<String, List<String>>? errors;

  /// Returns the first error message for a given [field], or null.
  String? fieldError(String field) => errors?[field]?.firstOrNull;

  @override
  List<Object?> get props => [...super.props, errors];
}

/// Thrown when the server returns a 5xx error.
class ServerException extends NetworkException {
  const ServerException({
    String? message,
    int? statusCode,
  }) : super(
          message: message ?? 'Server error. Please try again later.',
          statusCode: statusCode ?? 500,
        );
}

/// Thrown when the request or response exceeds the configured timeout.
class TimeoutException extends NetworkException {
  const TimeoutException()
      : super(
          message:
              'The request timed out. Check your connection and try again.',
        );
}

/// Thrown when no internet connectivity is detected.
class NoInternetException extends NetworkException {
  const NoInternetException()
      : super(
          message: 'No internet connection. Please check your network.',
        );
}

/// Thrown when the response body cannot be parsed into the expected type.
class ParseException extends NetworkException {
  const ParseException({String? message})
      : super(
          message: message ?? 'Failed to process the server response.',
        );
}

/// Thrown for file upload failures (size/type validation, write errors).
class UploadException extends NetworkException {
  const UploadException({required super.message});
}

// ── Extension helpers ─────────────────────────────────────────────────────────

extension NetworkExceptionX on NetworkException {
  /// Returns `true` if the exception represents an authentication failure.
  bool get isUnauthorized => this is UnauthorizedException;

  /// Returns `true` if no internet connection was available.
  bool get isOffline => this is NoInternetException;

  /// Returns `true` if the failure was a server-side error.
  bool get isServerError => this is ServerException;
}
