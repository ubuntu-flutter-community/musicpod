import 'package:flutter/material.dart';
import 'package:yaru_icons/yaru_icons.dart';
import 'package:yaru_widgets/yaru_widgets.dart';

class SearchField extends StatefulWidget {
  const SearchField({super.key, this.onChanged, this.text, this.label});

  final void Function(String)? onChanged;
  final String? text;
  final String? label;

  @override
  State<SearchField> createState() => _SearchFieldState();
}

class _SearchFieldState extends State<SearchField> {
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.text);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final light = theme.brightness == Brightness.light;

    return SizedBox(
      height: 35,
      child: TextField(
        controller: _controller,
        autofocus: true,
        onChanged: widget.onChanged,
        decoration: InputDecoration(
          hintText: widget.label == null ? null : widget.label!,
          contentPadding: const EdgeInsets.only(left: 10, right: 10),
          suffixIconConstraints:
              const BoxConstraints(maxHeight: 35, maxWidth: 35),
          suffixIcon: YaruIconButton(
            onPressed: _clear,
            icon: const Icon(
              YaruIcons.edit_clear,
            ),
          ),
          fillColor: light ? Colors.white : Theme.of(context).dividerColor,
        ),
      ),
    );
  }

  void _clear() {
    if (widget.onChanged != null) widget.onChanged!('');
    _controller.clear();
  }
}
