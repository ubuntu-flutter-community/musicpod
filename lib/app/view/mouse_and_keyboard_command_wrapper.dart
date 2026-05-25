import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_it/flutter_it.dart';

import '../../common/data/audio_type.dart';
import '../../player/player_model.dart';
import '../page_ids.dart';
import '../../search/search_model.dart';
import '../app_manager.dart';
import 'back_gesture.dart';
import '../routing_manager.dart';

class MouseAndKeyboardCommandWrapper extends StatelessWidget {
  const MouseAndKeyboardCommandWrapper({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) => Shortcuts(
    shortcuts: <LogicalKeySet, Intent>{
      LogicalKeySet(LogicalKeyboardKey.keyF, LogicalKeyboardKey.meta):
          const _SearchIntent(),
      LogicalKeySet(LogicalKeyboardKey.keyF, LogicalKeyboardKey.control):
          const _SearchIntent(),
      LogicalKeySet(LogicalKeyboardKey.comma, LogicalKeyboardKey.meta):
          const _SettingsIntent(),
      LogicalKeySet(LogicalKeyboardKey.meta, LogicalKeyboardKey.backspace):
          const _BackIntent(),
      LogicalKeySet(LogicalKeyboardKey.alt, LogicalKeyboardKey.backspace):
          const _BackIntent(),
      LogicalKeySet(LogicalKeyboardKey.enter, LogicalKeyboardKey.alt):
          const _FullWindowIntent(),
      LogicalKeySet(LogicalKeyboardKey.enter, LogicalKeyboardKey.meta):
          const _FullWindowIntent(),
      LogicalKeySet(LogicalKeyboardKey.space, LogicalKeyboardKey.alt):
          const _PlayPauseIntent(),
      LogicalKeySet(LogicalKeyboardKey.arrowRight, LogicalKeyboardKey.alt):
          const _PlayNextIntent(),
      LogicalKeySet(LogicalKeyboardKey.arrowLeft, LogicalKeyboardKey.alt):
          const _PlayPreviousIntent(),
    },
    child: Actions(
      actions: <Type, Action<Intent>>{
        _SearchIntent: CallbackAction<_SearchIntent>(
          onInvoke: (intent) {
            final currentPageId = di<RoutingManager>().selectedPageId;

            if (currentPageId == PageIDs.searchPage) {
              if (di<AppManager>().fullWindowMode.value) {
                di<AppManager>().setFullWindowMode(false);
              } else {
                di<RoutingManager>().pop();
              }
            } else {
              if (di<AppManager>().fullWindowMode.value) {
                di<AppManager>().setFullWindowMode(false);
              }
              di<SearchModel>().setAudioType(switch (currentPageId) {
                PageIDs.localAudio => AudioType.local,
                PageIDs.radio => AudioType.radio,
                _ => AudioType.podcast,
              });
              di<RoutingManager>().push(pageId: PageIDs.searchPage);
            }

            return null;
          },
        ),
        _SettingsIntent: CallbackAction<_SettingsIntent>(
          onInvoke: (intent) {
            if (di<AppManager>().fullWindowMode.value) {
              di<AppManager>().setFullWindowMode(false);
            }
            di<RoutingManager>().push(pageId: PageIDs.settings);
            return null;
          },
        ),
        _BackIntent: CallbackAction<_BackIntent>(
          onInvoke: (intent) {
            if (di<AppManager>().fullWindowMode.value) {
              di<AppManager>().setFullWindowMode(false);
            }
            di<RoutingManager>().pop();
            return null;
          },
        ),
        _FullWindowIntent: CallbackAction<_FullWindowIntent>(
          onInvoke: (intent) {
            di<AppManager>().toggleFullWindowMode();
            return null;
          },
        ),
        _PlayPauseIntent: CallbackAction<_PlayPauseIntent>(
          onInvoke: (intent) {
            di<PlayerModel>().playOrPause();
            return null;
          },
        ),
        _PlayNextIntent: CallbackAction<_PlayNextIntent>(
          onInvoke: (intent) {
            final playerModel = di<PlayerModel>();

            final audio = playerModel.audio;
            if (audio == null) return;

            if (audio.isRadio) {
              di<SearchModel>().findSimilarStationCommand.run(audio);
            } else {
              playerModel.playNext();
            }
            return null;
          },
        ),
        _PlayPreviousIntent: CallbackAction<_PlayPreviousIntent>(
          onInvoke: (intent) {
            final playerModel = di<PlayerModel>();

            final audio = playerModel.audio;
            if (audio == null) return;

            if (audio.isRadio) {
              playerModel.playNext();
            } else {
              playerModel.playPrevious();
            }
            return null;
          },
        ),
      },
      child: RawGestureDetector(
        gestures: <Type, GestureRecognizerFactory>{
          _MouseBackButtonRecognizer:
              GestureRecognizerFactoryWithHandlers<_MouseBackButtonRecognizer>(
                () => _MouseBackButtonRecognizer(),
                (instance) =>
                    instance.onTapDown = (details) =>
                        di<RoutingManager>().pop(),
              ),
        },
        child: BackGesture(child: child),
      ),
    ),
  );
}

class _SearchIntent extends Intent {
  const _SearchIntent();
}

class _SettingsIntent extends Intent {
  const _SettingsIntent();
}

class _BackIntent extends Intent {
  const _BackIntent();
}

class _FullWindowIntent extends Intent {
  const _FullWindowIntent();
}

class _PlayPauseIntent extends Intent {
  const _PlayPauseIntent();
}

class _PlayNextIntent extends Intent {
  const _PlayNextIntent();
}

class _PlayPreviousIntent extends Intent {
  const _PlayPreviousIntent();
}

class _MouseBackButtonRecognizer extends BaseTapGestureRecognizer {
  GestureTapDownCallback? onTapDown;

  @override
  void handleTapCancel({
    required PointerDownEvent down,
    PointerCancelEvent? cancel,
    required String reason,
  }) {}

  @override
  void handleTapDown({required PointerDownEvent down}) {
    final TapDownDetails details = TapDownDetails(
      globalPosition: down.position,
      localPosition: down.localPosition,
      kind: getKindForPointer(down.pointer),
    );

    if (down.buttons == kBackMouseButton && onTapDown != null) {
      invokeCallback<void>('onTapDown', () => onTapDown!(details));
    }
  }

  @override
  void handleTapUp({
    required PointerDownEvent down,
    required PointerUpEvent up,
  }) {}
}
