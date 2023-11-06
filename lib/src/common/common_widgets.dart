import 'dart:io';

import 'package:flutter/material.dart';
import 'package:musicpod/constants.dart';
import 'package:yaru_widgets/yaru_widgets.dart';

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

double? get avatarIconSize => _yaruApp ? kYaruTitleBarItemHeight / 2 : null;

double? get snackBarWidth => _yaruApp ? kSnackBarWidth : null;

double get searchBarWidth => _mobile ? kSearchBarWidth : 600;

bool get showSideBarFilter => _yaruApp ? true : false;

FontWeight get smallTextFontWeight =>
    _yaruApp ? FontWeight.w100 : FontWeight.w400;

bool get _yaruApp => Platform.isLinux;

bool get _mobile => Platform.isAndroid || Platform.isIOS;

bool get shrinkTitleBarItems => _yaruApp;
