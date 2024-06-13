import 'package:flutter/material.dart';
import 'package:most_schema_parser/most_schema_parser.dart';

import '../json_reader_writer.dart';
import '../utils/property_builder.dart';

/// Value Property widget.
class ValuePropertyView extends StatelessWidget {
  /// Most JSON Value Property
  final MostValueProperty property;

  /// JSON property reader-writer.
  final JsonReaderWriter jsonRw;

  /// Property builder.
  final PropertyBuilder propertyBuilder;

  /// Creates [ValuePropertyView]
  const ValuePropertyView({
    super.key,
    required this.property,
    required this.jsonRw,
    required this.propertyBuilder,
  });

  @override
  Widget build(BuildContext context) {
    final property = this.property;
    final propertyRw = jsonRw.property(property.fullPath);

    final spec = PropertyBuilderSpec(
      property: property,
      jsonRw: jsonRw,
      propertyRw: propertyRw,
    );

    final widget = propertyBuilder.buildInputView(context, spec);
    if (widget != null) return widget;

    return propertyBuilder.buildUnsupportedView(context, spec);
  }
}
