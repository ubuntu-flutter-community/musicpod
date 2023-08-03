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
const kBackgroundDark = Color.fromARGB(255, 37, 37, 37);
const kBackGroundLight = Colors.white;

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
