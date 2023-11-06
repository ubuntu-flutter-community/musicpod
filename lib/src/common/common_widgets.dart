import 'dart:io';

import 'package:flutter/material.dart';
import 'package:yaru_widgets/yaru_widgets.dart';

import '../../constants.dart';
import 'icons.dart';

class NavBackButton extends StatelessWidget {
  const NavBackButton({super.key});

  @override
  Widget build(BuildContext context) {
    return Platform.isLinux
        ? const YaruBackButton(
            style: YaruBackButtonStyle.rounded,
          )
        : const BackButton();
  }
}

class SideBarProgress extends StatelessWidget {
  const SideBarProgress({super.key});

  @override
  Widget build(BuildContext context) {
    return _yaruApp
        ? const SizedBox(
            height: 18,
            width: 18,
            child: Progress(),
          )
        : SizedBox(
            height: iconSize(),
            width: iconSize(),
            child: const Progress(),
          );
  }
}

class Progress extends StatelessWidget {
  const Progress({
    super.key,
    this.value,
    this.backgroundColor,
    this.color,
    this.valueColor,
    this.semanticsLabel,
    this.semanticsValue,
    this.strokeCap,
    this.strokeWidth = 3.0,
    this.padding,
  });

  final double? value;
  final Color? backgroundColor;
  final Color? color;
  final Animation<Color?>? valueColor;
  final double strokeWidth;
  final String? semanticsLabel;
  final String? semanticsValue;
  final StrokeCap? strokeCap;
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    final c = color ?? Theme.of(context).primaryColor.withOpacity(0.5);
    return _yaruApp
        ? YaruCircularProgressIndicator(
            strokeWidth: strokeWidth,
            value: value,
            valueColor: valueColor,
            semanticsLabel: semanticsLabel,
            semanticsValue: semanticsValue,
            trackColor: c,
          )
        : Padding(
            padding: padding ?? const EdgeInsets.all(4),
            child: CircularProgressIndicator(
              strokeWidth: strokeWidth,
              value: value,
              valueColor: valueColor,
              semanticsLabel: semanticsLabel,
              semanticsValue: semanticsValue,
              backgroundColor: c,
            ),
          );
  }
}

double? get avatarIconSize => _yaruApp ? kYaruTitleBarItemHeight / 2 : null;

double? get snackBarWidth => _yaruApp ? kSnackBarWidth : null;

double get searchBarWidth => _mobile ? kSearchBarWidth : 600;

bool get showSideBarFilter => _yaruApp ? true : false;

FontWeight get smallTextFontWeight =>
    _yaruApp ? FontWeight.w100 : FontWeight.w400;

FontWeight get mediumTextWeight => _yaruApp ? FontWeight.w200 : FontWeight.w500;

bool get _yaruApp => Platform.isLinux;

bool get _mobile => Platform.isAndroid || Platform.isIOS;

bool get shrinkTitleBarItems => _yaruApp;

double get chipHeight => _yaruApp ? kYaruTitleBarItemHeight : 40;

EdgeInsetsGeometry get gridPadding =>
    _yaruApp ? kPodcastGridPadding : kMobilePodcastGridPadding;
