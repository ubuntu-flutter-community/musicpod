import 'package:flutter/material.dart';
import 'package:flutter_it/flutter_it.dart';
import 'package:media_kit_video/media_kit_video.dart';

import '../../app/app_manager.dart';
import '../../common/data/audio.dart';
import '../../common/view/icons.dart';
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
  });
  final Audio? audio;
  final double size;
  final bool? isVideo;

  @override
  State<BottomPlayerImage> createState() => _BottomPlayerImageState();
}

class _BottomPlayerImageState extends State<BottomPlayerImage> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final fullWindowMode = watchValue((AppManager m) => m.fullWindowMode);

    Widget child;

    final fallBackImage = PlayerFallBackImage(
      audioType: widget.audio?.audioType,
      height: widget.size,
      width: widget.size,
    );
    if (fullWindowMode) {
      child = SizedBox.square(dimension: widget.size);
    } else if (widget.isVideo == true) {
      child = RepaintBoundary(
        child: MouseRegion(
          cursor: SystemMouseCursors.click,
          child: GestureDetector(
            onTap: () => di<AppManager>().toggleFullWindowMode(),
            child: Video(
              height: widget.size,
              width: widget.size,
              filterQuality: FilterQuality.medium,
              controller: di<PlayerModel>().controller,
              controls: (state) {
                return const SizedBox.shrink();
              },
            ),
          ),
        ),
      );
    } else if (widget.audio?.canHaveLocalCover == true) {
      child = LocalCover(
        key: ValueKey(widget.audio!.path),
        albumId: widget.audio!.albumDbId!,
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
          if (_hovered || fullWindowMode)
            Positioned.fill(
              child: Container(
                color: fullWindowMode
                    ? Colors.transparent
                    : const Color.fromARGB(192, 0, 0, 0),
                child: Center(
                  child: IconButton(
                    onPressed: () => di<AppManager>().toggleFullWindowMode(),
                    icon: Icon(
                      fullWindowMode ? Iconz.fullScreenExit : Iconz.fullScreen,
                      color: fullWindowMode ? null : Colors.white,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
