import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
// ignore: depend_on_referenced_packages
import 'package:json_schema/json_schema.dart';
import 'package:most_key_value_editor/most_key_value_editor.dart';

import 'ip_property.dart';

void main() {
  runApp(const ExampleApp());
}

class ExampleApp extends StatelessWidget {
  const ExampleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Editor',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const EditorPage(
        initialJson: {
          "person": {
            "last_name": "Doe",
            "gender": "alien",
            "age": 42,
          },
          "ipv4": "0.0.0.256",
        },
        initialJsonSchema: {
          "title": "Person",
          "required": [
            "person",
            "admin",
            "ipv4",
          ],
          "properties": {
            "person": {
              "type": "object",
              "required": [
                "first_name",
                "last_name",
                "nicknames",
                "gender",
                "age",
              ],
              "properties": {
                "first_name": {"type": "string"},
                "last_name": {"type": "string"},
                "nicknames": {
                  "type": "array",
                  "items": {"type": "string"},
                },
                "gender": {
                  "type": "string",
                  "enum": ["male", "female", "prefer not to say"]
                },
                "age": {
                  "description":
                      "Age in years which must be equal to or greater than zero.",
                  "type": "integer",
                  "minimum": 0
                },
              },
            },
            "admin": {"type": "boolean"},
            "ipv4": {
              "title": "IP",
              "type": "string",
              "pattern":
                  r"^(([0-9]|[1-9][0-9]|1[0-9]{2}|2[0-4][0-9]|25[0-5])\.){3}([0-9]|[1-9][0-9]|1[0-9]{2}|2[0-4][0-9]|25[0-5])$"
            },
          },
        },
      ),
    );
  }
}

class EditorPage extends StatefulWidget {
  final Map<String, dynamic> initialJson;
  final Map<String, dynamic> initialJsonSchema;

  const EditorPage({
    super.key,
    required this.initialJson,
    required this.initialJsonSchema,
  });

  JsonSchema get jsonSchema => JsonSchema.create(initialJsonSchema);

  @override
  State<EditorPage> createState() => _EditorPageState();
}

class _EditorPageState extends State<EditorPage> {
  late final MostKeyValueEditorController controller;

  @override
  void initState() {
    super.initState();
    controller = MostKeyValueEditorController(
      initialState: EditorState.fromAccessor(JsonAccessor()),
      onChangedTransformer: ValidateCommand(
        const EditorStateValidator.merge([
          PropertiesValidator(),
          UnspecifiedPropertiesValidator(),
          JsonSchemaValidator(),
          MockNameValidator(),
        ]),
      ),
    );

    controller
      ..executeCommand(SeedJsonCommand(widget.initialJson))
      ..executeCommand(SeedJsonSchemaCommand(widget.jsonSchema));
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  void _copyToClipboard(MostKeyValueEditorController controller) {
    final map = controller.jsonAccessor.read();
    Clipboard.setData(ClipboardData(text: json.encode(map)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Editor Demo'),
        actions: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: ElevatedButton.icon(
              onPressed: () => _copyToClipboard(controller),
              label: const Text('Copy'),
              icon: const Icon(Icons.copy),
            ),
          ),
        ],
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 800),
          child: MostKeyValueEditor(
            controller: controller,
            inputBuilders: const [
              customInputBuilder,
            ],
          ),
        ),
      ),
    );
  }
}

class MockNameValidator extends EditorStateValidator {
  const MockNameValidator();

  @override
  List<ValidationMessage> validate(EditorState state) {
    final firstName = state.jsonAccessor.getValue('person.first_name');
    final lastName = state.jsonAccessor.getValue('person.last_name');
    return firstName == "John" && lastName == "Doe"
        ? [
            const ValidationMessage.propertyError(
              path: "person.first_name",
              message: "Please use real name",
            ),
            const ValidationMessage.propertyError(
              path: "person.last_name",
              message: "Please use real name",
            ),
          ]
        : [];
  }
}
