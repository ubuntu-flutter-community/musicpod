import 'package:flutter/material.dart';
import 'package:watch_it/watch_it.dart';

import '../../common/view/icons.dart';
import '../../extensions/build_context_x.dart';
import '../../settings/settings_model.dart';
import '../player_model.dart';

class SeekButton extends StatelessWidget with WatchItMixin {
  const SeekButton({
    super.key,
    required this.active,
    this.forward = true,
    this.iconColor,
  });
  final bool active;
  final bool forward;
  final Color? iconColor;

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final playerModel = di<PlayerModel>();
    final useYaruTheme =
        watchPropertyValue((SettingsModel m) => m.useYaruTheme);

    final icon = Icon(
      forward ? Iconz.forward30 : Iconz.backward10,
      color: iconColor,
    );
    return IconButton(
      color: iconColor ??
          (active ? (theme.colorScheme.onSurface) : theme.disabledColor),
      onPressed: () async {
        playerModel.seekInSeconds(forward ? 30 : -10);
      },
      icon: useYaruTheme
          ? Stack(
              alignment: Alignment.center,
              children: [
                icon,
                Positioned(
                  bottom: 0,
                  right: 5,
                  child: Text(
                    forward ? '30' : '10',
                    style: context.theme.textTheme.labelSmall?.copyWith(
                      fontSize: 7,
                      color: iconColor,
                    ),
                  ),
                ),
              ],
            )
          : icon,
    );
  }
}
