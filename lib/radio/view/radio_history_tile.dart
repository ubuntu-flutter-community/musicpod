import 'package:flutter/material.dart';
import 'package:radio_browser_api/radio_browser_api.dart';
import 'package:watch_it/watch_it.dart';
import 'package:yaru/constants.dart';

import '../../common/data/audio.dart';
import '../../common/data/mpv_meta_data.dart';
import '../../common/view/icons.dart';
import '../../common/view/icy_image.dart';
import '../../common/view/mpv_metadata_dialog.dart';
import '../../common/view/tapable_text.dart';
import '../../common/view/theme.dart';
import '../../constants.dart';
import '../../extensions/build_context_x.dart';
import '../../extensions/theme_data_x.dart';
import '../../l10n/l10n.dart';
import '../../library/library_model.dart';
import '../../online_album_art_utils.dart';
import '../../player/player_mixin.dart';
import '../../search/search_model.dart';
import '../radio_model.dart';
import 'station_page.dart';

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
          (_) {
            di<LibraryModel>().pushNamed(kSearchPageId);
            di<SearchModel>()
              ..setTag(Tag(name: tag.toLowerCase(), stationCount: 1))
              ..setAudioType(AudioType.radio)
              ..search();
          },
        ),
      ),
      trailing: IconButton(
        tooltip: context.l10n.metadata,
        onPressed: () => showDialog(
          context: context,
          builder: (context) {
            final image = UrlStore().get(e.value.icyTitle);
            return MpvMetadataDialog(
              mpvMetaData: e.value,
              image: image,
            );
          },
        ),
        icon: Icon(
          Iconz().info,
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
          di<LibraryModel>().pushNamed(kSearchPageId);
          di<SearchModel>().radioNameSearch(e.value.icyName).then((v) {
            if (v?.firstOrNull?.urlResolved != null) {
              di<LibraryModel>().push(
                builder: (_) =>
                    StationPage(station: Audio.fromStation(v.first)),
                pageId: v!.first.urlResolved!,
              );
            }
          });
        },
      ),
    );
  }
}
