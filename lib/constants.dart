import 'package:flutter/material.dart';
import 'package:yaru_widgets/constants.dart';

const kRepoUrl = 'http://github.com/ubuntu-flutter-community/musicpod';

const kSearchBarWidth = 350.0;

const kGridPadding = EdgeInsets.only(
  bottom: kYaruPagePadding,
  left: kYaruPagePadding - 5,
  right: kYaruPagePadding - 5,
);
const kPodcastGridPadding = EdgeInsets.only(
  top: 15,
  bottom: kYaruPagePadding,
  left: kYaruPagePadding - 5,
  right: kYaruPagePadding - 5,
);

const kHeaderPadding = EdgeInsets.only(
  top: kYaruPagePadding,
  left: kYaruPagePadding,
  right: kYaruPagePadding,
  bottom: kYaruPagePadding - 5,
);

const kCardHeight = 200.0;

const kCardBottomHeight = 30.0;

const kImageGridDelegate = SliverGridDelegateWithMaxCrossAxisExtent(
  maxCrossAxisExtent: kCardHeight - 40,
  mainAxisExtent: kCardHeight - kCardBottomHeight,
  mainAxisSpacing: 0,
  crossAxisSpacing: 10,
);

const kDiskGridDelegate = SliverGridDelegateWithMaxCrossAxisExtent(
  maxCrossAxisExtent: kCardHeight,
  mainAxisSpacing: 20,
  crossAxisSpacing: 20,
);

const kShimmerBaseLight = Color.fromARGB(120, 230, 230, 230);
const kShimmerBaseDark = Color.fromARGB(255, 51, 51, 51);
const kShimmerHighLightLight = Color.fromARGB(197, 218, 218, 218);
const kShimmerHighLightDark = Color.fromARGB(255, 57, 57, 57);

const kAudioQueueThreshHold = 100;

const kLikedAudios = 'likedAudios.json';
const kTagFavsFileName = 'tagFavs.json';
const kLastFav = 'lastFav';
const kPlaylistsFileName = 'playlists.json';
const kPinnedAlbumsFileName = 'pinnedAlbums.json';
const kPodcastsFileName = 'podcasts.json';
const kStarredStationsFileName = 'starredStations.json';
const kSettingsFileName = 'settings.json';
const kLastPositionsFileName = 'lastPositions.json';
const kMusicPodConfigSubDir = 'musicpod';
const kDirectoryProperty = 'directory';
const kRadioUrl = 'de1.api.radio-browser.info';
const kRadioBrowserBaseUrl = 'all.api.radio-browser.info';
const kLastAudio = 'lastAudio';
const kLastPositionAsString = 'lastPositionAsString';
const kLastDurationAsString = 'lastDurationAsString';
const kLocalAudioIndex = 'localAudioIndex';
const kAppIndex = 'appIndex';
const kNeverShowImportFails = 'neverShowImportFails';

const shops = <String, String>{
  'https://us.7digital.com/': '7digital',
  'https://www.hdtracks.com/': 'hdtracks',
  'https://www.qobuz.com': 'qobuz',
  'https://www.amazon.com/music/player': 'Amazon Music',
  'https://bandcamp.com/tag/buy': 'Bandcamp',
};

// Patch notes

// 2023 08 09
const kPatchNotes20230809disposed = 'patchNotes20230809disposed';
const kPatchNotesTitle20230809 = 'Patch notes: 2023-09-08';
const kPatchNotes20230809 = 'Hello there :) \n\n'
    'I hope you are enjoying MusicPod.'
    ' There was a bug in how to subscribe to podcasts.'
    ' This bug is now fixed but with this bugfix MusicPod will not find'
    ' your podcast subscriptions you made until now.'
    ' Sadly this can only be fixed by unsubscribing'
    ' and then resubscribing again to your favorite podcasts.'
    ' Please unsubscribe and subscribe to your favorite podcasts now.'
    ' Thank you very much and have fun with MusicPod.';

// 2023 08 11
const kPatchNotes20230811disposed = 'patchNotes20230809disposed';
const kPatchNotesTitle20230811 = 'Patch notes: 2023-09-11';
const kPatchNotes20230811 = 'Hello there :) \n\n'
    'The podcast genre is now shown in the top of each page.'
    ' If it does not show up for an already subscribed podcast, resubscribe to update.'
    '\nThe notification for new episodes of one of your subscribed podcasts now shows the podcast name again.';

// 2023 08 19
const kPatchNotes20230819disposed = 'patchNotes20230819disposed';
const kPatchNotesTitle20230819 = 'Patch notes: 2023-08-19';
const kPatchNotes20230819 = 'Hello there :)\n\n'
    'Albums should now be better categorized in a unique way.'
    '\nSadly this once against needs you to'
    '\nunpin and pin your favorite albums again.';

// 2023 11 02
const kPatchNotes20231102disposed = 'patchNotes20231102disposed';
const kPatchNotesTitle20231102 = 'Patch notes: 2023-11-02';
const kPatchNotes20231102 = 'Hello MusicPod Users :)\n\n'
    'The Radio experience has been improved!'
    '\n* the current title is now displayed (if provided by the station)'
    '\n* the thumbnails are scaled to the grid'
    '\n* save your favorite tags (genres) with the star button'
    '\n* your last tag selection is now saved';

const kRecentPatchNotesDisposed = kPatchNotes20231102disposed;
const kRecentPatchNotesTitle = kPatchNotesTitle20231102;
const kRecentPatchNotes = kPatchNotes20231102;

const kPatchNotesDisposed = 'kPatchNotesDisposed';
