import 'package:flutter/material.dart';
import 'package:signals_flutter/signals_flutter.dart';
import 'package:ubuntu_service/ubuntu_service.dart';
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
import '../settings/settings_service.dart';
import 'local_audio_body.dart';
import 'local_audio_control_panel.dart';
import 'local_audio_view.dart';

class LocalAudioPage extends StatefulWidget {
  const LocalAudioPage({
    super.key,
  });

  @override
  State<LocalAudioPage> createState() => _LocalAudioPageState();
}

class _LocalAudioPageState extends State<LocalAudioPage> {
  @override
  void initState() {
    super.initState();
    final service = getService<LocalAudioService>();
    final settingsService = getService<SettingsService>();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) async {
      if (!mounted) return;
      await service.init(
        onFail: (failedImports) {
          if (!mounted || settingsService.neverShowFailedImports.value) {
            return;
          }
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              duration: const Duration(seconds: 10),
              content: FailedImportsContent(
                onNeverShowFailedImports: () =>
                    settingsService.setNeverShowFailedImports(true),
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
    final appStateService = getService<AppStateService>();
    final showWindowControls = appStateService.showWindowControls;

    final localAudioService = getService<LocalAudioService>();
    final audios = localAudioService.audios;

    localAudioService.audiosChanged.watch(context);

    void search({
      required String? text,
    }) {
      if (text != null) {
        localAudioService.search(text);
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

    final index = appStateService.localAudioIndex;

    final headerBar = HeaderBar(
      style: showWindowControls.watch(context)
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
              localAudioView: LocalAudioView.values[index.watch(context)],
              titles: audios,
              albums: localAudioService.allAlbums,
              artists: localAudioService.allArtists,
            ),
          ),
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
    final audioType =
        getService<PlayerService>().audio.watch(context)?.audioType;

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
