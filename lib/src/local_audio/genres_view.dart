import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:yaru/yaru.dart';

import '../../app.dart';
import '../../common.dart';
import '../../constants.dart';
import '../../data.dart';
import '../../local_audio.dart';
import '../globals.dart';
import '../l10n/l10n.dart';

class GenresView extends ConsumerWidget {
  const GenresView({
    super.key,
    this.genres,
    this.noResultMessage,
    this.noResultIcon,
  });

  final Set<Audio>? genres;
  final Widget? noResultMessage, noResultIcon;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (genres == null) {
      return const Center(
        child: Progress(),
      );
    }

    if (genres!.isEmpty) {
      return NoSearchResultPage(
        icons: noResultIcon,
        message: noResultMessage,
      );
    }
    final model = ref.read(localAudioModelProvider);
    return Padding(
      padding: const EdgeInsets.only(top: 15),
      child: GridView.builder(
        itemCount: genres!.length,
        padding: gridPadding,
        gridDelegate: kDiskGridDelegate,
        itemBuilder: (context, index) {
          final showWindowControls =
              ref.watch(appModelProvider.select((a) => a.showWindowControls));
          final artistAudiosWithGenre =
              model.findArtistsOfGenre(genres!.elementAt(index));

          final text = genres!.elementAt(index).genre ?? context.l10n.unknown;

          return YaruSelectableContainer(
            selected: false,
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) {
                  return Scaffold(
                    appBar: HeaderBar(
                      style: showWindowControls
                          ? YaruTitleBarStyle.normal
                          : YaruTitleBarStyle.undecorated,
                      leading: (navigatorKey.currentState?.canPop() == true)
                          ? const NavBackButton()
                          : const SizedBox.shrink(),
                      titleSpacing: 0,
                      title: Text(text),
                    ),
                    body: ArtistsView(
                      artists: artistAudiosWithGenre,
                    ),
                  );
                },
              ),
            ),
            borderRadius: BorderRadius.circular(300),
            child: Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  width: double.infinity,
                  height: double.infinity,
                  child: RoundImageContainer(
                    images: const {},
                    fallBackText:
                        artistAudiosWithGenre?.firstOrNull?.genre ?? 'a',
                  ),
                ),
                ArtistVignette(text: text),
              ],
            ),
          );
        },
      ),
    );
  }
}
