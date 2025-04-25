import 'package:flutter/material.dart';
import 'package:watch_it/watch_it.dart';
import 'package:yaru/yaru.dart';

import '../../app/view/routing_manager.dart';
import '../../app_config.dart';
import '../../extensions/build_context_x.dart';
import '../page_ids.dart';
import 'icons.dart';
import 'theme.dart';

class SearchButton extends StatelessWidget {
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
  Widget build(BuildContext context) {
    final onTap = onPressed ??
        () => di<RoutingManager>().push(pageId: PageIDs.searchPage);

    return AppConfig.yaruStyled
        ? YaruSearchButton(
            searchActive: active,
            onPressed: onTap,
            icon: icon ??
                Icon(
                  YaruIcons.search,
                  color: iconColor,
                ),
            selectedIcon: icon,
          )
        : IconButton(
            isSelected: active,
            onPressed: onTap,
            selectedIcon: icon ??
                Icon(
                  Iconz.search,
                  color: iconColor ?? context.theme.colorScheme.primary,
                  size: iconSize,
                ),
            icon: icon ??
                Icon(
                  Iconz.search,
                  size: iconSize,
                  color: iconColor,
                ),
          );
  }
}
