import 'package:flutter/cupertino.dart';
import 'package:most_schema_parser/most_schema_parser.dart';

import '../json_reader_writer.dart';
import '../utils/property_builder.dart';
import 'nesting_indicator_view.dart';
import 'property_name_view.dart';

/// Editor view type
sealed class EditorViewType {
  MostProperty get property;
  bool get topLevel;

  Widget build(
    JsonReaderWriter jsonRw,
    PropertyBuilder propertyBuilder,
  );
}

class ValuePropertyEditorViewType implements EditorViewType {
  @override
  final bool topLevel;

  @override
  final MostValueProperty property;

  const ValuePropertyEditorViewType({
    required this.property,
    this.topLevel = false,
  });

  @override
  Widget build(
    JsonReaderWriter jsonRw,
    PropertyBuilder propertyBuilder,
  ) {
    final property = this.property;
    final propertyRw = jsonRw.property(property.fullPath);
    final validationErrors = propertyRw.validationResult;

    final spec = PropertyBuilderSpec(
      property: property,
      jsonRw: jsonRw,
      propertyRw: propertyRw,
    );

    final child = Builder(
      builder: (context) =>
          propertyBuilder.buildTitledView(context, spec) ??
          propertyBuilder.buildUnsupportedView(context, spec),
    );

    return Padding(
      padding: topLevel ? const EdgeInsets.only(top: 16) : EdgeInsets.zero,
      child: NestingIndicatorView(
        level: property.level,
        validationResult: validationErrors,
        child: child,
      ),
    );
  }
}

class ObjectPropertyEditorViewType implements EditorViewType {
  @override
  final bool topLevel;

  @override
  final MostObjectProperty property;

  const ObjectPropertyEditorViewType({
    required this.property,
    this.topLevel = false,
  });

  @override
  Widget build(
    JsonReaderWriter jsonRw,
    PropertyBuilder propertyBuilder,
  ) {
    final propertyRw = jsonRw.property(property.fullPath);
    final validationErrors =
        jsonRw.property(property.fullPath).validationResult;

    final child = Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Expanded(
            child: PropertyNameView(
              property: property,
              propertyRw: propertyRw,
              validationResult: propertyRw.validationResult,
            ),
          ),
          if (!property.required) ...{
            CupertinoSwitch(
              value: propertyRw.value != null,
              onChanged: (isEnabled) {
                propertyRw.value = isEnabled ? <String, dynamic>{} : null;
              },
            ),
            const SizedBox(width: 16),
          },
        ],
      ),
    );

    return Padding(
      padding: topLevel ? const EdgeInsets.only(top: 16) : EdgeInsets.zero,
      child: NestingIndicatorView(
        level: property.level,
        validationResult: validationErrors,
        child: child,
      ),
    );
  }
}
