import 'package:flutter/material.dart';
import 'package:lrc/lrc.dart';
import 'package:watch_it/watch_it.dart';

import '../../common/data/audio.dart';
import '../../common/view/ui_constants.dart';
import '../../extensions/build_context_x.dart';
import '../../extensions/taget_platform_x.dart';
import '../../local_audio/view/local_cover.dart';
import '../../settings/settings_model.dart';
import '../player_model.dart';
import 'audio_visualizer.dart';
import 'player_fall_back_image.dart';
import 'player_remote_source_image.dart';

class FullHeightPlayerImage extends StatelessWidget with WatchItMixin {
  const FullHeightPlayerImage({
    super.key,
    this.fit,
    this.height,
    this.width,
    this.borderRadius,
    this.emptyFallBack = false,
    this.showAudioVisualizer = false,
  });

  final BoxFit? fit;
  final double? height, width;
  final BorderRadius? borderRadius;
  final bool emptyFallBack;
  final bool showAudioVisualizer;

  @override
  Widget build(BuildContext context) {
    final audio = watchPropertyValue((PlayerModel m) => m.audio);
    final showAudioVisualizer = watchPropertyValue(
      (PlayerModel m) => m.showAudioVisualizer && this.showAudioVisualizer,
    );
    final showPlayerLyrics = watchPropertyValue(
      (SettingsModel m) => m.showPlayerLyrics,
    );

    final size = context.isPortrait
        ? fullHeightPlayerImageSize
        : isMobile
        ? fullHeightPlayerImageSize / 3
        : fullHeightPlayerImageSize;
    final theHeight = height ?? size;
    final theWidth = width ?? size;

    final fallBackImage = PlayerFallBackImage(
      noIcon: emptyFallBack,
      audioType: audio?.audioType,
      height: theHeight,
      width: theWidth,
    );

    Widget image;
    if (audio?.canHaveLocalCover == true) {
      image = LocalCover(
        key: ValueKey(audio!.albumId!),
        albumId: audio.albumId!,
        path: audio.path!,
        width: theWidth,
        height: theHeight,
        fit: fit ?? BoxFit.fitHeight,
        fallback: fallBackImage,
      );
    } else {
      image = PlayerRemoteSourceImage(
        height: theHeight,
        width: theWidth,
        fit: fit,
        fallBackIcon: fallBackImage,
        errorIcon: fallBackImage,
      );
    }

    if (showAudioVisualizer) {
      return AudioVisualizer(height: height ?? 200);
    }

    if (showPlayerLyrics && audio != null) {
      return PlayerLyrics(audio: audio, size: size);
    }

    return SizedBox(
      height: theHeight,
      width: theWidth,
      child: ClipRRect(
        borderRadius: borderRadius ?? BorderRadius.circular(10),
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 200),
          child: image,
        ),
      ),
    );
  }
}

class PlayerLyrics extends StatefulWidget with WatchItStatefulWidgetMixin {
  const PlayerLyrics({super.key, required this.audio, required this.size});

  final Audio audio;
  final double size;

  @override
  State<PlayerLyrics> createState() => _PlayerLyricsState();
}

class _PlayerLyricsState extends State<PlayerLyrics> {
  List<LrcLine>? lrc;
  String? lyrcisString;

  @override
  void initState() {
    super.initState();

    if (widget.audio.lyrics != null) {
      if (widget.audio.lyrics!.isValidLrc) {
        lrc = Lrc.parse(widget.audio.lyrics!).lyrics;
      } else {
        lyrcisString = widget.audio.lyrics;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (lyrcisString != null) {
      return Text(lyrcisString!);
    }

    if (lrc == null || lrc!.isEmpty) {
      return const Text('no lyrcis found');
    }

    final position = watchPropertyValue((PlayerModel m) => m.position);
    final color = watchPropertyValue(
      (PlayerModel m) => m.color ?? context.colorScheme.primary,
    );

    return SizedBox(
      height: widget.size,
      width: widget.size,
      child: ListView.builder(
        itemCount: lrc!.length,
        itemBuilder: (context, index) {
          final line = lrc!.elementAt(index);
          return ListTile(
            selectedColor: color,
            selected: line.timestamp.inSeconds == position?.inSeconds,
            title: Text(line.lyrics),
          );
        },
      ),
    );
  }
}
