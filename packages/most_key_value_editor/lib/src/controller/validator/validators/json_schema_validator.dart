import '../../most_key_value_editor_controller.dart';
import '../editor_state_validator.dart';
import '../models/validation_message.dart';

/// Validator for JSON schema.
class JsonSchemaValidator implements EditorStateValidator {
  /// Create [JsonSchemaValidator].
  const JsonSchemaValidator();

  @override
  List<ValidationMessage> validate(EditorState state) {
    final jsonSchema = state.jsonSchema;
    if (jsonSchema == null) {
      return [
        const ValidationMessage.error('Schema is not provided'),
      ];
    }

    final map = state.jsonAccessor.read();
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
