import 'package:json_schema/json_schema.dart';

import '../properties/most_property.dart';

/// DTO used for property mapper.
class PropertySpec {
  /// JSON Schema of the property.
  final JsonSchema unresolvedPropertySchema;

  /// Resolved JSON Schema of the property.
  ///
  /// Same as [unresolvedPropertySchema]
  /// except for the case when `ref` is specified.
  final JsonSchema propertySchema;

  /// `title` property.
  final String? title;

  /// `description` property.
  final String? description;

  /// `propertyName` property from the parent JSON Schema.
  final String propertyName;

  /// `title` property.
  final bool required;

  /// Whether the property is required on its parent.
  final MostProperty? parent;

  /// Creates a [PropertySpec].
  PropertySpec({
    required this.unresolvedPropertySchema,
    required this.propertySchema,
    required this.title,
    required this.description,
    required this.propertyName,
    required this.required,
    required this.parent,
  });
}
