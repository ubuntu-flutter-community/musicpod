import 'package:flutter/material.dart';
import 'package:musicpod/string_x.dart';
import 'package:radio_browser_api/radio_browser_api.dart';
import 'package:yaru_widgets/yaru_widgets.dart';

class TagPopup extends StatelessWidget {
  const TagPopup({
    super.key,
    this.onSelected,
    this.tags,
    required this.value,
    this.textStyle,
  });

  final void Function(Tag? tag)? onSelected;
  final List<Tag>? tags;
  final Tag? value;
  final TextStyle? textStyle;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final buttonStyle = TextButton.styleFrom(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(6),
      ),
    );
    final fallBackTextStyle =
        theme.textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w100);
    return YaruPopupMenuButton<Tag>(
      style: buttonStyle,
      onSelected: onSelected,
      initialValue: value,
      child: Text(
        value?.name.capitalize().camelToSentence() ?? '',
        style: textStyle ?? fallBackTextStyle,
      ),
      itemBuilder: (context) {
        return [
          for (final t in tags ?? <Tag>[])
            PopupMenuItem(
              value: t,
              child: Text(t.name),
            )
        ];
      },
    );
  }
}
