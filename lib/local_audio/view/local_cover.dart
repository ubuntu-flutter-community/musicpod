import 'dart:typed_data';

import 'package:flutter/material.dart';

import '../../common/data/audio.dart';
import '../cover_store.dart';

class LocalCover extends StatefulWidget {
  const LocalCover({
    super.key,
    required this.audio,
    required this.fallback,
    this.dimension,
    this.height,
    this.fit,
    this.width,
  });

  final Audio audio;
  final Widget fallback;
  final double? dimension;
  final double? height;
  final double? width;
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
    final fit = widget.fit ?? BoxFit.fitHeight;
    const medium = FilterQuality.medium;

    Widget child = FutureBuilder(
      future: _future,
      builder: (context, snapshot) {
        if (!snapshot.hasData || snapshot.hasError) {
          return Container(
            key: const ValueKey(0),
            child: widget.fallback,
          );
        } else {
          return Image.memory(
            key: const ValueKey(1),
            snapshot.data!,
            fit: fit,
            height: widget.dimension ?? widget.height,
            width: widget.width,
            filterQuality: medium,
          );
        }
      },
    );

    return SizedBox(
      height: widget.dimension ?? widget.height,
      width: widget.dimension ?? widget.width,
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 500),
        transitionBuilder: (Widget child, Animation<double> animation) =>
            FadeTransition(opacity: animation, child: child),
        reverseDuration: const Duration(milliseconds: 500),
        child: child,
      ),
    );
  }
}
