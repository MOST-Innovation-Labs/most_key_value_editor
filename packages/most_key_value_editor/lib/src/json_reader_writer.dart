import 'package:most_schema_parser/most_schema_parser.dart';

import 'validator/validation_result.dart';

typedef JsonPropertyReaderWriterWrapper = JsonPropertyReaderWriter Function(
  JsonPropertyReaderWriter,
);

/// Class to perform operations on JSON.
class JsonReaderWriter {
  static const _maxRecentCommand = 50;

  final JsonPropertyReaderWriterWrapper? wrapPropertyRw;
  final List<_Command> _recentCommands;
  final Map<String, dynamic> _json;

  final void Function(Map<String, dynamic>)? onChanged;

  /// Creates [JsonReaderWriter].
  JsonReaderWriter({
    this.wrapPropertyRw,
    this.onChanged,
  })  : _recentCommands = [],
        _json = {};

  /// Replaces JSON with the provided one.
  void seed(Map<String, dynamic> json) {
    _addCommand(
      _SeedCommand(
        oldValue: _json.deepCopyMap(),
        newValue: json.deepCopyMap(),
      ),
    );

    _seed(json);
  }

  void _seed(Map<String, dynamic> json) {
    _json.clear();
    _json.addAll(json.deepCopyMap());
  }

  /// Returns JSON.
  Map<String, dynamic> read() {
    Map<String, dynamic> resultJson = _json.deepCopyMap();

    void removeNulls(Map<String, dynamic> sourceMap) {
      final sourceMapKeys = sourceMap.keys.toList();

      for (final sourceMapKey in sourceMapKeys) {
        final sourceValue = sourceMap[sourceMapKey];
        if (sourceValue is Map) {
          final submap = castToJsonMap(sourceValue);
          removeNulls(submap);
        } else if (sourceValue == null) {
          sourceMap.remove(sourceMapKey);
        }
      }
    }

    removeNulls(resultJson);

    return resultJson;
  }

  dynamic _get(String path) => MutatorPointer(_json).get(path);

  void _set(String path, dynamic obj) => MutatorPointer(_json).set(path, obj);

  /// Returns [JsonPropertyReaderWriter] for the specified path.
  ///
  /// Path must be a valid dot-separated path for the given property.
  JsonPropertyReaderWriter property(String path) {
    final propertyRw = JsonPropertyReaderWriter(
      path: path,
      get: () => _get(path),
      set: (newValue) {
        _addCommand(
          _SetCommand(
            path: path,
            oldValue: _get(path),
            newValue: newValue,
          ),
        );
        _set(path, newValue);
        onChanged?.call(_json);
      },
      getValidationResult: () => const ValidationResult.notValidated(),
    );

    final wrapPropertyRw = this.wrapPropertyRw;
    return wrapPropertyRw == null ? propertyRw : wrapPropertyRw(propertyRw);
  }

  void _addCommand(_Command command) {
    _recentCommands.add(command);

    if (_recentCommands.length > _maxRecentCommand) {
      final newCommandsList = _recentCommands.sublist(
        _recentCommands.length - _maxRecentCommand,
      );
      _recentCommands.clear();
      _recentCommands.addAll(newCommandsList);
    }
  }

  /// Returns true if the last change can be undone.
  // TODO move to controller
  bool get canUndo => _recentCommands.isNotEmpty;

  /// Reverts last change in JSON.
  void undo() {
    if (_recentCommands.isEmpty) return;
    final lastCommand = _recentCommands.removeLast();
    switch (lastCommand) {
      case _SeedCommand():
        _seed(lastCommand.oldValue);
      case _SetCommand():
        _set(lastCommand.path, lastCommand.oldValue);
    }
    onChanged?.call(_json);
  }
}

/// Class to perform operations on JSON property.
class JsonPropertyReaderWriter {
  /// Path.
  final String path;

  /// Value.
  final dynamic Function() _get;

  /// Sets value;
  final void Function(dynamic) _set;

  /// Most recent validation result.
  final ValidationResult Function() _getValidationResult;

  /// Creates [JsonPropertyReaderWriter]
  JsonPropertyReaderWriter({
    required this.path,
    required dynamic Function() get,
    required void Function(dynamic) set,
    required ValidationResult Function() getValidationResult,
  })  : _getValidationResult = getValidationResult,
        _set = set,
        _get = get;

  dynamic get value => _get();
  set value(dynamic newValue) => _set(newValue);
  ValidationResult get validationResult => _getValidationResult();

  /// Returns a copy with an overridden validation delegate.
  JsonPropertyReaderWriter withValidationErrors(
    ValidationResult Function() onGetValidationResult,
  ) =>
      JsonPropertyReaderWriter(
        path: path,
        get: _get,
        set: _set,
        getValidationResult: onGetValidationResult,
      );
}

sealed class _Command {}

class _SetCommand extends _Command {
  final String path;
  final dynamic oldValue;
  final dynamic newValue;

  _SetCommand({
    required this.path,
    required this.oldValue,
    required this.newValue,
  });
}

class _SeedCommand extends _Command {
  final Map<String, dynamic> oldValue;
  final Map<String, dynamic> newValue;

  _SeedCommand({
    required this.oldValue,
    required this.newValue,
  });
}
