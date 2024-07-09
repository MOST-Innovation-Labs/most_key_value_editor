import 'package:json_diff/json_diff.dart';
import 'package:most_schema_parser/most_schema_parser.dart';

import '../json_reader_writer.dart';

class MostUnspecifiedPropertiesValidator implements MostValidator {
  final List<MostProperty>? properties;
  final JsonReaderWriter jsonRw;
  final bool fatal;

  const MostUnspecifiedPropertiesValidator(
    this.properties,
    this.jsonRw, {
    this.fatal = false,
  });

  @override
  List<ValidationMessage> validate(Map<String, dynamic> map) {
    final properties = this.properties;
    if (properties == null) return [];

    final specifiedPropertiesMap =
        _getMapWithSpecifiedPropertiesOnly(properties);
    final differ = JsonDiffer.fromJson(specifiedPropertiesMap, map);
    final diff = differ.diff();

    if (diff.hasNothing) return [];

    return [
      fatal
          ? ValidationMessage.error(
              "Source JSON contains unspecified properties:\n"
              "$diff",
            )
          : ValidationMessage.warning(
              "Source JSON contains unspecified properties:\n"
              "$diff",
            ),
    ];
  }

  Map<String, dynamic> _getMapWithSpecifiedPropertiesOnly(
    List<MostProperty> properties,
  ) {
    final JsonReaderWriter resultRw = JsonReaderWriter();

    void traverseProperties(
      List<MostProperty> properties, {
      bool topLevel = false,
    }) {
      for (final property in properties) {
        switch (property) {
          case MostObjectProperty():
            if (property.required ||
                jsonRw.property(property.fullPath).value != null) {
              traverseProperties(property.properties);
            }
          case MostValueProperty():
            resultRw.property(property.fullPath).value =
                jsonRw.property(property.fullPath).value;
        }
      }
    }

    traverseProperties(properties, topLevel: true);

    return resultRw.read();
  }
}
