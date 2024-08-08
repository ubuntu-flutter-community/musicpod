import 'package:flutter/material.dart';
import 'package:watch_it/watch_it.dart';

import '../../common/data/audio.dart';
import '../../extensions/build_context_x.dart';
import '../../l10n/l10n.dart';
import '../search_model.dart';

class AudioTypeFilterButton extends StatelessWidget with WatchItMixin {
  const AudioTypeFilterButton({super.key});

  @override
  Widget build(BuildContext context) {
    final searchModel = di<SearchModel>();
    final audioType = watchPropertyValue((SearchModel m) => m.audioType);

    return PopupMenuButton<AudioType>(
      initialValue: audioType,
      onSelected: (v) async {
        searchModel.setAudioType(v);
        searchModel.search();
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
        padding: const EdgeInsets.symmetric(horizontal: 10),
        child: Text(
          audioType.localize(context.l10n),
          style: context.t.textTheme.labelSmall?.copyWith(
            color: context.t.colorScheme.primary,
            fontWeight: FontWeight.bold,
          ),
          overflow: TextOverflow.ellipsis,
        ),
      ),
    );
  }
}
