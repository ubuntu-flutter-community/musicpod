import 'package:flutter/material.dart';
import 'package:watch_it/watch_it.dart';

import '../../common/data/audio_type.dart';
import '../../common/view/common_widgets.dart';
import '../../constants.dart';
import '../../l10n/l10n.dart';
import '../../library/library_model.dart';
import '../../search/search_model.dart';

class OpenRadioSearchButton extends StatelessWidget with WatchItMixin {
  const OpenRadioSearchButton({super.key});

  @override
  Widget build(BuildContext context) {
    return ImportantButton(
      onPressed: () {
        di<LibraryModel>().push(pageId: kSearchPageId);
        di<SearchModel>()
          ..setAudioType(AudioType.radio)
          ..search();
      },
      child: Text(context.l10n.discover),
    );
  }
}
