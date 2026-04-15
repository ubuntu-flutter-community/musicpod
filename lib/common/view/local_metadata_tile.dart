import 'package:flutter/material.dart';
import 'package:flutter_it/flutter_it.dart';
import 'package:yaru/yaru.dart';

import '../../extensions/build_context_x.dart';
import '../../l10n/app_localizations.dart';
import '../../l10n/l10n.dart';
import '../../local_audio/data/change_metadata_capsule.dart';
import '../../local_audio/local_audio_manager.dart';
import '../data/audio.dart';
import 'icons.dart';
import 'ui_constants.dart';

class LocalMetadataTile extends StatefulWidget with WatchItStatefulWidgetMixin {
  const LocalMetadataTile.title({super.key, required this.audio, this.pageId})
    : type = LocalMetadataTileType.title;

  const LocalMetadataTile.album({super.key, required this.audio, this.pageId})
    : type = LocalMetadataTileType.album;

  const LocalMetadataTile.artist({super.key, required this.audio, this.pageId})
    : type = LocalMetadataTileType.artist;

  const LocalMetadataTile.trackNumber({
    super.key,
    required this.audio,
    this.pageId,
  }) : type = LocalMetadataTileType.trackNumber;

  const LocalMetadataTile.diskNumber({
    super.key,
    required this.audio,
    this.pageId,
  }) : type = LocalMetadataTileType.diskNumber;

  const LocalMetadataTile.totalDisks({
    super.key,
    required this.audio,
    this.pageId,
  }) : type = LocalMetadataTileType.totalDisks;

  const LocalMetadataTile.genre({super.key, required this.audio, this.pageId})
    : type = LocalMetadataTileType.genre;

  final LocalMetadataTileType type;
  final Audio audio;
  final String? pageId;

  @override
  State<LocalMetadataTile> createState() => _LocalMetadataTileState();
}

class _LocalMetadataTileState extends State<LocalMetadataTile> {
  late TextEditingController _controller;
  bool pendingLocalChange = false;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: _initText());
  }

  String _initText([Audio? newAudio]) => switch (widget.type) {
    LocalMetadataTileType.title => (newAudio ?? widget.audio).title ?? '',
    LocalMetadataTileType.album => (newAudio ?? widget.audio).album ?? '',
    LocalMetadataTileType.artist => (newAudio ?? widget.audio).artist ?? '',
    LocalMetadataTileType.trackNumber =>
      (newAudio ?? widget.audio).trackNumber == null
          ? ''
          : (newAudio ?? widget.audio).trackNumber.toString(),
    LocalMetadataTileType.diskNumber =>
      (newAudio ?? widget.audio).discNumber == null
          ? ''
          : (newAudio ?? widget.audio).discNumber.toString(),
    LocalMetadataTileType.totalDisks =>
      (newAudio ?? widget.audio).discTotal == null
          ? ''
          : (newAudio ?? widget.audio).discTotal.toString(),
    LocalMetadataTileType.genre => (newAudio ?? widget.audio).genre ?? '',
  };

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    registerHandler(
      select: (LocalAudioManager m) => m.changeMetadataCommand,
      handler: (context, newValue, cancel) {
        if (newValue != null &&
            newValue.path == widget.audio.path &&
            pendingLocalChange) {
          _controller.text = _initText(newValue);
          pendingLocalChange = false;
          setState(() {});
        }
      },
    );

    final localAudioMetadataChanging = watchValue(
      (LocalAudioManager m) => m.changeMetadataCommand.isRunning,
    );

    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: kLargestSpace),
      subtitle: TextField(
        enabled: !localAudioMetadataChanging,
        controller: _controller,
        onSubmitted: onSubmitted,
        onChanged: (_) => setState(() => pendingLocalChange = true),
        decoration: InputDecoration(
          suffixIcon: ListenableBuilder(
            listenable: _controller,
            builder: (context, child) {
              final wasChanged =
                  _controller.text.isNotEmpty &&
                  _controller.text !=
                      switch (widget.type) {
                        LocalMetadataTileType.title => widget.audio.title,
                        LocalMetadataTileType.album => widget.audio.album,
                        LocalMetadataTileType.artist => widget.audio.artist,
                        LocalMetadataTileType.trackNumber =>
                          widget.audio.trackNumber?.toString(),
                        LocalMetadataTileType.diskNumber =>
                          widget.audio.discNumber?.toString(),
                        LocalMetadataTileType.totalDisks =>
                          widget.audio.discTotal?.toString(),
                        LocalMetadataTileType.genre => widget.audio.genre,
                      };
              return IconButton(
                style: IconButton.styleFrom(
                  shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.only(
                      topRight: Radius.circular(kYaruButtonRadius),
                      bottomRight: Radius.circular(kYaruButtonRadius),
                    ),
                  ),
                ),
                icon: pendingLocalChange
                    ? Icon(Iconz.download, color: context.colorScheme.primary)
                    : YaruAnimatedVectorIcon(
                        key: ValueKey(pendingLocalChange),
                        YaruAnimatedIcons.ok_filled,
                        color: wasChanged
                            ? context.colorScheme.success
                            : context.colorScheme.onSurface,
                      ),
                onPressed: () => onSubmitted(_controller.text),
              );
            },
          ),
          label: Text(widget.type.localize(context.l10n)),
        ),
      ),
    );
  }

  void onSubmitted(String text) {
    final manager = di<LocalAudioManager>();

    if (widget.audio.albumDbId != null) {
      manager.findAlbumCommand(widget.audio.albumDbId!, force: true).run();
    }

    return switch (widget.type) {
      LocalMetadataTileType.title => manager.changeMetadataCommand.run(
        ChangeMetadataCapsule(audio: widget.audio, title: text),
      ),
      LocalMetadataTileType.album => manager.changeMetadataCommand.run(
        ChangeMetadataCapsule(audio: widget.audio, album: text),
      ),
      LocalMetadataTileType.artist => manager.changeMetadataCommand.run(
        ChangeMetadataCapsule(audio: widget.audio, artist: text),
      ),
      LocalMetadataTileType.trackNumber => manager.changeMetadataCommand.run(
        ChangeMetadataCapsule(audio: widget.audio, trackNumber: text),
      ),
      LocalMetadataTileType.diskNumber => manager.changeMetadataCommand.run(
        ChangeMetadataCapsule(audio: widget.audio, discNumber: text),
      ),
      LocalMetadataTileType.totalDisks => manager.changeMetadataCommand.run(
        ChangeMetadataCapsule(audio: widget.audio, discTotal: text),
      ),
      LocalMetadataTileType.genre => manager.changeMetadataCommand.run(
        ChangeMetadataCapsule(audio: widget.audio, genre: text),
      ),
    };
  }
}

enum LocalMetadataTileType {
  title,
  album,
  artist,
  trackNumber,
  diskNumber,
  totalDisks,
  genre;

  String localize(AppLocalizations l10n) => switch (this) {
    title => l10n.title,
    album => l10n.album,
    artist => l10n.artist,
    trackNumber => l10n.trackNumber,
    diskNumber => l10n.diskNumber,
    totalDisks => l10n.totalDisks,
    genre => l10n.genre,
  };
}
