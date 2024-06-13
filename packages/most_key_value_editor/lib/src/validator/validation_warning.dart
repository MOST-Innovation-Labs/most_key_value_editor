part of 'validation_message.dart';

/// Generic validation warning.
sealed class ValidationWarning implements ValidationMessage {
  const ValidationWarning._();
}

class GenericValidationWarning extends ValidationWarning {
  /// Warning message.
  final String message;

  const GenericValidationWarning._(this.message) : super._();

  @override
  String get displayMessage => message;
}
