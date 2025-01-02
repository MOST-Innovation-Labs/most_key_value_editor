import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:most_schema_parser/most_schema_parser.dart';

import '../../json_accessor.dart';
import '../fields/string_field.dart';

/// Input for [NumberMostProperty].
class NumberPropertyInput extends StatelessWidget {
  // ignore: unused_field
  final NumberMostProperty _property;
  final JsonPropertyAccessor _accessor;

  /// Create [NumberPropertyInput].
  const NumberPropertyInput({
    super.key,
    required NumberMostProperty property,
    required JsonPropertyAccessor accessor,
  })  : _accessor = accessor,
        _property = property;

  @override
  Widget build(BuildContext context) {
    final dynamic value = _accessor.value;

    return StringField(
      initial: value is num ? '$value' : null,
      icon: const Icon(CupertinoIcons.number_square),
      formatters: [FilteringTextInputFormatter.digitsOnly],
      onChanged: (newValue) {
        final number = num.tryParse(newValue ?? '');
        _accessor.value = number;
      },
    );
  }
}
