/// Replaces `JsonPointer` from `package:rfc_6901`.
///
/// `JsonPointer` creates new object on every write.
/// `MutatorPointer` updates existing object on every write.
class MutatorPointer {
  final Map<String, dynamic> _mapReference;

  /// Creates [MutatorPointer].
  MutatorPointer(this._mapReference);

  /// Reads value from an underlying provided JSON.
  dynamic get(String path) {
    final segments = path.split('.').toList();
    if (segments.any((s) => s.isEmpty)) {
      throw MutatorPointerException('Path contains empty segments: $path');
    }

    if (segments.isEmpty) return _mapReference;

    final propertyName = segments.removeLast();

    Map? map = _mapReference;
    while (segments.isNotEmpty && map != null) {
      final segment = segments.removeAt(0);
      final potentialMap = map[segment];
      map = potentialMap is Map ? potentialMap : null;
    }

    return map?[propertyName];
  }

  /// Sets value to an underlying provided JSON.
  void set(String path, dynamic newValue) {
    final segments = path.split('.').toList();
    if (segments.any((s) => s.isEmpty)) {
      throw MutatorPointerException('Path contains empty segments: $path');
    }
    if (segments.isEmpty) {
      throw MutatorPointerException('Empty path is not supported for `set`');
    }

    final propertyName = segments.removeLast();

    Map map = _mapReference;
    while (segments.isNotEmpty) {
      final segment = segments.removeAt(0);
      final potentialMap = map[segment];
      if (potentialMap is Map) {
        map = potentialMap;
      } else {
        map[segment] = <String, dynamic>{};
        map = map[segment];
      }
    }

    map[propertyName] = newValue;
  }
}

/// [MutatorPointer] exception.
class MutatorPointerException implements Exception {
  /// Error message.
  final String message;

  /// Creates [MutatorPointerException]
  MutatorPointerException(this.message);

  @override
  String toString() => 'MutatorPointerException: $message';
}
