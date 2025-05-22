import 'package:flutter/material.dart';
import 'package:watch_it/watch_it.dart';

import '../../app/view/routing_manager.dart';
import '../../common/data/audio.dart';
import '../../common/view/copy_clipboard_content.dart';
import '../../common/view/icons.dart';
import '../../common/view/modals.dart';
import '../../common/view/mpv_metadata_dialog.dart';
import '../../common/view/snackbars.dart';
import '../../common/view/tapable_text.dart';
import '../../common/view/ui_constants.dart';
import '../../extensions/build_context_x.dart';
import '../../extensions/theme_data_x.dart';
import '../../l10n/l10n.dart';
import '../../player/player_model.dart';
import '../../search/search_model.dart';
import '../../settings/settings_model.dart';
import '../online_art_model.dart';
import 'radio_history_tile_image.dart';
import 'station_page.dart';

enum _RadioHistoryTileVariant { regular, simple }

class RadioHistoryTile extends StatelessWidget with WatchItMixin {
  const RadioHistoryTile({
    super.key,
    required this.icyTitle,
    required this.selected,
    this.allowNavigation = true,
  }) : _variant = _RadioHistoryTileVariant.regular;

  const RadioHistoryTile.simple({
    super.key,
    required this.icyTitle,
    required this.selected,
    this.allowNavigation = false,
  }) : _variant = _RadioHistoryTileVariant.simple;

  final _RadioHistoryTileVariant _variant;
  final String icyTitle;
  final bool selected;
  final bool allowNavigation;

  @override
  Widget build(BuildContext context) {
    final icyName = di<PlayerModel>().getMetadata(icyTitle)?.icyName;
    final useYaruTheme = watchPropertyValue(
      (SettingsModel m) => m.useYaruTheme,
    );
    return switch (_variant) {
      _RadioHistoryTileVariant.simple => _SimpleRadioHistoryTile(
        key: ValueKey(icyTitle),
        icyTitle: icyTitle,
        selected: selected,
      ),
      _RadioHistoryTileVariant.regular => ListTile(
        key: ValueKey(icyTitle),
        selected: selected,
        selectedColor: context.theme.contrastyPrimary,
        contentPadding: const EdgeInsets.symmetric(horizontal: kLargestSpace),
        leading: RadioHistoryTileImage(
          key: ValueKey(icyTitle),
          height: useYaruTheme ? 34 : 40,
          width: useYaruTheme ? 34 : 40,
          icyTitle: icyTitle,
        ),
        trailing: IconButton(
          tooltip: context.l10n.metadata,
          onPressed: () {
            final imageUrl = di<OnlineArtModel>().getCover(icyTitle);
            final metadata = di<PlayerModel>().getMetadata(icyTitle);
            if (metadata == null) return;

            showModal(
              mode: ModalMode.platformModalMode,
              context: context,
              content: MpvMetadataDialog(
                mode: ModalMode.platformModalMode,
                image: imageUrl,
                mpvMetaData: metadata,
              ),
            );
          },
          icon: Icon(Iconz.info),
        ),
        title: TapAbleText(
          overflow: TextOverflow.visible,
          maxLines: 10,
          text: icyTitle,
          onTap: () => showSnackBar(
            context: context,
            content: CopyClipboardContent(text: icyTitle),
          ),
        ),
        subtitle: TapAbleText(
          text: icyName ?? context.l10n.station,
          onTap: !allowNavigation || icyName == null
              ? null
              : () async {
                  di<SearchModel>().radioNameSearch(icyName).then((v) {
                    if (v?.firstOrNull?.stationUUID != null) {
                      di<RoutingManager>().push(
                        builder: (_) =>
                            StationPage(uuid: Audio.fromStation(v.first).uuid!),
                        pageId: v!.first.stationUUID,
                      );
                    }
                  });
                },
        ),
      ),
    };
  }
}

class _SimpleRadioHistoryTile extends StatelessWidget {
  const _SimpleRadioHistoryTile({
    super.key,
    required this.icyTitle,
    required this.selected,
  });

  final String icyTitle;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      selected: selected,
      selectedColor: context.theme.colorScheme.onSurface,
      contentPadding: const EdgeInsets.symmetric(horizontal: kLargestSpace),
      leading: Visibility(visible: selected, child: const Text('>')),
      trailing: Visibility(visible: selected, child: const Text('<')),
      title: TapAbleText(
        overflow: TextOverflow.visible,
        maxLines: 10,
        text: icyTitle,
        onTap: () => showSnackBar(
          context: context,
          content: CopyClipboardContent(text: icyTitle),
        ),
      ),
      subtitle: Text(
        di<PlayerModel>().getMetadata(icyTitle)?.icyName ??
            context.l10n.station,
      ),
    );
  }
}
