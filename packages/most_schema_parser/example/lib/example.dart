// ignore: depend_on_referenced_packages
import 'package:json_schema/json_schema.dart';
import 'package:most_schema_parser/most_schema_parser.dart';

void main() {
  final parser = MostJsonSchemaParser();
  final jsonSchema = JsonSchema.create(schema);
  final mostProperties = parser.parse(jsonSchema);

  print(mostProperties);
}

const schema = '''
{
  "title": "Person",
  "properties": {
    "firstName": {
      "type": "string",
      "description": "The person's first name."
    },
    "lastName": {
      "type": "string",
      "description": "The person's last name."
    },
    "age": {
      "description": "Age in years which must be equal to or greater than zero.",
      "type": "integer",
      "minimum": 0
    }
  }
}
''';
