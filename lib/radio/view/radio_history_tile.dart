import 'package:flutter/material.dart';
import 'package:watch_it/watch_it.dart';
import 'package:yaru/constants.dart';
import 'package:yaru/yaru.dart';

import '../../common/data/audio.dart';
import '../../common/data/mpv_meta_data.dart';
import '../../common/view/copy_clipboard_content.dart';
import '../../common/view/icons.dart';
import '../../common/view/mpv_metadata_dialog.dart';
import '../../common/view/snackbars.dart';
import '../../common/view/tapable_text.dart';
import '../../common/view/theme.dart';
import '../../extensions/build_context_x.dart';
import '../../extensions/theme_data_x.dart';
import '../../l10n/l10n.dart';
import '../../library/library_model.dart';
import '../../search/search_model.dart';
import '../radio_model.dart';
import 'icy_image.dart';
import 'station_page.dart';

enum _RadioHistoryTileVariant { regular, simple }

class RadioHistoryTile extends StatelessWidget {
  const RadioHistoryTile({
    super.key,
    required this.entry,
    required this.selected,
  }) : _variant = _RadioHistoryTileVariant.regular;

  const RadioHistoryTile.simple({
    super.key,
    required this.entry,
    required this.selected,
  }) : _variant = _RadioHistoryTileVariant.simple;

  final _RadioHistoryTileVariant _variant;
  final MapEntry<String, MpvMetaData> entry;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    return switch (_variant) {
      _RadioHistoryTileVariant.simple => _SimpleRadioHistoryTile(
          key: ValueKey(entry.value.icyTitle),
          entry: entry,
          selected: selected,
        ),
      _RadioHistoryTileVariant.regular => ListTile(
          key: ValueKey(entry.value.icyTitle),
          selected: selected,
          selectedColor: context.theme.contrastyPrimary,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: kYaruPagePadding),
          leading: IcyImage(
            key: ValueKey(entry.value.icyTitle),
            height: yaruStyled ? 34 : 40,
            width: yaruStyled ? 34 : 40,
            mpvMetaData: entry.value,
          ),
          trailing: IconButton(
            tooltip: context.l10n.metadata,
            onPressed: () => showDialog(
              context: context,
              builder: (context) {
                final image = di<RadioModel>().getCover(entry.value.icyTitle);
                return MpvMetadataDialog(
                  mpvMetaData: entry.value,
                  image: image,
                );
              },
            ),
            icon: Icon(
              Iconz.info,
            ),
          ),
          title: TapAbleText(
            overflow: TextOverflow.visible,
            maxLines: 10,
            text: entry.value.icyTitle,
            onTap: () => showSnackBar(
              context: context,
              content: CopyClipboardContent(text: entry.value.icyTitle),
            ),
          ),
          subtitle: TapAbleText(
            text: entry.value.icyName,
            onTap: () async {
              final libraryModel = di<LibraryModel>();
              if (libraryModel.selectedPageId == entry.value.icyUrl) return;

              await di<RadioModel>().init();
              di<SearchModel>().radioNameSearch(entry.value.icyName).then((v) {
                if (v?.firstOrNull?.stationUUID != null) {
                  libraryModel.push(
                    builder: (_) =>
                        StationPage(station: Audio.fromStation(v.first)),
                    pageId: v!.first.stationUUID,
                  );
                }
              });
            },
          ),
        )
    };
  }
}

class _SimpleRadioHistoryTile extends StatelessWidget {
  const _SimpleRadioHistoryTile({
    super.key,
    required this.entry,
    required this.selected,
  });

  final MapEntry<String, MpvMetaData> entry;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      key: ValueKey(entry.value.icyTitle),
      selected: selected,
      selectedColor: context.theme.colorScheme.onSurface,
      contentPadding: const EdgeInsets.symmetric(horizontal: kYaruPagePadding),
      leading: Visibility(
        visible: selected,
        child: const Text('>'),
      ),
      trailing: Visibility(
        visible: selected,
        child: const Text('<'),
      ),
      title: TapAbleText(
        overflow: TextOverflow.visible,
        maxLines: 10,
        text: entry.value.icyTitle,
        onTap: () => showSnackBar(
          context: context,
          content: CopyClipboardContent(text: entry.value.icyTitle),
        ),
      ),
      subtitle: Text(
        entry.value.icyName,
      ),
    );
  }
}
