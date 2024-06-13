import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
// ignore: depend_on_referenced_packages
import 'package:json_schema/json_schema.dart';
import 'package:most_key_value_editor/most_key_value_editor.dart';
import 'package:most_schema_parser/most_schema_parser.dart';

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
          "lastName": "Doe",
          "age": 42,
          "ipv4": "0.0.0.256",
        },
        initialJsonSchema: {
          "title": "Person",
          "required": [
            "firstName",
            "age",
          ],
          "properties": {
            "firstName": {
              "type": "string",
              "description": "The person's first name."
            },
            "lastName": {
              "type": "string",
              "description": "The person's last name."
            },
            "age": {
              "description":
                  "Age in years which must be equal to or greater than zero.",
              "type": "integer",
              "minimum": 0
            },
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

  @override
  State<EditorPage> createState() => _EditorPageState();
}

class _EditorPageState extends State<EditorPage> {
  static const customMappers = <PropertyMapper>[
    IpV4PropertyMapper(),
  ];
  static const customBuilder = PropertyBuilder(
    inputBuilders: [
      ipv4PropertyInputBuilder,
    ],
  );

  late final MostKeyValueEditorController controller;

  @override
  void initState() {
    super.initState();
    controller = MostKeyValueEditorController(
      parser: const MostJsonSchemaParser(
        customMappers: customMappers,
      ),
    );

    controller
      ..seedJson(widget.initialJson)
      ..seedJsonSchema(JsonSchema.create(widget.initialJsonSchema));
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  void _copyToClipboard(MostKeyValueEditorController controller) {
    final map = controller.jsonRw.read();
    Clipboard.setData(ClipboardData(text: json.encode(map)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Editor Demo'),
        actions: [
          ListenableBuilder(
            listenable: controller,
            builder: (context, _) {
              return Padding(
                padding: const EdgeInsets.all(8.0),
                child: ElevatedButton.icon(
                  onPressed: controller.jsonRw.canUndo
                      ? () => controller.jsonRw.undo()
                      : null,
                  label: const Text('Undo'),
                  icon: const Icon(Icons.undo_rounded),
                ),
              );
            },
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: ElevatedButton.icon(
              onPressed: () => _copyToClipboard(controller),
              label: const Text('Copy'),
              icon: const Icon(Icons.copy),
            ),
          ),
          ListenableBuilder(
            listenable: controller,
            builder: (context, _) {
              return Padding(
                padding: const EdgeInsets.all(8.0),
                child: ElevatedButton.icon(
                  onPressed: () => controller.validate(),
                  label: const Text('Validate'),
                  icon: ValidationStateView(
                    validationResult: controller.validationResult,
                  ),
                ),
              );
            },
          ),
        ],
      ),
      body: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 800),
        child: MostKeyValueEditor(
          controller: controller,
          customBuilder: customBuilder,
        ),
      ),
    );
  }
}
