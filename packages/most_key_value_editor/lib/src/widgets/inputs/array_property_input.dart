import 'package:flutter/material.dart';
import 'package:most_schema_parser/most_schema_parser.dart';

import '../../json_accessor.dart';
import '../../utils/property_builder.dart';
import '../value_property_view.dart';

/// Input for [ArrayMostProperty].
class ArrayPropertyInput extends StatelessWidget {
  final ArrayMostProperty _property;
  final JsonPropertyAccessor _accessor;
  final PropertyBuilder _propertyBuilder;

  /// Create [ArrayPropertyInput].
  const ArrayPropertyInput({
    super.key,
    required ArrayMostProperty property,
    required JsonPropertyAccessor accessor,
    required PropertyBuilder propertyBuilder,
  })  : _propertyBuilder = propertyBuilder,
        _accessor = accessor,
        _property = property;

  void _onChanged(List newValue) {
    _accessor.value = newValue.isEmpty ? null : newValue.toSet().toList();
  }

  @override
  Widget build(BuildContext context) {
    final value = _accessor.value;
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
                          final itemPath = _property.itemProperty.fullPath;
                          JsonAccessor? itemAccessor;
                          itemAccessor = ListeningProxyJsonAccessor(
                            JsonAccessor(),
                            onChanged: (path) {
                              final value =
                                  itemAccessor?.property(itemPath).value;
                              if (items[index] == value) return;

                              items[index] = value;
                              _onChanged(items);
                            },
                          );
                          itemAccessor.property(itemPath).value = items[index];

                          return ValuePropertyView(
                            property: _property.itemProperty,
                            jsonAccessor: itemAccessor,
                            propertyBuilder: _propertyBuilder,
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
            _accessor.value = items;
          },
        ),
        const SizedBox(height: 40),
      ],
    );
  }
}
