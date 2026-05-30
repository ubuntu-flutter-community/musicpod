import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_it/flutter_it.dart';
import 'package:lrc/lrc.dart';
import 'package:scroll_to_index/scroll_to_index.dart';
import 'package:yaru/constants.dart';

import '../../common/data/audio.dart';
import '../../common/data/audio_type.dart';
import '../../common/view/theme.dart';
import '../../common/view/ui_constants.dart';
import '../../extensions/build_context_x.dart';
import '../../extensions/string_x.dart';
import '../../extensions/theme_data_x.dart';
import '../../lyrics/data/lyrics_and_art_result_and_param.dart';
import '../../lyrics/lyrics_manager.dart';
import '../../lyrics/lyrics_service.dart';
import '../../settings/settings_model.dart';
import '../../settings/view/settings_action.dart';
import '../mpv_metadata_manager.dart';
import '../player_model.dart';

class PlayerLyrics extends StatelessWidget with WatchItMixin {
  const PlayerLyrics({super.key});

  @override
  Widget build(BuildContext context) {
    final audio = watchPropertyValue((PlayerModel m) => m.audio);
    final splitByDash = watchValue(
      (MpvMetadataManager m) =>
          m.mpvMetaDataCommand.select((cmd) => cmd?.icyTitle.splitByDash),
    );

    final title = audio?.audioType != AudioType.radio
        ? null
        : splitByDash?.songName;
    final artist = audio?.audioType != AudioType.radio
        ? null
        : splitByDash?.artist;

    final geniusAccessToken = watchPropertyValue(
      (SettingsModel m) => m.lyricsGeniusAccessToken,
    );
    final neverAskAgainForGeniusToken = watchPropertyValue(
      (SettingsModel m) => m.neverAskAgainForGeniusToken,
    );

    if (neverAskAgainForGeniusToken || audio == null) {
      return const NoLyricsFound();
    }

    if (geniusAccessToken == null || geniusAccessToken.isEmpty)
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
          Padding(
            padding: const EdgeInsets.only(bottom: kMediumSpace),
            child: Text(context.l10n.onlineLyricsNotSetup),
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

class _PlayerLyrics extends StatelessWidget with WatchItMixin {
  const _PlayerLyrics({required this.audio, this.title, this.artist});

  final Audio audio;
  final String? title;
  final String? artist;

  @override
  Widget build(BuildContext context) {
    callAfterEveryBuild((_, _) {
      di<LyricsManager>().maybeRunCommand(
        LyricsAndArtParam(audio: audio, title: title, artist: artist),
      );
    });

    final lyricsGeniusAccessToken = watchPropertyValue(
      (SettingsModel m) => m.lyricsGeniusAccessToken,
    );
    if (lyricsGeniusAccessToken?.isEmpty ?? true) {
      return const _OnlineLyricsNotSetup();
    }

    final results = watchValue((LyricsManager m) => m.command.results);

    if (results.hasError) {
      if (results.error is GeniusNotSetupException) {
        return const _OnlineLyricsNotSetup();
      }
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(kLargestSpace),
          child: Text(results.error.toString()),
        ),
      );
    }

    if (results.isRunning) {
      return const Center(child: CircularProgressIndicator());
    }

    final data = results.data;
    final lrcLines = data?.lrcLines;
    if (lrcLines?.isNotEmpty ?? false) {
      return _LrcLineViewer(lrc: lrcLines!);
    }

    final lyricsString = data?.lyricsString;
    if (lyricsString?.isNotEmpty ?? false) {
      return SingleChildScrollView(
        padding: const EdgeInsets.all(kLargestSpace),
        child: SelectableText(
          lyricsString!.trim(),
          style: getPlayerLyricsTextStyle(theme: context.theme),
        ),
      );
    }

    return const NoLyricsFound();
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

    final color = context.theme.contrastyPrimary;

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
          ),
        ),
        TextButton.icon(
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
        const SizedBox(height: kMediumSpace),
      ],
    );
  }
}
