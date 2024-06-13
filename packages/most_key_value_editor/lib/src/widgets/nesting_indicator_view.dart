import 'dart:math';

import 'package:flutter/material.dart';

import '../utils/color_ext.dart';
import '../validator/validation_result.dart';

/// Nesting indicator widget.
class NestingIndicatorView extends StatelessWidget {
  /// Child.
  final Widget child;

  /// Nesting level.
  ///
  /// `0` indicates root.
  final int level;

  /// Validation result.
  final ValidationResult validationResult;

  /// Creates [NestingIndicatorView].
  const NestingIndicatorView({
    super.key,
    required this.child,
    required this.level,
    required this.validationResult,
  });

  ///       i: 0 =>  1 =>  2 =>  3 =>  4 =>  5 =>  6 ...
  /// returns: 0 => 30 => 20 => 13 =>  9 =>  6 =>  4 ...
  num _lightenShiftPercent(int i) {
    if (i == 0) return 0;
    return 30 * pow(2 / 3, i - 1);
  }

  //      i: 0 =>  1 =>  2 =>  3 =>  4 =>  5 =>  6 ...
  // result: 0 => 30 => 50 => 63 => 72 => 78 => 82 ...
  num _lightenPercent(int i) {
    double sum = 0;
    for (int index = 0; index <= i; index++) {
      sum += _lightenShiftPercent(index);
    }
    return sum;
  }

  @override
  Widget build(BuildContext context) {
    final validationResult = this.validationResult;

    Widget child = this.child;

    final color = switch (validationResult) {
      NotValidated() => Colors.grey,
      Validated() =>
        validationResult.errors.isNotEmpty ? Colors.red : Colors.green,
    };

    for (int i = level; i >= 0; i--) {
      final indicatorColor = color.lighten(_lightenPercent(i).round());

      child = Container(
        padding: const EdgeInsets.only(left: 4),
        decoration: BoxDecoration(
          border: Border(left: BorderSide(color: indicatorColor, width: 4)),
        ),
        child: child,
      );
    }

    return child;
  }
}
