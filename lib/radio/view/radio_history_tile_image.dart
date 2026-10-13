import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../common/view/icons.dart';
import '../../common/view/modals.dart';
import '../../common/view/mpv_metadata_dialog.dart';
import '../../common/view/progress.dart';
import '../../common/view/safe_network_image.dart';
import '../../common/view/ui_constants.dart';
import '../../extensions/build_context_x.dart';
import '../../extensions/platform_x.dart';
import '../../player/manager/mpv_metadata_history_manager.dart';
import '../manager/online_art_manager.dart';

class RadioHistoryTileImage extends ConsumerWidget {
  const RadioHistoryTileImage({
    super.key,
    required this.icyTitle,
    this.height = kAudioTrackWidth,
    this.width = kAudioTrackWidth,
    this.fit,
  });

  final String? icyTitle;

  final double height, width;
  final BoxFit? fit;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bR = BorderRadius.circular(4);
    final artAsync = ref.watch(onlineArtManagerProvider(icyTitle));
    final imageUrl = artAsync.value;
    final isLoading = artAsync.isLoading;
    final progressSize = (height * 0.4).clamp(14.0, 24.0);

    final Widget content;
    if (isLoading) {
      content = Center(
        child: SizedBox(
          width: progressSize,
          height: progressSize,
          child: const Progress(strokeWidth: 2),
        ),
      );
    } else if (imageUrl == null) {
      content = Center(child: Icon(Iconz.radio));
    } else {
      content = SafeNetworkImage(
        url: imageUrl,
        height: height,
        width: width,
        cacheHeight: (height * 2).toInt(),
        cacheWidth: (width * 2).toInt(),
        loadingWidget: Center(
          child: SizedBox(
            width: progressSize,
            height: progressSize,
            child: const Progress(strokeWidth: 2),
          ),
        ),
        errorWidget: Icon(Iconz.radio),
        filterQuality: FilterQuality.medium,
        fit: fit ?? BoxFit.fitHeight,
      );
    }

    return Tooltip(
      message: context.l10n.metadata,
      child: ClipRRect(
        borderRadius: bR,
        child: InkWell(
          borderRadius: bR,
          onTap: () {
            final metadata = ref
                .read(mpvMetadataHistoryManagerProvider.notifier)
                .getMetadata(icyTitle);
            if (metadata == null) return;
            showModal(
              mode: ModalMode.platformModalMode,
              context: context,
              content: isMobile
                  ? MpvMetadataDialog.bottomSheet(
                      image: imageUrl,
                      mpvMetaData: metadata,
                    )
                  : MpvMetadataDialog.dialog(
                      image: imageUrl,
                      mpvMetaData: metadata,
                    ),
            );
          },
          child: SizedBox(height: height, width: width, child: content),
        ),
      ),
    );
  }
}
