import 'dart:io';
import 'dart:typed_data';

import 'package:audio_metadata_reader/audio_metadata_reader.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import 'package:yaru/yaru.dart';

import '../../common/data/audio.dart';
import '../../common/view/icons.dart';
import '../../constants.dart';
import '../../extensions/build_context_x.dart';
import '../../extensions/theme_data_x.dart';
import '../cover_store.dart';

class LocalCover extends StatefulWidget {
  const LocalCover({
    super.key,
    required this.audio,
    this.fallback,
    this.dimension,
    this.fit,
  });

  final Audio audio;
  final Widget? fallback;
  final double? dimension;
  final BoxFit? fit;

  @override
  State<LocalCover> createState() => _LocalCoverState();
}

class _LocalCoverState extends State<LocalCover> {
  late Future<Uint8List?> _future;

  Future<Uint8List?> _getCover() async {
    if (widget.audio.path != null && widget.audio.albumId?.isNotEmpty == true) {
      final metadata =
          await readMetadata(File(widget.audio.path!), getImage: true);
      return CoverStore().put(
        albumId: widget.audio.albumId!,
        data: metadata.pictures
            .firstWhereOrNull((e) => e.bytes.isNotEmpty)
            ?.bytes,
      );
    }

    return null;
  }

  @override
  void initState() {
    super.initState();
    _future = _getCover();
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.t;
    final fit = widget.fit ?? BoxFit.fitHeight;
    const medium = FilterQuality.medium;
    final dim = widget.dimension ?? kAudioCardDimension;
    final maybeData = CoverStore().get(widget.audio.albumId);

    if (maybeData != null) {
      return Image.memory(
        maybeData,
        fit: fit,
        height: dim,
        filterQuality: medium,
      );
    }

    return FutureBuilder(
      future: _future,
      builder: (context, snapshot) {
        final maybe = snapshot.data;

        if (snapshot.hasError) {
          widget.fallback ?? Icon(Iconz().musicNote);
        }

        if (maybe == null) {
          return widget.fallback ??
              Shimmer.fromColors(
                baseColor: theme.cardColor,
                highlightColor: theme.isLight
                    ? theme.cardColor.scale(lightness: -0.01)
                    : theme.cardColor.scale(lightness: 0.01),
                child: Container(
                  color: theme.cardColor,
                ),
              );
        }

        return Image.memory(
          CoverStore().put(albumId: widget.audio.albumId!, data: maybe)!,
          fit: fit,
          height: dim,
          filterQuality: medium,
        );
      },
    );
  }
}
