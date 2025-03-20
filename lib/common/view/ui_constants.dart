import 'package:flutter/material.dart';

const kLargestSpace = 20.0;

const kMediumSpace = 10.0;

const kSmallestSpace = 5.0;

const kTinyButtonSize = 30.0;

const kTinyButtonIconSize = 13.0;

const kDesktopSearchBarWidth = 335.0;

const kMobileSearchBarWidth = 270.0;

const kSnackBarWidth = 500.0;

const fullHeightPlayerImageSize = 300.0;

const kMaxAudioPageHeaderHeight = 200.0;

const kMinAudioPageHeaderHeight = 0.0;

const kSnackBarDuration = Duration(seconds: 10);

const kAudioTilePadding = EdgeInsets.symmetric(horizontal: 10);

const kAudioTileTrackPadding = EdgeInsets.only(right: kLargestSpace);

const kAudioTileSpacing = EdgeInsets.only(right: 10.0);

const kAudioTrackWidth = 40.0;

const kSideBarThreshHold = 1500.0;

const kSideBarPlayerWidth = 500.0;

const kGridPadding = EdgeInsets.only(
  top: 0,
  bottom: kLargestSpace,
  left: kLargestSpace - 5,
  right: kLargestSpace - 5,
);
const kMobileGridPadding = EdgeInsets.only(
  top: 0,
  bottom: kLargestSpace,
  left: kLargestSpace - 5,
  right: kLargestSpace - 5,
);

const kHeaderPadding = EdgeInsets.only(
  top: kLargestSpace,
  left: kLargestSpace,
  right: kLargestSpace,
  bottom: kLargestSpace - 5,
);

const kAudioCardDimension = 130.0;

const kAudioCardBottomHeight = 30.0;

const kMasterDetailBreakPoint = 720.0;

const kMasterDetailSideBarWidth = 250.0;

const kAdaptivContainerBreakPoint = 1200.0;

const kAudioCardGridDelegate = SliverGridDelegateWithMaxCrossAxisExtent(
  maxCrossAxisExtent: kAudioCardDimension + 40,
  mainAxisExtent: kAudioCardDimension + kAudioCardBottomHeight + 8,
  mainAxisSpacing: 0,
  crossAxisSpacing: 10,
);

const kMobileAudioCardGridDelegate = SliverGridDelegateWithMaxCrossAxisExtent(
  maxCrossAxisExtent: kAudioCardDimension,
  mainAxisExtent: kAudioCardDimension + kAudioCardBottomHeight + 5,
  mainAxisSpacing: 0,
  crossAxisSpacing: 10,
);

const kDiskGridDelegate = SliverGridDelegateWithMaxCrossAxisExtent(
  maxCrossAxisExtent: kAudioCardDimension + 10,
  mainAxisSpacing: 10,
  crossAxisSpacing: 10,
);

const kAudioControlPanelPadding = EdgeInsets.only(
  top: kLargestSpace / 2,
  left: kLargestSpace,
  right: kLargestSpace,
  bottom: kLargestSpace / 2,
);

const kMainPageIconPadding = EdgeInsets.only(right: 4.0);

const kAudioHeaderDescriptionWidth = 400.0;

const kShowLeadingThreshold = 3000;

const kMusicPodDefaultColor = Color(0xFFed3c63);
