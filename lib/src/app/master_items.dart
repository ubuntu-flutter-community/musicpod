import 'package:collection/collection.dart';
import 'package:flutter/material.dart';

import '../../common.dart';
import '../../constants.dart';
import '../../data.dart';
import '../../library.dart';
import '../../local_audio.dart';
import '../../podcasts.dart';
import '../../radio.dart';
import '../common/side_bar_fall_back_image.dart';
import '../l10n/l10n.dart';
import '../theme.dart';
import 'master_item.dart';

List<MasterItem> createMasterItems({
  required bool isOnline,
  required void Function({required AudioType audioType, required String text})
      onTextTap,
  required LibraryModel libraryModel,
  required String? countryCode,
}) {
  return [
    MasterItem(
      titleBuilder: (context) => Text(context.l10n.localAudio),
      pageBuilder: (context) => const LocalAudioPage(),
      iconBuilder: (context, selected) => LocalAudioPageIcon(
        selected: selected,
      ),
      content: (kLocalAudio, {}),
    ),
    MasterItem(
      titleBuilder: (context) => Text(context.l10n.radio),
      pageBuilder: (context) => RadioPage(
        countryCode: countryCode,
        isOnline: isOnline,
        onTextTap: (text) => onTextTap(text: text, audioType: AudioType.radio),
      ),
      iconBuilder: (context, selected) => RadioPageIcon(
        selected: selected,
      ),
      content: (kRadio, {}),
    ),
    MasterItem(
      titleBuilder: (context) => Text(context.l10n.podcasts),
      pageBuilder: (context) {
        return PodcastsPage(
          isOnline: isOnline,
          countryCode: countryCode,
        );
      },
      iconBuilder: (context, selected) => PodcastsPageIcon(
        selected: selected,
      ),
      content: (kPodcasts, {}),
    ),
    MasterItem(
      iconBuilder: (context, selected) => Icon(Iconz().plus),
      titleBuilder: (context) => Text(context.l10n.playlistDialogTitleNew),
      pageBuilder: (context) => const SizedBox.shrink(),
      content: (kNewPlaylist, {}),
    ),
    MasterItem(
      titleBuilder: (context) => Text(context.l10n.likedSongs),
      content: (kLikedAudios, libraryModel.likedAudios),
      pageBuilder: (context) => LikedAudioPage(
        onTextTap: onTextTap,
        likedLocalAudios: libraryModel.likedAudios,
      ),
      subtitleBuilder: (context) => Text(context.l10n.playlist),
      iconBuilder: (context, selected) =>
          LikedAudioPage.createIcon(context: context, selected: selected),
    ),
    for (final playlist in libraryModel.playlists.entries)
      MasterItem(
        titleBuilder: (context) => Text(playlist.key),
        subtitleBuilder: (context) => Text(context.l10n.playlist),
        content: (playlist.key, playlist.value),
        pageBuilder: (context) => PlaylistPage(
          onTextTap: onTextTap,
          playlist: playlist,
          libraryModel: libraryModel,
        ),
        iconBuilder: (context, selected) => SideBarFallBackImage(
          color: getAlphabetColor(playlist.key),
          child: Icon(
            Iconz().playlist,
          ),
        ),
      ),
    for (final podcast in libraryModel.podcasts.entries)
      MasterItem(
        titleBuilder: (context) => PodcastPageTitle(
          feedUrl: podcast.key,
          title: podcast.value.firstOrNull?.album ??
              podcast.value.firstOrNull?.title ??
              podcast.value.firstOrNull.toString(),
        ),
        subtitleBuilder: (context) => Text(
          podcast.value.firstOrNull?.artist ?? context.l10n.podcast,
        ),
        content: (podcast.key, podcast.value),
        pageBuilder: (context) => PodcastPage(
          pageId: podcast.key,
          title: podcast.value.firstOrNull?.album ??
              podcast.value.firstOrNull?.title ??
              podcast.value.firstOrNull.toString(),
          audios: podcast.value,
          onTextTap: onTextTap,
          addPodcast: libraryModel.addPodcast,
          removePodcast: libraryModel.removePodcast,
          imageUrl: podcast.value.firstOrNull?.albumArtUrl ??
              podcast.value.firstOrNull?.imageUrl,
        ),
        iconBuilder: (context, selected) => PodcastPage.createIcon(
          context: context,
          imageUrl: podcast.value.firstOrNull?.albumArtUrl ??
              podcast.value.firstOrNull?.imageUrl,
        ),
      ),
    for (final album in libraryModel.pinnedAlbums.entries)
      MasterItem(
        titleBuilder: (context) => Text(
          album.value.firstOrNull?.album ?? album.key,
        ),
        subtitleBuilder: (context) =>
            Text(album.value.firstOrNull?.artist ?? context.l10n.album),
        content: (album.key, album.value),
        pageBuilder: (context) => AlbumPage(
          onTextTap: onTextTap,
          album: album.value,
          id: album.key,
          addPinnedAlbum: libraryModel.addPinnedAlbum,
          isPinnedAlbum: libraryModel.isPinnedAlbum,
          removePinnedAlbum: libraryModel.removePinnedAlbum,
        ),
        iconBuilder: (context, selected) => AlbumPage.createIcon(
          context,
          album.value.firstOrNull?.pictureData,
        ),
      ),
    for (final station in libraryModel.starredStations.entries)
      MasterItem(
        titleBuilder: (context) => Text(station.key),
        subtitleBuilder: (context) {
          return Text(context.l10n.station);
        },
        content: (station.key, station.value),
        pageBuilder: (context) => isOnline
            ? StationPage(
                isStarred: true,
                starStation: (station) {},
                onTextTap: (text) =>
                    onTextTap(text: text, audioType: AudioType.radio),
                unStarStation: libraryModel.unStarStation,
                name: station.key,
                station: station.value.first,
              )
            : const OfflinePage(),
        iconBuilder: (context, selected) => StationPage.createIcon(
          context: context,
          imageUrl: station.value.first.imageUrl,
          selected: selected,
        ),
      ),
  ];
}
