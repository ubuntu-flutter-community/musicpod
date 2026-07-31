import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_it/flutter_it.dart';

import '../../common/view/audio_page_type.dart';
import '../../common/view/global_keys.dart';
import '../../common/view/icons.dart';
import '../../common/view/progress.dart';
import '../../common/view/spaced_divider.dart';
import '../../common/view/theme.dart';
import '../../common/view/ui_constants.dart';
import '../../extensions/build_context_x.dart';
import '../../player/manager/player_manager.dart';
import '../data/play_anywhere_param.dart';
import '../page_ids.dart';
import '../play_anywhere_manager.dart';
import '../routing_manager.dart';
import 'master_item.dart';

class MasterTile extends StatelessWidget {
  const MasterTile({
    super.key,
    required this.item,
    required this.selectedPageId,
  });

  final MasterItem item;
  final String? selectedPageId;

  @override
  Widget build(BuildContext context) => _MasterTile(
    key: ValueKey(item.pageId),
    audioPageType: item.audioPageType,
    onTap: () => di<RoutingManager>().push(pageId: item.pageId),
    pageId: item.pageId,
    leading: item.iconBuilder(selectedPageId == item.pageId),
    title: item.titleBuilder(context),
    subtitle: item.subtitleBuilder?.call(context),
    selected: selectedPageId == item.pageId,
  );
}

class _MasterTile extends StatelessWidget {
  const _MasterTile({
    super.key,
    this.selected,
    this.leading,
    required this.title,
    this.subtitle,
    required this.pageId,
    required this.onTap,
    required this.audioPageType,
  });

  final bool? selected;
  final Widget? leading;
  final Widget? title;
  final Widget? subtitle;
  final String pageId;
  final void Function() onTap;
  final AudioPageType audioPageType;

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final masterTile = ListTile(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(context.buttonRadius),
      ),
      title: _titleStyle(title, theme.textTheme.bodyMedium?.color),
      onTap: () {
        masterScaffoldKey.currentState
          ?..closeEndDrawer()
          ..closeDrawer();
        onTap();
      },
      selected: selected ?? false,
      leading: leading,
      subtitle: _subTitleStyle(subtitle, theme.textTheme.bodyMedium?.color),
    );

    final Widget tile;
    if (pageId == PageIDs.customContent) {
      tile = _FramedMasterTile(tile: masterTile);
    } else {
      tile = Padding(
        padding: const EdgeInsets.only(
          bottom: kSmallestSpace,
          left: kMediumSpace,
          right: kMediumSpace,
        ),
        child: masterTile,
      );
    }

    return _PlayAbleMasterTile(
      audioPageType: audioPageType,
      selected: selected,
      pageId: pageId,
      tile: tile,
    );
  }
}

Widget? _titleStyle(Widget? child, Color? color) {
  if (child == null) {
    return child;
  }

  return DefaultTextStyle.merge(
    child: child,
    maxLines: 1,
    overflow: TextOverflow.ellipsis,
    style: TextStyle(color: color),
  );
}

Widget? _subTitleStyle(Widget? child, Color? color) {
  if (child == null) {
    return child;
  }

  return DefaultTextStyle.merge(
    child: child,
    maxLines: 1,
    overflow: TextOverflow.ellipsis,
    style: TextStyle(color: color),
  );
}

class _FramedMasterTile extends StatelessWidget {
  const _FramedMasterTile({required this.tile});

  final Widget tile;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SpacedDivider(top: 10, bottom: 10, right: 0, left: 0),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: kMediumSpace),
          child: tile,
        ),
        const SpacedDivider(top: 10, bottom: 10, right: 0, left: 0),
      ],
    );
  }
}

class _PlayAbleMasterTile extends StatefulWidget
    with WatchItStatefulWidgetMixin {
  const _PlayAbleMasterTile({
    required this.pageId,
    required this.tile,
    required this.audioPageType,
    this.selected,
  });

  final String pageId;
  final AudioPageType audioPageType;
  final Widget tile;
  final bool? selected;

  @override
  State<_PlayAbleMasterTile> createState() => __PlayAbleMasterTileState();
}

class __PlayAbleMasterTileState extends State<_PlayAbleMasterTile> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    if (PageIDs.permanent
        .whereNot((e) => e == PageIDs.likedAudios)
        .contains(widget.pageId)) {
      return widget.tile;
    }

    final isEnQueued = watchPropertyValue(
      (PlayerManager m) => m.queue.name == widget.pageId,
    );
    final isPlaying = watchPropertyValue((PlayerManager m) => m.isPlaying);

    final playAudiosByIdCommandResults = watchValue(
      (PlayAnywhereManager m) => m.command.results,
    );

    final isRunning = playAudiosByIdCommandResults.isRunning;
    final paramPageId = playAudiosByIdCommandResults.paramData;

    final busy = isRunning && paramPageId == widget.pageId;

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
              child: SizedBox.square(
                dimension: kTinyButtonSize,
                child: IconButton(
                  style: tonedIconButtonStyle(context.colorScheme),
                  onPressed: isRunning
                      ? null
                      : () => di<PlayAnywhereManager>().command.run(
                          PlayAnywhereParam(
                            pageId: widget.pageId,
                            audioPageType: widget.audioPageType,
                          ),
                        ),
                  icon: busy
                      ? const SizedBox(
                          width: 15,
                          height: 15,
                          child: Progress(strokeWidth: 1),
                        )
                      : Icon(
                          isPlaying && isEnQueued
                              ? Iconz.pause
                              : Iconz.playFilled,
                          size: kTinyButtonIconSize,
                          color: context.theme.colorScheme.onSurface,
                        ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
