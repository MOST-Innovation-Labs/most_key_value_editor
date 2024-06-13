part 'validation_error.dart';
part 'validation_warning.dart';

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
