import 'package:flutter/material.dart';

const kRepoUrl = 'http://github.com/ubuntu-flutter-community/musicpod';

const kSideBarIconSize = 23.0;

const kHeaderBarItemHeight = 35.0;

const kSearchBarWidth = 350.0;

const kPagePadding = 20.0;
const kGridPadding = EdgeInsets.only(
  bottom: kPagePadding,
  left: kPagePadding - 5,
  right: kPagePadding - 5,
);
const kPodcastGridPadding = EdgeInsets.only(
  top: 15,
  bottom: kPagePadding,
  left: kPagePadding - 5,
  right: kPagePadding - 5,
);

const kHeaderPadding = EdgeInsets.only(
  top: kPagePadding,
  left: kPagePadding,
  right: kPagePadding,
  bottom: kPagePadding - 5,
);

const kCardHeight = 200.0;

const kImageGridDelegate = SliverGridDelegateWithMaxCrossAxisExtent(
  maxCrossAxisExtent: kCardHeight,
  mainAxisSpacing: 10,
  crossAxisSpacing: 10,
);

const kShimmerBaseLight = Color.fromARGB(120, 230, 230, 230);
const kShimmerBaseDark = Color.fromARGB(255, 51, 51, 51);
const kShimmerHighLightLight = Color.fromARGB(197, 218, 218, 218);
const kShimmerHighLightDark = Color.fromARGB(255, 57, 57, 57);

const kLikedAudios = 'likedAudios.json';
const kPlaylistsFileName = 'playlists.json';
const kPinnedAlbumsFileName = 'pinnedAlbums.json';
const kPodcastsFileName = 'podcasts.json';
const kStarredStationsFileName = 'starredStations.json';
const kMusicPodConfigSubDir = 'musicpod';
const kDirectoryProperty = 'directory';
const kRadioUrl = 'de1.api.radio-browser.info';
const kLastAudio = 'lastAudio';
const kLastPositionAsString = 'lastPositionAsString';
const kLastDurationAsString = 'lastDurationAsString';
const kLocalAudioIndex = 'localAudioIndex';

// Bug fix notes

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

const kRecentPatchNotesDisposed = kPatchNotes20230809disposed;
const kRecentPatchNotesTitle = kPatchNotesTitle20230809;
const kRecentPatchNotes = kPatchNotes20230809;
