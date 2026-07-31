import 'package:flutter/material.dart';
import 'package:flutter_it/flutter_it.dart';

import '../../app/data/play_anywhere_param.dart';
import '../../app/play_anywhere_manager.dart';
import '../../app/routing_manager.dart';
import '../../common/data/audio.dart';
import '../../common/view/audio_page_type.dart';
import '../../common/view/audio_tile_image.dart';
import '../../common/view/stared_station_icon_button.dart';
import '../../common/view/tapable_text.dart';
import '../../common/view/ui_constants.dart';
import '../../extensions/build_context_x.dart';
import '../../extensions/theme_data_x.dart';
import '../../radio/view/radio_page_tag_bar.dart';
import '../../radio/view/station_page.dart';

class RadioSearchResultTile extends StatelessWidget {
  const RadioSearchResultTile({
    super.key,
    required this.station,
    required this.selected,
    required this.width,
    required this.currentAudio,
    required this.playing,
  });

  final Audio station;
  final bool selected;
  final double width;
  final Audio? currentAudio;
  final bool playing;

  @override
  Widget build(BuildContext context) {
    const maxLines = 1;
    final theme = context.theme;

    return ListTile(
      leading: AudioTileImage(size: kAudioTrackWidth, audio: station),
      selected: selected,
      selectedColor: context.theme.contrastyPrimary,
      title: Row(
        spacing: kLargestSpace,
        children: [
          Expanded(
            flex: 3,
            child: Column(
              children: [
                TapAbleText(
                  text: station.title ?? context.l10n.unknown,
                  onTap: () => di<RoutingManager>().push(
                    pageId: station.uuid!,
                    builder: (context) => StationPage(uuid: station.uuid!),
                  ),
                  maxLines: maxLines,
                ),
                Align(
                  alignment: Alignment.centerLeft,
                  child: (station.tags?.isEmpty ?? true)
                      ? Text(context.l10n.station)
                      : RadioPageTagBar(
                          station: station,
                          tagLimit: 2,
                          style:
                              theme.listTileTheme.subtitleTextStyle ??
                              theme.textTheme.bodyMedium?.copyWith(
                                color: selected
                                    ? theme.colorScheme.primary
                                    : theme.colorScheme.onSurfaceVariant,
                              ),
                        ),
                ),
              ],
            ),
          ),
          if (width > 500)
            Expanded(
              child: Text(
                '${(station.bitRate ?? 0) > 0 ? '${station.bitRate} kbps' : context.l10n.unknown}',
                maxLines: maxLines,
              ),
            ),
          if (width > 800)
            Expanded(
              child: Text(
                '${station.codec?.isNotEmpty == true ? '${station.codec}' : context.l10n.unknown}',
                maxLines: maxLines,
              ),
            ),

          if (width > 1100)
            Expanded(
              child: Text(
                '${(station.clicks ?? 0) > 0 ? '${station.clicks} ${context.l10n.clicks}' : context.l10n.unknown}',
                maxLines: maxLines,
              ),
            ),
          if (width > 1200)
            Expanded(
              child: Text(
                '${(station.language ?? '').trim().isNotEmpty ? '${station.language!.split(',').join(', ')}' : context.l10n.unknown}',
                maxLines: maxLines,
              ),
            ),
        ],
      ),

      trailing: StaredStationIconButton(
        audio: station,
        color: currentAudio == station && playing
            ? theme.contrastyPrimary
            : null,
      ),
      onTap: () => di<PlayAnywhereManager>().command.run(
        PlayAnywhereParam(
          pageId: station.uuid!,
          audioPageType: AudioPageType.radio,
        ),
      ),
    );
  }
}
