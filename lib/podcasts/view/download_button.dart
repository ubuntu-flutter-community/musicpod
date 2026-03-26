import 'package:flutter/material.dart';
import 'package:flutter_it/flutter_it.dart';
import 'package:yaru/constants.dart';

import '../../common/data/audio.dart';
import '../../common/view/icons.dart';
import '../../common/view/progress.dart';
import '../../extensions/build_context_x.dart';
import '../../extensions/taget_platform_x.dart';
import '../../extensions/theme_data_x.dart';
import '../../l10n/l10n.dart';
import '../../settings/settings_model.dart';
import '../download_model.dart';

class DownloadButton extends StatelessWidget with WatchItMixin {
  const DownloadButton({
    super.key,
    this.iconSize,
    required this.audio,
    required this.addPodcast,
    required this.hasDownload,
  });

  final double? iconSize;
  final Audio? audio;
  final void Function()? addPodcast;
  final bool hasDownload;

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final model = di<DownloadModel>();
    final value = watchPropertyValue(
      (DownloadModel m) => m.getValue(audio?.url),
    );

    final useYaruTheme = watchPropertyValue(
      (SettingsModel m) => m.useYaruTheme,
    );

    final radius =
        (useYaruTheme
            ? kYaruTitleBarItemHeight
            : isMobile
            ? 40
            : 35) /
        2;

    return Stack(
      alignment: Alignment.center,
      children: [
        SizedBox.square(
          dimension: (radius * 2) - 3,
          child: Progress(
            adaptive: false,
            padding: EdgeInsets.zero,
            value: value == null || value == 1.0 ? 0 : value,
            backgroundColor: Colors.transparent,
          ),
        ),
        IconButton(
          isSelected: hasDownload,
          tooltip: audio?.path != null
              ? context.l10n.removeDownloadEpisode
              : context.l10n.downloadEpisode,
          icon: Icon(
            hasDownload ? Iconz.downloadFilled : Iconz.download,
            color: hasDownload ? theme.colorScheme.primary : null,
          ),
          onPressed: () {
            if (hasDownload) {
              model.deleteDownload(audio: audio);
            } else {
              addPodcast?.call();
              model.startDownload(
                finishedMessage: context.l10n.downloadFinished(
                  audio?.title ?? '',
                ),
                canceledMessage: context.l10n.downloadCancelled(
                  audio?.title ?? '',
                ),
                audio: audio,
              );
            }
          },
          iconSize: iconSize,
          color: hasDownload
              ? theme.contrastyPrimary
              : theme.colorScheme.onSurface,
        ),
      ],
    );
  }
}
