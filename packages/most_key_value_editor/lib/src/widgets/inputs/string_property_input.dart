import 'package:flutter/material.dart';
import 'package:most_schema_parser/most_schema_parser.dart';

import '../../json_reader_writer.dart';
import '../form_fields/string_form_field.dart';

Widget _iconBuilder(BuildContext context, RegExp? regExp, dynamic value) {
  if (regExp == null) {
    return const Icon(Icons.text_fields_rounded);
  } else {
    return const Icon(Icons.emoji_symbols_rounded);
  }
}

class StringPropertyInput extends StatelessWidget {
  final StringMostProperty property;
  final JsonPropertyReaderWriter propertyRw;
  final Widget Function(BuildContext, RegExp?, dynamic value) iconBuilder;

  const StringPropertyInput({
    super.key,
    required this.property,
    required this.propertyRw,
    this.iconBuilder = _iconBuilder,
  });

  @override
  Widget build(BuildContext context) {
    final dynamic value = propertyRw.value;
    final regExp = property.pattern;

    return StringFormField(
      initial: value is String ? value : null,
      icon: iconBuilder(context, regExp, value),
      validate: (value) {
        if (property.required && (value?.isEmpty ?? true)) {
          return 'Missing required string.';
        }
        if (value == null) {
          return null;
        }

        if (regExp == null) return null;
        if (regExp.hasMatch(value)) return null;

        return 'Value "$value" is not matching "$regExp"';
      },
      onChanged: (newValue) {
        propertyRw.value = newValue;
      },
    );
  }
}
