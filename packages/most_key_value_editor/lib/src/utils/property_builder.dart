import 'package:flutter/material.dart';
import 'package:most_schema_parser/most_schema_parser.dart';

import '../controller/validator/models/validation_result.dart';
import '../json_accessor.dart';

/// Property [Widget] builder
class PropertyBuilder {
  /// Builders for titles.
  final List<PropertyTitleWidgetBuilder<Widget?, MostValueProperty>>
      titleBuilders;

  /// Builders for inputs.
  final List<PropertyWidgetBuilder<Widget?, MostProperty>> inputBuilders;

  /// Builder for unsupported types.
  ///
  /// Used as a fallback.
  final PropertyWidgetBuilder<Widget?, MostProperty>? unsupportedBuilder;

  /// Creates [PropertyBuilder].
  const PropertyBuilder({
    this.titleBuilders = const [],
    this.inputBuilders = const [],
    this.unsupportedBuilder,
  });

  /// Property [Widget] builder to replace the whole list tile.
  Widget? buildTitledView(
    BuildContext context,
    PropertyBuilderSpec<MostValueProperty> spec,
    ValidationResult validationResult,
  ) {
    for (final builder in titleBuilders) {
      final widget = builder.call(context, this, spec, validationResult);
      if (widget != null) return widget;
    }

    return null;
  }

  /// Property [Widget] builder to replace the the input view.
  Widget? buildInputView(
    BuildContext context,
    PropertyBuilderSpec<MostValueProperty> spec,
  ) {
    for (final builder in inputBuilders) {
      final widget = builder.call(context, this, spec);
      if (widget != null) return widget;
    }

    return null;
  }

  /// Property [Widget] builder for unsupported properties
  Widget buildUnsupportedView(
    BuildContext context,
    PropertyBuilderSpec spec,
  ) {
    final widget = unsupportedBuilder?.call(context, this, spec);
    if (widget != null) return widget;

    return const Text('Unsupported Type');
  }
}

/// Used for property builder definitions.
typedef PropertyTitleWidgetBuilder<T extends Widget?, R extends MostProperty>
    = T Function(
  BuildContext context,
  PropertyBuilder propBuilder,
  PropertyBuilderSpec<R> propSpec,
  ValidationResult validationResult,
);

/// Used for property builder definitions.
typedef PropertyWidgetBuilder<T extends Widget?, R extends MostProperty> = T
    Function(
  BuildContext context,
  PropertyBuilder propBuilder,
  PropertyBuilderSpec<R> propSpec,
);

/// DTO for [PropertyBuilder]
class PropertyBuilderSpec<T extends MostProperty> {
  /// Property.
  final T property;

  /// JSON Accessor.
  final JsonAccessor jsonAccessor;

  /// Property JSON Accessor.
  final JsonPropertyAccessor accessor;

  /// Create [PropertyBuilderSpec].
  PropertyBuilderSpec({
    required this.property,
    required this.jsonAccessor,
    required this.accessor,
  });
}
