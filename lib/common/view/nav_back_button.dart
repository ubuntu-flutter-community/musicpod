import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:yaru/yaru.dart';

import '../../app/routing_manager.dart';
import '../../dependencies.dart';
import '../../extensions/platform_x.dart';
import '../../settings/data/shared_preferences_keys.dart';
import '../../settings/manager/settings_manager.dart';
import 'icons.dart';

class NavBackButton extends ConsumerWidget {
  const NavBackButton({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    void onTap() {
      ref.read(settingsScrollIndexProvider.notifier).set(0);
      di<RoutingManager>().pop();
    }

    final useYaruTheme =
        ref.watch(settingsBoolManagerProvider(SPKeys.useYaruTheme)) ?? isLinux;

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
