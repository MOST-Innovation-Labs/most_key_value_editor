import 'package:flutter/material.dart';
import 'package:most_schema_parser/most_schema_parser.dart';

import '../../json_reader_writer.dart';

enum BoolValue {
  yes,
  no,
  unknown;

  static BoolValue fromBool(bool? value) => switch (value) {
        true => BoolValue.yes,
        false => BoolValue.no,
        _ => BoolValue.unknown,
      };

  bool? toBoolOrNull() => switch (this) {
        BoolValue.yes => true,
        BoolValue.no => false,
        BoolValue.unknown => null,
      };
}

class BooleanPropertyInput extends StatelessWidget {
  final BooleanMostProperty property;
  final JsonPropertyReaderWriter propertyRw;

  const BooleanPropertyInput({
    super.key,
    required this.property,
    required this.propertyRw,
  });

  @override
  Widget build(BuildContext context) {
    final dynamic value = propertyRw.value;

    return FormField<bool>(
      builder: (context) {
        final boolValue = BoolValue.fromBool(value);

        return Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            _buildOption(BoolValue.yes, boolValue),
            _buildOption(BoolValue.no, boolValue),
            if (!property.required || (boolValue == BoolValue.unknown))
              _buildOption(BoolValue.unknown, boolValue),
          ],
        );
      },
    );
  }

  Widget _buildOption(
    BoolValue value,
    BoolValue groupValue,
  ) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Radio<BoolValue>(
          value: value,
          groupValue: groupValue,
          onChanged: (BoolValue? newValue) {
            if (newValue == null) return;
            propertyRw.value = value.toBoolOrNull();
          },
        ),
        Text(switch (value) {
          BoolValue.yes => 'yes',
          BoolValue.no => 'no',
          BoolValue.unknown => 'unknown',
        })
      ],
    );
  }
}
