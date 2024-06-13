import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:most_schema_parser/most_schema_parser.dart';

import '../../json_reader_writer.dart';
import '../form_fields/string_form_field.dart';

class NumberPropertyInput extends StatelessWidget {
  final NumberMostProperty property;
  final JsonPropertyReaderWriter propertyRw;

  const NumberPropertyInput({
    super.key,
    required this.property,
    required this.propertyRw,
  });

  @override
  Widget build(BuildContext context) {
    final dynamic value = propertyRw.value;

    return StringFormField(
      initial: value is num ? '$value' : null,
      icon: const Icon(Icons.numbers),
      formatters: [FilteringTextInputFormatter.digitsOnly],
      validate: (value) {
        if (property.required && (value?.isEmpty ?? true)) {
          return 'Missing required number.';
        }
        if (value == null) {
          return null;
        }

        final number = num.tryParse(value);
        if (property.required && number == null) {
          return 'Missing required number.';
        }
        if (number == null) {
          return null;
        }

        final minimum = property.minimum;
        if (minimum != null && number < minimum) {
          return 'Value must be greater or equal to $minimum';
        }

        return null;
      },
      onChanged: (newValue) {
        final number = num.tryParse(newValue);
        propertyRw.value = number;
      },
    );
  }
}
