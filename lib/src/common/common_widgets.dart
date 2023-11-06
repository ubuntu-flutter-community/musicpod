import 'dart:io';

import 'package:flutter/material.dart';
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

bool get showSideBarFilter => Platform.isLinux ? true : false;

FontWeight get smallTextFontWeight =>
    Platform.isLinux ? FontWeight.w100 : FontWeight.w400;
