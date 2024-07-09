import 'package:flutter/material.dart';
import 'package:most_schema_parser/most_schema_parser.dart';

class MostFormValidator implements MostValidator {
  final GlobalKey<FormState> formKey;

  const MostFormValidator(this.formKey);

  @override
  List<ValidationMessage> validate(Map<String, dynamic> map) {
    final isFormValid = formKey.currentState?.validate() ?? true;

    if (isFormValid) return [];

    return [
      const ValidationMessage.error('Form contains errors'),
    ];
  }
}
