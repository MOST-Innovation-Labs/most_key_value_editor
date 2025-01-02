import 'package:flutter/material.dart';
import 'package:json_schema/json_schema.dart' hide ValidationError;
import 'package:most_schema_parser/most_schema_parser.dart';

import '../json_accessor.dart';
import 'validator/editor_state_validator.dart';
import 'validator/models/validation_result.dart';

part 'editor_state.dart';
part 'editor_transformer.dart';

/// Editor controller.
///
/// Responsible for:
/// - storing current json schema
/// - storing current json state
/// - validation
class MostKeyValueEditorController<T extends EditorState>
    extends ChangeNotifier {
  /// Transformer that is called on each change.
  ///
  /// Transformer is called before the [notifyListeners] call.
  final EditorTransformer<T>? onChangedTransformer;

  /// Current state.
  T state;

  /// Create [MostKeyValueEditorController].
  MostKeyValueEditorController({
    required T initialState,
    this.onChangedTransformer,
  }) : state = initialState;

  /// Backing [JsonSchema].
  JsonSchema? get jsonSchema => state.jsonSchema;

  /// Parsed [MostProperty] list from [JsonSchema].
  List<MostProperty>? get propeties => state.properties;

  /// Returns most recent [ValidationResult].
  ValidationResult get validationResult => state.validationResult;

  /// Returns [JsonAccessor] to manipulate the JSON.
  JsonAccessor get jsonAccessor => ListeningProxyJsonAccessor(
        state.jsonAccessor,
        onChanged: _onStateChanged,
      );

  void _onStateChanged([String? path]) {
    if (onChangedTransformer case var onChangedTransformer?) {
      state = onChangedTransformer(state);
    }
    notifyListeners();
  }

  /// Execute command on the editor.
  ///
  /// See:
  /// - [SeedJsonSchemaCommand]
  /// - [SeedJsonCommand]
  /// - [ValidateCommand]
  void executeCommand(EditorTransformer<T> transformer) {
    state = transformer(state);
    _onStateChanged();
  }

  /// Reads current state as a JSON.
  Map<String, dynamic> read() => state.jsonAccessor.read();
}
