import 'package:flutter/material.dart';
import 'package:watch_it/watch_it.dart';
import 'package:yaru/yaru.dart';

import '../../common/data/audio.dart';
import '../../common/data/audio_type.dart';
import '../../common/page_ids.dart';
import '../../common/view/global_keys.dart';
import '../../common/view/icons.dart';
import '../../common/view/spaced_divider.dart';
import '../../common/view/ui_constants.dart';
import '../../extensions/build_context_x.dart';
import '../../library/library_model.dart';
import '../../local_audio/local_audio_model.dart';
import '../../player/player_model.dart';
import '../../radio/radio_model.dart';
import 'master_item.dart';
import 'routing_manager.dart';

class MasterTileWithPageId extends StatelessWidget {
  const MasterTileWithPageId({
    super.key,
    required this.item,
    required this.selectedPageId,
  });

  final MasterItem item;
  final String? selectedPageId;

  @override
  Widget build(BuildContext context) => MasterTile(
        key: ValueKey(item.pageId),
        onTap: () => di<RoutingManager>().push(pageId: item.pageId),
        pageId: item.pageId,
        leading: item.iconBuilder?.call(selectedPageId == item.pageId),
        title: item.titleBuilder(context),
        subtitle: item.subtitleBuilder?.call(context),
        selected: selectedPageId == item.pageId,
      );
}

class MasterTile extends StatelessWidget {
  const MasterTile({
    super.key,
    this.selected,
    this.leading,
    required this.title,
    this.subtitle,
    this.trailing,
    required this.pageId,
    required this.onTap,
  });

  final bool? selected;
  final Widget? leading;
  final Widget? title;
  final Widget? subtitle;
  final Widget? trailing;
  final String pageId;
  final void Function() onTap;

  @override
  Widget build(BuildContext context) {
    final yaruMasterTile = YaruMasterTile(
      title: title,
      onTap: () {
        masterScaffoldKey.currentState
          ?..closeEndDrawer()
          ..closeDrawer();
        onTap();
      },
      selected: selected,
      leading: leading,
      subtitle: subtitle,
      trailing: trailing,
    );

    final Widget tile;
    if (pageId == PageIDs.customContent) {
      tile = _FramedMasterTile(tile: yaruMasterTile);
    } else {
      tile = yaruMasterTile;
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: kSmallestSpace),
      child: _PlayAbleMasterTile(
        selected: selected,
        pageId: pageId,
        tile: tile,
      ),
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
  });

  final String pageId;
  final Widget tile;
  final bool? selected;

  @override
  State<_PlayAbleMasterTile> createState() => __PlayAbleMasterTileState();
}

class __PlayAbleMasterTileState extends State<_PlayAbleMasterTile> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    if (PageIDs.permanent.contains(widget.pageId)) {
      return widget.tile;
    }

    final isEnQueued = watchPropertyValue(
      (PlayerModel m) => m.queueName != null && m.queueName == widget.pageId,
    );
    final isPlaying = watchPropertyValue((PlayerModel m) => m.isPlaying);
    final playerModel = di<PlayerModel>();

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
                  onPressed: () async {
                    final audios = await getAudiosById(widget.pageId);
                    if (audios?.firstOrNull?.audioType == AudioType.radio) {
                      di<RadioModel>().clickStation(audios?.firstOrNull);
                    }
                    if (isEnQueued) {
                      isPlaying ? playerModel.pause() : playerModel.resume();
                    } else if (audios != null) {
                      playerModel
                          .startPlaylist(
                            audios: audios,
                            listName: widget.pageId,
                          )
                          .then(
                            (_) => di<LibraryModel>().removePodcastUpdate(
                              widget.pageId,
                            ),
                          );
                    }
                  },
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

  Future<List<Audio>?>? getAudiosById(String pageId) async {
    final libraryModel = di<LibraryModel>();

    if (libraryModel.isStarredStation(pageId)) {
      var audio = await di<RadioModel>().getStationByUUID(pageId);
      return audio == null ? [] : [audio];
    }

    return libraryModel.getPodcast(pageId) ??
        libraryModel.getPlaylistById(pageId) ??
        di<LocalAudioModel>().findAlbum(pageId);
  }
}
