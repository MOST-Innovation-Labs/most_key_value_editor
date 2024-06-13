import 'package:json_schema/json_schema.dart';

import '../properties/most_property.dart';
import 'most_json_schema_property_parser.dart';
import 'property_mapper.dart';
import 'property_mappers.dart';
import 'property_spec.dart';

/// Parser for JSON Schema object model.
class MostJsonSchemaParser implements MostJsonSchemaPropertyParser {
  /// List of default mappers.
  static const List<PropertyMapper> defaultMappers = [
    BooleanPropertyMapper(),
    StringPropertyMapper(),
    NumberPropertyMapper(),
    ArrayPropertyMapper(),
    ObjectPropertyMapper(),
  ];

  /// List of custom mappers.
  ///
  /// [customMappers] are checked _before_ [defaultMappers].
  final List<PropertyMapper> customMappers;

  /// Creates [MostJsonSchemaParser].
  const MostJsonSchemaParser({
    this.customMappers = const [],
  });

  /// Parse JSON Schema.
  List<MostProperty> parse(JsonSchema jsonSchema) {
    return jsonSchema.properties.values.map(parseProperty).toList();
  }

  /// Parse JSON Schema property.
  @override
  MostProperty parseProperty(
    JsonSchema jsonSchema, {
    MostProperty? parent,
    String? overrideTitle,
    String? overridePropertyName,
    bool? overrideRequired,
  }) {
    final String? title = overrideTitle ?? jsonSchema.title;
    final String? description = jsonSchema.description;
    final String propName = overridePropertyName ?? jsonSchema.propertyName!;
    final bool required = overrideRequired ?? jsonSchema.requiredOnParent;

    JsonSchema propertySchema = jsonSchema;
    while (propertySchema.ref != null) {
      propertySchema = propertySchema.resolvePath(propertySchema.ref);
    }

    final propertySpec = PropertySpec(
      unresolvedPropertySchema: jsonSchema,
      propertySchema: propertySchema,
      title: title,
      description: description,
      propertyName: propName,
      required: required,
      parent: parent,
    );

    for (final mapper in customMappers) {
      final mostProperty = mapper.mapOrNull(this, propertySpec);
      if (mostProperty != null) return mostProperty;
    }

    for (final mapper in defaultMappers) {
      final mostProperty = mapper.mapOrNull(this, propertySpec);
      if (mostProperty != null) return mostProperty;
    }

    throw UnsupportedError('Type not supported');
  }
}
