import 'package:flutter/material.dart';
import 'package:watch_it/watch_it.dart';
import 'package:yaru/yaru.dart';

import '../../settings/settings_model.dart';

class DropDownArrow extends StatelessWidget with WatchItMixin {
  const DropDownArrow({super.key});

  @override
  Widget build(BuildContext context) {
    final useYaruTheme =
        watchPropertyValue((SettingsModel m) => m.useYaruTheme);
    return useYaruTheme
        ? const Icon(YaruIcons.pan_down)
        : const Icon(Icons.arrow_drop_down);
  }
}
