import 'package:flutter/material.dart';
import 'package:watch_it/watch_it.dart';
import 'package:yaru/constants.dart';

import '../../../build_context_x.dart';
import '../../../globals.dart';
import '../../../player.dart';
import '../../../radio.dart';
import '../../../theme_data_x.dart';
import '../../common/icy_image.dart';
import '../../common/tapable_text.dart';
import '../../data/mpv_meta_data.dart';
import '../../theme.dart';

class RadioHistoryTile extends StatelessWidget with PlayerMixin {
  const RadioHistoryTile({super.key, required this.e, required this.selected});

  final MapEntry<String, MpvMetaData> e;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    final radioModel = di<RadioModel>();
    return ListTile(
      key: ValueKey(e.value.icyTitle),
      selected: selected,
      selectedColor: context.t.contrastyPrimary,
      contentPadding: const EdgeInsets.symmetric(horizontal: kYaruPagePadding),
      leading: IcyImage(
        height: yaruStyled ? 34 : 40,
        width: yaruStyled ? 34 : 40,
        mpvMetaData: e.value,
        onGenreTap: (tag) => radioModel.init().then(
              (_) => navigatorKey.currentState?.push(
                MaterialPageRoute(
                  builder: (context) {
                    return RadioSearchPage(
                      radioSearch: RadioSearch.tag,
                      searchQuery: tag.toLowerCase(),
                    );
                  },
                ),
              ),
            ),
      ),
      title: TapAbleText(
        overflow: TextOverflow.visible,
        maxLines: 10,
        text: e.value.icyTitle,
        onTap: () => onTitleTap(
          text: e.value.icyTitle,
          context: context,
        ),
      ),
      subtitle: TapAbleText(
        text: e.value.icyName,
        onTap: () {
          radioModel
              .getStations(
            radioSearch: RadioSearch.name,
            query: e.value.icyName,
          )
              .then((stations) {
            if (stations != null && stations.isNotEmpty) {
              onArtistTap(audio: stations.first, context: context);
            }
          });
        },
      ),
    );
  }
}
