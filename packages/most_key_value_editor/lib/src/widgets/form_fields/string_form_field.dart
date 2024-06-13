import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Form Field for string.
class StringFormField extends StatefulWidget {
  /// Initial value.
  ///
  /// Defaults to empty string if type is not [String].
  final dynamic initial;

  /// Leading icon.
  final Widget icon;

  /// Formatters.
  final List<TextInputFormatter> formatters;

  /// Validation callback.
  final String? Function(String?)? validate;

  /// Called every time the value changes.
  ///
  /// This includes clearing the field to an empty state.
  final ValueChanged<String> onChanged;

  /// Creates [StringFormField].
  const StringFormField({
    super.key,
    required this.initial,
    required this.icon,
    this.formatters = const [],
    this.validate,
    required this.onChanged,
  });

  @override
  State<StringFormField> createState() => _StringFormFieldState();
}

class _StringFormFieldState extends State<StringFormField> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(
      text: widget.initial is String ? widget.initial : '',
    );
    _controller.addListener(() {
      if (!mounted) return;
      if (_controller.text == widget.initial) return;
      if (_controller.text.isEmpty && widget.initial == null) return;

      widget.onChanged(_controller.text);
    });
  }

  @override
  void didUpdateWidget(covariant StringFormField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.initial != widget.initial &&
        widget.initial != _controller.text) {
      WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
        _controller.text = widget.initial is String ? widget.initial : '';
      });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: _controller,
      decoration: InputDecoration(
        icon: widget.icon,
      ),
      inputFormatters: widget.formatters,
      autovalidateMode: AutovalidateMode.disabled,
      validator: widget.validate,
    );
  }
}
