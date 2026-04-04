import 'package:flutter/material.dart';
import 'package:flutter_it/flutter_it.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../app/app_manager.dart';
import '../../app/routing_manager.dart';
import '../../common/data/audio.dart';
import '../../common/data/audio_type.dart';
import '../../common/view/copy_clipboard_content.dart';
import '../../common/view/snackbars.dart';
import '../../extensions/build_context_x.dart';
import '../../extensions/string_x.dart';
import '../../l10n/l10n.dart';
import '../../local_audio/local_audio_manager.dart';
import '../../local_audio/view/album_page.dart';
import '../../local_audio/view/artist_page.dart';
import '../../podcasts/view/lazy_podcast_page.dart';
import '../../radio/view/station_page.dart';
import '../../settings/settings_model.dart';
import '../mpv_metadata_manager.dart';
import '../player_model.dart';
import 'player_track.dart';
import 'player_view.dart';

class PlayerTitleAndArtist extends StatelessWidget with WatchItMixin {
  const PlayerTitleAndArtist({super.key, required this.playerPosition});

  final PlayerPosition playerPosition;

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;

    final localAudioIsInitializing = watchValue(
      (LocalAudioManager m) => m.initAudiosCommand.isRunning,
    );

    final audio = watchPropertyValue((PlayerModel m) => m.audio);

    final icyTitle = watchValue(
      (MpvMetadataManager m) =>
          m.mpvMetaDataCommand.select((cmd) => cmd?.icyTitle),
    );
    final showPositionDuration = watchPropertyValue(
      (SettingsModel m) => m.showPositionDuration,
    );

