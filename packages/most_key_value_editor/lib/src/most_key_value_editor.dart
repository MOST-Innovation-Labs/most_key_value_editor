import 'dart:async';

import 'package:flutter/material.dart';
import 'package:most_schema_parser/most_schema_parser.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';

import 'controller/most_key_value_editor_controller.dart';
import 'controller/validator/models/validation_result.dart';
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
class MostKeyValueEditor<T extends EditorState> extends StatefulWidget {
  /// Editor Controller.
  final MostKeyValueEditorController<T> controller;

  /// Builder for [EditorViewType].
  final EditorViewTypeBuilder editorViewTypeBuilder;

  /// Custom title builders.
  ///
  /// Checked before the default ones.
  final List<PropertyTitleWidgetBuilder<Widget?, MostValueProperty>>
      titleBuilders;

  /// Custom input builders.
  ///
  /// Checked before the default ones.
  final List<PropertyWidgetBuilder<Widget?, MostProperty>> inputBuilders;

  /// Unsupported property type builder.
  final PropertyWidgetBuilder<Widget?, MostProperty>? unsupportedBuilder;

  /// Parser  for [EditorViewType].
  final EditorViewTypeParser editorViewTypeParser;

  /// Delay after stop typing before the search.
  final Duration searchDebounceDuration;

  /// Duration of the scroll to searched property.
  final Duration searchScrollDuration;

  /// Create [MostKeyValueEditor].
  const MostKeyValueEditor({
    super.key,
    required this.controller,
    this.editorViewTypeBuilder = defaultEditorViewTypeBuilder,
    this.titleBuilders = const [],
    this.inputBuilders = const [],
    this.unsupportedBuilder,
    this.editorViewTypeParser = const EditorViewTypeParser(),
    this.searchDebounceDuration = const Duration(milliseconds: 300),
    this.searchScrollDuration = const Duration(milliseconds: 300),
  });

  @override
  State<MostKeyValueEditor<T>> createState() => _MostKeyValueEditorState<T>();
}

class _MostKeyValueEditorState<T extends EditorState>
    extends State<MostKeyValueEditor<T>> {
  late final PropertyBuilder propertyBuilder;

  late ItemScrollController _itemScrollController;
  late SearchController _searchController;

  List<EditorViewType>? _currentParsedViewTypes;

  Timer? _searchDebounceTimer;
  String lastQuery = '';

  @override
  void initState() {
    super.initState();
    propertyBuilder = PropertyBuilder(
      titleBuilders: [
        ...widget.titleBuilders,
        _defaultTitledViewBuilder,
      ],
      inputBuilders: [
        ...widget.inputBuilders,
        _defaultInputViewBuilder,
      ],
      unsupportedBuilder: widget.unsupportedBuilder,
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
        final properties = widget.controller.propeties;
        final List<EditorViewType> viewTypes = properties == null
            ? []
            : widget.editorViewTypeParser.parse(
                properties,
                widget.controller.jsonAccessor,
              );
        _currentParsedViewTypes = viewTypes;

        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: SearchAnchor(
                searchController: _searchController,
                builder: _searchBuilder,
                suggestionsBuilder: _suggestionsBuilder,
              ),
            ),
            Expanded(
              child: properties != null
                  ? ScrollablePositionedList.builder(
                      itemScrollController: _itemScrollController,
                      padding: const EdgeInsets.only(
                        top: 8,
                        bottom: 32,
                        left: 8,
                        right: 0,
                      ),
                      itemCount: viewTypes.length,
                      itemBuilder: (context, index) =>
                          widget.editorViewTypeBuilder(
                        viewTypes[index],
                        widget.controller.jsonAccessor,
                        propertyBuilder,
                        widget.controller.validationResult,
                      ),
                    )
                  : const Center(
                      child: Text(
                        'No schema',
                      ),
                    ),
            ),
          ],
        );
      },
    );
  }

  Widget _searchBuilder(BuildContext context, SearchController controller) {
    return SearchBar(
      controller: controller,
      padding: const WidgetStatePropertyAll<EdgeInsets>(
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
  }

  List<Widget> _suggestionsBuilder(_, SearchController controller) {
    final viewTypes = _currentParsedViewTypes;
    if (viewTypes == null || viewTypes.isEmpty) return [];
    final allSuggestions = viewTypes.map((e) => e.property).toList();
    final queryLowerCase = _searchController.text.trim().toLowerCase();

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
            (s) => _hasSearchMatch(queryLowerCase, s.displayTitle),
          )
          .map(
            (s) => ListTile(
              title: Text(s.displayTitle),
              subtitle: Text(s.fullPath),
              onTap: () {
                setState(() => controller.closeView(s.displayTitle));
              },
            ),
          )
          .toList(),
    ];
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
        accessor: spec.accessor,
      ),
    StringMostProperty() => StringPropertyInput(
        property: property,
        accessor: spec.accessor,
      ),
    EnumMostProperty() => EnumPropertyInput(
        property: property,
        accessor: spec.accessor,
      ),
    NumberMostProperty() => NumberPropertyInput(
        property: property,
        accessor: spec.accessor,
      ),
    ArrayMostProperty() => ArrayPropertyInput(
        property: property,
        accessor: spec.accessor,
        propertyBuilder: propBuilder,
      ),
    _ => null,
  };
}

Widget? _defaultTitledViewBuilder(
  BuildContext context,
  PropertyBuilder propBuilder,
  PropertyBuilderSpec<MostValueProperty> spec,
  ValidationResult validationResult,
) {
  return Row(
    crossAxisAlignment: CrossAxisAlignment.start,
    mainAxisAlignment: MainAxisAlignment.start,
    children: [
      SizedBox(
        width: 256,
        child: PropertyNameView(
          property: spec.property,
          accessor: spec.accessor,
          validationResult:
              validationResult.forProperty(spec.property.fullPath),
        ),
      ),
      const SizedBox(width: 8),
      Expanded(
        child: Align(
          alignment: Alignment.centerLeft,
          child: ValuePropertyView(
            property: spec.property,
            jsonAccessor: spec.jsonAccessor,
            propertyBuilder: propBuilder,
          ),
        ),
      ),
      const SizedBox(width: 16),
    ],
  );
}
