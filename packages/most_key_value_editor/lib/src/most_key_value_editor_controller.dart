import 'package:flutter/material.dart';
import 'package:json_schema/json_schema.dart' hide ValidationError;
import 'package:most_schema_parser/most_schema_parser.dart';

import 'json_reader_writer.dart';
import 'most_schema.dart';
import 'validator/most_form_validator.dart';
import 'validator/most_unspecified_properties_validator.dart';

typedef ValidatorProvider = MostValidator Function(
  MostKeyValueEditorController,
);

/// Editor controller.
///
/// Responsible for:
/// - storing Form key
/// - storing current json schema
/// - storing current json state
/// - validation
class MostKeyValueEditorController extends ChangeNotifier {
  static MostValidator defaultValidator(
    MostKeyValueEditorController controller,
  ) {
    final schema = controller.schema;
    final jsonRw = controller.jsonRw;
    final formKey = controller.formKey;
    return MostMultiValidator([
      MostJsonSchemaValidator(schema?.jsonSchema),
      MostFormValidator(formKey),
      MostUnspecifiedPropertiesValidator(schema?.properties, jsonRw),
    ]);
  }

  /// Form key that is used to validate Form fields.
  late final GlobalKey<FormState> formKey;
  late final MostJsonSchemaParser _parser;
  late final JsonReaderWriter _jsonRw;
  late final ValidatorProvider _validatorProvider;

  MostSchema? _schema;
  ValidationResult _validationResult = const ValidationResult.notValidated();

  MostKeyValueEditorController({
    MostJsonSchemaParser parser = const MostJsonSchemaParser(),
    ValidatorProvider validatorProvider = defaultValidator,
  })  : _parser = parser,
        _validatorProvider = validatorProvider,
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

  MostSchema? get schema => _schema;

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
    final validator = _validatorProvider(this);
    final validationResult = validator.validate(map);
    return ValidationResult.validated(validationResult);
  }
}
