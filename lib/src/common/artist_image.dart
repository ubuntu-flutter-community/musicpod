import '../../build_context_x.dart';
import '../../common.dart';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:yaru_widgets/yaru_widgets.dart';

class ArtistImage extends StatelessWidget {
  const ArtistImage({
    super.key,
    this.images,
  });

  final Set<Uint8List>? images;

  @override
  Widget build(BuildContext context) {
    final theme = context.t;
    final boxShadow = BoxShadow(
      offset: const Offset(0, 0),
      spreadRadius: 1,
      blurRadius: 1,
      color: theme.shadowColor.withOpacity(0.4),
    );

    if (images?.length == 1) {
      return Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: MemoryImage(images!.first),
            fit: BoxFit.fitHeight,
            filterQuality: FilterQuality.medium,
          ),
          boxShadow: [
            boxShadow,
          ],
        ),
      );
    }

    if (images?.isNotEmpty == true) {
      if (images!.length >= 4) {
        return Container(
          decoration: BoxDecoration(
            boxShadow: [
              boxShadow,
            ],
          ),
          child: FourImagesGrid(
            images: images!,
          ),
        );
      } else if (images!.length >= 2) {
        return Container(
          decoration: BoxDecoration(
            image: DecorationImage(
              fit: BoxFit.fitHeight,
              image: MemoryImage(images!.first),
            ),
            boxShadow: [
              boxShadow,
            ],
          ),
          child: YaruClip.diagonal(
            position: YaruDiagonalClip.bottomLeft,
            child: Image.memory(
              images!.elementAt(1),
              fit: BoxFit.fitHeight,
              filterQuality: FilterQuality.medium,
            ),
          ),
        );
      }
    }

    return const SizedBox.shrink();
  }
}

class ArtistVignette extends StatelessWidget {
  const ArtistVignette({
    super.key,
    required this.text,
  });

  final String text;

  @override
  Widget build(BuildContext context) {
    final theme = context.t;

    return Center(
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(5.0),
        decoration: BoxDecoration(
          color: theme.colorScheme.inverseSurface,
          boxShadow: [
            BoxShadow(
              offset: const Offset(0, 1),
              color: Colors.black.withOpacity(0.3),
              blurRadius: 3,
              spreadRadius: 0.1,
            ),
          ],
        ),
        child: Text(
          text,
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.w100,
            fontSize: 15,
            color: theme.colorScheme.onInverseSurface,
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
