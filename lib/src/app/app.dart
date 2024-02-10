import 'dart:io';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:signals_flutter/signals_flutter.dart';
import 'package:ubuntu_service/ubuntu_service.dart';
import 'package:yaru_widgets/yaru_widgets.dart';

import '../../app.dart';
import '../../build_context_x.dart';
import '../../constants.dart';
import '../../library.dart';
import '../../local_audio.dart';
import '../../patch_notes.dart';
import '../../player.dart';
import '../../podcasts.dart';
import '../../radio.dart';
import '../external_path/external_path_service.dart';
import '../settings/settings_service.dart';
import 'connectivity_notifier.dart';
import 'master_detail_page.dart';

class App extends StatefulWidget {
  const App({super.key});

  static Widget create() {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => RadioModel(getService<RadioService>()),
        ),
        ChangeNotifierProvider(
          create: (_) => PlayerModel(
            service: getService<PlayerService>(),
          ),
        ),
        ChangeNotifierProvider(
          create: (_) => LocalAudioModel(
            localAudioService: getService<LocalAudioService>(),
            libraryService: getService<LibraryService>(),
          ),
        ),
        ChangeNotifierProvider(
          create: (_) => LibraryModel(
            getService<LibraryService>(),
            getService<AppStateService>(),
          ),
        ),
        ChangeNotifierProvider(
          create: (_) => PodcastModel(
            getService<PodcastService>(),
            getService<LibraryService>(),
          ),
        ),
        ChangeNotifierProvider(
          create: (_) => ConnectivityNotifier(
            getService<Connectivity>(),
          ),
        ),
      ],
      child: const App(),
    );
  }

  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> with WidgetsBindingObserver {
  String? _countryCode;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addObserver(this);

    _countryCode = WidgetsBinding.instance.platformDispatcher.locale.countryCode
        ?.toLowerCase();

    final settingService = getService<SettingsService>();

    final libraryModel = context.read<LibraryModel>();
    final playerModel = context.read<PlayerModel>();

    final connectivityNotifier = context.read<ConnectivityNotifier>();

    final extPathService = getService<ExternalPathService>();

    if (!Platform.isAndroid && !Platform.isIOS) {
      YaruWindow.of(context).onClose(
        () async {
          await resetAllServices();
          return true;
        },
      );
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      connectivityNotifier.init().then(
        (_) {
          libraryModel.init().then(
            (_) {
              playerModel.init().then((_) {
                if (settingService.recentPatchNotesDisposed.value == false) {
                  showPatchNotes(context, settingService.disposePatchNotes);
                }
                extPathService.init(playerModel.play);
              });
            },
          );
        },
      );
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Future<void> didChangeAppLifecycleState(AppLifecycleState state) async {
    if (state == AppLifecycleState.paused) {
      await resetAllServices();
    }
  }

  @override
  Widget build(BuildContext context) {
    final playerToTheRight = context.m.size.width > kSideBarThreshHold;

    final appStateService = getService<AppStateService>();
    final isFullScreen = appStateService.fullScreen;

    final playerModel = context.read<PlayerModel>();

    return KeyboardListener(
      focusNode: FocusNode(),
      onKeyEvent: (value) {
        if (value.runtimeType == KeyDownEvent &&
            value.logicalKey == LogicalKeyboardKey.space) {
          playerModel.playOrPause();
        }
      },
      child: Watch.builder(
        builder: (context) {
          return Stack(
            alignment: Alignment.center,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Column(
                      children: [
                        Expanded(
                          child: MasterDetailPage(
                            countryCode: _countryCode,
                          ),
                        ),
                        if (!playerToTheRight)
                          const PlayerView(
                            playerViewMode: PlayerViewMode.bottom,
                          ),
                      ],
                    ),
                  ),
                  if (playerToTheRight)
                    const SizedBox(
                      width: kSideBarPlayerWidth,
                      child: PlayerView(
                        playerViewMode: PlayerViewMode.sideBar,
                      ),
                    ),
                ],
              ),
              if (isFullScreen.value == true)
                const Scaffold(
                  body: PlayerView(
                    playerViewMode: PlayerViewMode.fullWindow,
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}
