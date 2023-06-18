import 'package:flutter/material.dart';
import 'package:yaru_widgets/yaru_widgets.dart';

const Duration _kSelectedTileAnimationDuration = Duration(milliseconds: 250);

class ResponsiveMasterTile extends StatelessWidget {
  const ResponsiveMasterTile({
    super.key,
    this.leading,
    this.title,
    this.onTap,
    required this.availableWidth,
  });

  final Widget? leading;
  final Widget? title;
  final VoidCallback? onTap;
  final double availableWidth;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth >= 130) {
          return YaruMasterTile(
            title: title,
            leading: leading,
            onTap: onTap,
          );
        }

        return _CompactMasterTile(
          leading: leading,
          onTap: onTap,
        );
      },
    );
  }
}

/// Same looking version of [YaruMasterTile], with only the leading.
class _CompactMasterTile extends StatelessWidget {
  const _CompactMasterTile({
    required this.leading,
    this.onTap,
  });

  final Widget? leading;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scope = YaruMasterTileScope.maybeOf(context);
    final isSelected = scope?.selected ?? false;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 6),
      child: AnimatedContainer(
        duration: _kSelectedTileAnimationDuration,
        decoration: BoxDecoration(
          borderRadius:
              const BorderRadius.all(Radius.circular(kYaruButtonRadius)),
          color:
              isSelected ? theme.colorScheme.onSurface.withOpacity(0.07) : null,
        ),
        child: InkWell(
          borderRadius:
              const BorderRadius.all(Radius.circular(kYaruButtonRadius)),
          child: Padding(
            padding: const EdgeInsets.all(6),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: leading != null ? [leading!] : [],
            ),
          ),
          onTap: () {
            scope?.onTap();
            onTap?.call();
          },
        ),
      ),
    );
  }
}
