part of 'most_key_value_editor_controller.dart';

/// Transforms [EditorState] class.
/// Usually used as a command.
///
/// See:
/// - [SeedJsonSchemaCommand]
/// - [SeedJsonCommand]
/// - [ValidateCommand]
/// - [EditorTransformerExtension]
abstract class EditorTransformer<T extends EditorState> {
  /// Default const contructor.
  const EditorTransformer();

  /// Transformer body.
  T call(T state);
}

/// Seeds JSON Schema to the state.
class SeedJsonSchemaCommand<T extends EditorState>
    implements EditorTransformer<T> {
  final MostJsonSchemaParser _parser;
  final JsonSchema _jsonSchema;

  /// Create [SeedJsonSchemaCommand].
  const SeedJsonSchemaCommand(
    this._jsonSchema, {
    MostJsonSchemaParser parser = const MostJsonSchemaParser(),
  }) : _parser = parser;

  @override
  T call(T state) {
    return state.copyWith(
      jsonSchema: _jsonSchema,
      properties: _parser.parse(_jsonSchema),
    ) as T;
  }
}

/// Seeds JSON to the state.
class SeedJsonCommand<T extends EditorState> implements EditorTransformer<T> {
  final Map<String, dynamic> _json;

  /// Create [SeedJsonCommand].
  SeedJsonCommand(this._json);

  @override
  T call(T state) {
    state.jsonAccessor.seed(_json);
    return state;
  }
}

/// Validates the state and saves validation result to the state.
class ValidateCommand<T extends EditorState> implements EditorTransformer<T> {
  final EditorStateValidator _validator;

  /// Create [ValidateCommand].
  ValidateCommand(this._validator);

  /// Create [ValidateCommand] that represents a list of validators.
  ValidateCommand.fromList(List<EditorStateValidator> validators)
      : _validator = EditorStateValidator.merge(validators);

  @override
  T call(T state) {
    return state.copyWith(
      validationResult: ValidationResult.validated(
        _validator.validate(state),
      ),
    ) as T;
  }
}

/// Chaining extension.
extension EditorTransformerExtension<T extends EditorState>
    on EditorTransformer<T> {
  /// Executes specifid transformer right after [this].
  EditorTransformer<T> then(EditorTransformer<T> command) {
    return _EditorTransformer((state) => command(this(state)));
  }
}

class _EditorTransformer<T extends EditorState>
    implements EditorTransformer<T> {
  final T Function(T state) transformFn;

  const _EditorTransformer(this.transformFn);

  @override
  T call(T state) => transformFn(state);
}
