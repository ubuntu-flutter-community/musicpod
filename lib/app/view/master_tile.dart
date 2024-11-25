import 'package:flutter/material.dart';
import 'package:watch_it/watch_it.dart';
import 'package:yaru/yaru.dart';

import '../../common/data/audio_type.dart';
import '../../common/view/ui_constants.dart';
import '../../constants.dart';
import '../../extensions/build_context_x.dart';
import '../../library/library_model.dart';
import '../../player/player_model.dart';
import '../../common/view/icons.dart';
import '../../common/view/spaced_divider.dart';
import '../../radio/radio_model.dart';

class MasterTile extends StatelessWidget {
  const MasterTile({
    super.key,
    this.selected,
    this.leading,
    required this.title,
    this.subtitle,
    this.trailing,
    required this.libraryModel,
    required this.pageId,
    required this.onTap,
  });

  final bool? selected;
  final Widget? leading;
  final Widget? title;
  final Widget? subtitle;
  final Widget? trailing;
  final LibraryModel libraryModel;
  final String pageId;
  final void Function() onTap;

  @override
  Widget build(BuildContext context) {
    final yaruMasterTile = Padding(
      padding: pageId == kLocalAudioPageId
          ? const EdgeInsets.only(top: 5)
          : EdgeInsets.zero,
      child: YaruMasterTile(
        title: title,
        onTap: onTap,
        selected: selected,
        leading: leading,
        subtitle: subtitle,
        trailing: trailing,
      ),
    );

    final Widget tile;
    if (pageId == kNewPlaylistPageId) {
      tile = _FramedMasterTile(tile: yaruMasterTile);
    } else {
      tile = yaruMasterTile;
    }

    return _PlayAbleMasterTile(
      selected: selected,
      pageId: pageId,
      tile: tile,
      libraryModel: libraryModel,
    );
  }
}

class _FramedMasterTile extends StatelessWidget {
  const _FramedMasterTile({
    required this.tile,
  });

  final Widget tile;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SpacedDivider(
          top: 10,
          bottom: 10,
          right: 0,
          left: 0,
        ),
        tile,
        const SpacedDivider(
          top: 10,
          bottom: 10,
          right: 0,
          left: 0,
        ),
      ],
    );
  }
}

class _PlayAbleMasterTile extends StatefulWidget
    with WatchItStatefulWidgetMixin {
  const _PlayAbleMasterTile({
    required this.pageId,
    required this.tile,
    this.selected,
    required this.libraryModel,
  });

  final String pageId;
  final Widget tile;
  final bool? selected;
  final LibraryModel libraryModel;

  @override
  State<_PlayAbleMasterTile> createState() => __PlayAbleMasterTileState();
}

class __PlayAbleMasterTileState extends State<_PlayAbleMasterTile> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final audios = widget.libraryModel.getAudiosById(widget.pageId);

    if (audios == null || audios.isEmpty) {
      return widget.tile;
    }

    final isEnQueued = watchPropertyValue(
      (PlayerModel m) => m.queueName != null && m.queueName == widget.pageId,
    );
    final isPlaying = watchPropertyValue((PlayerModel m) => m.isPlaying);
    final playerModel = di<PlayerModel>();

    void onPlay() {
      if (audios.first.audioType == AudioType.radio) {
        di<RadioModel>().clickStation(audios.first);
      }
      if (isEnQueued) {
        isPlaying ? playerModel.pause() : playerModel.resume();
      } else {
        playerModel
            .startPlaylist(
              audios: audios,
              listName: widget.pageId,
            )
            .then(
              (_) => widget.libraryModel.removePodcastUpdate(
                widget.pageId,
              ),
            );
      }
    }

    return MouseRegion(
      onEnter: (e) => setState(() => _hovered = true),
      onExit: (e) => setState(() => _hovered = false),
      child: Stack(
        children: [
          widget.tile,
          if (isEnQueued || _hovered || widget.selected == true)
            Positioned(
              right: 25,
              top: 12,
              child: CircleAvatar(
                radius: kTinyButtonSize / 2,
                child: IconButton(
                  onPressed: onPlay,
                  icon: Icon(
                    isPlaying && isEnQueued ? Iconz.pause : Iconz.playFilled,
                    size: kTinyButtonIconSize,
                    color: context.theme.colorScheme.primary,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
