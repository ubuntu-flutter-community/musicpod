import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/page_ids.dart';
import '../../app/routing_manager.dart';
import '../../extensions/build_context_x.dart';
import 'icons.dart';

class SearchButton extends ConsumerWidget {
  const SearchButton({
    super.key,
    this.onPressed,
    this.active,
    this.icon,
    this.iconColor,
  });

  final void Function()? onPressed;
  final bool? active;
  final Widget? icon;
  final Color? iconColor;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final onTap =
        onPressed ??
        () => ref
            .read(routingManagerProvider.notifier)
            .push(pageId: PageIDs.searchPage);
    final iconSize = context.theme.iconTheme.size ?? 24.0;

    final label = context.l10n.search;
    return IconButton(
      tooltip: label,
      isSelected: active,
      onPressed: onTap,
      selectedIcon:
          icon ??
          Icon(
            Iconz.search,
            color: iconColor ?? context.theme.colorScheme.onSurface,
            size: iconSize,
            semanticLabel: label,
          ),
      icon:
          icon ??
          Icon(
            Iconz.search,
            size: iconSize,
            color: iconColor,
            semanticLabel: label,
          ),
    );
  }
}
