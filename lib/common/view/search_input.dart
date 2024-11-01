import '../../extensions/build_context_x.dart';
import 'dart:async';
import 'package:flutter/material.dart';
import 'theme.dart';

class SearchInput extends StatefulWidget {
  const SearchInput({
    super.key,
    this.text,
    this.onClear,
    this.onSubmitted,
    this.onChanged,
    this.hintText,
    this.suffixIcon,
    this.prefixIcon,
    this.autoFocus = true,
  });
  final String? text;
  final void Function()? onClear;
  final void Function(String?)? onSubmitted;
  final void Function(String)? onChanged;
  final String? hintText;
  final Widget? suffixIcon;
  final Widget? prefixIcon;
  final bool autoFocus;

  @override
  State<SearchInput> createState() => _SearchInputState();
}

class _SearchInputState extends State<SearchInput> {
  late TextEditingController _controller;
  Timer? _debounce;

  _onSearchChanged(String query) {
    if (_debounce?.isActive ?? false) _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      widget.onChanged?.call(query);
    });
  }

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.text);
  }

  @override
  void dispose() {
    _controller.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    return SizedBox(
      height: yaruStyled ? null : 38,
      child: TextField(
        onTap: () {
          _controller.selection = TextSelection(
            baseOffset: 0,
            extentOffset: _controller.value.text.length,
          );
        },
        controller: _controller,
        key: widget.key,
        autofocus: widget.autoFocus,
        onSubmitted: _onSearchChanged,
        onChanged: _onSearchChanged,
        style: yaruStyled ? theme.textTheme.bodyMedium : null,
        decoration: yaruStyled
            ? createYaruDecoration(
                theme: theme,
                hintText: widget.hintText,
                suffixIcon: widget.suffixIcon,
                prefixIcon: widget.prefixIcon,
              )
            : createMaterialDecoration(
                colorScheme: theme.colorScheme,
                hintText: widget.hintText,
                suffixIcon: widget.suffixIcon,
                prefixIcon: widget.prefixIcon,
              ),
      ),
    );
  }
}
