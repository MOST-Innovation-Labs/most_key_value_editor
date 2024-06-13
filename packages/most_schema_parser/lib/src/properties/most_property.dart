part 'most_object_property.dart';
part 'most_value_property.dart';

/// Object model JSON Schema property representation.
abstract interface class MostProperty {
  /// Title.
  /// Mapped from `title`.
  final String? title;

  /// Description.
  /// Mapped from `description`.
  final String? description;

  /// Description.
  /// Mapped from the name of the property.
  final String propertyName;

  /// Parent property.
  /// Null only in root property.
  final MostProperty? parent;

  /// Whether the property is required on its parent.
  final bool required;

  /// Creates an object model for the JSON Schema property.
  const MostProperty({
    this.title,
    this.description,
    required this.propertyName,
    required this.required,
    this.parent,
  });

  /// Nesting level.
  /// Starting from `0` for root properties.
  int get level {
    int currentLevel = 0;

    MostProperty? prop = parent;
    while (prop != null) {
      currentLevel++;
      prop = prop.parent;
    }

    return currentLevel;
  }

  /// Dot-separated path for the given property.
  String get fullPath {
    String path = propertyName;

    MostProperty? prop = parent;
    while (prop != null) {
      path = '${prop.propertyName}.$path';
      prop = prop.parent;
    }

    return path;
  }

  @override
  String toString() => fullPath;
}
