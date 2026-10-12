import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../common/view/common_control_panel.dart';
import '../../extensions/build_context_x.dart';
import '../../settings/data/shared_preferences_keys.dart';
import '../../settings/manager/settings_manager.dart';
import '../data/local_audio_view.dart';
import '../manager/local_audio_manager.dart';

class LocalAudioControlPanel extends ConsumerWidget {
  const LocalAudioControlPanel({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final index =
        ref.watch(settingsIntManagerProvider(SPKeys.localAudioIndex)) ?? 0;

    final importing = ref.watch(
      localAudioManagerProvider.select((s) => s.isLoading),
    );

    return CommonControlPanel(
      labels: LocalAudioView.values
          .map((e) => Text(e.localize(context.l10n)))
          .toList(),
      isSelected: LocalAudioView.values
          .map(
            (e) =>
                e ==
                LocalAudioView.values[index.clamp(
                  0,
                  LocalAudioView.values.length - 1,
                )],
          )
          .toList(),
      onSelected: importing
          ? null
          : (idx) => ref
                .read(
                  settingsIntManagerProvider(SPKeys.localAudioIndex).notifier,
                )
                .set(idx),
    );
  }
}
