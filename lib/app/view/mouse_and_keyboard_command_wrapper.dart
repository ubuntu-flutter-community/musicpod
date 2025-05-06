import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:watch_it/watch_it.dart';
import '../../common/data/audio_type.dart';
import '../../common/page_ids.dart';
import '../../search/search_model.dart';
import 'routing_manager.dart';

class MouseAndKeyboardCommandWrapper extends StatelessWidget {
  const MouseAndKeyboardCommandWrapper({
    super.key,
    required this.child,
  });

  final Widget child;

  @override
  Widget build(BuildContext context) => Shortcuts(
        shortcuts: <LogicalKeySet, Intent>{
          LogicalKeySet(LogicalKeyboardKey.keyF, LogicalKeyboardKey.meta):
              const SearchIntent(),
          LogicalKeySet(LogicalKeyboardKey.keyF, LogicalKeyboardKey.control):
              const SearchIntent(),
        },
        child: Actions(
          actions: <Type, Action<Intent>>{
            SearchIntent: CallbackAction<SearchIntent>(
              onInvoke: (intent) {
                final currentPageId = di<RoutingManager>().selectedPageId;
                final searchModel = di<SearchModel>();
                searchModel.setAudioType(
                  switch (currentPageId) {
                    PageIDs.localAudio => AudioType.local,
                    PageIDs.radio => AudioType.radio,
                    _ => AudioType.podcast,
                  },
                );

                if (currentPageId == PageIDs.searchPage) {
                  di<RoutingManager>().pop();
                } else {
                  di<RoutingManager>().push(pageId: PageIDs.searchPage);
                }
                return null;
              },
            ),
          },
          child: RawGestureDetector(
            gestures: <Type, GestureRecognizerFactory>{
              _MouseBackButtonRecognizer: GestureRecognizerFactoryWithHandlers<
                  _MouseBackButtonRecognizer>(
                () => _MouseBackButtonRecognizer(),
                (instance) => instance.onTapDown =
                    (details) => di<RoutingManager>().pop(),
              ),
            },
            child: child,
          ),
        ),
      );
}

class SearchIntent extends Intent {
  const SearchIntent();
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
