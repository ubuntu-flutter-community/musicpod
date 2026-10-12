import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:yaru/yaru.dart';

import '../../extensions/platform_x.dart';
import '../../settings/data/shared_preferences_keys.dart';
import '../../settings/manager/settings_manager.dart';

class CommonSwitch extends ConsumerWidget {
  const CommonSwitch({super.key, required this.value, this.onChanged});

  final bool value;
  final void Function(bool)? onChanged;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final useYaruTheme =
        ref.watch(settingsBoolManagerProvider(SPKeys.useYaruTheme)) ?? isLinux;
    return useYaruTheme
        ? YaruSwitch(value: value, onChanged: onChanged)
        : Switch(value: value, onChanged: onChanged);
  }
}

class CommonCheckBox extends ConsumerWidget {
  const CommonCheckBox({super.key, required this.value, this.onChanged});

  final bool value;
  final void Function(bool?)? onChanged;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final useYaruTheme =
        ref.watch(settingsBoolManagerProvider(SPKeys.useYaruTheme)) ?? isLinux;
    return useYaruTheme
        ? YaruCheckbox(value: value, onChanged: onChanged)
        : Checkbox(value: value, onChanged: onChanged);
  }
}
