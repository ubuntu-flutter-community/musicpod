import 'package:flutter/material.dart';
import 'package:flutter_it/flutter_it.dart';
import 'package:yaru/yaru.dart';

import '../../extensions/build_context_x.dart';
import '../../l10n/app_localizations.dart';
import '../../local_audio/change_local_meta_data_manager.dart';
import '../../local_audio/data/change_metadata_capsule.dart';
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
  Widget build(BuildContext context) {
    final manager = di<ChangeLocalMetaDataManager>(param1: widget.audio);

    final changedAudio = watch(manager.command).value;

    final audioChangePersisted =
        changedAudio != null &&
        switch (widget.type) {
          LocalMetadataTileType.title =>
            changedAudio.title != widget.audio.title &&
                widget.audio.title != null,
          LocalMetadataTileType.album =>
            changedAudio.album != widget.audio.album &&
                widget.audio.album != null,
          LocalMetadataTileType.artist =>
            changedAudio.artist != widget.audio.artist &&
                widget.audio.artist != null,
          LocalMetadataTileType.trackNumber =>
            changedAudio.trackNumber != widget.audio.trackNumber &&
                widget.audio.trackNumber != null,
          LocalMetadataTileType.diskNumber =>
            changedAudio.discNumber != widget.audio.discNumber &&
                widget.audio.discNumber != null,
          LocalMetadataTileType.totalDisks =>
            changedAudio.discTotal != widget.audio.discTotal &&
                widget.audio.discTotal != null,
          LocalMetadataTileType.genre =>
            changedAudio.genre != widget.audio.genre &&
                widget.audio.genre != null,
        };

    onDispose(() {
      _controller.dispose();
    });

    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: kLargestSpace),
      subtitle: TextField(
        controller: _controller,
        onSubmitted: (text) => updateDraft(text, manager),
        onChanged: (text) => updateDraft(text, manager),
        decoration: InputDecoration(
          suffixIcon: ListenableBuilder(
            listenable: _controller,
            builder: (context, child) {
              final thisFieldWasChanged =
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
                icon: thisFieldWasChanged && !audioChangePersisted
                    ? Icon(Iconz.download, color: context.colorScheme.primary)
                    : YaruAnimatedVectorIcon(
                        YaruAnimatedIcons.ok_filled,
                        color: audioChangePersisted
                            ? context.colorScheme.success
                            : context.colorScheme.onSurface,
                      ),
                onPressed: manager.command.run,
              );
            },
          ),
          label: Text(widget.type.localize(context.l10n)),
        ),
      ),
    );
  }

  void updateDraft(String text, ChangeLocalMetaDataManager manager) {
    return switch (widget.type) {
      LocalMetadataTileType.title => manager.updateDraft(
        ChangeMetadataCapsule(title: text),
      ),
      LocalMetadataTileType.album => manager.updateDraft(
        ChangeMetadataCapsule(album: text),
      ),
      LocalMetadataTileType.artist => manager.updateDraft(
        ChangeMetadataCapsule(artist: text),
      ),
      LocalMetadataTileType.trackNumber => manager.updateDraft(
        ChangeMetadataCapsule(trackNumber: text),
      ),
      LocalMetadataTileType.diskNumber => manager.updateDraft(
        ChangeMetadataCapsule(discNumber: text),
      ),
      LocalMetadataTileType.totalDisks => manager.updateDraft(
        ChangeMetadataCapsule(discTotal: text),
      ),
      LocalMetadataTileType.genre => manager.updateDraft(
        ChangeMetadataCapsule(genre: text),
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
