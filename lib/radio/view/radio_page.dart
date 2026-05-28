import 'package:flutter/material.dart';
import 'package:flutter_it/flutter_it.dart';

import '../../app/page_ids.dart';
import '../../app/routing_manager.dart';
import '../../common/data/audio_type.dart';
import '../../common/view/header_bar.dart';
import '../../common/view/search_button.dart';
import '../../common/view/theme.dart';
import '../../extensions/build_context_x.dart';
import '../../search/search_manager.dart';
import '../../search/search_type.dart';
import 'radio_lib_page.dart';

class RadioPage extends StatelessWidget {
  const RadioPage({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: HeaderBar(
      actions: [
        Flexible(
          child: Padding(
            padding: appBarSingleActionSpacing,
            child: SearchButton(
              active: false,
              onPressed: () {
                di<RoutingManager>().push(pageId: PageIDs.searchPage);
                final searchManager = di<SearchManager>();
                if (searchManager.audioType != AudioType.radio) {
                  searchManager
                    ..setAudioType(AudioType.radio)
                    ..setSearchType(SearchType.radioName)
                    ..setSearchQuery('')
                    ..search(clear: true);
                }
              },
            ),
          ),
        ),
      ],
      title: Text('${context.l10n.radio} ${context.l10n.collection}'),
    ),
    body: const RadioLibPage(),
  );
}
