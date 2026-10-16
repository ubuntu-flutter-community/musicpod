import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lrc/lrc.dart';
import 'package:scroll_to_index/scroll_to_index.dart';
import 'package:yaru/yaru.dart';

import '../../common/data/audio.dart';
import '../../common/data/audio_type.dart';
import '../../common/data/retry_capsule.dart';
import '../../common/view/common_widgets.dart';
import '../../common/view/error_retry_body.dart';
import '../../common/view/progress.dart';
import '../../common/view/theme.dart';
import '../../common/view/ui_constants.dart';
import '../../extensions/build_context_x.dart';
import '../../extensions/string_x.dart';
import '../../extensions/theme_data_x.dart';
import '../../player/manager/current_audio_manager.dart';
import '../../player/manager/mpv_metadata_manager.dart';
import '../../player/manager/position_manager.dart';
import '../../settings/data/shared_preferences_keys.dart';
import '../../settings/manager/settings_manager.dart';
import '../data/lyrics_and_art_result_and_param.dart';
import '../lyrics_manager.dart';

class LyricsViewer extends ConsumerWidget {
  const LyricsViewer({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final audio = ref.watch(currentAudioManagerProvider);
    final splitByDash = ref
        .watch(mpvMetadataManagerProvider)
        ?.icyTitle
        .splitByDash;
    final title = audio?.audioType != AudioType.radio
        ? null
        : splitByDash?.songName;
    final artist = audio?.audioType != AudioType.radio
        ? null
        : splitByDash?.artist;

    final tryToFetchOnline =
        ref.watch(settingsBoolManagerProvider(SPKeys.tryToFetchLyricsOnline)) ??
        true;

    return _PlayerLyrics(
      audio: audio,
      title: title,
      artist: artist,
      tryToFetchOnline: tryToFetchOnline,
      autoScroll: audio?.isLocal ?? false,
      highlightCurrentLine: audio?.isLocal ?? false,
    );
  }
}

class _PlayerLyrics extends ConsumerStatefulWidget {
  const _PlayerLyrics({
    this.audio,
    this.title,
    this.artist,
    required this.tryToFetchOnline,
    required this.autoScroll,
    this.highlightCurrentLine = true,
  });

  final Audio? audio;
  final String? title;
  final String? artist;
  final bool tryToFetchOnline;
  final bool autoScroll;
  final bool highlightCurrentLine;

  @override
  ConsumerState<_PlayerLyrics> createState() => _PlayerLyricsState();
}

class _PlayerLyricsState extends ConsumerState<_PlayerLyrics> {
  late bool _autoScroll;

  @override
  void initState() {
    super.initState();
    _autoScroll = widget.autoScroll;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final retryViewId =
        '${widget.audio?.toString() ?? ''}_${widget.title ?? ''}_${widget.artist ?? ''}';

    final param = LyricsAndArtParam(
      audio: widget.audio,
      title: widget.title,
      artist: widget.artist,
      tryToFetchOnline: widget.tryToFetchOnline,
    );
    final lyricsAsync = ref.watch(lyricsManagerProvider(param));

    const padding = EdgeInsets.symmetric(
      vertical: kLargestSpace,
      horizontal: 2 * kLargestSpace,
    );

    return Column(
      spacing: kLargestSpace,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: switch (lyricsAsync) {
            AsyncLoading() => const Center(child: Progress()),
            AsyncError(:final error, :final stackTrace) => Center(
              child: ErrorRetryBody(
                error: error,
                errorText: context.l10n.fetchingLyricsOnlineFailed,
                stackTrace: stackTrace,
                errorTextStyle: context.textTheme.bodyLarge,
                retryCapsule: RetryCapsule(
                  retryViewId: retryViewId,
                  onRetry: () => ref.invalidate(lyricsManagerProvider(param)),
                ),
              ),
            ),
            AsyncData(value: final result) =>
              result == null
                  ? const NoLyricsFound()
                  : result.lrcLines != null && result.lrcLines!.isNotEmpty
                  ? _LrcLineViewer(
                      padding: padding,
                      lrc: result.lrcLines!,
                      autoScroll: _autoScroll,
                      highlightCurrentLine: widget.highlightCurrentLine,
                    )
                  : result.plainLyrics != null && result.plainLyrics!.isNotEmpty
                  ? SingleChildScrollView(
                      padding: padding,
                      child: SelectableText(
                        result.plainLyrics!.trim(),
                        style: getPlayerLyricsTextStyle(theme: context.theme),
                      ),
                    )
                  : const NoLyricsFound(),
          },
        ),
        Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 2 * kLargestSpace + kMediumPlusSpace,
          ),
          child: YaruExpandable(
            header: Text(l10n.settings),
            child: Column(
              children: [
                Consumer(
                  builder: (context, ref, _) {
                    final tryToFetch =
                        ref.watch(
                          settingsBoolManagerProvider(
                            SPKeys.tryToFetchLyricsOnline,
                          ),
                        ) ??
                        true;
                    return ListTile(
                      title: Text(l10n.tryToFetchLyricsOnlineTitle),
                      trailing: CommonSwitch(
                        value: tryToFetch,
                        onChanged: (v) => ref
                            .read(
                              settingsBoolManagerProvider(
                                SPKeys.tryToFetchLyricsOnline,
                              ).notifier,
                            )
                            .set(v),
                      ),
                    );
                  },
                ),
                ListTile(
                  trailing: CommonSwitch(
                    value: _autoScroll,
                    onChanged: (v) => setState(() => _autoScroll = v),
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

class _LrcLineViewer extends ConsumerStatefulWidget {
  const _LrcLineViewer({
    required this.lrc,
    required this.autoScroll,
    this.highlightCurrentLine = true,
    required this.padding,
  });

  final bool autoScroll;
  final List<LrcLine> lrc;
  final bool highlightCurrentLine;
  final EdgeInsets padding;

  @override
  ConsumerState<_LrcLineViewer> createState() => _LrcLineViewerState();
}

class _LrcLineViewerState extends ConsumerState<_LrcLineViewer> {
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
    final position = ref.watch(positionManagerProvider);
    final maybe = widget.lrc.firstWhereOrNull(
      (e) => e.timestamp.inSeconds == position?.inSeconds,
    );
    if (maybe != null && widget.highlightCurrentLine) {
      _selectedIndex = widget.lrc.indexOf(maybe);
    }

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
        padding: widget.padding,
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
