import 'package:flutter/material.dart';
import 'package:musicpod/app/common/constants.dart';
import 'package:yaru_icons/yaru_icons.dart';
import 'package:yaru_widgets/yaru_widgets.dart';

class SearchButton extends StatelessWidget {
  const SearchButton({
    super.key,
    required this.searchActive,
    required this.setSearchActive,
  });

  final bool searchActive;
  final void Function(bool value) setSearchActive;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: SizedBox(
        height: kHeaderBarItemHeight,
        width: kHeaderBarItemHeight,
        child: YaruIconButton(
          isSelected: searchActive,
          selectedIcon: Icon(
            YaruIcons.search,
            size: 16,
            color: theme.colorScheme.onSurface,
          ),
          icon: Icon(
            YaruIcons.search,
            size: 16,
            color: theme.colorScheme.onSurface,
          ),
          onPressed: () => setSearchActive(!searchActive),
        ),
      ),
    );
  }
}
