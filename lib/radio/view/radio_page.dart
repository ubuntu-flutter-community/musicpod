import 'package:flutter/material.dart';
import 'package:watch_it/watch_it.dart';
import 'package:yaru/theme.dart';

import '../../app/connectivity_model.dart';
import '../../common/data/audio.dart';
import '../../common/view/header_bar.dart';
import '../../common/view/offline_page.dart';
import '../../common/view/search_button.dart';
import '../../common/view/theme.dart';
import '../../constants.dart';
import '../../l10n/l10n.dart';
import '../../library/library_model.dart';
import '../../search/search_model.dart';
import 'radio_lib_page.dart';

class RadioPage extends StatelessWidget with WatchItMixin {
  const RadioPage({super.key});

  @override
  Widget build(BuildContext context) {
    final isOnline = watchPropertyValue((ConnectivityModel m) => m.isOnline);
    if (!isOnline) return const OfflinePage();

    return Scaffold(
      resizeToAvoidBottomInset: isMobile ? false : null,
      appBar: HeaderBar(
        adaptive: true,
        actions: [
          Flexible(
            child: Padding(
              padding: appBarSingleActionSpacing,
              child: SearchButton(
                active: false,
                onPressed: () {
                  di<LibraryModel>().pushNamed(pageId: kSearchPageId);
                  di<SearchModel>()
                    ..setAudioType(AudioType.radio)
                    ..search();
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
}
