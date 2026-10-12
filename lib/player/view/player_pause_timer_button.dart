import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:yaru/yaru.dart';

import '../../common/view/icons.dart';
import '../../common/view/modals.dart';
import '../../common/view/theme.dart';
import '../../common/view/ui_constants.dart';
import '../../extensions/build_context_x.dart';
import '../../extensions/duration_x.dart';
import '../../extensions/platform_x.dart';
import '../manager/pause_timer_manager.dart';

Duration durationUntilNextTimeOfDay({
  required TimeOfDay targetTime,
  required DateTime now,
}) {
  var targetDateTime = DateTime(
    now.year,
    now.month,
    now.day,
    targetTime.hour,
    targetTime.minute,
  );

  if (!targetDateTime.isAfter(now)) {
    targetDateTime = targetDateTime.add(const Duration(days: 1));
  }

  return targetDateTime.difference(now);
}

class PlayerPauseTimerButton extends ConsumerWidget {
  const PlayerPauseTimerButton({super.key, this.iconColor});

  final Color? iconColor;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isTimerActive = ref.watch(pauseTimerManagerProvider);
    return IconButton(
      isSelected: isTimerActive,
      tooltip: context.l10n.schedulePlaybackStopTimer,
      onPressed: () => showModal(
        context: context,
        mode: ModalMode.platformModalMode,
        content: isMobile ? const _BottomSheet() : const _Dialog(),
      ),
      icon: Icon(
        isTimerActive ? Iconz.sleepFilled : Iconz.sleep,
        color: iconColor,
      ),
    );
  }
}

class _Dialog extends ConsumerStatefulWidget {
  const _Dialog();

  @override
  ConsumerState<_Dialog> createState() => _DialogState();
}

class _DialogState extends ConsumerState<_Dialog> {
  TimeOfDay _timeOfDay = TimeOfDay.now();
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      content: YaruTimeEntry(
        autofocus: true,
        initialTimeOfDay: _timeOfDay,
        onChanged: (value) {
          if (value != null) {
            setState(() => _timeOfDay = value);
          }
        },
      ),
      actions: [
        TextButton(
          onPressed: () {
            ref
                .read(pauseTimerManagerProvider.notifier)
                .setTimer(null, message: context.l10n.playbackTimerCancelled);
            context.pop();
          },
          child: Text(context.l10n.cancel),
        ),
        ElevatedButton(
          onPressed: () {
            final duration = durationUntilNextTimeOfDay(
              targetTime: _timeOfDay,
              now: DateTime.now(),
            );
            ref
                .read(pauseTimerManagerProvider.notifier)
                .setTimer(
                  duration,
                  message: context.l10n.playbackWasPausedByTimer,
                );
            context.toast(
              Text(
                context.l10n.playbackWillStopIn(
                  duration.formattedTime,
                  _timeOfDay.format(context),
                ),
              ),
            );
            context.pop();
          },
          child: Text(context.l10n.ok),
        ),
      ],
    );
  }
}

class _BottomSheet extends ConsumerStatefulWidget {
  const _BottomSheet();

  @override
  ConsumerState<_BottomSheet> createState() => _BottomSheetState();
}

class _BottomSheetState extends ConsumerState<_BottomSheet> {
  TimeOfDay _timeOfDay = TimeOfDay.now();
  @override
  Widget build(BuildContext context) {
    return BottomSheet(
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(kLargestSpace),
          child: Column(
            children: space(
              heightGap: kLargestSpace,
              children: [
                Text(
                  context.l10n.schedulePlaybackStopTimer,
                  style: context.textTheme.headlineSmall,
                ),
                YaruTimeEntry(
                  autofocus: true,
                  initialTimeOfDay: _timeOfDay,
                  onChanged: (value) {
                    if (value != null) {
                      setState(() => _timeOfDay = value);
                    }
                  },
                ),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Row(
                        children: space(
                          expandAll: true,
                          children: [
                            TextButton(
                              onPressed: () {
                                ref
                                    .read(pauseTimerManagerProvider.notifier)
                                    .setTimer(
                                      null,
                                      message:
                                          context.l10n.playbackTimerCancelled,
                                    );
                                context.pop();
                              },
                              child: Text(context.l10n.cancel),
                            ),
                            ElevatedButton(
                              onPressed: () {
                                final duration = durationUntilNextTimeOfDay(
                                  targetTime: _timeOfDay,
                                  now: DateTime.now(),
                                );
                                ref
                                    .read(pauseTimerManagerProvider.notifier)
                                    .setTimer(
                                      duration,
                                      message:
                                          context.l10n.playbackWasPausedByTimer,
                                    );
                                context.toast(
                                  Text(
                                    context.l10n.playbackWillStopIn(
                                      duration.formattedTime,
                                      _timeOfDay.format(context),
                                    ),
                                  ),
                                );
                                context.pop();
                              },
                              child: Text(context.l10n.ok),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
      onClosing: () {},
      enableDrag: false,
    );
  }
}
