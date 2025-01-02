import 'package:flutter/material.dart';
import 'package:most_schema_parser/most_schema_parser.dart';

import '../../json_accessor.dart';

/// Tri-state boolean value.
enum BoolValue {
  /// Represents [true].
  yes,

  /// Represents [false].
  no,

  /// Represents [null].
  unknown;

  /// Create from [bool].
  static BoolValue fromBool(bool? value) => switch (value) {
        true => BoolValue.yes,
        false => BoolValue.no,
        _ => BoolValue.unknown,
      };

  /// Convert to nullable [bool].
  bool? toBoolOrNull() => switch (this) {
        BoolValue.yes => true,
        BoolValue.no => false,
        BoolValue.unknown => null,
      };
}

/// Input for [BooleanMostProperty].
class BooleanPropertyInput extends StatelessWidget {
  final BooleanMostProperty _property;
  final JsonPropertyAccessor _accessor;

  /// Create [BooleanPropertyInput].
  const BooleanPropertyInput({
    super.key,
    required BooleanMostProperty property,
    required JsonPropertyAccessor accessor,
  })  : _accessor = accessor,
        _property = property;

  @override
  Widget build(BuildContext context) {
    final dynamic value = _accessor.value;

    final boolValue = BoolValue.fromBool(value);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        _buildOption(BoolValue.yes, boolValue),
        _buildOption(BoolValue.no, boolValue),
        if (!_property.required || (boolValue == BoolValue.unknown))
          _buildOption(BoolValue.unknown, boolValue),
      ],
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
            _accessor.value = value.toBoolOrNull();
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
