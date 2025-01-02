import 'package:flutter/material.dart';
import 'package:most_key_value_editor/most_key_value_editor.dart';
import 'package:most_schema_parser/most_schema_parser.dart';

RegExp get _ipRegExp => RegExp(
      r"^(([0-9]|[1-9][0-9]|1[0-9]{2}|2[0-4][0-9]|25[0-5])\.){3}([0-9]|[1-9][0-9]|1[0-9]{2}|2[0-4][0-9]|25[0-5])$",
    );

bool _isRegExpMatching(RegExp? regExp, RegExp other) {
  if (regExp == null) return false;
  final pattern = regExp.pattern;
  final regExpPattern = other.pattern;
  return pattern == regExpPattern;
}

Widget? customInputBuilder(
  BuildContext context,
  PropertyBuilder _,
  PropertyBuilderSpec<MostProperty> spec,
) {
  Widget iconBuilder(BuildContext context, RegExp? regExp, dynamic value) {
    if (_isRegExpMatching(regExp, _ipRegExp)) {
      return const Icon(Icons.laptop_chromebook_rounded);
    }

    return StringPropertyInput.defaultIconBuilder(context, regExp, value);
  }

  if (spec.property case StringMostProperty property) {
    return StringPropertyInput(
      property: property,
      accessor: spec.accessor,
      iconBuilder: iconBuilder,
    );
  }
  return null;
}
