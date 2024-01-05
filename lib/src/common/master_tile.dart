import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:yaru_widgets/yaru_widgets.dart';

import '../../build_context_x.dart';
import '../../common.dart';
import '../../constants.dart';
import '../../data.dart';
import '../../l10n.dart';
import '../../library.dart';
import '../../player.dart';

class MasterTile extends StatefulWidget {
  const MasterTile({
    super.key,
    this.selected,
    this.leading,
    required this.title,
    this.subtitle,
    this.trailing,
    required this.libraryModel,
    required this.pageId,
    required this.audios,
  });

  final bool? selected;
  final Widget? leading;
  final Widget? title;
  final Widget? subtitle;
  final Widget? trailing;
  final LibraryModel libraryModel;
  final String pageId;
  final Set<Audio> audios;

  @override
  State<MasterTile> createState() => _MasterTileState();
}

class _MasterTileState extends State<MasterTile> {
  var _hovered = false;

  @override
  Widget build(BuildContext context) {
    final yaruMasterTile = Padding(
      padding: widget.pageId == kLocalAudio
          ? const EdgeInsets.only(top: 5)
          : EdgeInsets.zero,
      child: YaruMasterTile(
        title: widget.title,
        onTap: widget.pageId == kNewPlaylist
            ? () => showDialog(
                  context: context,
                  builder: (context) {
                    return PlaylistDialog(
                      playlistName: context.l10n.createNewPlaylist,
                      allowCreate: true,
                      libraryModel: widget.libraryModel,
                    );
                  },
                )
            : null,
        selected: widget.selected,
        leading: widget.leading,
        subtitle: widget.subtitle,
        trailing: widget.trailing,
      ),
    );

    final Widget tile;
    if (widget.pageId == kNewPlaylist) {
      tile = _EmbracedMasterTile(yaruMasterTile: yaruMasterTile);
    } else {
      tile = yaruMasterTile;
    }

    if (widget.audios.isEmpty) {
      return tile;
    }

    final isEnQueued = context.select(
      (PlayerModel m) => m.queueName != null && m.queueName == widget.pageId,
    );
    final isPlaying = context.select(
      (PlayerModel m) => m.isPlaying,
    );

    final playerModel = context.read<PlayerModel>();

    void onPlay() {
      if (isEnQueued) {
        isPlaying ? playerModel.pause() : playerModel.resume();
      } else {
        playerModel.startPlaylist(
          audios: widget.audios,
          listName: widget.pageId,
        );
      }
    }

    return MouseRegion(
      onEnter: (e) => setState(() => _hovered = true),
      onExit: (e) => setState(() => _hovered = false),
      child: Stack(
        children: [
          tile,
          if (_hovered || widget.selected == true)
            Positioned(
              right: 25,
              top: 12,
              child: CircleAvatar(
                radius: kTinyButtonSize / 2,
                child: IconButton(
                  onPressed: onPlay,
                  icon: Icon(
                    isPlaying && isEnQueued
                        ? Iconz().pause
                        : Iconz().playFilled,
                    size: kTinyButtonIconSize,
                    color: context.t.colorScheme.primary,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _EmbracedMasterTile extends StatelessWidget {
  const _EmbracedMasterTile({
    required this.yaruMasterTile,
  });

  final Widget yaruMasterTile;

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
        yaruMasterTile,
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
