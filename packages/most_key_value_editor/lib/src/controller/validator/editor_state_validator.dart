import '../most_key_value_editor_controller.dart';
import 'models/validation_message.dart';

/// Editor State Validator.
abstract class EditorStateValidator {
  /// Default const constructor.
  const EditorStateValidator();

  /// Merges validators.
  const factory EditorStateValidator.merge(
    List<EditorStateValidator> validators,
  ) = _MergeEditorStateValidator;

  /// Returns validation messages (errors and warning) or an empty list.
  List<ValidationMessage> validate(EditorState state);
}

class _MergeEditorStateValidator implements EditorStateValidator {
  final List<EditorStateValidator> validators;

  const _MergeEditorStateValidator(this.validators);

  @override
  List<ValidationMessage> validate(EditorState state) {
    final messages = <ValidationMessage>[];
    for (final validator in validators) {
      messages.addAll(validator.validate(state));
    }
    return messages;
  }
}
