import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:yaru_widgets/yaru_widgets.dart';

import '../../app.dart';
import '../../build_context_x.dart';
import '../../common.dart';
import '../../constants.dart';
import '../../data.dart';
import '../../globals.dart';
import '../../local_audio.dart';
import '../../player.dart';
import '../l10n/l10n.dart';
import '../library/library_model.dart';
import 'cache_dialog.dart';

class LocalAudioPage extends StatefulWidget {
  const LocalAudioPage({
    super.key,
  });

  @override
  State<LocalAudioPage> createState() => _LocalAudioPageState();
}

class _LocalAudioPageState extends State<LocalAudioPage>
    with SingleTickerProviderStateMixin {
  @override
  void initState() {
    super.initState();
    final model = context.read<LocalAudioModel>();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      if (!mounted) return;
      model.init(
        onFail: (failedImports) {
          if (!mounted || context.read<LibraryModel>().neverShowFailedImports) {
            return;
          }
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              duration: const Duration(seconds: 10),
              content: FailedImportsContent(
                onNeverShowFailedImports:
                    context.read<LibraryModel>().setNeverShowLocalImports,
                failedImports: failedImports,
              ),
            ),
          );
        },
      ).then((_) {
        if (!mounted) return;
        if ((model.localAudioCache == null &&
                model.useLocalAudioCache == null) &&
            model.audios != null &&
            model.audios!.length > kCreateCacheLimit) {
          showCacheSuggestion(
            context: context,
            onUseLocalAudioCache: model.setUseLocalAudioCache,
            createCache: model.createLocalAudioCache,
            localAudioLength: model.audios!.length,
          );
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final showWindowControls =
        context.select((AppModel a) => a.showWindowControls);

    final model = context.read<LocalAudioModel>();
    final audios = context.select((LocalAudioModel m) => m.audios);
    final artists = model.allArtists;
    final albums = model.allAlbums;
    void search({
      required String? text,
      bool replace = false,
    }) {
      if (text != null) {
        model.search(text);
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) {
              return const LocalAudioSearchPage();
            },
          ),
        );
      } else {
        Navigator.of(context).pop();
      }
    }

    final findArtist = model.findArtist;
    final findImages = model.findImages;
    final findAlbum = model.findAlbum;

    final libraryModel = context.read<LibraryModel>();
    final localAudioView =
        context.select((LocalAudioModel m) => m.localAudioView);
    final setLocalAudioView = model.setLocalAudioView;

    context.select((LocalAudioModel m) => m.useLocalAudioCache);

    final isPinnedAlbum = libraryModel.isPinnedAlbum;
    final removePinnedAlbum = libraryModel.removePinnedAlbum;
    final addPinnedAlbum = libraryModel.addPinnedAlbum;

    final playerModel = context.read<PlayerModel>();
    final startPlaylist = playerModel.startPlaylist;

    final headerBar = HeaderBar(
      style: showWindowControls
          ? YaruTitleBarStyle.normal
          : YaruTitleBarStyle.undecorated,
      leading: (navigatorKey.currentState?.canPop() == true)
          ? NavBackButton(
              onPressed: () => search(text: null),
            )
          : const SizedBox.shrink(),
      titleSpacing: 0,
      actions: [
        Flexible(
          child: Padding(
            padding: appBarActionSpacing,
            child: SearchButton(
              active: false,
              onPressed: () => search(text: ''),
            ),
          ),
        ),
      ],
      title: Text(context.l10n.localAudio),
    );

    final body = switch (localAudioView) {
      LocalAudioView.titles => TitlesView(
          audios: audios,
        ),
      LocalAudioView.artists => ArtistsView(
          artists: artists,
          findArtist: findArtist,
          findImages: findImages,
        ),
      LocalAudioView.albums => AlbumsView(
          albums: albums,
          addPinnedAlbum: addPinnedAlbum,
          findAlbum: findAlbum,
          isPinnedAlbum: isPinnedAlbum,
          removePinnedAlbum: removePinnedAlbum,
          startPlaylist: startPlaylist,
        ),
    };

    return Scaffold(
      appBar: headerBar,
      body: Column(
        children: [
          Row(
            children: [
              const SizedBox(
                width: 20,
              ),
              YaruChoiceChipBar(
                yaruChoiceChipBarStyle: YaruChoiceChipBarStyle.wrap,
                selectedFirst: false,
                clearOnSelect: false,
                labels: LocalAudioView.values
                    .map((e) => Text(e.localize(context.l10n)))
                    .toList(),
                isSelected: LocalAudioView.values
                    .map((e) => e == localAudioView)
                    .toList(),
                onSelected: (index) =>
                    setLocalAudioView(LocalAudioView.values[index]),
              ),
            ],
          ),
          Expanded(child: body),
        ],
      ),
    );
  }
}

class LocalAudioPageIcon extends StatelessWidget {
  const LocalAudioPageIcon({
    super.key,
    required this.selected,
  });

  final bool selected;

  @override
  Widget build(BuildContext context) {
    final audioType = context.select((PlayerModel m) => m.audio?.audioType);

    final theme = context.t;
    if (audioType == AudioType.local) {
      return Icon(
        Iconz().play,
        color: theme.colorScheme.primary,
      );
    }

    return Padding(
      padding: kMainPageIconPadding,
      child:
          selected ? Icon(Iconz().localAudioFilled) : Icon(Iconz().localAudio),
    );
  }
}
