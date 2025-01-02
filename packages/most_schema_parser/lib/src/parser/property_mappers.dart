import 'package:json_schema/json_schema.dart';

import '../properties/most_property.dart';
import '../properties/most_value_properties.dart';
import 'most_json_schema_property_parser.dart';
import 'property_mapper.dart';
import 'property_spec.dart';

/// Mapper for [MostObjectProperty].
class ObjectPropertyMapper extends PropertyMapper {
  /// Create [ObjectPropertyMapper].
  const ObjectPropertyMapper();

  @override
  MostProperty? mapOrNull(
    MostJsonSchemaPropertyParser propertyParser,
    PropertySpec spec,
  ) {
    if (spec.propertySchema.properties.isEmpty) return null;

    final mostProperty = MostObjectProperty(
      title: spec.title,
      description: spec.description,
      propertyName: spec.propertyName,
      required: spec.required,
      parent: spec.parent,
    );

    final properties = spec.propertySchema.properties.entries
        .map(
          (entry) => propertyParser.parseProperty(
            entry.value,
            parent: mostProperty,
          ),
        )
        .toList();
    for (final property in properties) {
      mostProperty.properties.add(property);
    }

    return mostProperty;
  }
}

/// Mapper for [BooleanMostProperty].
class BooleanPropertyMapper extends PropertyMapper {
  /// Create [BooleanPropertyMapper].
  const BooleanPropertyMapper();

  @override
  MostProperty? mapOrNull(
    MostJsonSchemaPropertyParser propertyParser,
    PropertySpec spec,
  ) {
    if (spec.propertySchema.properties.isNotEmpty) return null;
    if (spec.propertySchema.type != SchemaType.boolean) return null;

    return BooleanMostProperty(
      title: spec.title,
      description: spec.description,
      propertyName: spec.propertyName,
      required: spec.required,
      parent: spec.parent,
    );
  }
}

/// Mapper for [StringMostProperty].
class StringPropertyMapper extends PropertyMapper {
  /// Create [StringPropertyMapper].
  const StringPropertyMapper();

  @override
  MostProperty? mapOrNull(
    MostJsonSchemaPropertyParser propertyParser,
    PropertySpec spec,
  ) {
    if (spec.propertySchema.properties.isNotEmpty) return null;
    if (spec.propertySchema.type != SchemaType.string) return null;
    if (spec.propertySchema.enumValues?.isNotEmpty ?? false) return null;

    return StringMostProperty(
      title: spec.title,
      description: spec.description,
      propertyName: spec.propertyName,
      required: spec.required,
      parent: spec.parent,
      pattern: spec.propertySchema.pattern,
    );
  }
}

/// Mapper for [EnumMostProperty].
class EnumPropertyMapper extends PropertyMapper {
  /// Create [EnumPropertyMapper].
  const EnumPropertyMapper();

  @override
  MostProperty? mapOrNull(
    MostJsonSchemaPropertyParser propertyParser,
    PropertySpec spec,
  ) {
    if (spec.propertySchema.properties.isNotEmpty) return null;
    if (spec.propertySchema.type != SchemaType.string) return null;
    if (spec.propertySchema.enumValues?.isEmpty ?? true) return null;

    return EnumMostProperty(
      title: spec.title,
      description: spec.description,
      propertyName: spec.propertyName,
      required: spec.required,
      parent: spec.parent,
      values: spec.propertySchema.enumValues!.cast<String>(),
    );
  }
}

/// Mapper for [NumberMostProperty].
class NumberPropertyMapper extends PropertyMapper {
  /// Create [NumberPropertyMapper].
  const NumberPropertyMapper();

  @override
  MostProperty? mapOrNull(
    MostJsonSchemaPropertyParser propertyParser,
    PropertySpec spec,
  ) {
    if (spec.propertySchema.properties.isNotEmpty) return null;
    if (spec.propertySchema.type != SchemaType.number &&
        spec.propertySchema.type != SchemaType.integer) return null;

    return NumberMostProperty(
      title: spec.title,
      description: spec.description,
      propertyName: spec.propertyName,
      required: spec.required,
      parent: spec.parent,
      minimum: spec.propertySchema.minimum,
    );
  }
}

/// Mapper for [ArrayMostProperty].
class ArrayPropertyMapper extends PropertyMapper {
  /// Create [ArrayPropertyMapper].
  const ArrayPropertyMapper();

  @override
  MostProperty? mapOrNull(
    MostJsonSchemaPropertyParser propertyParser,
    PropertySpec spec,
  ) {
    if (spec.propertySchema.properties.isNotEmpty) return null;
    if (spec.propertySchema.type != SchemaType.array) return null;

    return ArrayMostProperty(
      title: spec.title,
      description: spec.description,
      propertyName: spec.propertyName,
      required: spec.required,
      parent: spec.parent,
      itemProperty: propertyParser.parseProperty(
        spec.propertySchema.items!,
        overridePropertyName: 'item',
        overrideRequired: true,
      ) as MostValueProperty,
    );
  }
}
