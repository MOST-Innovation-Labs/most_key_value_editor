import 'models/validation_message.dart';

abstract class MostValidator {
  /// Returns validation messages (errors and warning) or an empty list.
  List<ValidationMessage> validate(Map<String, dynamic> map);
}
