import 'validation_message.dart';

/// Validation result.
sealed class ValidationResult {
  const ValidationResult._();

  /// Creates the object that indicates that NOT validated state.
  const factory ValidationResult.notValidated() = NotValidated._;

  /// Creates the object that indicates that validated state.
  const factory ValidationResult.validated(
    List<ValidationMessage> messages,
  ) = Validated._;
}

/// Validation result that indicates that validation had been NOT executed yet.
class NotValidated extends ValidationResult {
  const NotValidated._() : super._();
}

/// Validation result that indicates that validation had been executed.
class Validated extends ValidationResult {
  /// List of [ValidationMessage].
  final List<ValidationMessage> validationMessages;

  const Validated._(this.validationMessages) : super._();

  /// Errors.
  Iterable<ValidationError> get errors =>
      validationMessages.whereType<ValidationError>();

  /// Warnings.
  Iterable<ValidationWarning> get warnings =>
      validationMessages.whereType<ValidationWarning>();
}
