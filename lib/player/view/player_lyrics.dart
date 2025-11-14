import 'dart:io';

import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:lrc/lrc.dart';
import 'package:path/path.dart' as p;
import 'package:path/path.dart';
import 'package:scroll_to_index/scroll_to_index.dart';
import 'package:flutter_it/flutter_it.dart';
import 'package:yaru/constants.dart';

import '../../common/data/audio.dart';
import '../../common/view/ui_constants.dart';
import '../../extensions/build_context_x.dart';
import '../../l10n/l10n.dart';
import '../player_model.dart';

class PlayerLyrics extends StatefulWidget with WatchItStatefulWidgetMixin {
  const PlayerLyrics({super.key, required this.audio});

  final Audio audio;

  @override
  State<PlayerLyrics> createState() => _PlayerLyricsState();
}

class _PlayerLyricsState extends State<PlayerLyrics> {
  late AutoScrollController _controller;
  int? _selectedIndex;
  bool _autoScroll = true;

  List<LrcLine>? lrc;
  String? lyricsString;

  @override
  void initState() {
    super.initState();
    _controller = AutoScrollController();

    if (widget.audio.lyrics != null) {
      if (widget.audio.lyrics!.isValidLrc) {
        lrc = Lrc.parse(widget.audio.lyrics!).lyrics;
      } else {
        lyricsString = widget.audio.lyrics;
      }
    } else {
      if (widget.audio.path != null) {
        final base = basenameWithoutExtension(widget.audio.path!);
        final dir = File(widget.audio.path!).parent;
        final maybe = p.join(dir.path, base + '.lrc');
        final file = File(maybe);
        if (file.existsSync()) {
          final lrcString = file.readAsStringSync();
          if (lrcString.isValidLrc) {
            lrc = Lrc.parse(lrcString).lyrics;
          } else {
            lyricsString = lrcString;
          }
        }
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (lyricsString != null) {
      return Text(lyricsString!);
    }

    if (lrc == null || lrc!.isEmpty) {
      return const Text('no lyrcis found');
    }

    watchPropertyValue((PlayerModel m) {
      final maybe = lrc?.firstWhereOrNull(
        (e) => e.timestamp.inSeconds == m.position?.inSeconds,
      );
      if (maybe != null) {
        _selectedIndex = lrc?.indexOf(maybe);
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
              itemCount: lrc!.length,
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
                      lrc!.elementAt(index).lyrics,
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
