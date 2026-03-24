import 'package:flutter/material.dart';
import 'package:flutter_it/flutter_it.dart';

import '../../common/data/audio.dart';
import '../../common/view/copy_clipboard_content.dart';
import '../../common/view/icons.dart';
import '../../common/view/snackbars.dart';
import '../../l10n/l10n.dart';
import '../../player/mpv_metadata_manager.dart';

class RadioPageCopyHistoryButton extends StatelessWidget with WatchItMixin {
  const RadioPageCopyHistoryButton({super.key, required this.station});

  final Audio station;

  @override
  Widget build(BuildContext context) => IconButton(
    tooltip: context.l10n.copyToClipBoard,
    onPressed: () {
      showSnackBar(
        context: context,
        content: SingleChildScrollView(
          child: CopyClipboardContent(
            text: di<MpvMetadataManager>().getMpvMetaDataHistoryList(
              filter: station.title,
            ),
            showActions: false,
          ),
        ),
      );
    },
    icon: Icon(Iconz.copy),
  );
}
