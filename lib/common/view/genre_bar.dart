import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:watch_it/watch_it.dart';

import '../../app/view/routing_manager.dart';
import '../data/audio.dart';
import 'tapable_text.dart';
import '../../extensions/build_context_x.dart';
import '../../extensions/theme_data_x.dart';
import '../../local_audio/view/genre_page.dart';

class GenreBar extends StatelessWidget {
  const GenreBar({super.key, required this.audios});

  final List<Audio> audios;

  @override
  Widget build(BuildContext context) {
    final style = context.theme.pageHeaderDescription;
    final Set<String> genres = {};
    for (var e in audios) {
      final g = e.genre?.trim();
      if (g?.isNotEmpty == true) {
        genres.add(g!);
      }
    }

    return SingleChildScrollView(
      child: Wrap(
        alignment: WrapAlignment.center,
        runAlignment: WrapAlignment.center,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: genres
            .mapIndexed(
              (i, e) => Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TapAbleText(
                    style: style,
                    wrapInFlexible: false,
                    text: e,
                    onTap: () => di<RoutingManager>().push(
                      builder: (context) => GenrePage(genre: e),
                      pageId: e,
                    ),
                  ),
                  if (i != genres.length - 1) const Text(' · '),
                ],
              ),
            )
            .toList(),
      ),
    );
  }
}
