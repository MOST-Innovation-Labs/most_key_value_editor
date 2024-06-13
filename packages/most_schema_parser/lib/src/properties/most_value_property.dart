part of 'most_property.dart';

/// Object model JSON Schema property (without children) representation.
class MostValueProperty extends MostProperty {
  /// Creates an object model for the JSON Schema property (without children).
  const MostValueProperty({
    required super.title,
    required super.description,
    required super.propertyName,
    required super.required,
    required super.parent,
  });
}
