import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/full_window_mode_manager.dart';
import '../../app/routing_manager.dart';
import '../../app/page_ids.dart';
import '../../common/view/icons.dart';
import '../../extensions/build_context_x.dart';

import '../manager/settings_manager.dart';
import 'settings_tile.dart';

enum _SettingsButtonMode { icon, important, tile }

class SettingsButton extends ConsumerWidget {
  const SettingsButton.icon({super.key, this.scrollIndex = 0})
    : _mode = _SettingsButtonMode.icon;

  const SettingsButton.important({super.key, this.scrollIndex = 0})
    : _mode = _SettingsButtonMode.important;

  const SettingsButton.tile({super.key, this.scrollIndex = 0})
    : _mode = _SettingsButtonMode.tile;

  final _SettingsButtonMode _mode;
  final int scrollIndex;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    Future<void> onPressed() async {
      await ref
          .read(fullWindowModeManagerProvider.notifier)
          .setFullWindowMode(false);
      await Future.delayed(const Duration(milliseconds: 300));
      ref.read(settingsScrollIndexProvider.notifier).set(scrollIndex);
      await ref
          .read(routingManagerProvider.notifier)
          .push(pageId: PageIDs.settings);
    }

    return switch (_mode) {
      _SettingsButtonMode.icon => IconButton(
        tooltip: l10n.settings,
        onPressed: onPressed,
        icon: Icon(Iconz.settings, semanticLabel: l10n.settings),
      ),
      _SettingsButtonMode.important => ElevatedButton(
        onPressed: onPressed,
        child: Text(context.l10n.settings),
      ),
      _SettingsButtonMode.tile => const SettingsTile(),
    };
  }
}
