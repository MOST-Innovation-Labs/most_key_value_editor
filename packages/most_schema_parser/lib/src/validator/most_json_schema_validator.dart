import 'package:json_schema/json_schema.dart';

import 'most_validator.dart';
import 'models/validation_message.dart';

class MostJsonSchemaValidator implements MostValidator {
  final JsonSchema? jsonSchema;

  const MostJsonSchemaValidator(this.jsonSchema);

  @override
  List<ValidationMessage> validate(Map<String, dynamic> map) {
    final jsonSchema = this.jsonSchema;
    if (jsonSchema == null) {
      return [
        const ValidationMessage.error('Schema is not provided'),
      ];
    }

    final validationResult = jsonSchema.validate(map);
    final messages = <ValidationMessage>[];

    for (final error in [
      ...validationResult.errors,
      ...validationResult.warnings
    ]) {
      final path = _normalizeSchemaPath(error.instancePath) ?? '';
      messages.add(
        ValidationMessage.propertyError(
          path: path,
          message: error.message,
        ),
      );
    }

    return messages;
  }

  static String? _normalizeSchemaPath(String? path) {
    if (path == null) return null;

    String normalizedPath = path.replaceAll(' ', '').replaceAll('/', '.');
    if (normalizedPath.startsWith('.')) {
      normalizedPath = normalizedPath.substring(1);
    }
    return normalizedPath;
  }
}
