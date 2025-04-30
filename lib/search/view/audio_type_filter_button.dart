import 'package:flutter/material.dart';
import 'package:watch_it/watch_it.dart';

import '../../common/data/audio_type.dart';
import '../../common/view/modals.dart';
import '../../extensions/build_context_x.dart';
import '../../l10n/l10n.dart';
import '../search_model.dart';

class AudioTypeFilterButton extends StatelessWidget {
  const AudioTypeFilterButton({super.key, required OverlayMode mode})
      : _mode = mode;

  final OverlayMode _mode;

  @override
  Widget build(BuildContext context) => switch (_mode) {
        OverlayMode.bottomSheet => const AudioTypeFilterBottomSheetButton(),
        OverlayMode.popup => const AudioTypeFilterPopover()
      };
}

class AudioTypeFilterPopover extends StatelessWidget with WatchItMixin {
  const AudioTypeFilterPopover({super.key});

  @override
  Widget build(BuildContext context) {
    final searchModel = di<SearchModel>();
    final audioType = watchPropertyValue((SearchModel m) => m.audioType);

    final shape =
        RoundedRectangleBorder(borderRadius: BorderRadius.circular(100));
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 5),
      child: DecoratedBox(
        decoration: ShapeDecoration(
          shape: shape,
        ),
        child: Material(
          color: Colors.transparent,
          shape: shape,
          clipBehavior: Clip.antiAlias,
          child: PopupMenuButton<AudioType>(
            initialValue: audioType,
            onSelected: (v) async {
              searchModel
                ..setAudioType(v)
                ..search(clear: true);
            },
            itemBuilder: (context) => AudioType.values
                .map(
                  (e) => PopupMenuItem<AudioType>(
                    value: e,
                    child: Text(
                      e.localize(
                        context.l10n,
                      ),
                    ),
                  ),
                )
                .toList(),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Text(
                audioType.localize(context.l10n),
                style: context.theme.textTheme.labelSmall?.copyWith(
                  color: context.theme.colorScheme.primary,
                  fontWeight: FontWeight.bold,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class AudioTypeFilterBottomSheetButton extends StatelessWidget
    with WatchItMixin {
  const AudioTypeFilterBottomSheetButton({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final searchModel = di<SearchModel>();
    final audioType = watchPropertyValue((SearchModel m) => m.audioType);

    return IconButton(
      padding: EdgeInsets.zero,
      onPressed: () => showModalBottomSheet(
        context: context,
        builder: (context) => BottomSheet(
          onClosing: () {},
          builder: (context) => ListView(
            shrinkWrap: true,
            padding: const EdgeInsets.all(10),
            children: AudioType.values
                .map(
                  (e) => Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: ListTile(
                      leading: Icon(e.iconData),
                      onTap: () async {
                        Navigator.of(context).pop();
                        searchModel
                          ..setAudioType(e)
                          ..search(clear: true);
                      },
                      title: Text(
                        '${l10n.search}: ${e.localize(context.l10n)}',
                      ),
                    ),
                  ),
                )
                .toList(),
          ),
        ),
      ),
      icon: Icon(audioType.iconData),
    );
  }
}
