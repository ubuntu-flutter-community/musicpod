import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_it/flutter_it.dart';
import 'package:lrc/lrc.dart';
import 'package:scroll_to_index/scroll_to_index.dart';
import 'package:yaru/yaru.dart';

import '../../common/data/audio.dart';
import '../../common/data/audio_type.dart';
import '../../common/view/common_widgets.dart';
import '../../common/view/error_retry_body.dart';
import '../../common/view/theme.dart';
import '../../common/view/ui_constants.dart';
import '../../extensions/build_context_x.dart';
import '../../extensions/command_x.dart';
import '../../extensions/string_x.dart';
import '../../extensions/theme_data_x.dart';
import '../data/lyrics_and_art_result_and_param.dart';
import '../lyrics_manager.dart';
import '../../settings/settings_manager.dart';
import '../../player/mpv_metadata_manager.dart';
import '../../player/player_manager.dart';

class LyricsViewer extends StatelessWidget with WatchItMixin {
  const LyricsViewer({super.key});

  @override
  Widget build(BuildContext context) {
    final audio = watchPropertyValue((PlayerManager m) => m.audio);
    final splitByDash = watchValue(
      (MpvMetadataManager m) =>
          m.mpvMetaDataCommand.select((cmd) => cmd?.icyTitle.splitByDash),
    );
    final tryToFetchOnline = watchPropertyValue(
      (SettingsManager m) => m.tryToFetchLyricsOnline,
    );

    final title = audio?.audioType != AudioType.radio
        ? null
        : splitByDash?.songName;
    final artist = audio?.audioType != AudioType.radio
        ? null
        : splitByDash?.artist;

    return _PlayerLyrics(
      audio: audio,
      title: title,
      artist: artist,
      tryToFetchOnline: tryToFetchOnline,
    );
  }
}

class _PlayerLyrics extends StatefulWidget with WatchItStatefulWidgetMixin {
  const _PlayerLyrics({
    this.audio,
    this.title,
    this.artist,
    required this.tryToFetchOnline,
  });

  final Audio? audio;
  final String? title;
  final String? artist;
  final bool tryToFetchOnline;

  @override
  State<_PlayerLyrics> createState() => _PlayerLyricsState();
}

class _PlayerLyricsState extends State<_PlayerLyrics> {
  bool autoScroll = true;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    callAfterEveryBuild((_, _) {
      di<LyricsManager>().command.runRestricted(
        param: LyricsAndArtParam(
          audio: widget.audio,
          title: widget.title,
          artist: widget.artist,
          tryToFetchOnline: widget.tryToFetchOnline,
        ),
        runWhen: RunWhen.paramChanges,
      );
    });

    return Column(
      spacing: kLargestSpace,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: watchValue((LyricsManager m) => m.command.results).toWidget(
            whileRunning: (lastResult, param) =>
                const Center(child: CircularProgressIndicator()),
            onError: (error, lastResult, param) => Center(
              child: ErrorRetryBody(
                error: error,
                errorTextStyle: context.textTheme.bodyLarge,
                onRetry: () => di<LyricsManager>().command.runRestricted(
                  param: LyricsAndArtParam(
                    audio: widget.audio,
                    title: widget.title,
                    artist: widget.artist,
                    tryToFetchOnline: widget.tryToFetchOnline,
                  ),
                  immediatelyClearErrors: true,
                  runWhen: RunWhen.hasNoValueAndNoErrors,
                ),
              ),
            ),
            onNullData: (param) => const NoLyricsFound(),
            onData: (result, param) =>
                result!.lrcLines != null && result.lrcLines!.isNotEmpty
                ? _LrcLineViewer(lrc: result.lrcLines!, autoScroll: autoScroll)
                : result.plainLyrics != null && result.plainLyrics!.isNotEmpty
                ? SingleChildScrollView(
                    padding: const EdgeInsets.all(kLargestSpace),
                    child: SelectableText(
                      result.plainLyrics!.trim(),
                      style: getPlayerLyricsTextStyle(theme: context.theme),
                    ),
                  )
                : const NoLyricsFound(),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: kMediumPlusSpace),
          child: YaruExpandable(
            header: Text(l10n.settings),
            child: Column(
              children: [
                YaruTile(
                  title: Text(l10n.tryToFetchLyricsOnlineTitle),
                  trailing: CommonSwitch(
                    value: watchPropertyValue(
                      (SettingsManager m) => m.tryToFetchLyricsOnline,
                    ),
                    onChanged: di<SettingsManager>().setTryToFetchLyricsOnline,
                  ),
                ),
                YaruTile(
                  trailing: CommonSwitch(
                    value: autoScroll,
                    onChanged: (v) => setState(() => autoScroll = v),
                  ),
                  title: Text(context.l10n.autoScrolling, maxLines: 1),
                ),
                const SizedBox(height: kMediumSpace),
              ],
            ),
          ),
        ),
        const SizedBox(height: kMediumSpace),
      ],
    );
  }
}

class NoLyricsFound extends StatelessWidget {
  const NoLyricsFound({super.key});

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.all(kLargestSpace),
    child: Text(context.l10n.noLyricsFound),
  );
}

class _LrcLineViewer extends StatefulWidget with WatchItStatefulWidgetMixin {
  const _LrcLineViewer({required this.lrc, required this.autoScroll});

  final bool autoScroll;
  final List<LrcLine> lrc;

  @override
  State<_LrcLineViewer> createState() => _LrcLineViewerState();
}

class _LrcLineViewerState extends State<_LrcLineViewer> {
  late AutoScrollController _controller;
  int? _selectedIndex;

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
    watchPropertyValue((PlayerManager m) {
      final maybe = widget.lrc.firstWhereOrNull(
        (e) => e.timestamp.inSeconds == m.position?.inSeconds,
      );
      if (maybe != null) {
        _selectedIndex = widget.lrc.indexOf(maybe);
      }

      return m.position;
    });

    if (_selectedIndex != null && widget.autoScroll) {
      _controller.scrollToIndex(
        _selectedIndex!,
        preferPosition: AutoScrollPosition.middle,
      );
    }

    final color = context.theme.contrastyPrimary;
    return ScrollConfiguration(
      behavior: ScrollConfiguration.of(
        context,
      ).copyWith(scrollbars: !widget.autoScroll),
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
                style: getPlayerLyricsTextStyle(
                  theme: context.theme,
                  index: index,
                  selectedIndex: _selectedIndex,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
