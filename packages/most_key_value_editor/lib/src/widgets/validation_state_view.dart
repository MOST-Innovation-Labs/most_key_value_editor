import 'package:flutter/material.dart';

import '../controller/validator/models/validation_result.dart';

/// Validation state widget.
class ValidationStateView extends StatelessWidget {
  /// Validation result.
  final ValidationResult validationResult;

  /// Creates [ValidationStateView]
  const ValidationStateView({
    super.key,
    required this.validationResult,
  });

  @override
  Widget build(BuildContext context) {
    final validationResult = this.validationResult;
    return Row(
      key: ValueKey(validationResult),
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (validationResult is Validated) ...[
          if (validationResult.validationMessages.isNotEmpty) ...[
            if (validationResult.errors.isNotEmpty)
              Tooltip(
                message: validationResult.errors
                    .map((e) => e.displayMessage)
                    .join('\n\n'),
                child: const Icon(Icons.error, color: Colors.red),
              ),
            if (validationResult.warnings.isNotEmpty)
              Tooltip(
                message: validationResult.warnings
                    .map((e) => e.displayMessage)
                    .join('\n\n'),
                child: const Icon(Icons.warning, color: Colors.yellow),
              ),
          ] else ...[
            const Tooltip(
              message: 'All good!',
              child: Icon(Icons.check_circle, color: Colors.green),
            ),
          ],
        ] else ...[
          const Tooltip(
            message: 'Not validated yet.',
            child: Icon(Icons.question_mark_sharp, color: Colors.grey),
          ),
        ],
      ],
    );
  }
}
