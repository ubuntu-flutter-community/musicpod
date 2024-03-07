import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../common.dart';
import '../../constants.dart';
import '../../data.dart';
import '../../globals.dart';
import '../../library.dart';
import '../../local_audio.dart';
import '../../podcasts.dart';
import '../../radio.dart';
import '../../utils.dart';
import '../app/app_model.dart';

void onLocalAudioTitleTap({
  required Audio audio,
  required BuildContext context,
  required WidgetRef ref,
}) {
  final libraryModel = ref.read(libraryModelProvider);
  final localAudioModel = ref.read(localAudioModelProvider);

  final albumAudios = localAudioModel.findAlbum(audio);
  if (albumAudios?.firstOrNull == null) return;
  final id = generateAlbumId(albumAudios!.first);
  if (id == null) return;

  navigatorKey.currentState?.push(
    MaterialPageRoute(
      builder: (context) {
        return AlbumPage(
          isPinnedAlbum: libraryModel.isPinnedAlbum,
          removePinnedAlbum: libraryModel.removePinnedAlbum,
          addPinnedAlbum: libraryModel.addPinnedAlbum,
          id: id,
          album: albumAudios,
        );
      },
    ),
  );
}

void onLocalAudioArtistTap({
  required Audio audio,
  required BuildContext context,
  required WidgetRef ref,
}) {
  final localAudioModel = ref.read(localAudioModelProvider);
  final artistAudios = localAudioModel.findArtist(audio);
  if (artistAudios?.firstOrNull == null) return;
  final images = localAudioModel.findImages(artistAudios ?? {});

  navigatorKey.currentState?.push(
    MaterialPageRoute(
      builder: (context) {
        return ArtistPage(
          artistAudios: artistAudios,
          images: images,
        );
      },
    ),
  );
}

void onTitleTap({
  Audio? audio,
  String? text,
  required BuildContext context,
  required WidgetRef ref,
}) {
  if (audio?.audioType == AudioType.local) {
    ref.read(appModelProvider).setFullScreen(false);
  }

  if (text?.isNotEmpty == true) {
    Clipboard.setData(ClipboardData(text: text!));
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        duration: kSnackBarDuration,
        content: CopyClipboardContent(text: text),
      ),
    );
  } else if ((audio?.audioType == AudioType.radio ||
          audio?.audioType == AudioType.podcast) &&
      audio?.url?.isNotEmpty == true) {
    Clipboard.setData(ClipboardData(text: audio!.url!));
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        duration: kSnackBarDuration,
        content: CopyClipboardContent(
          text: audio.url!,
          onSearch: () {
            if (audio.url != null) {
              launchUrl(Uri.parse(audio.url ?? ''));
            }
          },
        ),
      ),
    );
  } else {
    if (audio?.audioType == null || audio?.title == null) {
      return;
    }
    onLocalAudioTitleTap(
      audio: audio!,
      context: context,
      ref: ref,
    );
  }
}

void onArtistTap({
  required Audio? audio,
  required String? artist,
  required BuildContext context,
  required WidgetRef ref,
}) {
  if (audio?.audioType == null || audio?.artist == null) {
    return;
  }
  if (audio?.audioType != AudioType.radio) {
    ref.read(appModelProvider).setFullScreen(false);
  }
  if (audio!.audioType == AudioType.radio && audio.url?.isNotEmpty == true) {
    final libModel = ref.read(libraryModelProvider);
    navigatorKey.currentState?.push(
      MaterialPageRoute(
        builder: (context) {
          return StationPage(
            station: audio,
            name: audio.title ?? '',
            unStarStation: libModel.unStarStation,
            starStation: (station) =>
                libModel.addStarredStation(audio.url!, {audio}),
          );
        },
      ),
    );
  } else if (audio.audioType == AudioType.podcast &&
      audio.website?.isNotEmpty == true) {
    searchAndPushPodcastPage(
      context: context,
      feedUrl: audio.website,
      itemImageUrl: audio.albumArtUrl,
      genre: audio.genre,
      play: false,
      ref: ref,
    );
  } else {
    onLocalAudioArtistTap(
      audio: audio,
      context: context,
      ref: ref,
    );
  }
}

String createQueueElement(Audio? audio) {
  final title = audio?.title?.isNotEmpty == true ? audio?.title! : '';
  final artist = audio?.artist?.isNotEmpty == true ? ' • ${audio?.artist}' : '';
  return '$title$artist'.trim();
}
