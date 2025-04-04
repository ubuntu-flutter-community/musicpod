import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:watch_it/watch_it.dart';

import '../../l10n/l10n.dart';
import '../local_cover_model.dart';
import 'failed_import_snackbar.dart';

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
  Uint8List? _cover;

  @override
  void initState() {
    super.initState();
    final localCoverModel = di<LocalCoverModel>();
    _cover = localCoverModel.get(widget.albumId);
    _future = _cover != null
        ? Future.value(_cover)
        : localCoverModel.getCover(
            albumId: widget.albumId,
            path: widget.path,
            onError: () => showFailedImportsSnackBar(
              failedImports: [widget.path],
              context: context,
              message: context.l10n.failedToReadMetadata,
            ),
          );
  }

  @override
  Widget build(BuildContext context) {
    if (_cover == null) {
      watchPropertyValue((LocalCoverModel m) => m.storeLength);
      _cover = di<LocalCoverModel>().get(widget.albumId);
    }
    final fit = widget.fit ?? BoxFit.fitHeight;
    const medium = FilterQuality.medium;

    Widget child = _cover != null
        ? Image.memory(
            key: ValueKey(widget.albumId),
            _cover!,
            fit: fit,
            height: widget.dimension ?? widget.height,
            width: widget.width,
            filterQuality: medium,
          )
        : FutureBuilder(
            future: _future,
            builder: (context, snapshot) {
              if (!snapshot.hasData || snapshot.hasError) {
                return Container(
                  key: ValueKey('${widget.albumId}1'),
                  child: widget.fallback,
                );
              } else {
                return Image.memory(
                  key: ValueKey('${widget.albumId}2'),
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
        duration: const Duration(milliseconds: 200),
        transitionBuilder: (Widget child, Animation<double> animation) =>
            FadeTransition(opacity: animation, child: child),
        reverseDuration: const Duration(milliseconds: 200),
        child: child,
      ),
    );
  }
}
