import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:watch_it/watch_it.dart';

import '../../app/app_model.dart';
import '../../app/view/routing_manager.dart';
import '../../common/data/audio.dart';
import '../../common/data/audio_type.dart';
import '../../common/view/copy_clipboard_content.dart';
import '../../common/view/snackbars.dart';
import '../../common/view/theme.dart';
import '../../extensions/build_context_x.dart';
import '../../l10n/l10n.dart';
import '../../local_audio/local_audio_model.dart';
import '../../local_audio/view/album_page.dart';
import '../../local_audio/view/artist_page.dart';
import '../../podcasts/podcast_model.dart';
import '../../podcasts/view/lazy_podcast_page.dart';
import '../../radio/view/station_page.dart';
import '../../settings/settings_model.dart';
import '../player_model.dart';
import 'player_track.dart';
import 'player_view.dart';

class PlayerTitleAndArtist extends StatelessWidget with WatchItMixin {
  const PlayerTitleAndArtist({
    super.key,
    required this.playerPosition,
  });

  final PlayerPosition playerPosition;

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final audio = watchPropertyValue((PlayerModel m) => m.audio);

    final icyTitle =
        watchPropertyValue((PlayerModel m) => m.mpvMetaData?.icyTitle);
    final showPositionDuration =
        watchPropertyValue((SettingsModel m) => m.showPositionDuration);

    final appModel = di<AppModel>();
    final routingManager = di<RoutingManager>();
    final localAudioModel = di<LocalAudioModel>();
    final playerModel = di<PlayerModel>();
    final podcastModel = di<PodcastModel>();

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
        InkWell(
          borderRadius: switch (playerPosition) {
            PlayerPosition.bottom => BorderRadius.circular(4),
            _ => BorderRadius.circular(10),
          },
          onTap: audio == null
              ? null
              : () => _onTitleTap(
                    audio: audio,
                    text: icyTitle,
                    context: context,
                    routingManager: routingManager,
                    playerModel: playerModel,
                    localAudioModel: localAudioModel,
                    appModel: appModel,
                  ),
          child: Tooltip(
            message: _title(audio: audio, icyTitle: icyTitle),
            child: Text(
              _title(audio: audio, icyTitle: icyTitle),
              style: switch (playerPosition) {
                PlayerPosition.bottom => _bottomTitleTextStyle(),
                _ => _fullHeightTitleTextStyle(theme)
              },
              textAlign: _textAlign(),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ),
        InkWell(
          borderRadius: switch (playerPosition) {
            PlayerPosition.bottom => BorderRadius.circular(4),
            _ => BorderRadius.circular(8),
          },
          onTap: audio == null
              ? null
              : () => _onArtistTap(
                    audio: audio,
                    routingManager: routingManager,
                    localAudioModel: localAudioModel,
                    appModel: appModel,
                    podcastModel: podcastModel,
                  ),
          child: Tooltip(
            message: _subTitle(audio),
            child: Text(
              _subTitle(audio),
              style: switch (playerPosition) {
                PlayerPosition.bottom => _bottomArtistTextStyle(),
                _ => _fullHeightArtistTextStyle(theme)
              },
              textAlign: _textAlign(),
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
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
      fontWeight: largeTextWeight,
      fontSize: 26,
      color: theme.colorScheme.onSurface,
    );
  }

  TextStyle _fullHeightArtistTextStyle(ThemeData theme) {
    return TextStyle(
      fontWeight: smallTextFontWeight,
      fontSize: 20,
      color: theme.colorScheme.onSurface,
    );
  }

  TextStyle _bottomTitleTextStyle() => const TextStyle(
        fontWeight: FontWeight.w400,
        fontSize: 14,
      );

  TextStyle _bottomArtistTextStyle() => TextStyle(
        fontWeight: smallTextFontWeight,
        fontSize: 12,
      );

  String _subTitle(Audio? audio) => (switch (audio?.audioType) {
            AudioType.podcast => audio?.album,
            AudioType.radio => audio?.title,
            _ => audio?.artist
          } ??
          '')
      .trim();

  String _title({required Audio? audio, required String? icyTitle}) =>
      icyTitle?.isNotEmpty == true && audio?.audioType == AudioType.radio
          ? icyTitle!
          : (audio?.title?.isNotEmpty == true ? audio!.title! : '').trim();

  void _onTitleTap({
    Audio? audio,
    String? text,
    required BuildContext context,
    required PlayerModel playerModel,
    required RoutingManager routingManager,
    required LocalAudioModel localAudioModel,
    required AppModel appModel,
  }) {
    if (text?.isNotEmpty == true && audio?.audioType == AudioType.radio ||
        audio?.audioType == null) {
      showSnackBar(
        context: context,
        content: CopyClipboardContent(text: text!),
      );
      return;
    }

    switch (audio?.audioType) {
      case AudioType.local:
        _onLocalAudioTitleTap(
          context: context,
          audio: audio!,
          appModel: appModel,
          routingManager: routingManager,
          localAudioModel: localAudioModel,
        );
        return;
      case AudioType.radio:
      case AudioType.podcast:
        if (audio?.url == null) return;
        showSnackBar(
          context: context,
          content: CopyClipboardContent(
            text: audio!.url!,
            onSearch: () => launchUrl(Uri.parse(audio.url!)),
          ),
        );
        return;
      default:
        return;
    }
  }

  void _onLocalAudioTitleTap({
    required BuildContext context,
    required Audio audio,
    required AppModel appModel,
    required RoutingManager routingManager,
    required LocalAudioModel localAudioModel,
  }) {
    if (audio.albumId == null) {
      showSnackBar(
        context: context,
        content: Text(context.l10n.albumNotFound),
      );
      return;
    }

    appModel.setFullWindowMode(false);
    routingManager.push(
      builder: (_) => AlbumPage(id: audio.albumId!),
      pageId: audio.albumId!,
    );
  }

  void _onArtistTap({
    required Audio audio,
    required PodcastModel podcastModel,
    required LocalAudioModel localAudioModel,
    required RoutingManager routingManager,
    required AppModel appModel,
  }) {
    switch (audio.audioType) {
      case AudioType.local:
        _onLocalAudioArtistTap(
          audio: audio,
          appModel: appModel,
          libraryModel: routingManager,
          localAudioModel: localAudioModel,
        );
        return;
      case AudioType.radio:
        _onRadioArtistTap(audio: audio, routingManager: routingManager);
        return;
      case AudioType.podcast:
        if (audio.website != null &&
            routingManager.selectedPageId != audio.website) {
          final feedUrl = audio.website!;

          routingManager.push(
            pageId: feedUrl,
            builder: (_) => LazyPodcastPage(
              feedUrl: feedUrl,
              imageUrl: audio.imageUrl ?? audio.albumArtUrl,
            ),
          );
        }
        return;
      default:
        return;
    }
  }

  void _onRadioArtistTap({
    required Audio audio,
    required RoutingManager routingManager,
  }) {
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

  void _onLocalAudioArtistTap({
    required Audio audio,
    required LocalAudioModel localAudioModel,
    required AppModel appModel,
    required RoutingManager libraryModel,
  }) {
    final artistId = audio.artist;
    if (artistId == null) return;
    appModel.setFullWindowMode(false);
    libraryModel.push(
      builder: (_) => ArtistPage(pageId: artistId),
      pageId: artistId,
    );
  }
}
