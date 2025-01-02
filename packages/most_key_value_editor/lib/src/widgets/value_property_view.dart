import 'package:flutter/material.dart';
import 'package:most_schema_parser/most_schema_parser.dart';

import '../json_accessor.dart';
import '../utils/property_builder.dart';

/// Value Property widget.
class ValuePropertyView extends StatelessWidget {
  /// Most JSON Value Property
  final MostValueProperty property;

  /// JSON property reader-writer.
  final JsonAccessor jsonAccessor;

  /// Property builder.
  final PropertyBuilder propertyBuilder;

  /// Creates [ValuePropertyView]
  const ValuePropertyView({
    super.key,
    required this.property,
    required this.jsonAccessor,
    required this.propertyBuilder,
  });

  @override
  Widget build(BuildContext context) {
    final property = this.property;
    final accessor = jsonAccessor.property(property.fullPath);

    final spec = PropertyBuilderSpec(
      property: property,
      jsonAccessor: jsonAccessor,
      accessor: accessor,
    );

    final widget = propertyBuilder.buildInputView(context, spec);
    if (widget != null) return widget;

    return propertyBuilder.buildUnsupportedView(context, spec);
  }
}
