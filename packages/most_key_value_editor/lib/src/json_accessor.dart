import 'package:most_schema_parser/most_schema_parser.dart';

/// Class to perform operations on JSON property.
abstract class JsonAccessor {
  /// Create [JsonAccessor].
  factory JsonAccessor() = _JsonAccessor;

  /// Replaces JSON with the provided one.
  void seed(Map<String, dynamic> json);

  /// Returns JSON.
  Map<String, dynamic> read({bool removeNulls = true});

  /// Get property value.
  ///
  /// Path must be a valid dot-separated path for the given property.
  dynamic getValue(String path);

  /// Set property value.
  ///
  /// Path must be a valid dot-separated path for the given property.
  void setValue(String path, dynamic value);

  /// Returns [JsonPropertyAccessor] for the specified path.
  ///
  /// Path must be a valid dot-separated path for the given property.
  JsonPropertyAccessor property(String path);
}

/// Class to perform operations on JSON property.
abstract class JsonPropertyAccessor {
  /// Path.
  String get path;

  /// Get value.
  dynamic get value;

  /// Set value.
  set value(dynamic newValue);
}

class _JsonAccessor implements JsonAccessor {
  final Map<String, dynamic> _json;

  _JsonAccessor() : _json = {};

  @override
  void seed(Map<String, dynamic> json) {
    _json.clear();
    _json.addAll(json.deepCopyMap());
  }

  @override
  Map<String, dynamic> read({bool removeNulls = true}) {
    Map<String, dynamic> resultJson = _json.deepCopyMap();

    void removeNullsFromMap(Map<String, dynamic> sourceMap) {
      final sourceMapKeys = sourceMap.keys.toList();

      for (final sourceMapKey in sourceMapKeys) {
        final sourceValue = sourceMap[sourceMapKey];
        if (sourceValue is Map) {
          final submap = castToJsonMap(sourceValue);
          removeNullsFromMap(submap);
        } else if (sourceValue == null) {
          sourceMap.remove(sourceMapKey);
        }
      }
    }

    if (removeNulls) {
      removeNullsFromMap(resultJson);
    }

    return resultJson;
  }

  @override
  dynamic getValue(String path) => MutatorPointer(_json).get(path);

  @override
  void setValue(String path, dynamic newValue) {
    MutatorPointer(_json).set(path, newValue);
  }

  @override
  JsonPropertyAccessor property(String path) {
    return _JsonPropertyAccessor(this, path);
  }
}

class _JsonPropertyAccessor implements JsonPropertyAccessor {
  final JsonAccessor accessor;
  @override
  final String path;

  _JsonPropertyAccessor(this.accessor, this.path);

  @override
  dynamic get value => accessor.getValue(path);

  @override
  set value(dynamic newValue) => accessor.setValue(path, newValue);
}

/// Proxy for JSON accessor.
///
/// Provides [onChanged] callback that is called on every change.
class ListeningProxyJsonAccessor implements JsonAccessor {
  /// Accessor to be wrapped.
  final JsonAccessor accessor;

  /// Changes callback.
  final void Function(String? path) onChanged;

  /// Create [ListeningProxyJsonAccessor].
  ListeningProxyJsonAccessor(
    this.accessor, {
    required this.onChanged,
  });

  @override
  Map<String, dynamic> read({bool removeNulls = true}) => accessor.read();

  @override
  dynamic getValue(String path) => accessor.getValue(path);

  @override
  void seed(Map<String, dynamic> json) {
    accessor.seed(json);
    onChanged(null);
  }

  @override
  void setValue(String path, dynamic value) {
    accessor.setValue(path, value);
    onChanged(path);
  }

  @override
  JsonPropertyAccessor property(String path) {
    return _JsonPropertyAccessor(this, path);
  }
}
