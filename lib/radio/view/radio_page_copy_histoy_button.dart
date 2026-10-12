import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../common/data/audio.dart';
import '../../common/view/copy_clipboard_content.dart';
import '../../common/view/icons.dart';
import '../../extensions/build_context_x.dart';
import '../../player/manager/mpv_metadata_history_manager.dart';

class RadioPageCopyHistoryButton extends ConsumerWidget {
  const RadioPageCopyHistoryButton({super.key, required this.station});

  final Audio station;

  @override
  Widget build(BuildContext context, WidgetRef ref) => IconButton(
    tooltip: context.l10n.copyToClipBoard,
    onPressed: () => context.toast(
      SingleChildScrollView(
        child: CopyClipboardContent(
          text: ref
              .read(mpvMetadataHistoryManagerProvider.notifier)
              .getHistoryList(filter: station.title),
          showActions: false,
        ),
      ),
    ),
    icon: Icon(Iconz.copy),
  );
}
