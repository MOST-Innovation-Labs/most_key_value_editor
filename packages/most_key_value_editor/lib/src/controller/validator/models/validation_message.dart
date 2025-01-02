/// Validation warning.
///
/// Either a [ValidationWarning] or [ValidationError].
sealed class ValidationMessage {
  /// Creates a generic warning.
  const factory ValidationMessage.warning(String message) =
      GenericValidationWarning._;

  /// Creates a generic error.
  const factory ValidationMessage.error(String message) =
      GenericValidationError._;

  /// Creates a property error.
  const factory ValidationMessage.propertyError({
    required String path,
    required String message,
  }) = PropertyValidationError._;

  /// Validaton message.
  String get displayMessage;
}

/// Generic validation warning.
sealed class ValidationWarning implements ValidationMessage {
  const ValidationWarning._();
}

/// Warning message.
class GenericValidationWarning extends ValidationWarning {
  /// Warning message.
  final String message;

  const GenericValidationWarning._(this.message) : super._();

  @override
  String get displayMessage => message;
}

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
