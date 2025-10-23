import 'dart:io';

import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:lrc/lrc.dart';
import 'package:path/path.dart';
import 'package:scroll_to_index/scroll_to_index.dart';
import 'package:watch_it/watch_it.dart';
import 'package:path/path.dart' as p;

import '../../common/data/audio.dart';
import '../../extensions/build_context_x.dart';
import '../player_model.dart';

class PlayerLyrics extends StatefulWidget with WatchItStatefulWidgetMixin {
  const PlayerLyrics({
    super.key,
    required this.audio,
    required this.width,
    required this.height,
  });

  final Audio audio;
  final double width;
  final double height;

  @override
  State<PlayerLyrics> createState() => _PlayerLyricsState();
}

class _PlayerLyricsState extends State<PlayerLyrics> {
  late AutoScrollController _controller;
  int? _selectedIndex;

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

    final color = watchPropertyValue(
      (PlayerModel m) => m.color ?? context.colorScheme.primary,
    );

    return SizedBox(
      height: widget.height,
      width: widget.width,
      child: ListView.builder(
        controller: _controller,
        itemCount: lrc!.length,
        itemBuilder: (context, index) => ListTile(
          key: ValueKey(index),
          selected: _selectedIndex == index,
          selectedColor: color,
          title: Text(lrc!.elementAt(index).lyrics),
        ),
      ),
    );
  }
}
