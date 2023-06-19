import 'package:flutter/material.dart';

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
const kIconPadding = EdgeInsets.only(top: 8, bottom: 8, right: 5);
const kDialogWidth = 450.0;
const kGridDelegate = SliverGridDelegateWithMaxCrossAxisExtent(
  mainAxisExtent: 150,
  mainAxisSpacing: 10,
  crossAxisSpacing: 10,
  maxCrossAxisExtent: 550,
);
const kImageGridDelegate = SliverGridDelegateWithMaxCrossAxisExtent(
  maxCrossAxisExtent: 250,
  // childAspectRatio: 0.9,
  // mainAxisExtent: 250,
  mainAxisSpacing: 10,
  crossAxisSpacing: 10,
);
const kSnapcraftColor = Color(0xFFE95420);
const kDebianColor = Color(0xFFdb2264);
const kGreenLight = Color.fromARGB(255, 51, 121, 63);
const kGreenDark = Color.fromARGB(255, 128, 211, 143);
const kStarColor = Color(0xFFf99b11);
const kStarDevColor = Color(0xFFb24a26);
const kCheckForUpdateTimeOutInMinutes = 30;
const kFakeReviewText =
    'Lorem ipsum dolor sit amet, consetetur sadipscing elitr, sed diam nonumy eirmod tempor invidunt ut labore et dolore magna aliquyam erat, sed diam voluptua. At vero eos et accusam et justo duo dolores et ea rebum. Stet clita kasd gubergren, no sea takimata sanctus est Lorem ipsum dolor sit amet. Lorem ipsum dolor sit amet, consetetur sadipscing elitr, sed diam nonumy eirmod tempor invidunt ut labore et dolore magna aliquyam erat, sed diam voluptua. At vero eos et accusam et justo duo dolores et ea rebum. Stet clita kasd gubergren, no sea takimata sanctus est Lorem ipsum dolor sit amet.';

const kBorderContainerBgDark = Color.fromARGB(255, 46, 46, 46);
const badgeTextStyle = TextStyle(color: Colors.white, fontSize: 10);

const kShimmerBaseLight = Color.fromARGB(120, 230, 230, 230);
const kShimmerBaseDark = Color.fromARGB(255, 51, 51, 51);
const kShimmerHighLightLight = Color.fromARGB(197, 218, 218, 218);
const kShimmerHighLightDark = Color.fromARGB(255, 57, 57, 57);

const kLeadingGap = 40.0;

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
