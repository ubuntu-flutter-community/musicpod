import '../../common/data/audio.dart';
import '../../constants.dart';
import '../../extensions/build_context_x.dart';
import '../../l10n/l10n.dart';
import '../../library/library_model.dart';
import '../../local_audio/local_audio_model.dart';
import '../../local_audio/view/local_audio_search_page.dart';
import '../search_model.dart';
import 'package:flutter/material.dart';
import 'package:watch_it/watch_it.dart';

class AudioTypeFilterButton extends StatelessWidget with WatchItMixin {
  const AudioTypeFilterButton({super.key});

  @override
  Widget build(BuildContext context) {
    final searchModel = di<SearchModel>();
    final audioType = watchPropertyValue((SearchModel m) => m.audioType);

    return PopupMenuButton<AudioType>(
      initialValue: audioType,
      onSelected: (v) async {
        if (v == AudioType.local) {
          di<LocalAudioModel>().search(di<SearchModel>().searchQuery);
          await di<LibraryModel>().push(
            builder: (_) => const LocalAudioSearchPage(),
            pageId: kSearchPageId,
          );
        } else {
          searchModel.setAudioType(v);
          searchModel.search();
        }
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
      icon: Padding(
        padding: const EdgeInsets.only(right: 5),
        child: Text(
          audioType.localize(context.l10n),
          style: context.t.textTheme.labelSmall?.copyWith(
            color: context.t.colorScheme.primary,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
