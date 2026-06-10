import 'package:flutter/material.dart';
import 'package:flutter_it/flutter_it.dart';
import 'package:yaru/yaru.dart';

import '../../app/routing_manager.dart';
import '../../settings/settings_manager.dart';
import 'icons.dart';

class NavBackButton extends StatelessWidget with WatchItMixin {
  const NavBackButton({super.key});

  @override
  Widget build(BuildContext context) {
    void onTap() {
      di<SettingsManager>().scrollIndex = 0;
      di<RoutingManager>().pop();
    }

    final useYaruTheme = watchPropertyValue(
      (SettingsManager m) => m.useYaruTheme,
    );

    if (useYaruTheme) {
      return YaruBackButton(
        style: YaruBackButtonStyle.rounded,
        onPressed: onTap,
        icon: Icon(Iconz.goBack),
      );
    }
    return Center(child: BackButton(onPressed: onTap));
  }
}
