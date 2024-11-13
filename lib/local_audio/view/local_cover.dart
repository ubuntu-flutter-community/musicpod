import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:watch_it/watch_it.dart';

import '../local_cover_model.dart';

class LocalCover extends StatefulWidget with WatchItStatefulWidgetMixin {
  const LocalCover({
    super.key,
    required this.albumId,
    required this.path,
    required this.fallback,
    this.dimension,
    this.height,
    this.fit,
    this.width,
  });

  final String albumId;
  final String path;
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
    final localCoverModel = di<LocalCoverModel>();
    final init = localCoverModel.get(widget.albumId);
    _future = init != null
        ? Future.value(init)
        : localCoverModel.getCover(
            albumId: widget.albumId,
            path: widget.path,
          );
  }

  @override
  Widget build(BuildContext context) {
    watchPropertyValue((LocalCoverModel m) => m.store);
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
