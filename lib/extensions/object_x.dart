import 'dart:io';

import 'package:dio/dio.dart';
import 'package:podcast_search/podcast_search.dart';

import '../app/app_config.dart';
import '../l10n/app_localizations.dart';
import '../lyrics/lyrics_service.dart';
import '../podcasts/podcast_service.dart';
import '../radio/radio_service.dart';
import '../search/search_timeout_exception.dart';

extension ObjectX on Object? {
  String localizedErrorMessage(
    AppLocalizations l10n, {
    String? title,
  }) => switch (this) {
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
    NoLyrcicsFoundException() => l10n.noLyricsFound,
    DioException() =>
      (this as DioException).error is SocketException
          ? l10n.appCanNotConnectToHost(
              AppConfig.appTitle,
              '${(this as DioException).requestOptions.uri.host}',
            )
          : (this as DioException).response?.statusCode == 404
          ? l10n.noLyricsFound
          : (this as DioException).message ?? (this as DioException).toString(),
    _ => this.toString(),
  };
}
