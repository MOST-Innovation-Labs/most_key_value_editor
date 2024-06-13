import 'package:flutter/material.dart';
import 'package:json_diff/json_diff.dart';
import 'package:json_schema/json_schema.dart' hide ValidationError;
import 'package:most_schema_parser/most_schema_parser.dart';

import 'json_reader_writer.dart';
import 'validator/validation_message.dart';
import 'validator/validation_result.dart';

/// Editor controller.
///
/// Responsible for:
/// - storing Form key
/// - storing current json schema
/// - storing current json state
/// - validation
class MostKeyValueEditorController extends ChangeNotifier {
  /// Form key that is used to validate Form fields.
  late final GlobalKey<FormState> formKey;
  late final MostJsonSchemaParser _parser;
  late final JsonReaderWriter _jsonRw;

  MostSchema? _schema;
  ValidationResult _validationResult = const ValidationResult.notValidated();

  MostKeyValueEditorController({
    MostJsonSchemaParser parser = const MostJsonSchemaParser(),
  })  : _parser = parser,
        formKey = GlobalKey<FormState>() {
    _jsonRw = JsonReaderWriter(
      wrapPropertyRw: _wrapPropertyRw,
      onChanged: (_) => notifyListeners(),
    );
  }

  JsonPropertyReaderWriter _wrapPropertyRw(
    JsonPropertyReaderWriter propertyRw,
  ) {
    return propertyRw.withValidationErrors(() {
      final validationResult = _validationResult;

      switch (validationResult) {
        case NotValidated():
          return validationResult;

        case Validated():
          final path = propertyRw.path;
          final propertyRelatedErrors = validationResult.validationMessages
              .whereType<PropertyValidationError>()
              .where((e) => e.path.startsWith(path))
              .toList();
          return ValidationResult.validated(propertyRelatedErrors);
      }
    });
  }

  /// Replaces JSON Schema with the provided one.
  void seedJsonSchema(JsonSchema jsonSchema) {
    final properties = _parser.parse(jsonSchema);

    _schema = MostSchema(
      jsonSchema: jsonSchema,
      properties: properties,
    );
    _validationResult = const ValidationResult.notValidated();
    notifyListeners();
  }

  /// Replaces JSON with the provided one.
  void seedJson(Map<String, dynamic> json) {
    _jsonRw.seed(json);
    _validationResult = const ValidationResult.notValidated();
    notifyListeners();
  }

  List<MostProperty>? get mostPropertiesOrNull => _schema?.properties;

  /// Returns [JsonReaderWriter] to manipulate the JSON.
  JsonReaderWriter get jsonRw => _jsonRw;

  /// Returns most recent [ValidationResult].
  ValidationResult get validationResult => _validationResult;

  /// Performs validation and returns JSON if validation passed.
  Map<String, dynamic>? validateAndReadOrNull() {
    final resultMap = _jsonRw.read();
    final validationResult = _validate(resultMap);
    _validationResult = validationResult;
    notifyListeners();

    return validationResult is Validated && validationResult.errors.isEmpty
        ? resultMap
        : null;
  }

  /// Performs validation.
  void validate() => validateAndReadOrNull();

  /// Resets most recent validation result.
  void resetValidationError() {
    _validationResult = const ValidationResult.notValidated();
    notifyListeners();
  }

  ValidationResult _validate(Map<String, dynamic> map) {
    final schema = _schema;

    List<ValidationMessage> messages = [];

    if (schema == null) {
      messages.add(
        const ValidationMessage.error('Schema is not provided'),
      );
    } else {
      final isFormValid = formKey.currentState?.validate() ?? true;

      if (!isFormValid) {
        messages.add(
          const ValidationMessage.error('Form contains errors'),
        );
      }

      final validationResult = schema.jsonSchema.validate(map);

      if (!validationResult.isValid) {
        for (final error in [
          ...validationResult.errors,
          ...validationResult.warnings
        ]) {
          final path = _normalizeSchemaPath(error.instancePath) ?? '';
          messages.add(
            ValidationMessage.propertyError(
              path: path,
              message: error.message,
            ),
          );
        }
      }

      final specifiedPropertiesMap = _getMapWithSpecifiedPropertiesOnly(schema);
      final differ = JsonDiffer.fromJson(specifiedPropertiesMap, map);
      final diff = differ.diff();

      if (!diff.hasNothing) {
        messages.add(
          ValidationMessage.warning(
            "Source JSON contains unspecified properties:\n"
            "$diff",
          ),
        );
      }
    }

    return ValidationResult.validated(messages);
  }

  static String? _normalizeSchemaPath(String? path) {
    if (path == null) return null;

    String normalizedPath = path.replaceAll(' ', '').replaceAll('/', '.');
    if (normalizedPath.startsWith('.')) {
      normalizedPath = normalizedPath.substring(1);
    }
    return normalizedPath;
  }

  Map<String, dynamic> _getMapWithSpecifiedPropertiesOnly(MostSchema schema) {
    final JsonReaderWriter resultRw = JsonReaderWriter();

    void traverseProperties(
      List<MostProperty> properties, {
      bool topLevel = false,
    }) {
      for (final property in properties) {
        switch (property) {
          case MostObjectProperty():
            if (property.required ||
                jsonRw.property(property.fullPath).value != null) {
              traverseProperties(property.properties);
            }
          case MostValueProperty():
            resultRw.property(property.fullPath).value =
                jsonRw.property(property.fullPath).value;
        }
      }
    }

    traverseProperties(schema.properties, topLevel: true);

    return resultRw.read();
  }
}

class MostSchema {
  final JsonSchema jsonSchema;
  final List<MostProperty> properties;

  const MostSchema({
    required this.jsonSchema,
    required this.properties,
  });
}
