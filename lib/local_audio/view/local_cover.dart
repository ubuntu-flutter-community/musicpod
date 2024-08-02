import 'dart:typed_data';

import 'package:flutter/material.dart';

import '../../common/data/audio.dart';
import '../../constants.dart';
import '../cover_store.dart';

class LocalCover extends StatefulWidget {
  const LocalCover({
    super.key,
    required this.audio,
    required this.fallback,
    this.dimension,
    this.fit,
  });

  final Audio audio;
  final Widget fallback;
  final double? dimension;
  final BoxFit? fit;

  @override
  State<LocalCover> createState() => _LocalCoverState();
}

class _LocalCoverState extends State<LocalCover> {
  late Future<Uint8List?> _future;

  @override
  void initState() {
    super.initState();
    final init = CoverStore().get(widget.audio.albumId);
    _future = init != null ? Future.value(init) : getCover(widget.audio);
  }

  @override
  Widget build(BuildContext context) {
    Widget child = FutureBuilder(
      future: _future,
      builder: (context, snapshot) {
        if (!snapshot.hasData || snapshot.hasError) {
          return Container(
            key: const ValueKey(0),
            child: widget.fallback,
          );
        } else {
          return _buildImage(
            snapshot.data!,
            const ValueKey(1),
          );
        }
      },
    );

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 500),
      transitionBuilder: (Widget child, Animation<double> animation) {
        return FadeTransition(opacity: animation, child: child);
      },
      reverseDuration: const Duration(milliseconds: 500),
      child: child,
    );
  }

  Image _buildImage(Uint8List data, Key key) {
    final fit = widget.fit ?? BoxFit.fitHeight;
    const medium = FilterQuality.medium;
    final dim = widget.dimension ?? kAudioCardDimension;
    return Image.memory(
      key: key,
      data,
      fit: fit,
      height: dim,
      filterQuality: medium,
    );
  }
}
