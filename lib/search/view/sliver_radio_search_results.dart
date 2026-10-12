import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../common/view/no_search_result_page.dart';
import '../../extensions/build_context_x.dart';
import '../../player/manager/current_audio_manager.dart';
import '../../player/manager/play_pause_manager.dart';
import '../../radio/view/radio_connect_mixin.dart';
import '../manager/search_manager.dart';
import 'radio_search_result_tile.dart';

class SliverRadioSearchResults extends StatelessWidget with RadioConnectMixin {
  const SliverRadioSearchResults({super.key, required this.width});

  final double width;

  @override
  Widget build(BuildContext context) => Consumer(
    builder: (context, ref, _) {
      registerRadioConnectHandler(context, ref);
      return _Content(width: width);
    },
  );
}

class _Content extends ConsumerWidget {
  const _Content({required this.width});

  final double width;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final playing = ref.watch(playPauseManagerProvider);
    final currentAudio = ref.watch(currentAudioManagerProvider);

    final radioSearchResult = ref
        .watch(searchManagerProvider.select((s) => s.radioSearchResult))
        ?.where((e) => e.uuid != null);

    final searchQuery = ref.watch(
      searchManagerProvider.select((s) => s.searchQuery),
    );
    final searchType = ref.watch(
      searchManagerProvider.select((s) => s.searchType),
    );
    final loading = ref.watch(searchManagerProvider.select((s) => s.isLoading));

    if (radioSearchResult == null ||
        (searchQuery?.isEmpty == true && radioSearchResult.isEmpty == true)) {
      return SliverNoSearchResultPage(
        message: Text(
          '${context.l10n.search} ${searchType.localize(context.l10n)}',
        ),
      );
    }
    if (radioSearchResult.isEmpty && !loading) {
      return SliverNoSearchResultPage(
        message: Text(context.l10n.noStationFound),
      );
    }

    return SliverList.builder(
      itemCount: radioSearchResult.length,
      itemBuilder: (context, index) {
        final station = radioSearchResult.elementAt(index);
        final selected = currentAudio?.uuid == station.uuid;
        return Padding(
          padding: const EdgeInsets.only(bottom: 5),
          child: RadioSearchResultTile(
            key: ValueKey(station.uuid),
            station: station,
            selected: selected,
            width: width,
            currentAudio: currentAudio,
            playing: playing,
          ),
        );
      },
    );
  }
}
