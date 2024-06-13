import 'package:most_schema_parser/most_schema_parser.dart';

import '../json_reader_writer.dart';
import 'editor_view_type.dart';

/// Parser for view types.
class EditorViewTypeParser {
  /// Creates [EditorViewTypeParser].
  const EditorViewTypeParser();

  /// Parses [MostProperty] list to list of view types.
  List<EditorViewType> parse(
    List<MostProperty> properties,
    JsonReaderWriter jsonRw,
  ) {
    final List<EditorViewType> viewTypes = [];

    void traverseProperties(
      List<MostProperty> properties, {
      bool topLevel = false,
    }) {
      for (final property in properties) {
        switch (property) {
          case MostObjectProperty():
            viewTypes.add(ObjectPropertyEditorViewType(
              property: property,
              topLevel: topLevel,
            ));
            if (property.required ||
                jsonRw.property(property.fullPath).value != null) {
              traverseProperties(property.properties);
            }
          case MostValueProperty():
            viewTypes.add(ValuePropertyEditorViewType(
              property: property,
              topLevel: topLevel,
            ));
        }
      }
    }

    traverseProperties(properties, topLevel: true);

    return viewTypes;
  }
}
