import 'package:flutter/cupertino.dart';
import 'package:most_schema_parser/most_schema_parser.dart';

import '../../json_accessor.dart';
import '../fields/string_field.dart';

/// Input for [StringMostProperty].
class StringPropertyInput extends StatelessWidget {
  /// Default icon builder.
  static Widget defaultIconBuilder(
    BuildContext context,
    RegExp? regExp,
    dynamic value,
  ) {
    if (regExp == null) {
      return value == null
          ? const Icon(CupertinoIcons.textformat_abc_dottedunderline)
          : const Icon(CupertinoIcons.textformat_abc);
    } else {
      return const Icon(CupertinoIcons.asterisk_circle);
    }
  }

  final StringMostProperty _property;
  final JsonPropertyAccessor _accessor;
  final Widget Function(BuildContext, RegExp?, dynamic value) _iconBuilder;

  /// Create [StringPropertyInput].
  const StringPropertyInput({
    super.key,
    required StringMostProperty property,
    required JsonPropertyAccessor accessor,
    Widget Function(BuildContext, RegExp?, dynamic) iconBuilder =
        defaultIconBuilder,
  })  : _iconBuilder = iconBuilder,
        _accessor = accessor,
        _property = property;

  @override
  Widget build(BuildContext context) {
    final dynamic value = _accessor.value;
    final regExp = _property.pattern;

    return StringField(
      initial: value is String ? value : null,
      icon: _iconBuilder(context, regExp, value),
      onChanged: (newValue) {
        _accessor.value = newValue;
      },
    );
  }
}
