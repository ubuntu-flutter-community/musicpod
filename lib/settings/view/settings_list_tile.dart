import 'package:flutter/material.dart';
import 'package:yaru/yaru.dart';

import '../../common/view/icons.dart';
import '../../extensions/build_context_x.dart';

class SettingsListTile extends StatelessWidget {
  const SettingsListTile({
    this.titleString,
    this.onTap,
    super.key,
    this.borderRadius,
    required this.position,
    this.title,
    this.subtitle,
    this.selected,
    this.trailing,
    this.includeChevron = false,
    this.tileColor,
    this.leading,
  });

  final Widget? leading;
  final String? titleString;
  final Widget? title;
  final Widget? subtitle;
  final void Function()? onTap;
  final BorderRadius? borderRadius;
  final ListTilePosition position;
  final bool? selected;
  final Widget? trailing;
  final bool includeChevron;
  final Color? tileColor;

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final textTheme = context.textTheme;
    final bodyLarge = textTheme.bodyLarge;

    return Material(
      color: Colors.transparent,
      borderRadius: getBorderRadius(),
      child: Padding(
        padding: switch (position) {
          ListTilePosition.first => const EdgeInsets.only(bottom: 2),
          ListTilePosition.middle => const EdgeInsets.only(bottom: 2),
          ListTilePosition.last => EdgeInsets.zero,
          ListTilePosition.single => EdgeInsets.zero,
        },
        child: ListTile(
          onTap: onTap,
          selected: selected ?? false,

          contentPadding: const EdgeInsets.symmetric(
            horizontal: 24,
            vertical: 12,
          ),
          shape: RoundedRectangleBorder(borderRadius: getBorderRadius()),
          tileColor: tileColor ?? theme.cardColor,
          leading: leading,
          title:
              title ??
              Text(
                titleString ?? '',
                style: bodyLarge?.copyWith(
                  color: theme.colorScheme.onSurface,
                  fontSize: 16,
                  fontWeight: FontWeight.w400,
                ),
              ),
          subtitle: subtitle,
          trailing: trailing ?? (includeChevron ? Icon(Iconz.chevron) : null),
        ),
      ),
    );
  }

  BorderRadius getBorderRadius() {
    return switch (position) {
      ListTilePosition.first => BorderRadius.vertical(
        top: Radius.circular(borderRadius?.topLeft.x ?? kYaruContainerRadius),
        bottom: Radius.circular(borderRadius?.bottomLeft.x ?? 0),
      ),
      ListTilePosition.middle => BorderRadius.zero,
      ListTilePosition.last => BorderRadius.vertical(
        top: Radius.circular(borderRadius?.topLeft.x ?? 0),
        bottom: Radius.circular(
          borderRadius?.bottomLeft.x ?? kYaruContainerRadius,
        ),
      ),
      ListTilePosition.single => BorderRadius.all(
        Radius.circular(borderRadius?.topLeft.x ?? kYaruContainerRadius),
      ),
    };
  }
}

enum ListTilePosition { first, middle, last, single }
