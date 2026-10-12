import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:media_kit_video/media_kit_video.dart';

import '../../app/full_window_mode_manager.dart';
import '../../common/data/audio.dart';
import '../../common/view/icons.dart';
import '../../dependencies.dart';
import '../../local_audio/view/local_cover.dart';
import '../service/player_service.dart';
import 'player_fall_back_image.dart';
import 'player_remote_source_image.dart';

class BottomPlayerImage extends ConsumerStatefulWidget {
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
  ConsumerState<BottomPlayerImage> createState() => _BottomPlayerImageState();
}

class _BottomPlayerImageState extends ConsumerState<BottomPlayerImage> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final fullWindowMode = ref.watch(fullWindowModeManagerProvider);

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
            onTap: () => ref
                .read(fullWindowModeManagerProvider.notifier)
                .toggleFullWindowMode(),
            child: Video(
              height: widget.size,
              width: widget.size,
              filterQuality: FilterQuality.medium,
              controller: di<PlayerService>().controller,
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

    return RepaintBoundary(
      child: MouseRegion(
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
                      onPressed: () => ref
                          .read(fullWindowModeManagerProvider.notifier)
                          .toggleFullWindowMode(),
                      icon: Icon(
                        fullWindowMode
                            ? Iconz.fullScreenExit
                            : Iconz.fullScreen,
                        color: fullWindowMode ? null : Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
