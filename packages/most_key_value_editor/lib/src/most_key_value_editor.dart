import 'dart:async';

import 'package:flutter/material.dart';
import 'package:most_schema_parser/most_schema_parser.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';

import 'most_key_value_editor_controller.dart';
import 'utils/most_property_ext.dart';
import 'utils/property_builder.dart';
import 'widgets/editor_view_type.dart';
import 'widgets/editor_view_type_parser.dart';
import 'widgets/inputs/array_property_input.dart';
import 'widgets/inputs/boolean_property_input.dart';
import 'widgets/inputs/enum_property_input.dart';
import 'widgets/inputs/number_property_input.dart';
import 'widgets/inputs/string_property_input.dart';
import 'widgets/property_name_view.dart';
import 'widgets/value_property_view.dart';

/// Most Key-Value Editor.
// TODO convert search to an option
class MostKeyValueEditor extends StatefulWidget {
  /// Controller.
  final MostKeyValueEditorController controller;

  /// Custom Builder.
  ///
  /// Custom builder is checked before the default one.
  final PropertyBuilder? customBuilder;

  final EditorViewTypeParser editorViewTypeParser;
  final Duration searchDebounceDuration;
  final Duration searchScrollDuration;

  const MostKeyValueEditor({
    super.key,
    required this.controller,
    this.customBuilder,
    this.editorViewTypeParser = const EditorViewTypeParser(),
    this.searchDebounceDuration = const Duration(milliseconds: 300),
    this.searchScrollDuration = const Duration(milliseconds: 300),
  });

  @override
  State<MostKeyValueEditor> createState() => _MostKeyValueEditorState();
}

class _MostKeyValueEditorState extends State<MostKeyValueEditor> {
  late final PropertyBuilder propertyBuilder;
  late ItemScrollController _itemScrollController;
  late SearchController _searchController;

  List<EditorViewType>? _currentParsedViewTypes;

  Timer? _searchDebounceTimer;
  String lastQuery = '';

  @override
  void initState() {
    super.initState();
    final customBuilder = widget.customBuilder;
    propertyBuilder = PropertyBuilder(
      titleBuilders: [
        if (customBuilder != null) ...customBuilder.titleBuilders,
        _defaultTitledViewBuilder,
      ],
      inputBuilders: [
        if (customBuilder != null) ...customBuilder.inputBuilders,
        _defaultInputViewBuilder,
      ],
      unsupportedBuilder: customBuilder?.unsupportedBuilder,
    );
    _itemScrollController = ItemScrollController();

    _searchController = SearchController();
    _searchController.addListener(() => onTextChanged(_searchController.text));
  }

  void onTextChanged(String query) {
    if (!mounted) return;
    if (!_itemScrollController.isAttached) return;

    final trimmedQuery = query.trim();
    if (trimmedQuery == lastQuery) return;
    lastQuery = trimmedQuery;

    final viewTypes = _currentParsedViewTypes;
    if (viewTypes == null || viewTypes.isEmpty) return;

    _searchDebounceTimer?.cancel();
    _searchDebounceTimer = Timer(widget.searchDebounceDuration, () {
      _search(viewTypes, trimmedQuery);
    });
  }

  @override
  void dispose() {
    _searchDebounceTimer?.cancel();
    _searchDebounceTimer = null;
    super.dispose();
  }

  bool _hasSearchFullMatch(String queryLowerCase, String? other) {
    if (other == null) return false;
    return other.toLowerCase() == queryLowerCase;
  }

  bool _hasSearchMatch(String queryLowerCase, String? other) {
    if (other == null) return false;
    return other.toLowerCase().contains(queryLowerCase);
  }

