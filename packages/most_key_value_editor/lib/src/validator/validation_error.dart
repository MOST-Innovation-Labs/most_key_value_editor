part of 'validation_message.dart';

/// Validation error.
sealed class ValidationError implements ValidationMessage {
  const ValidationError._();
}

/// Generic validation error.
class GenericValidationError extends ValidationError {
  /// Error message.
  final String message;

  const GenericValidationError._(this.message) : super._();

  @override
  String get displayMessage => message;
}

/// Property validation error.
class PropertyValidationError extends ValidationError {
  /// Dot-separated property path.
  final String path;

  /// Error message.
  final String message;

  const PropertyValidationError._({
    required this.path,
    required this.message,
  }) : super._();

  @override
  String get displayMessage => '[$path] $message';
}
