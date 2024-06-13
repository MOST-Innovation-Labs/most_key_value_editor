import '../properties/most_property.dart';
import 'most_json_schema_property_parser.dart';
import 'property_spec.dart';

/// Property mapper.
///
/// Allows to map specific JSON Schema properties to [MostProperty].
abstract class PropertyMapper {
  /// Creates [PropertyMapper].
  const PropertyMapper();

  /// Resolves [spec] to a [MostProperty] or return `null`.
  MostProperty? mapOrNull(
    MostJsonSchemaPropertyParser propertyParser,
    PropertySpec spec,
  );
}

/// Custom property mapper.
class CustomPropertyMapper extends PropertyMapper {
  /// Callback that resolves [spec] to a [MostProperty], or return `null`.
  final MostProperty? Function(PropertySpec spec) mapper;

  /// Creates [CustomPropertyMapper].
  const CustomPropertyMapper(this.mapper);

  @override
  MostProperty? mapOrNull(
    MostJsonSchemaPropertyParser propertyParser,
    PropertySpec spec,
  ) =>
      mapper(spec);
}
