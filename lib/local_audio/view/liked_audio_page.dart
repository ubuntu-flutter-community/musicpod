import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/page_ids.dart';
import '../../app/routing_manager.dart';
import '../../common/data/retry_capsule.dart';
import '../../common/view/audio_page_type.dart';
import '../../common/view/error_retry_body.dart';
import '../../common/view/fall_back_header_image.dart';
import '../../common/view/icons.dart';
import '../../common/view/progress.dart';
import '../../common/view/side_bar_fall_back_image.dart';
import '../../common/view/local_audio_page.dart';
import '../../extensions/build_context_x.dart';
import '../../extensions/theme_data_x.dart';
import '../manager/liked_audios_manager.dart';
import 'artist_page.dart';

class LikedAudioPage extends ConsumerWidget {
  const LikedAudioPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) =>
      ref.watch(likedAudiosManagerProvider).when(
        loading: () => const Center(child: Progress()),
        error: (error, st) => ErrorRetryBody(
          error: error,
          retryCapsule: RetryCapsule(
            onRetry: () => ref.invalidate(likedAudiosManagerProvider),
            retryViewId: PageIDs.likedAudios,
          ),
          stackTrace: st,
        ),
        data: (likedAudios) => LocalAudioPage(
            onPageLabelTab: (text) =>
                ref.read(routingManagerProvider.notifier).push(
                      builder: (_) => ArtistPage(pageId: text),
                      pageId: text,
                    ),
            noSearchResultMessage: Text(context.l10n.likedSongsSubtitle),
            audios: likedAudios,
            audioPageType: AudioPageType.likedAudio,
            pageId: PageIDs.likedAudios,
            pageTitle: context.l10n.likedSongs,
            pageLabel: context.l10n.playlist,
            pageSubTitle: '${likedAudios?.length ?? 0} ${context.l10n.titles}',
            description: Text(
              context.l10n.likedSongsSubtitle,
              style: context.theme.pageHeaderDescription,
            ),
            image: FallBackHeaderImage(child: Icon(Iconz.heart, size: 65)),
            startNewPlaylistOnTap: true,
          ),
      );
}

class LikedAudioPageIcon extends StatelessWidget {
  const LikedAudioPageIcon({super.key, required this.selected});

  final bool selected;

  @override
  Widget build(BuildContext context) => SideBarFallBackImage(
    child: selected ? Icon(Iconz.heartFilled) : Icon(Iconz.heart),
  );
}
