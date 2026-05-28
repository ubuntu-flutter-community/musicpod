import 'package:flutter/material.dart';
import 'package:flutter_it/flutter_it.dart';
import 'package:podcast_search/podcast_search.dart';

import '../../common/view/icons.dart';
import '../../extensions/build_context_x.dart';
import '../../l10n/app_localizations.dart';
import '../search_manager.dart';

class PodcastSearchAttributePopupButton extends StatelessWidget
    with WatchItMixin {
  const PodcastSearchAttributePopupButton({super.key});

  @override
  Widget build(BuildContext context) {
    final attribute = watchValue((SearchManager m) => m.podcastSearchAttribute);
    return PopupMenuButton<Attribute>(
      icon: Icon(attribute.iconData),
      style: IconButton.styleFrom(shape: const RoundedRectangleBorder()),
      initialValue: attribute,
      onSelected: (value) => di<SearchManager>()
        ..setPodcastSearchAttribute(value)
        ..search(clear: true),
      itemBuilder: (context) => Attribute.values
          .map(
            (e) => PopupMenuItem(
              child: ListTile(
                title: Text(e.localize(context.l10n)),
                leading: Icon(e.iconData),
              ),
              value: e,
            ),
          )
          .toList(),
    );
  }
}

extension _AttributeX on Attribute {
  String localize(AppLocalizations l10n) => switch (this) {
    Attribute.none => l10n.all,
    Attribute.title => l10n.title,
    Attribute.language => l10n.language,
    Attribute.author => l10n.author,
    Attribute.genre => l10n.genre,
    Attribute.artist => l10n.artist,
    Attribute.rating => l10n.rating,
    Attribute.keywords => l10n.keywords,
    Attribute.description => l10n.description,
  };

  IconData get iconData => switch (this) {
    Attribute.none => Icons.filter_alt_outlined,
    Attribute.title => Icons.title,
    Attribute.language => Icons.translate,
    Attribute.author => Icons.copyright,
    Attribute.genre => Icons.type_specimen,
    Attribute.artist => Iconz.artist,
    Attribute.rating => Iconz.star,
    Attribute.keywords => Iconz.check,
    Attribute.description => Iconz.info,
  };
}
