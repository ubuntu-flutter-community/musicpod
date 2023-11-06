import 'package:flutter/material.dart';
import 'package:musicpod/src/common/icons.dart';
import 'package:radio_browser_api/radio_browser_api.dart';
import 'package:yaru_widgets/yaru_widgets.dart';

import '../l10n/l10n.dart';

class TagPopup extends StatelessWidget {
  const TagPopup({
    super.key,
    this.onSelected,
    this.tags,
    required this.value,
    this.textStyle,
    required this.addFav,
    required this.removeFav,
    this.favs,
  });

  final void Function(Tag? tag)? onSelected;
  final List<Tag>? tags;
  final Set<String>? favs;
  final Tag? value;
  final TextStyle? textStyle;
  final void Function(Tag? tag) addFav;
  final void Function(Tag? tag) removeFav;

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
          for (final t in [
            ...[null, ...?tags].where((e) => favs?.contains(e?.name) == true),
            ...[null, ...?tags].where((e) => favs?.contains(e?.name) == false),
          ])
            PopupMenuItem(
              value: t,
              onTap: t != null ? null : () => onSelected?.call(t),
              child: StatefulBuilder(
                builder: (context, stateSetter) {
                  return Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(t?.name ?? context.l10n.all),
                      IconButton(
                        onPressed: () {
                          favs?.contains(t?.name) == false
                              ? addFav(t)
                              : removeFav(t);
                          stateSetter(() {});
                        },
                        icon: Icon(
                          favs?.contains(t?.name) == true
                              ? Iconz().starFilled
                              : Iconz().star,
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
        ];
      },
    );
  }
}
