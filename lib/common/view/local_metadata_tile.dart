import 'package:flutter/material.dart';
import 'package:watch_it/watch_it.dart';
import 'package:yaru/yaru.dart';

import '../../extensions/build_context_x.dart';
import '../../l10n/app_localizations.dart';
import '../../l10n/l10n.dart';
import '../../library/library_model.dart';
import '../../local_audio/local_audio_model.dart';
import '../data/audio.dart';
import 'icons.dart';
import 'ui_constants.dart';

class LocalMetadataTile extends StatefulWidget with WatchItStatefulWidgetMixin {
  const LocalMetadataTile.title({
    super.key,
    required this.audio,
    this.pageId,
  }) : type = LocalMetadataTileType.title;

  const LocalMetadataTile.album({
    super.key,
    required this.audio,
    this.pageId,
  }) : type = LocalMetadataTileType.album;

  const LocalMetadataTile.artist({
    super.key,
    required this.audio,
    this.pageId,
  }) : type = LocalMetadataTileType.artist;

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

  const LocalMetadataTile.genre({
    super.key,
    required this.audio,
    this.pageId,
  }) : type = LocalMetadataTileType.genre;

  final LocalMetadataTileType type;
  final Audio audio;
  final String? pageId;

  @override
  State<LocalMetadataTile> createState() => _LocalMetadataTileState();
}

class _LocalMetadataTileState extends State<LocalMetadataTile> {
  late TextEditingController _controller;
  bool wasChangedLocally = false;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(
      text: switch (widget.type) {
        LocalMetadataTileType.title => widget.audio.title ?? '',
        LocalMetadataTileType.album => widget.audio.album ?? '',
        LocalMetadataTileType.artist => widget.audio.artist ?? '',
        LocalMetadataTileType.trackNumber => widget.audio.trackNumber == null
            ? ''
            : widget.audio.trackNumber.toString(),
        LocalMetadataTileType.diskNumber => widget.audio.discNumber == null
            ? ''
            : widget.audio.discNumber.toString(),
        LocalMetadataTileType.totalDisks => widget.audio.discTotal == null
            ? ''
            : widget.audio.discTotal.toString(),
        LocalMetadataTileType.genre => widget.audio.genre.toString(),
      },
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    watchPropertyValue((LocalAudioModel m) => m.audios.hashCode);
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(
        horizontal: kLargestSpace,
      ),
      subtitle: TextField(
        controller: _controller,
        onSubmitted: onSubmitted,
        onChanged: (_) {
          setState(() {
            wasChangedLocally = true;
          });
        },
        decoration: InputDecoration(
          suffixIcon: ListenableBuilder(
            listenable: _controller,
            builder: (context, child) {
              final wasChanged = _controller.text.isNotEmpty &&
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
                icon: wasChangedLocally
                    ? Icon(
                        Iconz.download,
                        color: context.colorScheme.primary,
                      )
                    : YaruAnimatedVectorIcon(
                        key: ValueKey(wasChangedLocally),
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
    final model = di<LocalAudioModel>();
    setState(() {
      wasChangedLocally = false;
    });
    void onChange() {
      setState(() {});
      di<LibraryModel>().notifyListeners();
      di<LocalAudioModel>().notifyListeners();
    }

    return switch (widget.type) {
      LocalMetadataTileType.title => model.changeMetadata(
          widget.audio,
          title: text,
          onChange: onChange,
        ),
      LocalMetadataTileType.album => model.changeMetadata(
          widget.audio,
          album: text,
          onChange: onChange,
        ),
      LocalMetadataTileType.artist => model.changeMetadata(
          widget.audio,
          artist: text,
          onChange: onChange,
        ),
      LocalMetadataTileType.trackNumber => model.changeMetadata(
          widget.audio,
          trackNumber: text,
          onChange: onChange,
        ),
      LocalMetadataTileType.diskNumber => model.changeMetadata(
          widget.audio,
          discNumber: text,
          onChange: onChange,
        ),
      LocalMetadataTileType.totalDisks => model.changeMetadata(
          widget.audio,
          discTotal: text,
          onChange: onChange,
        ),
      LocalMetadataTileType.genre => model.changeMetadata(
          widget.audio,
          genre: text,
          onChange: onChange,
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