    final hoverColor = theme.colorScheme.primary.withValues(alpha: 0.3);
    return Column(
      mainAxisSize: switch (playerPosition) {
        PlayerPosition.bottom => MainAxisSize.max,
        _ => MainAxisSize.min,
      },
      mainAxisAlignment: switch (playerPosition) {
        PlayerPosition.bottom => MainAxisAlignment.center,
        _ => MainAxisAlignment.start,
      },
      crossAxisAlignment: switch (playerPosition) {
        PlayerPosition.bottom => CrossAxisAlignment.start,
        _ => CrossAxisAlignment.center,
      },
      children: [
        Material(
          color: Colors.transparent,
          borderRadius: switch (playerPosition) {
            PlayerPosition.bottom => BorderRadius.circular(4),
            _ => BorderRadius.circular(10),
          },
          child: InkWell(
            hoverColor: hoverColor,
            borderRadius: switch (playerPosition) {
              PlayerPosition.bottom => BorderRadius.circular(4),
              _ => BorderRadius.circular(10),
            },
            onTap: localAudioIsInitializing || audio == null
                ? null
                : () => _onTitleTap(
                    audio: audio,
                    text: icyTitle,
                    context: context,
                  ),
            child: Tooltip(
              message: _title(audio: audio, icyTitle: icyTitle),
              child: Text(
                _title(audio: audio, icyTitle: icyTitle),
                style: switch (playerPosition) {
                  PlayerPosition.bottom => _bottomTitleTextStyle(),
                  _ => _fullHeightTitleTextStyle(theme),
                },
                textAlign: _textAlign(),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
        ),
        Material(
          borderRadius: switch (playerPosition) {
            PlayerPosition.bottom => BorderRadius.circular(4),
            _ => BorderRadius.circular(8),
          },
          color: Colors.transparent,
          child: InkWell(
            hoverColor: hoverColor,
            borderRadius: switch (playerPosition) {
              PlayerPosition.bottom => BorderRadius.circular(4),
              _ => BorderRadius.circular(8),
            },
            onTap: localAudioIsInitializing || audio == null
                ? null
                : () => _onArtistTap(context: context, audio: audio),
            child: Tooltip(
              message: _subTitle(audio),
              child: Text(
                _subTitle(audio),
                style: switch (playerPosition) {
                  PlayerPosition.bottom => _bottomArtistTextStyle(),
                  _ => _fullHeightArtistTextStyle(theme),
                },
                textAlign: _textAlign(),
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              ),
            ),
          ),
        ),
        if (playerPosition == PlayerPosition.bottom &&
            audio?.audioType != AudioType.radio &&
            showPositionDuration)
          const Padding(
            padding: EdgeInsets.only(top: 2, bottom: 5),
            child: PlayerSimpleTrack(),
          )
        else
          SizedBox(
            height: switch (playerPosition) {
              PlayerPosition.bottom => 3,
              _ => 0,
            },
          ),
      ],
    );
  }

  TextAlign _textAlign() {
    return switch (playerPosition) {
      PlayerPosition.bottom => TextAlign.start,
      _ => TextAlign.center,
    };
  }

  TextStyle _fullHeightTitleTextStyle(ThemeData theme) {
    return TextStyle(
      fontWeight: FontWeight.normal,
      fontSize: 26,
      color: theme.colorScheme.onSurface,
    );
  }

  TextStyle _fullHeightArtistTextStyle(ThemeData theme) {
    return TextStyle(
      fontWeight: FontWeight.normal,
      fontSize: 20,
      color: theme.colorScheme.onSurface,
    );
  }

  TextStyle _bottomTitleTextStyle() =>
      const TextStyle(fontWeight: FontWeight.w400, fontSize: 14);

  TextStyle _bottomArtistTextStyle() =>
      const TextStyle(fontWeight: FontWeight.normal, fontSize: 12);

  String _subTitle(Audio? audio) =>
      (switch (audio?.audioType) {
                AudioType.podcast => audio?.podcastTitle?.unEscapeHtml,
                AudioType.radio => audio?.title,
                _ => audio?.artist,
              } ??
              '')
          .trim();

  String _title({required Audio? audio, required String? icyTitle}) =>
      icyTitle?.isNotEmpty == true && audio?.audioType == AudioType.radio
      ? icyTitle!
      : (audio?.title?.isNotEmpty == true ? audio!.title! : '').trim();

  void _onTitleTap({
    required Audio audio,
    String? text,
    required BuildContext context,
  }) {
    if (text?.isNotEmpty == true && audio.audioType == AudioType.radio ||
        audio.audioType == null) {
      showSnackBar(
        context: context,
        content: CopyClipboardContent(text: text!),
      );
      return;
    }

    switch (audio.audioType) {
      case AudioType.local:
        _onLocalAudioTitleTap(context: context, audio: audio);
        return;
      case AudioType.radio:
      case AudioType.podcast:
        if (audio.url == null) return;
        showSnackBar(
          context: context,
          content: CopyClipboardContent(
            text: audio.url!,
            onSearch: () => launchUrl(Uri.parse(audio.url!)),
          ),
        );
        return;
      default:
        return;
    }
  }

  Future<void> _onLocalAudioTitleTap({
    required BuildContext context,
    required Audio audio,
  }) async {
    final id =
        audio.albumDbId ??
        di<LocalAudioManager>().findAlbumId(
          artist: audio.artist!,
          album: audio.album!,
        );

    if (id == null) {
      showSnackBar(context: context, content: Text(context.l10n.albumNotFound));
      return;
    }

    di<AppManager>().setFullWindowMode(false);
    di<RoutingManager>().push(
      builder: (_) => AlbumPage(id: id),
      pageId: id.toString(),
    );
  }

  void _onArtistTap({required BuildContext context, required Audio audio}) {
    final routingManager = di<RoutingManager>();
    switch (audio.audioType) {
      case AudioType.local:
        _onLocalAudioArtistTap(audio: audio);
        return;
      case AudioType.radio:
        _onRadioArtistTap(audio: audio);
        return;
      case AudioType.podcast:
        if (audio.feedUrl != null &&
            routingManager.selectedPageId != audio.feedUrl) {
          final feedUrl = audio.feedUrl!;

          routingManager.push(
            pageId: feedUrl,
            builder: (context) => LazyPodcastPage(
              feedUrl: feedUrl,
              imageUrl: audio.imageUrl ?? audio.albumArtUrl,
              updateMessage: context.l10n.newEpisodeAvailable,
              multiUpdateMessage: (length) =>
                  context.l10n.newEpisodesAvailableFor(length),
            ),
          );
        }
        return;
      default:
        return;
    }
  }

  void _onRadioArtistTap({required Audio audio}) {
    final routingManager = di<RoutingManager>();
    if (audio.url == null ||
        audio.uuid == null ||
        routingManager.selectedPageId == audio.uuid) {
      return;
    }
    routingManager.push(
      builder: (_) => StationPage(uuid: audio.uuid!),
      pageId: audio.uuid!,
    );
  }

  void _onLocalAudioArtistTap({required Audio audio}) {
    final artistId = audio.artist;
    if (artistId == null) return;
    di<AppManager>().setFullWindowMode(false);
    di<RoutingManager>().push(
      builder: (_) => ArtistPage(pageId: artistId),
      pageId: artistId,
    );
  }
}
