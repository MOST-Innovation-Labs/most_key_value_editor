import 'package:most_schema_parser/most_schema_parser.dart';

import '../../most_key_value_editor_controller.dart';
import '../editor_state_validator.dart';
import '../models/validation_message.dart';

/// Property validator.
typedef PropertyValidator = List<String> Function(
  MostValueProperty property,
  dynamic value,
);

/// Validator for [MostProperty]s.
class PropertiesValidator implements EditorStateValidator {
  /// Validator that is used for unknown properties.
  final PropertyValidator? customPropertyValidator;

  /// Return errors instead of warnings if true.
  final bool fatal;

  /// Create [PropertiesValidator].
  const PropertiesValidator({
    this.customPropertyValidator,
    this.fatal = true,
  });

  @override
  List<ValidationMessage> validate(EditorState state) {
    final jsonAccessor = state.jsonAccessor;
    final properties = state.properties;
    if (properties == null) {
      return [
        const ValidationMessage.warning("No schema to validate properties."),
      ];
    }

    List<ValidationMessage> validateProperty(MostProperty property) {
      switch (property) {
        case MostObjectProperty():
          return property.properties
              .map(validateProperty)
              .expand((list) => list)
              .toList();

        case MostValueProperty():
          final value = jsonAccessor.property(property.fullPath).value;

          return _validateValueProperty(property, value)
              .map(
                (error) => ValidationMessage.propertyError(
                  path: property.fullPath,
                  message: error,
                ),
              )
              .toList();
      }
    }

    return properties.map(validateProperty).expand((list) => list).toList();
  }

  List<String> _validateValueProperty(
    MostValueProperty property,
    dynamic value,
  ) {
    final errors = switch (property) {
      BooleanMostProperty() => _validateBool(property, value),
      StringMostProperty() => _validateString(property, value),
      EnumMostProperty() => _validateEnum(property, value),
      NumberMostProperty() => _validateNumber(property, value),
      ArrayMostProperty() => _validateArray(property, value),
      MostValueProperty() =>
        customPropertyValidator?.call(property, value) ?? [],
    };

    return errors;
  }

  List<String> _validateBool(
    BooleanMostProperty property,
    dynamic value,
  ) {
    if (value case bool? boolValue) {
      if (property.required && boolValue == null) {
        return ['Invalid value: value cannot be null'];
      }

      return [];
    }

    return ['Invalid type: boolean required'];
  }

  List<String> _validateString(
    StringMostProperty property,
    dynamic value,
  ) {
    if (value case String? stringValue) {
      if (property.pattern case RegExp regExp) {
        if (property.required && stringValue == null) {
          return ['Invalid value: value cannot be null'];
        }
        if (stringValue == null) return [];
        if (!regExp.hasMatch(stringValue)) {
          return ['Invalid value: "$value" is not matching "$regExp"'];
        }
      } else {
        if (property.required) {
          if (stringValue == null) {
            return ['Invalid value: value cannot be null'];
          }
          if (stringValue.isEmpty) {
            return ['Invalid value: value cannot be empty'];
          }
        }
      }

      return [];
    }

    return ['Invalid type: string required'];
  }

  List<String> _validateEnum(
    EnumMostProperty property,
    dynamic value,
  ) {
    if (value case List<String>? stringListValue) {
      if (property.required) {
        if (stringListValue == null) {
          return ['Invalid value: value cannot be null'];
        }
        if (stringListValue.isEmpty) {
          return ['Invalid value: value cannot be empty'];
        }
      }

      return [];
    }
    return [];
  }

  List<String> _validateNumber(
    NumberMostProperty property,
    dynamic value,
  ) {
    if (value case num? numberValue) {
      if (property.required && (numberValue == null)) {
        return ['Invalid value: value cannot be null'];
      }

      if (numberValue case var numberValue?) {
        if (property.minimum case var minimum?) {
          if (numberValue < minimum) {
            return [
              'Invalid value: value is larger then minimum allowed ($minimum)'
            ];
          }
        }
      }

      return [];
    }

    return [];
  }

  List<String> _validateArray(
    ArrayMostProperty property,
    dynamic value,
  ) {
    if (value case List? listValue) {
      if (property.required) {
        if (listValue == null) {
          return ['Invalid value: value cannot be null'];
        }
        if (listValue.isEmpty) {
          return ['Invalid value: value cannot be empty'];
        }

        return listValue
            .map((listItem) =>
                _validateValueProperty(property.itemProperty, listItem))
            .expand((list) => list)
            .toList();
      }
      if (listValue == null) {
        return [];
      }

      return [];
    }
    return [];
  }
}
