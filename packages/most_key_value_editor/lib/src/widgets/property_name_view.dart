import 'package:flutter/material.dart';
import 'package:most_schema_parser/most_schema_parser.dart';

import '../controller/validator/models/validation_result.dart';
import '../json_accessor.dart';
import '../utils/most_property_ext.dart';

/// Property name widget.
class PropertyNameView extends StatelessWidget {
  /// Most property.
  final MostProperty property;

  /// Most property reader-writer.
  final JsonPropertyAccessor accessor;

  /// Most property validation result.
  final ValidationResult validationResult;

  /// Creates [PropertyNameView].
  const PropertyNameView({
    super.key,
    required this.property,
    required this.accessor,
    required this.validationResult,
  });

  String _stringify(dynamic value) {
    if (value is List) {
      return '[\n${value.map((e) => _stringify(e)).join(',\n')}\n]';
    }
    if (value is String && value.isEmpty) {
      return '*empty string*';
    }
    return '$value';
  }

  @override
  Widget build(BuildContext context) {
    final validationResult = this.validationResult;

    const iconSize = 18.0;
    final String displayTitle = property.displayTitle;
    final String? description = property.description;
    final bool required = property.required;
    final String fullPath = property.fullPath;
    final TextStyle style = Theme.of(context).textTheme.bodyMedium!;

    final nameWidget = Text.rich(
      TextSpan(
        children: [
          TextSpan(text: '', style: style),
          WidgetSpan(
            alignment: PlaceholderAlignment.middle,
            child: Tooltip(
              message: _stringify(accessor.value),
              child: const Icon(Icons.data_object_rounded, size: iconSize),
            ),
          ),
          if (description != null) ...[
            TextSpan(text: ' ', style: style),
            WidgetSpan(
              alignment: PlaceholderAlignment.middle,
              child: Tooltip(
                message: description,
                child: const Icon(Icons.info, size: iconSize),
              ),
            ),
          ],
          if (validationResult is Validated &&
              validationResult.errors.isNotEmpty) ...[
            TextSpan(text: ' ', style: style),
            WidgetSpan(
              alignment: PlaceholderAlignment.middle,
              child: Tooltip(
                message: validationResult.errors
                    .map((e) => e.displayMessage)
                    .join('\n\n'),
                child: const Icon(
                  Icons.error,
                  size: iconSize,
                  color: Colors.red,
                ),
              ),
            ),
          ],
          if (required) ...[
            TextSpan(text: ' ', style: style),
            TextSpan(
              text: '*',
              style: style.copyWith(
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.error,
              ),
            ),
          ],
          TextSpan(text: ' ', style: style),
          TextSpan(
            text: displayTitle,
            style: style,
          ),
        ],
      ),
      textAlign: TextAlign.start,
    );

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          nameWidget,
          Text(
            fullPath,
            style: style.copyWith(
              fontSize: (style.fontSize ?? 14) * 0.75,
              fontWeight: FontWeight.w300,
              fontStyle: FontStyle.italic,
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }
}
