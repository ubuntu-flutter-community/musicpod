import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:podcast_search/podcast_search.dart';

import '../app/app_config.dart';
import '../app/data/play_anywhere_bad_audios_exception.dart';
import '../common/view/audio_page_type.dart';
import '../l10n/app_localizations.dart';
import '../lyrics/data/online_lyrics_exceptions.dart';
import '../podcasts/data/podcast_exceptions.dart';
import '../radio/data/radio_exceptions.dart';
import '../search/data/search_timeout_exception.dart';

extension ObjectX on Object? {
  String localizedErrorMessage(
    AppLocalizations l10n, {
    String? title,
  }) => switch (this) {
    NetworkImageLoadException() => l10n.errorDetails(
      (this as NetworkImageLoadException).statusCode.toString(),
    ),
    FindRadioBrowserHostsTimeoutException() =>
      l10n.lookUpRadioBrowserHostsTimouted,
    LookUpRadioBrowserHostsException() => l10n.lookUpRadioBrowserHostsFailed,
    FindStationTimeoutException() => l10n.findStationsTimeoutMessage,
    RadioBrowserServerUnavailableException() =>
      l10n.radioBrowserServerUnavailable,
    RadioBrowserApiNotConnectedException() =>
      l10n.radioBrowserServerNotConnected,
    LoadTagsFailedException() => l10n.radioBrowserLoadingTagsFailed,
    LoadTagsTimeoutException() => l10n.radioBrowserLoadingTagsTimeouted,
    PodcastSearchNotSuccessfulException() => l10n.podcastSearchNotSuccessfull,
    FindEpisodesTimeoutException() => l10n.findEpisodesTimeoutMessage(
      title ?? l10n.podcast,
    ),
    PodcastFailedException() =>
      (this as PodcastFailedException).message.contains('host lookup')
          ? l10n.podcastFailedHostLookup
          : (this as PodcastFailedException).message,
    SearchTimeoutException() => l10n.searchTimeoutMessage,
    FetchOnlineLyricsTimeoutException() =>
      l10n.fetchingLyricsOnlineTimeoutMessage,
    SocketException() => l10n.lookUpRadioBrowserHostsFailed,
    DioException() =>
      (this as DioException).error is SocketException
          ? l10n.appCanNotConnectToHost(
              AppConfig.appTitle,
              '${(this as DioException).requestOptions.uri.host}',
            )
          : (this as DioException).response?.statusCode == 404
          ? l10n.noLyricsFound
          : (this as DioException).message ?? (this as DioException).toString(),
    PlayAnywhereBadAudiosException() => switch ((this
            as PlayAnywhereBadAudiosException)
        .result
        .param
        .audioPageType) {
      AudioPageType.playlist => l10n.emptyPlaylist,
      AudioPageType.album => l10n.albumNotFound,
      AudioPageType.radio => l10n.stationNotFound,
      AudioPageType.podcast => l10n.noPodcastFound,
      _ => l10n.nothingFound,
    },
    Exception() => (this as Exception).toString(),
    _ => this.toString(),
  };
}
