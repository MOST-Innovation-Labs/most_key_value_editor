import 'package:flutter/material.dart';
import 'package:most_schema_parser/most_schema_parser.dart';

import '../../json_reader_writer.dart';

class EnumPropertyInput extends StatelessWidget {
  final EnumMostProperty property;
  final JsonPropertyReaderWriter propertyRw;

  const EnumPropertyInput({
    super.key,
    required this.property,
    required this.propertyRw,
  });

  @override
  Widget build(BuildContext context) {
    final dynamic value = propertyRw.value;

    return DropdownButtonFormField(
      value: property.values.contains(value) ? value : null,
      items: property.values
          .map(
            (enumValue) => DropdownMenuItem(
              value: enumValue,
              child: Text(enumValue),
            ),
          )
          .toList(),
      validator: (value) {
        if (value == null) {
          return null;
        }
        if (!property.values.contains(value)) {
          return 'Value is not supported';
        }

        return null;
      },
      onChanged: (newValue) {
        propertyRw.value = newValue;
      },
    );
  }
}
