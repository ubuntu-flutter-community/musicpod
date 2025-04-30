import 'package:flutter/material.dart';
import 'package:watch_it/watch_it.dart';

import '../../app/view/routing_manager.dart';
import '../../common/data/audio_type.dart';
import '../../common/page_ids.dart';
import '../../common/view/common_widgets.dart';
import '../../l10n/l10n.dart';
import '../../search/search_model.dart';

class OpenRadioSearchButton extends StatelessWidget with WatchItMixin {
  const OpenRadioSearchButton({super.key});

  @override
  Widget build(BuildContext context) {
    return ImportantButton(
      onPressed: () {
        di<RoutingManager>().push(pageId: PageIDs.searchPage);
        di<SearchModel>()
          ..setAudioType(AudioType.radio)
          ..search();
      },
      child: Text(context.l10n.discover),
    );
  }
}
