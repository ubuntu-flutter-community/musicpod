import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../common.dart';
import '../../data.dart';
import '../../get.dart';
import '../../globals.dart';
import '../../library.dart';
import '../../local_audio.dart';
import '../../podcasts.dart';
import '../../radio.dart';
import '../app/app_model.dart';

mixin PlayerMixin {
  String getSubTitle(Audio? audio) =>
      switch (audio?.audioType) {
        AudioType.podcast => audio?.album,
        AudioType.radio => audio?.title,
        _ => audio?.artist
      } ??
      '';

  String getTitle({required Audio? audio, required String? icyTitle}) =>
      icyTitle?.isNotEmpty == true && audio?.audioType == AudioType.radio
          ? icyTitle!
          : (audio?.title?.isNotEmpty == true ? audio!.title! : '');

  void onTitleTap({
    Audio? audio,
    String? text,
    required BuildContext context,
  }) {
    if (text?.isNotEmpty == true && audio?.audioType == AudioType.radio) {
      showSnackBar(
        context: context,
        content: CopyClipboardContent(text: text!),
      );
      return;
    }

    switch (audio?.audioType) {
      case AudioType.local:
        _onLocalAudioTitleTap(
          audio: audio!,
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

  void _onLocalAudioTitleTap({required Audio audio}) {
    final localAudioModel = getIt<LocalAudioModel>();
    final albumAudios = localAudioModel.findAlbum(audio);
    if (albumAudios?.firstOrNull == null) return;
    final id = albumAudios!.first.albumId;
    if (id == null) return;

    getIt<AppModel>().setFullScreen(false);

    navigatorKey.currentState?.push(
      MaterialPageRoute(
        builder: (context) {
          return AlbumPage(
            id: id,
            album: albumAudios,
          );
        },
      ),
    );
  }

  void onArtistTap({required Audio audio, required BuildContext context}) {
    switch (audio.audioType) {
      case AudioType.local:
        _onLocalAudioArtistTap(
          audio: audio,
        );
        return;
      case AudioType.radio:
        _onRadioArtistTap(audio);
        return;
      case AudioType.podcast:
        _onPodcastArtistTap(
          audio: audio,
          context: context,
        );
        return;
      default:
        return;
    }
  }

  void _onRadioArtistTap(Audio audio) {
    final libraryModel = getIt<LibraryModel>();
    int? index = libraryModel.indexOfStation(audio.url!);
    if (index != null) {
      navigatorKey.currentState
          ?.maybePop()
          .then((value) => libraryModel.setIndex(index));
    } else {
      navigatorKey.currentState?.push(
        MaterialPageRoute(
          builder: (context) {
            return StationPage(station: audio);
          },
        ),
      );
    }
  }

  void _onPodcastArtistTap({
    required Audio audio,
    required BuildContext context,
  }) {
    final libraryModel = getIt<LibraryModel>();
    int? index = libraryModel.indexOfPodcast(audio.website!);
    if (index != null) {
      navigatorKey.currentState
          ?.maybePop()
          .then((value) => libraryModel.setIndex(index));
    } else {
      searchAndPushPodcastPage(
        context: context,
        feedUrl: audio.website,
        itemImageUrl: audio.albumArtUrl,
        genre: audio.genre,
        play: false,
      );
    }
  }

  void _onLocalAudioArtistTap({required Audio audio}) {
    final localAudioModel = getIt<LocalAudioModel>();
    final artistAudios = localAudioModel.findArtist(audio);
    if (artistAudios?.firstOrNull == null) return;
    final images = localAudioModel.findImages(artistAudios ?? {});
    getIt<AppModel>().setFullScreen(false);

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
}
