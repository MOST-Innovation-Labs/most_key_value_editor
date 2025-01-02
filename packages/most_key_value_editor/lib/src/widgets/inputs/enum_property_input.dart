import 'package:flutter/material.dart';
import 'package:most_schema_parser/most_schema_parser.dart';

import '../../json_accessor.dart';

/// Input for [EnumMostProperty].
class EnumPropertyInput extends StatelessWidget {
  final EnumMostProperty _property;
  final JsonPropertyAccessor _accessor;

  /// Create [EnumPropertyInput].
  const EnumPropertyInput({
    super.key,
    required EnumMostProperty property,
    required JsonPropertyAccessor accessor,
  })  : _accessor = accessor,
        _property = property;

  @override
  Widget build(BuildContext context) {
    final dynamic value = _accessor.value;

    return DropdownButton<String>(
      value: _property.values.contains(value) ? value : null,
      isExpanded: true,
      items: _property.values
          .map(
            (enumValue) => DropdownMenuItem(
              value: enumValue,
              child: Text(enumValue),
            ),
          )
          .toList(),
      onChanged: (newValue) {
        if (newValue == null) return;
        if (!_property.values.contains(newValue)) return;

        _accessor.value = newValue;
      },
    );
  }
}
