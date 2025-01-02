part of 'most_key_value_editor_controller.dart';

/// Editor State.
abstract class EditorState {
  /// Default public constructor.
  const EditorState();

  /// Creates state from [JsonAccessor].
  factory EditorState.fromAccessor(JsonAccessor jsonAccessor) = _EditorState;

  /// JSON Accessor.
  JsonAccessor get jsonAccessor;

  /// Validation Result.
  ValidationResult get validationResult;

  /// JSON Schema.
  JsonSchema? get jsonSchema;

  /// List of JSON Properties.
  List<MostProperty>? get properties;

  /// Cloning method.
  EditorState copyWith({
    JsonAccessor? jsonAccessor,
    ValidationResult? validationResult,
    JsonSchema? jsonSchema,
    List<MostProperty>? properties,
  });
}

class _EditorState extends EditorState {
  @override
  final JsonAccessor jsonAccessor;
  @override
  final ValidationResult validationResult;
  @override
  final JsonSchema? jsonSchema;
  @override
  final List<MostProperty>? properties;

  _EditorState(
    this.jsonAccessor, {
    this.validationResult = const ValidationResult.notValidated(),
    this.jsonSchema,
    this.properties,
  });

  @override
  _EditorState copyWith({
    JsonAccessor? jsonAccessor,
    ValidationResult? validationResult,
    JsonSchema? jsonSchema,
    List<MostProperty>? properties,
  }) {
    return _EditorState(
      jsonAccessor ?? this.jsonAccessor,
      validationResult: validationResult ?? this.validationResult,
      jsonSchema: jsonSchema ?? this.jsonSchema,
      properties: properties ?? this.properties,
    );
  }
}
