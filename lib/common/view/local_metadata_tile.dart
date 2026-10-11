import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:yaru/yaru.dart';

import '../../extensions/build_context_x.dart';
import '../../l10n/app_localizations.dart';
import '../../local_audio/manager/change_local_meta_data_manager.dart';
import '../../local_audio/data/change_metadata_capsule.dart';
import '../data/audio.dart';
import 'icons.dart';
import 'ui_constants.dart';

class LocalMetadataTile extends ConsumerStatefulWidget {
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
  ConsumerState<LocalMetadataTile> createState() => _LocalMetadataTileState();
}

class _LocalMetadataTileState extends ConsumerState<LocalMetadataTile> {
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: _initText());
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
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
    final metaState = ref.watch(changeLocalMetaDataManagerProvider(widget.audio));
    final changedAudio = metaState.savedAudio;

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

    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: kLargestSpace),
      subtitle: TextField(
        controller: _controller,
        onSubmitted: updateDraft,
        onChanged: updateDraft,
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
                onPressed: () => ref
                    .read(changeLocalMetaDataManagerProvider(widget.audio).notifier)
                    .save(),
              );
            },
          ),
          label: Text(widget.type.localize(context.l10n)),
        ),
      ),
    );
  }

  void updateDraft(String text) {
    final notifier =
        ref.read(changeLocalMetaDataManagerProvider(widget.audio).notifier);
    switch (widget.type) {
      case LocalMetadataTileType.title:
        notifier.updateDraft(ChangeMetadataCapsule(title: text));
      case LocalMetadataTileType.album:
        notifier.updateDraft(ChangeMetadataCapsule(album: text));
      case LocalMetadataTileType.artist:
        notifier.updateDraft(ChangeMetadataCapsule(artist: text));
      case LocalMetadataTileType.trackNumber:
        notifier.updateDraft(ChangeMetadataCapsule(trackNumber: text));
      case LocalMetadataTileType.diskNumber:
        notifier.updateDraft(ChangeMetadataCapsule(discNumber: text));
      case LocalMetadataTileType.totalDisks:
        notifier.updateDraft(ChangeMetadataCapsule(discTotal: text));
      case LocalMetadataTileType.genre:
        notifier.updateDraft(ChangeMetadataCapsule(genre: text));
    }
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
