part of 'most_property.dart';

/// Object model JSON Schema property (with children) representation.
class MostObjectProperty extends MostProperty {
  /// List of nested properties.
  final List<MostProperty> properties;

  /// Creates an object model for the JSON Schema property (with children).
  MostObjectProperty({
    required super.title,
    required super.description,
    required super.propertyName,
    required super.required,
    required super.parent,
  }) : properties = [];

  @override
  String toString() => '${super.toString()}'
      '\n${properties.map((e) => e.toString()).join('\n')}';
}
