import 'most_validator.dart';
import 'models/validation_message.dart';

class MostCallbackValidator implements MostValidator {
  final List<ValidationMessage> Function(Map<String, dynamic> map) validator;

  MostCallbackValidator(this.validator);

  @override
  List<ValidationMessage> validate(Map<String, dynamic> map) => validator(map);
}
