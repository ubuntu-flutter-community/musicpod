import 'package:flutter/material.dart';
import 'package:flutter_it/flutter_it.dart';

import '../../common/data/audio.dart';
import '../../common/view/copy_clipboard_content.dart';
import '../../common/view/icons.dart';
import '../../common/view/snackbars.dart';
import '../../l10n/l10n.dart';
import '../radio_model.dart';

class RadioPageCopyHistoryButton extends StatelessWidget with WatchItMixin {
  const RadioPageCopyHistoryButton({super.key, required this.station});

  final Audio station;

  @override
  Widget build(BuildContext context) {
    watchPropertyValue(
      (RadioModel m) => m.getRadioHistoryLength(filter: station.title),
    );
    final text = di<RadioModel>().getRadioHistoryList(filter: station.title);
    return IconButton(
      tooltip: context.l10n.copyToClipBoard,
      onPressed: text.isEmpty
          ? null
          : () {
              showSnackBar(
                context: context,
                content: SingleChildScrollView(
                  child: CopyClipboardContent(text: text, showActions: false),
                ),
              );
            },
      icon: Icon(Iconz.copy),
    );
  }
}
