import 'package:json_schema/json_schema.dart';
import 'package:most_schema_parser/most_schema_parser.dart';

class MostSchema {
  final JsonSchema jsonSchema;
  final List<MostProperty> properties;

  const MostSchema({
    required this.jsonSchema,
    required this.properties,
  });
}
