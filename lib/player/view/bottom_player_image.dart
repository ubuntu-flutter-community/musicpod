import 'package:flutter/material.dart';
import 'package:media_kit_video/media_kit_video.dart';
import 'package:flutter_it/flutter_it.dart';

import '../../app/app_model.dart';
import '../../common/data/audio.dart';
import '../../common/data/audio_type.dart';
import '../../common/view/icons.dart';
import '../../l10n/l10n.dart';
import '../../local_audio/view/local_cover.dart';
import '../player_model.dart';
import 'player_fall_back_image.dart';
import 'player_remote_source_image.dart';

class BottomPlayerImage extends StatefulWidget with WatchItStatefulWidgetMixin {
  const BottomPlayerImage({
    super.key,
    this.audio,
    required this.size,
    this.isVideo,
    required this.videoController,
    required this.isOnline,
  });
  final Audio? audio;
  final double size;
  final bool? isVideo;
  final VideoController videoController;
  final bool isOnline;

  @override
  State<BottomPlayerImage> createState() => _BottomPlayerImageState();
}

class _BottomPlayerImageState extends State<BottomPlayerImage> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    if (widget.isVideo == true) {
      return RepaintBoundary(
        child: MouseRegion(
          cursor: SystemMouseCursors.click,
          child: GestureDetector(
            onTap: () => di<AppModel>().setFullWindowMode(true),
            child: Video(
              height: widget.size,
              width: widget.size,
              filterQuality: FilterQuality.medium,
              controller: widget.videoController,
              controls: (state) {
                return const SizedBox.shrink();
              },
            ),
          ),
        ),
      );
    }

    Widget child;

    final fallBackImage = PlayerFallBackImage(
      audioType: widget.audio?.audioType,
      height: widget.size,
      width: widget.size,
    );

    if (widget.audio?.canHaveLocalCover == true) {
      child = LocalCover(
        key: ValueKey(widget.audio!.path),
        albumId: widget.audio!.albumId!,
        path: widget.audio!.path!,
        fit: BoxFit.cover,
        dimension: widget.size,
        fallback: fallBackImage,
      );
    } else {
      child = PlayerRemoteSourceImage(
        height: widget.size,
        width: widget.size,
        fit: BoxFit.cover,
        fallBackIcon: fallBackImage,
        errorIcon: fallBackImage,
      );
    }

    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: Stack(
        children: [
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 200),
            child: child,
          ),
          if (watchStream((PlayerModel s) => s.onlineArtError).data != null &&
              widget.audio?.audioType == AudioType.radio)
            Positioned(
              bottom: 5,
              right: 5,
              child: Padding(
                padding: const EdgeInsets.only(left: 5),
                child: Tooltip(
                  message: context.l10n.onlineArtError,
                  child: Icon(
                    Iconz.imageMissingFilled,
                    color: Colors.white,
                    shadows: [
                      const BoxShadow(offset: Offset(0, 1), blurRadius: 1),
                    ],
                  ),
                ),
              ),
            ),
          if (_hovered && widget.isOnline)
            Positioned.fill(
              child: Container(
                color: Colors.black45,
                child: Center(
                  child: IconButton(
                    onPressed: () => di<AppModel>().setFullWindowMode(true),
                    icon: Icon(Iconz.fullScreen, color: Colors.white),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
