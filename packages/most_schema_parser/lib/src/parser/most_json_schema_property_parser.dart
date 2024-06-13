import 'package:json_schema/json_schema.dart';

import '../properties/most_property.dart';

/// JSON Schema property parser.
abstract class MostJsonSchemaPropertyParser {
  /// Parse JSON Schema property.
  MostProperty parseProperty(
    JsonSchema jsonSchema, {
    MostProperty? parent,
    String? overrideTitle,
    String? overridePropertyName,
    bool? overrideRequired,
  });
}
