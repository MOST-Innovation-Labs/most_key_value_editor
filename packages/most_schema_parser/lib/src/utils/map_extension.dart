import 'dart:convert';

/// Fail-safe method to cast parsed JSON into `Map<String, dynamic>`.
Map<String, dynamic> castToJsonMap(
  dynamic source, {
  Map<String, dynamic> Function()? orElse,
}) {
  if (source is! Map) {
    return orElse?.call() ?? <String, dynamic>{};
  }

  if (!source.keys.every((key) => key is String)) {
    return orElse?.call() ?? <String, dynamic>{};
  }

  return source.cast<String, dynamic>();
}

extension DeepCopyMapExtension on Map<String, dynamic> {
  /// Creates deep copy of the provided Map.
  Map<String, dynamic> deepCopyMap() {
    final source = this;
    Map<String, dynamic> deepCopy = json.decode(json.encode(source));
    return deepCopy;
  }
}
