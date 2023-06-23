import 'package:flutter/material.dart';
import 'package:yaru_widgets/yaru_widgets.dart';

const kPagePadding = 20.0;
const kGridPadding = EdgeInsets.only(
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

const kImageGridDelegate = SliverGridDelegateWithMaxCrossAxisExtent(
  maxCrossAxisExtent: 250,
  // childAspectRatio: 0.9,
  // mainAxisExtent: 250,
  mainAxisSpacing: 10,
  crossAxisSpacing: 10,
);

const delegateSmall = YaruMasterResizablePaneDelegate(
  initialPaneWidth: 60,
  minPaneWidth: 60,
  minPageWidth: kYaruMasterDetailBreakpoint / 2,
);

const delegateBig = YaruMasterResizablePaneDelegate(
  initialPaneWidth: 250,
  minPaneWidth: 60,
  minPageWidth: kYaruMasterDetailBreakpoint / 2,
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
