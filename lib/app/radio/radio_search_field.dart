import 'package:flutter/material.dart';
import 'package:musicpod/l10n/l10n.dart';
import 'package:yaru_icons/yaru_icons.dart';
import 'package:yaru_widgets/yaru_widgets.dart';

class RadioSearchField extends StatefulWidget {
  const RadioSearchField({
    super.key,
    this.text,
    this.onSubmitted,
  });

  final String? text;
  final void Function(String? value)? onSubmitted;

  @override
  State<RadioSearchField> createState() => _RadioSearchFieldState();
}

class _RadioSearchFieldState extends State<RadioSearchField> {
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.text);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final light = theme.brightness == Brightness.light;

    return SizedBox(
      height: 35,
      width: 400,
      child: TextField(
        style: theme.textTheme.bodyMedium,
        strutStyle: const StrutStyle(
          leading: 0.2,
        ),
        textAlignVertical: TextAlignVertical.center,
        cursorWidth: 1,
        onSubmitted: widget.onSubmitted,
        controller: _controller,
        decoration: InputDecoration(
          contentPadding: const EdgeInsets.fromLTRB(12, 12, 12, 18),
          prefixIcon: const Icon(
            YaruIcons.search,
            size: 16,
          ),
          prefixIconConstraints:
              const BoxConstraints(minWidth: 34, minHeight: 30),
          hintText: context.l10n.search,
          suffixIconConstraints:
              const BoxConstraints(maxHeight: 35, maxWidth: 35),
          suffixIcon: _controller.text.isEmpty
              ? null
              : YaruIconButton(
                  onPressed: () {
                    _controller.clear();
                    widget.onSubmitted?.call(null);
                  },
                  icon: const Icon(
                    YaruIcons.edit_clear,
                  ),
                ),
          fillColor: light ? Colors.white : Theme.of(context).dividerColor,
        ),
      ),
    );
  }
}
