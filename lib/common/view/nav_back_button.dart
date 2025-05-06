import 'package:flutter/material.dart';
import 'package:watch_it/watch_it.dart';
import 'package:yaru/yaru.dart';

import '../../app/view/routing_manager.dart';
import '../../settings/settings_model.dart';
import 'icons.dart';

class NavBackButton extends StatelessWidget with WatchItMixin {
  const NavBackButton({super.key});

  @override
  Widget build(BuildContext context) {
    void onTap() {
      di<SettingsModel>().scrollIndex = 0;
      di<RoutingManager>().pop();
    }

    final useYaruTheme =
        watchPropertyValue((SettingsModel m) => m.useYaruTheme);

    if (useYaruTheme) {
      return YaruBackButton(
        style: YaruBackButtonStyle.rounded,
        onPressed: onTap,
        icon: Icon(Iconz.goBack),
      );
    }
    return Center(
      child: BackButton(
        onPressed: onTap,
      ),
    );
  }
}
