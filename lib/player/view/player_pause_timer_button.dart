import 'package:flutter/material.dart';
import 'package:watch_it/watch_it.dart';
import 'package:yaru/yaru.dart';

import '../../common/view/icons.dart';
import '../../common/view/modals.dart';
import '../../common/view/snackbars.dart';
import '../../common/view/theme.dart';
import '../../common/view/ui_constants.dart';
import '../../extensions/build_context_x.dart';
import '../../extensions/duration_x.dart';
import '../../extensions/taget_platform_x.dart';
import '../../l10n/l10n.dart';
import '../player_model.dart';

class PlayerPauseTimerButton extends StatelessWidget {
  const PlayerPauseTimerButton({super.key, this.iconColor});

  final Color? iconColor;

  @override
  Widget build(BuildContext context) => IconButton(
    tooltip: context.l10n.schedulePlaybackStopTimer,
    onPressed: () => showModal(
      context: context,
      mode: ModalMode.platformModalMode,
      content: isMobile ? const _BottomSheet() : const _Dialog(),
    ),
    icon: Icon(Iconz.sleep, color: iconColor),
  );
}

class _Dialog extends StatefulWidget {
  const _Dialog();

  @override
  State<_Dialog> createState() => _DialogState();
}

class _DialogState extends State<_Dialog> {
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
          onPressed: Navigator.of(context).pop,
          child: Text(context.l10n.cancel),
        ),
        ElevatedButton(
          onPressed: () {
            final duration = Duration(
              hours: _timeOfDay.hour - TimeOfDay.now().hour,
              minutes: _timeOfDay.minute - TimeOfDay.now().minute,
            );
            di<PlayerModel>().setTimer(duration);
            showSnackBar(
              context: context,
              content: Text(
                context.l10n.playbackWillStopIn(
                  duration.formattedTime,
                  _timeOfDay.format(context),
                ),
              ),
            );
            Navigator.of(context).pop();
          },
          child: Text(context.l10n.ok),
        ),
      ],
    );
  }
}

class _BottomSheet extends StatefulWidget {
  const _BottomSheet();

  @override
  State<_BottomSheet> createState() => _BottomSheetState();
}

class _BottomSheetState extends State<_BottomSheet> {
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
                              onPressed: Navigator.of(context).pop,
                              child: Text(context.l10n.cancel),
                            ),
                            ElevatedButton(
                              onPressed: () {
                                final duration = Duration(
                                  hours: _timeOfDay.hour - TimeOfDay.now().hour,
                                  minutes:
                                      _timeOfDay.minute -
                                      TimeOfDay.now().minute,
                                );
                                di<PlayerModel>().setTimer(duration);
                                showSnackBar(
                                  context: context,
                                  content: Text(
                                    context.l10n.playbackWillStopIn(
                                      duration.formattedTime,
                                      _timeOfDay.format(context),
                                    ),
                                  ),
                                );
                                Navigator.of(context).pop();
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
