import 'package:flutter/material.dart';
import 'package:most_schema_parser/most_schema_parser.dart';

import '../../json_reader_writer.dart';
import '../../utils/property_builder.dart';
import '../value_property_view.dart';

class ArrayPropertyInput extends StatelessWidget {
  final ArrayMostProperty property;
  final JsonPropertyReaderWriter propertyRw;
  final PropertyBuilder propertyBuilder;

  const ArrayPropertyInput({
    super.key,
    required this.property,
    required this.propertyRw,
    required this.propertyBuilder,
  });

  void _onChanged(List newValue) {
    propertyRw.value = newValue.isEmpty ? null : newValue.toSet().toList();
  }

  @override
  Widget build(BuildContext context) {
    final value = propertyRw.value;
    final items = List.of(value is List ? value : []);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ReorderableListView(
          shrinkWrap: true,
          onReorder: (oldIndex, newIndex) {
            if (oldIndex < newIndex) {
              newIndex -= 1;
            }
            final item = items.removeAt(oldIndex);
            items.insert(newIndex, item);

            _onChanged(items);
          },
          children: <Widget>[
            for (int index = 0; index < items.length; index += 1)
              Container(
                key: Key('$index${items[index]}'),
                padding: const EdgeInsets.only(right: 32),
                child: Row(
                  children: [
                    Expanded(
                      child: Builder(
                        builder: (context) {
                          // TODO refactor to make more efficient
                          final itemPath = property.itemProperty.fullPath;
                          JsonReaderWriter? itemRw;
                          itemRw = JsonReaderWriter(
                            onChanged: (json) {
                              final value = itemRw?.property(itemPath).value;
                              if (items[index] == value) return;

                              items[index] = value;
                              _onChanged(items);
                            },
                          );
                          itemRw.property(itemPath).value = items[index];

                          return ValuePropertyView(
                            property: property.itemProperty,
                            jsonRw: itemRw,
                            propertyBuilder: propertyBuilder,
                          );
                        },
                      ),
                    ),
                    const SizedBox(width: 8),
                    Padding(
                      padding: const EdgeInsets.all(4),
                      child: IconButton(
                        icon: const Icon(Icons.delete),
                        onPressed: () {
                          items.removeAt(index);
                          _onChanged(items);
                        },
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
        IconButton(
          icon: const Icon(Icons.add),
          onPressed: () {
            items.add(null);
            propertyRw.value = items;
          },
        ),
        const SizedBox(height: 40),
      ],
    );
  }
}
