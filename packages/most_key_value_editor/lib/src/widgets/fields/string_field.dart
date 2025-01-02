import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Form Field for string.
class StringField extends StatefulWidget {
  /// Initial value.
  ///
  /// Defaults to empty string if type is not [String].
  final dynamic initial;

  /// Leading icon.
  final Widget icon;

  /// Formatters.
  final List<TextInputFormatter> formatters;

  /// Called every time the value changes.
  ///
  /// This includes clearing the field to an empty state.
  final ValueChanged<String?> onChanged;

  /// Creates [StringField].
  const StringField({
    super.key,
    required this.initial,
    required this.icon,
    this.formatters = const [],
    required this.onChanged,
  });

  String get _initialOrEmpty => initial is String ? initial : '';

  @override
  State<StringField> createState() => _StringFieldState();
}

class _StringFieldState extends State<StringField> {
  late final TextEditingController _controller;
  late final FocusNode _focusNode;

  bool _isEditMode = false;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget._initialOrEmpty);
    _focusNode = FocusNode();
  }

  @override
  void didUpdateWidget(covariant StringField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.initial != widget.initial &&
        widget.initial != _controller.text) {
      WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
        _controller.text = widget._initialOrEmpty;
      });
    }
  }

  void _edit() {
    _controller.text = widget._initialOrEmpty;
    setState(() => _isEditMode = true);
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      FocusScope.of(context).requestFocus(_focusNode);
    });
  }

  void _cancel() {
    _controller.text = widget._initialOrEmpty;
    setState(() => _isEditMode = false);
  }

  void _saveNull() {
    widget.onChanged(null);
    setState(() => _isEditMode = false);
  }

  void _save() {
    if (_controller.text != widget.initial) {
      widget.onChanged(_controller.text);
    }
    setState(() => _isEditMode = false);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
          child: widget.icon,
        ),
        Expanded(
          child: TextField(
            controller: _controller,
            focusNode: _focusNode,
            decoration: InputDecoration(
              enabled: _isEditMode,
            ),
            inputFormatters: widget.formatters,
          ),
        ),
        if (_isEditMode) ...[
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: IconButton(
              icon: const Icon(Icons.cancel),
              onPressed: _cancel,
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: TextButton(
              onPressed: _saveNull,
              child: const Text(
                'null',
                style: TextStyle(fontWeight: FontWeight.w500),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: IconButton(
              icon: const Icon(Icons.check),
              onPressed: _save,
            ),
          ),
        ] else ...[
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: IconButton(
              icon: const Icon(Icons.edit),
              onPressed: _edit,
            ),
          ),
        ],
      ],
    );
  }
}
