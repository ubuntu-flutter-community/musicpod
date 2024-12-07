import 'package:flutter/material.dart';
import 'package:watch_it/watch_it.dart';
import 'package:yaru/yaru.dart';

import '../../app_config.dart';
import '../../constants.dart';
import '../../extensions/build_context_x.dart';
import '../../library/library_model.dart';
import 'icons.dart';
import 'theme.dart';

class SearchButton extends StatelessWidget {
  const SearchButton({super.key, this.onPressed, this.active, this.icon});

  final void Function()? onPressed;
  final bool? active;
  final Widget? icon;

  @override
  Widget build(BuildContext context) {
    final onTap =
        onPressed ?? () => di<LibraryModel>().push(pageId: kSearchPageId);

    return yaruStyled
        ? YaruSearchButton(
            searchActive: active,
            onPressed: onTap,
            icon: icon,
            selectedIcon: icon,
          )
        : IconButton(
            isSelected: active,
            onPressed: onTap,
            selectedIcon: icon ??
                Icon(
                  Iconz.search,
                  color: context.theme.colorScheme.primary,
                  size: iconSize,
                ),
            icon: icon ??
                Icon(
                  Iconz.search,
                  size: iconSize,
                ),
          );
  }
}
