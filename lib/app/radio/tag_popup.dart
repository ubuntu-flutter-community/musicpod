import 'package:flutter/material.dart';
import 'package:musicpod/l10n/l10n.dart';
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
        theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w500);
    return YaruPopupMenuButton<Tag?>(
      style: buttonStyle,
      onSelected: onSelected,
      initialValue: value,
      child: Text(
        value?.name ?? context.l10n.all,
        style: textStyle ?? fallBackTextStyle,
      ),
      itemBuilder: (context) {
        return [
          for (final t in [null, ...?tags])
            PopupMenuItem(
              value: t,
              onTap: t != null ? null : () => onSelected?.call(t),
              child: Text(t?.name ?? context.l10n.all),
            ),
        ];
      },
    );
  }
}
