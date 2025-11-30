import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_it/flutter_it.dart';
import 'package:lrc/lrc.dart';
import 'package:scroll_to_index/scroll_to_index.dart';
import 'package:yaru/constants.dart';

import '../../common/data/audio.dart';
import '../../common/view/ui_constants.dart';
import '../../extensions/build_context_x.dart';
import '../../l10n/l10n.dart';
import '../../lyrics/lyrics_service.dart';
import '../../settings/settings_model.dart';
import '../../settings/view/settings_action.dart';
import '../player_model.dart';

class PlayerLyrics extends StatelessWidget with WatchItMixin {
  const PlayerLyrics({super.key, required this.audio, this.title, this.artist});

  final Audio audio;
  final String? title;
  final String? artist;

  @override
  Widget build(BuildContext context) {
    final geniusAccessToken = watchPropertyValue(
      (SettingsModel m) => m.lyricsGeniusAccessToken,
    );
    final neverAskAgainForGeniusToken = watchPropertyValue(
      (SettingsModel m) => m.neverAskAgainForGeniusToken,
    );

    if ((geniusAccessToken == null || geniusAccessToken.isEmpty) &&
        !neverAskAgainForGeniusToken)
      return const _OnlineLyricsNotSetup();

    return _PlayerLyrics(audio: audio, title: title, artist: artist);
  }
}

class _OnlineLyricsNotSetup extends StatelessWidget {
  const _OnlineLyricsNotSetup();

  @override
  Widget build(BuildContext context) => Center(
    child: SizedBox(
      width: 300,
      child: Column(
        spacing: kMediumSpace,
        children: [
          // TODO: localize
          const Padding(
            padding: const EdgeInsets.only(bottom: kMediumSpace),
            child: Text(
              'If you want to fetch lyrics from Genius, please provide an API key '
              'in the settings.',
            ),
          ),
          const SettingsButton.important(scrollIndex: 7),
          OutlinedButton(
            onPressed: () =>
                di<SettingsModel>().setNeverAskAgainForGeniusToken(true),
            child: Text(context.l10n.doNotAskAgain),
          ),
        ].map((e) => SizedBox(width: double.infinity, child: e)).toList(),
      ),
    ),
  );
}

class _PlayerLyrics extends StatefulWidget with WatchItStatefulWidgetMixin {
  const _PlayerLyrics({required this.audio, this.title, this.artist});

  final Audio audio;
  final String? title;
  final String? artist;

  @override
  State<_PlayerLyrics> createState() => __PlayerLyricsState();
}

class __PlayerLyricsState extends State<_PlayerLyrics> {
  late final Future<({String? outputString, List<LrcLine>? outputLrcLines})?>
  _lyricsFuture;

  @override
  void initState() {
    super.initState();
    _lyricsFuture = _getLyrics();
  }

  Future<({String? outputString, List<LrcLine>? outputLrcLines})?>
  _getLyrics() async {
    final local = di<LocalLyricsService>().parseLocalLyrics(
      filePath: widget.audio.path,
      inputString: widget.audio.lyrics,
    );

    if (local?.outputLrcLines?.isNotEmpty ?? false) {
      return local;
    }
    if (local?.outputString?.isNotEmpty ?? false) {
      return local;
    }

    return di<OnlineLyricsService>().fetchLyricsFromGenius(
      title: widget.title ?? widget.audio.title ?? '',
      artist: widget.artist ?? widget.audio.artist,
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<
      ({String? outputString, List<LrcLine>? outputLrcLines})?
    >(
      future: _lyricsFuture,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          if (snapshot.error is GeniusNotSetupException) {
            return const _OnlineLyricsNotSetup();
          }
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(kLargestSpace),
              child: Text(snapshot.error.toString()),
            ),
          );
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final data = snapshot.data;
        final lrcLines = data?.outputLrcLines;
        if (lrcLines?.isNotEmpty ?? false) {
          return _LrcLineViewer(lrc: lrcLines!);
        }

        final lyricsString = data?.outputString;
        if (lyricsString?.isNotEmpty ?? false) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(kLargestSpace),
            child: Text(lyricsString!),
          );
        }

        return const NoLyricsFound();
      },
    );
  }
}

class NoLyricsFound extends StatelessWidget {
  const NoLyricsFound({super.key});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.topCenter,
      child: Padding(
        padding: const EdgeInsets.all(kLargestSpace),
        child: Text(context.l10n.noLyricsFound),
      ),
    );
  }
}

class _LrcLineViewer extends StatefulWidget with WatchItStatefulWidgetMixin {
  const _LrcLineViewer({required this.lrc});

  final List<LrcLine> lrc;

  @override
  State<_LrcLineViewer> createState() => _LrcLineViewerState();
}

class _LrcLineViewerState extends State<_LrcLineViewer> {
  late AutoScrollController _controller;
  int? _selectedIndex;
  bool _autoScroll = true;

  @override
  void initState() {
    super.initState();
    _controller = AutoScrollController();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    watchPropertyValue((PlayerModel m) {
      final maybe = widget.lrc.firstWhereOrNull(
        (e) => e.timestamp.inSeconds == m.position?.inSeconds,
      );
      if (maybe != null) {
        _selectedIndex = widget.lrc.indexOf(maybe);
      }

      return m.position;
    });

    if (_selectedIndex != null && _autoScroll) {
      _controller.scrollToIndex(
        _selectedIndex!,
        preferPosition: AutoScrollPosition.middle,
      );
    }

    final color = watchPropertyValue(
      (PlayerModel m) => m.color ?? context.colorScheme.primary,
    );

    return Column(
      spacing: kLargestSpace,
      children: [
        Expanded(
          child: ScrollConfiguration(
            behavior: ScrollConfiguration.of(
              context,
            ).copyWith(scrollbars: !_autoScroll),
            child: ListView.builder(
              controller: _controller,
              itemCount: widget.lrc.length,
              itemBuilder: (context, index) => AutoScrollTag(
                index: index,
                controller: _controller,
                key: ValueKey(index),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  child: ListTile(
                    key: ValueKey('${index}_tile'),
                    selected: _selectedIndex == index,
                    selectedTileColor: Colors.transparent,
                    selectedColor: color,
                    title: Text(
                      widget.lrc.elementAt(index).lyrics,
                      style: context.textTheme.bodyLarge?.copyWith(
                        fontSize: _selectedIndex == index ? 18 : 15,
                        fontWeight: _selectedIndex == index
                            ? FontWeight.bold
                            : FontWeight.w300,
                        color: _selectedIndex == index ? color : null,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
        SizedBox(
          width: 200,
          child: TextButton.icon(
            style: TextButton.styleFrom(
              iconColor: _autoScroll ? color : context.colorScheme.onSurface,
              foregroundColor: _autoScroll
                  ? color
                  : context.colorScheme.onSurface,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(kYaruButtonRadius),
              ),
            ),
            onPressed: () => setState(() => _autoScroll = !_autoScroll),
            label: Text(context.l10n.autoScrolling, maxLines: 1),
            icon: const Icon(Icons.auto_awesome),
          ),
        ),
      ],
    );
  }
}
