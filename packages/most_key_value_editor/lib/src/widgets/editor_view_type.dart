import 'package:flutter/cupertino.dart';
import 'package:most_schema_parser/most_schema_parser.dart';

import '../controller/validator/models/validation_result.dart';
import '../json_accessor.dart';
import '../utils/property_builder.dart';
import 'nesting_indicator_view.dart';
import 'property_name_view.dart';

/// Builder for a specific [EditorViewType].
typedef EditorViewTypeBuilder = Widget Function(
  EditorViewType editorViewType,
  JsonAccessor jsonAccessor,
  PropertyBuilder propertyBuilder,
  ValidationResult validationResult,
);

/// Default builder for a specific [EditorViewType].
Widget defaultEditorViewTypeBuilder(
  EditorViewType editorViewType,
  JsonAccessor jsonAccessor,
  PropertyBuilder propertyBuilder,
  ValidationResult validationResult,
) =>
    editorViewType.build(jsonAccessor, propertyBuilder, validationResult);

/// Editor view type
sealed class EditorViewType {
  /// Property.
  MostProperty get property;

  /// If it is a top-level property.
  ///
  /// Used in UI only.
  bool get topLevel;

  /// Default view type build method.
  Widget build(
    JsonAccessor jsonAccessor,
    PropertyBuilder propertyBuilder,
    ValidationResult validationResult,
  );
}

/// Value View Type.
class ValuePropertyEditorViewType implements EditorViewType {
  @override
  final bool topLevel;

  @override
  final MostValueProperty property;

  /// Create [ValuePropertyEditorViewType].
  const ValuePropertyEditorViewType({
    required this.property,
    this.topLevel = false,
  });

  @override
  Widget build(
    JsonAccessor jsonAccessor,
    PropertyBuilder propertyBuilder,
    ValidationResult validationResult,
  ) {
    final accessor = jsonAccessor.property(property.fullPath);
    final propertyValidationResult = validationResult.forProperty(
      property.fullPath,
    );

    final spec = PropertyBuilderSpec(
      property: property,
      jsonAccessor: jsonAccessor,
      accessor: accessor,
    );

    final child = Builder(
      builder: (context) =>
          propertyBuilder.buildTitledView(
              context, spec, propertyValidationResult) ??
          propertyBuilder.buildUnsupportedView(context, spec),
    );

    return Padding(
      padding: topLevel ? const EdgeInsets.only(top: 16) : EdgeInsets.zero,
      child: NestingIndicatorView(
        level: property.level,
        validationResult: propertyValidationResult,
        child: child,
      ),
    );
  }
}

/// Object View Type.
class ObjectPropertyEditorViewType implements EditorViewType {
  @override
  final bool topLevel;

  @override
  final MostObjectProperty property;

  /// Create [ObjectPropertyEditorViewType].
  const ObjectPropertyEditorViewType({
    required this.property,
    this.topLevel = false,
  });

  @override
  Widget build(
    JsonAccessor jsonAccessor,
    PropertyBuilder propertyBuilder,
    ValidationResult validationResult,
  ) {
    final accessor = jsonAccessor.property(property.fullPath);
    final propertyValidationResult = validationResult.forProperty(
      property.fullPath,
    );

    final child = Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Expanded(
            child: PropertyNameView(
              property: property,
              accessor: accessor,
              validationResult: propertyValidationResult,
            ),
          ),
          if (!property.required) ...{
            CupertinoSwitch(
              value: accessor.value != null,
              onChanged: (isEnabled) {
                accessor.value = isEnabled ? <String, dynamic>{} : null;
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
        validationResult: propertyValidationResult,
        child: child,
      ),
    );
  }
}
