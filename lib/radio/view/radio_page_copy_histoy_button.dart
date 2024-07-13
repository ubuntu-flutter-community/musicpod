import 'package:flutter/material.dart';
import 'package:watch_it/watch_it.dart';

import '../../l10n/l10n.dart';
import '../../common/view/copy_clipboard_content.dart';
import '../../common/view/icons.dart';
import '../../common/view/snackbars.dart';
import '../../common/data/audio.dart';
import '../../player/player_model.dart';

class RadioPageCopyHistoryButton extends StatelessWidget with WatchItMixin {
  const RadioPageCopyHistoryButton({super.key, required this.station});

  final Audio station;

  @override
  Widget build(BuildContext context) {
    watchPropertyValue(
      (PlayerModel m) => m.filteredRadioHistory(filter: station.title),
    );
    final text = di<PlayerModel>().getRadioHistoryList(filter: station.title);
    return IconButton(
      tooltip: context.l10n.copyToClipBoard,
      onPressed: text.isEmpty
          ? null
          : () {
              showSnackBar(
                context: context,
                content: SingleChildScrollView(
                  child: CopyClipboardContent(
                    text: text,
                    showActions: false,
                  ),
                ),
              );
            },
      icon: Icon(Iconz().copy),
    );
  }
}
