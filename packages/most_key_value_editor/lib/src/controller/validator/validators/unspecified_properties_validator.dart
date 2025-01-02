import 'package:json_diff/json_diff.dart';
import 'package:most_schema_parser/most_schema_parser.dart';

import '../../../json_accessor.dart';
import '../../most_key_value_editor_controller.dart';
import '../editor_state_validator.dart';
import '../models/validation_message.dart';

/// Validator for extra values in JSON that are NOT in the JSON Schema.
class UnspecifiedPropertiesValidator implements EditorStateValidator {
  /// Return errors instead of warnings if true.
  final bool fatal;

  /// Create [UnspecifiedPropertiesValidator].
  const UnspecifiedPropertiesValidator({
    this.fatal = false,
  });

  @override
  List<ValidationMessage> validate(EditorState state) {
    final jsonAccessor = state.jsonAccessor;
    final properties = state.properties;
    if (properties == null) return [];

    Map<String, dynamic> getMapWithSpecifiedPropertiesOnly(
      List<MostProperty> properties,
    ) {
      final JsonAccessor resultAccessor = JsonAccessor();

      void traverseProperties(
        List<MostProperty> properties, {
        bool topLevel = false,
      }) {
        for (final property in properties) {
          switch (property) {
            case MostObjectProperty():
              if (property.required ||
                  jsonAccessor.property(property.fullPath).value != null) {
                traverseProperties(property.properties);
              }
            case MostValueProperty():
              resultAccessor.property(property.fullPath).value =
                  jsonAccessor.property(property.fullPath).value;
          }
        }
      }

      traverseProperties(properties, topLevel: true);

      return resultAccessor.read();
    }

    final specifiedPropertiesMap =
        getMapWithSpecifiedPropertiesOnly(properties);
    final map = jsonAccessor.read();
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
}
