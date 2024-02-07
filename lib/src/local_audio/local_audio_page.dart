import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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
import 'local_audio_body.dart';
import 'local_audio_control_panel.dart';
import 'local_audio_view.dart';

class LocalAudioPage extends ConsumerStatefulWidget {
  const LocalAudioPage({
    super.key,
  });

  @override
  ConsumerState<LocalAudioPage> createState() => _LocalAudioPageState();
}

class _LocalAudioPageState extends ConsumerState<LocalAudioPage> {
  @override
  void initState() {
    super.initState();
    final model = ref.read(localAudioModelProvider);
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      if (!mounted) return;
      model.init(
        onFail: (failedImports) {
          if (!mounted ||
              ref.read(libraryModelProvider).neverShowFailedImports) {
            return;
          }
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              duration: const Duration(seconds: 10),
              content: FailedImportsContent(
                onNeverShowFailedImports:
                    ref.read(libraryModelProvider).setNeverShowLocalImports,
                failedImports: failedImports,
              ),
            ),
          );
        },
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final showWindowControls =
        ref.watch(appModelProvider.select((v) => v.showWindowControls));

    final model = ref.read(localAudioModelProvider);
    final audios = ref.watch(localAudioModelProvider.select((v) => v.audios));

    void search({
      required String? text,
    }) {
      if (text != null) {
        model.search(text);
        navigatorKey.currentState?.push(
          MaterialPageRoute(
            builder: (context) {
              return const LocalAudioSearchPage();
            },
          ),
        );
      } else {
        navigatorKey.currentState?.maybePop();
      }
    }

    final index = ref.watch(
      libraryModelProvider.select((value) => value.localAudioindex ?? 0),
    );
    final localAudioView = LocalAudioView.values[index];

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

    return Scaffold(
      appBar: headerBar,
      body: Column(
        children: [
          const LocalAudioControlPanel(),
          Expanded(
            child: LocalAudioBody(
              localAudioView: localAudioView,
              titles: audios,
              albums: model.allAlbums,
              artists: model.allArtists,
            ),
          ),
        ],
      ),
    );
  }
}

class LocalAudioPageIcon extends ConsumerWidget {
  const LocalAudioPageIcon({
    super.key,
    required this.selected,
  });

  final bool selected;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final audioType =
        ref.watch(playerModelProvider.select((m) => m.audio?.audioType));

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
