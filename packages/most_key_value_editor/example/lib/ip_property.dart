import 'package:flutter/material.dart';
// ignore: depend_on_referenced_packages
import 'package:json_schema/json_schema.dart';
import 'package:most_key_value_editor/most_key_value_editor.dart';
import 'package:most_schema_parser/most_schema_parser.dart';

class IpV4MostProperty extends MostValueProperty {
  static const ipRegExp =
      r"^(([0-9]|[1-9][0-9]|1[0-9]{2}|2[0-4][0-9]|25[0-5])\.){3}([0-9]|[1-9][0-9]|1[0-9]{2}|2[0-4][0-9]|25[0-5])$";

  static isRegExpMatching(RegExp regExp) {
    final pattern = regExp.pattern;
    final regExpPattern = RegExp(ipRegExp).pattern;
    return pattern == regExpPattern;
  }

  const IpV4MostProperty({
    required super.title,
    required super.description,
    required super.propertyName,
    required super.required,
    required super.parent,
  });
}

class IpV4PropertyMapper extends PropertyMapper {
  const IpV4PropertyMapper();

  @override
  MostProperty? mapOrNull(
    MostJsonSchemaPropertyParser propertyParser,
    PropertySpec spec,
  ) {
    if (spec.propertySchema.type != SchemaType.string) return null;
    final pattern = spec.propertySchema.pattern;
    if (pattern == null) return null;
    if (!IpV4MostProperty.isRegExpMatching(pattern)) return null;

    return IpV4MostProperty(
      title: spec.title,
      description: spec.description,
      propertyName: spec.propertyName,
      required: spec.required,
      parent: spec.parent,
    );
  }
}

Widget? ipv4PropertyInputBuilder(
  BuildContext context,
  PropertyBuilder _,
  PropertyBuilderSpec<MostProperty> spec,
) {
  if (spec.property is IpV4MostProperty) {
    return StringFormField(
      icon: const Icon(Icons.laptop_chromebook_rounded),
      initial: spec.propertyRw.value,
      validate: (value) {
        if (spec.property.required && (value?.isEmpty ?? true)) {
          return 'Missing required IPv4 address.';
        }
        if (value == null) {
          return null;
        }
        final pattern = RegExp(IpV4MostProperty.ipRegExp);
        if (pattern.hasMatch(value)) return null;

        return 'Invalid IP address.';
      },
      onChanged: (value) => spec.propertyRw.value = value,
    );
  }

  return null;
}