  void _search(List<EditorViewType> viewTypes, String query) {
    final queryLowerCased = query.toLowerCase();

    if (query.isNotEmpty) {
      for (int i = 0; i < viewTypes.length; i++) {
        final property = viewTypes[i].property;
        if (_hasSearchFullMatch(queryLowerCased, property.displayTitle)) {
          _itemScrollController.scrollTo(
            index: i,
            duration: widget.searchScrollDuration,
          );
          return;
        }
      }

      for (int i = 0; i < viewTypes.length; i++) {
        final property = viewTypes[i].property;
        if (_hasSearchMatch(queryLowerCased, property.displayTitle)) {
          _itemScrollController.scrollTo(
            index: i,
            duration: widget.searchScrollDuration,
          );
          return;
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: widget.controller,
      builder: (context, _) {
        final mostJsonSchema = widget.controller.mostPropertiesOrNull;
        final List<EditorViewType> viewTypes = mostJsonSchema == null
            ? []
            : widget.editorViewTypeParser.parse(
                mostJsonSchema,
                widget.controller.jsonRw,
              );
        _currentParsedViewTypes = viewTypes;

        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: SearchAnchor(
                searchController: _searchController,
                builder: (BuildContext context, SearchController controller) {
                  return SearchBar(
                    controller: controller,
                    padding: const MaterialStatePropertyAll<EdgeInsets>(
                      EdgeInsets.symmetric(horizontal: 16.0),
                    ),
                    onTap: () => controller.openView(),
                    onChanged: (_) => controller.openView(),
                    leading: const Icon(Icons.search),
                    trailing: [
                      IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.text = '';
                        },
                      ),
                    ],
                  );
                },
                suggestionsBuilder: (_, SearchController controller) {
                  final viewTypes = _currentParsedViewTypes;
                  if (viewTypes == null || viewTypes.isEmpty) return [];
                  final allSuggestions =
                      viewTypes.map((e) => e.property).toList();
                  final queryLowerCase =
                      _searchController.text.trim().toLowerCase();

                  return [
                    if (queryLowerCase.isNotEmpty) ...[
                      ListTile(
                        title: Text('Search for $queryLowerCase'),
                        onTap: () {
                          setState(() => controller.closeView(queryLowerCase));
                        },
                      )
                    ],
                    ...allSuggestions
                        .where(
                          (s) =>
                              _hasSearchMatch(queryLowerCase, s.displayTitle),
                        )
                        .map(
                          (s) => ListTile(
                            title: Text(s.displayTitle),
                            subtitle: Text(s.fullPath),
                            onTap: () {
                              setState(
                                  () => controller.closeView(s.displayTitle));
                            },
                          ),
                        )
                        .toList(),
                  ];
                },
              ),
            ),
            Expanded(
              child: Form(
                key: widget.controller.formKey,
                autovalidateMode: AutovalidateMode.disabled,
                onChanged: () => widget.controller.resetValidationError(),
                child: mostJsonSchema != null
                    ? ScrollablePositionedList.builder(
                        itemScrollController: _itemScrollController,
                        padding: const EdgeInsets.only(
                          top: 8,
                          bottom: 32,
                          left: 8,
                          right: 0,
                        ),
                        itemCount: viewTypes.length,
                        itemBuilder: (context, index) => viewTypes[index].build(
                          widget.controller.jsonRw,
                          propertyBuilder,
                        ),
                      )
                    : const Center(
                        child: Text(
                          'No schema',
                        ),
                      ),
              ),
            ),
          ],
        );
      },
    );
  }
}

Widget? _defaultInputViewBuilder(
  BuildContext context,
  PropertyBuilder propBuilder,
  PropertyBuilderSpec<MostProperty> spec,
) {
  final property = spec.property;
  return switch (property) {
    BooleanMostProperty() => BooleanPropertyInput(
        property: property,
        propertyRw: spec.propertyRw,
      ),
    StringMostProperty() => StringPropertyInput(
        property: property,
        propertyRw: spec.propertyRw,
      ),
    EnumMostProperty() => EnumPropertyInput(
        property: property,
        propertyRw: spec.propertyRw,
      ),
    NumberMostProperty() => NumberPropertyInput(
        property: property,
        propertyRw: spec.propertyRw,
      ),
    ArrayMostProperty() => ArrayPropertyInput(
        property: property,
        propertyRw: spec.propertyRw,
        propertyBuilder: propBuilder,
      ),
    _ => null,
  };
}

Widget? _defaultTitledViewBuilder(
  BuildContext context,
  PropertyBuilder propBuilder,
  PropertyBuilderSpec<MostValueProperty> spec,
) {
  return Row(
    crossAxisAlignment: CrossAxisAlignment.start,
    mainAxisAlignment: MainAxisAlignment.start,
    children: [
      SizedBox(
        width: 256,
        child: PropertyNameView(
          property: spec.property,
          propertyRw: spec.propertyRw,
          validationResult: spec.propertyRw.validationResult,
        ),
      ),
      const SizedBox(width: 8),
      Expanded(
        child: Align(
          alignment: Alignment.centerLeft,
          child: ValuePropertyView(
            property: spec.property,
            jsonRw: spec.jsonRw,
            propertyBuilder: propBuilder,
          ),
        ),
      ),
      const SizedBox(width: 16),
    ],
  );
}
