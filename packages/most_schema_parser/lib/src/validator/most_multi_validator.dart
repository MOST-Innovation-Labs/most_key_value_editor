import 'most_validator.dart';
import 'models/validation_message.dart';

class MostMultiValidator implements MostValidator {
  final List<MostValidator> validators;

  const MostMultiValidator(this.validators);

  @override
  List<ValidationMessage> validate(Map<String, dynamic> map) {
    final messages = <ValidationMessage>[];
    for (final validator in validators) {
      messages.addAll(validator.validate(map));
    }
    return messages;
  }
}
