import 'package:flutter/material.dart';
import 'package:watch_it/watch_it.dart';
import 'package:yaru/yaru.dart';

import '../../common/view/common_widgets.dart';
import '../../common/view/icons.dart';
import '../../common/view/snackbars.dart';
import '../../extensions/duration_x.dart';
import '../../l10n/l10n.dart';
import '../../player/player_model.dart';

class PodcastTimerButton extends StatelessWidget {
  const PodcastTimerButton({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: () => showDialog(
        context: context,
        builder: (context) => const _Dialog(),
      ),
      icon: Icon(Iconz().sleep),
    );
  }
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
        ImportantButton(
          onPressed: () {
            final duration = Duration(
              hours: _timeOfDay.hour - TimeOfDay.now().hour,
              minutes: _timeOfDay.minute - TimeOfDay.now().minute,
            );
            di<PlayerModel>().setTimer(duration);
            showSnackBar(
              context: context,
              content: Text(
                '${context.l10n.playbackWillStopIn}${duration.formattedTime} (${_timeOfDay.format(context)})',
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
