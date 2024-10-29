import 'dart:async';

import 'package:flutter/material.dart';
import 'package:safe_change_notifier/safe_change_notifier.dart';

import '../common/data/audio.dart';
import '../common/view/snackbars.dart';
import '../library/library_model.dart';
import '../player/player_model.dart';
import 'podcast_service.dart';
import 'view/podcast_page.dart';
import 'view/podcast_snackbar_contents.dart';

class PodcastModel extends SafeChangeNotifier {
  PodcastModel({
    required PodcastService podcastService,
  }) : _podcastService = podcastService;

  final PodcastService _podcastService;

  bool _loadingFeed = false;
  bool get loadingFeed => _loadingFeed;
  void setLoadingFeed(bool value) {
    if (_loadingFeed == value) return;
    _loadingFeed = value;
    notifyListeners();
  }

  var _firstUpdateChecked = false;
  Future<void> init({
    required String updateMessage,
    bool forceInit = false,
    Function({required String message})? notify,
  }) async {
    await _podcastService.init(forceInit: forceInit);

    if (_firstUpdateChecked == false) {
      update(updateMessage: updateMessage);
    }
    _firstUpdateChecked = true;

    notifyListeners();
  }

  void update({
    String? updateMessage,
    // Note: because the podcasts can be modified to include downloads
    // this needs a map and not only the feedurl
    Map<String, List<Audio>>? oldPodcasts,
  }) {
    _setCheckingForUpdates(true);
    _podcastService
        .updatePodcasts(updateMessage: updateMessage, oldPodcasts: oldPodcasts)
        .then((_) => _setCheckingForUpdates(false));
  }

  bool _checkingForUpdates = false;
  bool get checkingForUpdates => _checkingForUpdates;
  void _setCheckingForUpdates(bool value) {
    if (_checkingForUpdates == value) return;
    _checkingForUpdates = value;
    notifyListeners();
  }

  bool _updatesOnly = false;
  bool get updatesOnly => _updatesOnly;
  void setUpdatesOnly(bool value) {
    if (_updatesOnly == value) return;
    _updatesOnly = value;
    notifyListeners();
  }

  bool _downloadsOnly = false;
  bool get downloadsOnly => _downloadsOnly;
  void setDownloadsOnly(bool value) {
    if (_downloadsOnly == value) return;
    _downloadsOnly = value;
    notifyListeners();
  }

  // This is not optimal since the model uses widgets
  // but tolerable since snackbars update over the rest of the UI
  Future<void> loadPodcast({
    required BuildContext context,
    required LibraryModel libraryModel,
    required String feedUrl,
    String? itemImageUrl,
    String? genre,
    PlayerModel? playerModel,
  }) async {
    if (libraryModel.isPageInLibrary(feedUrl)) {
      return libraryModel.push(pageId: feedUrl);
    }

    showSnackBar(
      context: context,
      duration: const Duration(seconds: 1000),
      content: const PodcastSearchLoadingSnackBarContent(),
    );

    setLoadingFeed(true);
    return _podcastService
        .findEpisodes(
      feedUrl: feedUrl,
      itemImageUrl: itemImageUrl,
      genre: genre,
    )
        .then(
      (podcast) async {
        if (podcast.isEmpty) {
          if (context.mounted) {
            showSnackBar(
              context: context,
              content: const PodcastSearchEmptyFeedSnackBarContent(),
            );
          }
          return;
        }

        if (playerModel != null) {
          playerModel.startPlaylist(listName: feedUrl, audios: podcast);
        } else {
          libraryModel.push(
            builder: (_) => PodcastPage(
              imageUrl: itemImageUrl ?? podcast.firstOrNull?.imageUrl,
              preFetchedEpisodes: podcast,
              feedUrl: feedUrl,
              title: podcast.firstOrNull?.album ??
                  podcast.firstOrNull?.title ??
                  feedUrl,
            ),
            pageId: feedUrl,
          );
        }
      },
    ).whenComplete(
      () {
        setLoadingFeed(false);
        if (context.mounted) ScaffoldMessenger.of(context).clearSnackBars();
      },
    ).timeout(
      const Duration(seconds: 15),
      onTimeout: () {
        setLoadingFeed(false);
        if (context.mounted) {
          showSnackBar(
            context: context,
            content: const PodcastSearchTimeoutSnackBarContent(),
          );
        }
      },
    );
  }
}
