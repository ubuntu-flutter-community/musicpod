import 'package:flutter/material.dart';
import 'package:flutter_it/flutter_it.dart';
import 'package:yaru/yaru.dart';

import '../../settings/settings_model.dart';

class CommonSwitch extends StatelessWidget with WatchItMixin {
  const CommonSwitch({super.key, required this.value, this.onChanged});

  final bool value;
  final void Function(bool)? onChanged;

  @override
  Widget build(BuildContext context) {
    final useYaruTheme = watchPropertyValue(
      (SettingsModel m) => m.useYaruTheme,
    );
    return useYaruTheme
        ? YaruSwitch(value: value, onChanged: onChanged)
        : Switch(value: value, onChanged: onChanged);
  }
}

class CommonCheckBox extends StatelessWidget with WatchItMixin {
  const CommonCheckBox({super.key, required this.value, this.onChanged});

  final bool value;
  final void Function(bool?)? onChanged;

  @override
  Widget build(BuildContext context) {
    final useYaruTheme = watchPropertyValue(
      (SettingsModel m) => m.useYaruTheme,
    );
    return useYaruTheme
        ? YaruCheckbox(value: value, onChanged: onChanged)
        : Checkbox(value: value, onChanged: onChanged);
  }
}
