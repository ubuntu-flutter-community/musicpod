import 'package:flutter/material.dart';
import 'package:watch_it/watch_it.dart';
import 'package:yaru/yaru.dart';

import '../../app_config.dart';
import '../../library/library_model.dart';

class NavBackButton extends StatelessWidget {
  const NavBackButton({super.key});

  @override
  Widget build(BuildContext context) {
    void onTap() => di<LibraryModel>().pop();

    if (AppConfig.yaruStyled) {
      return YaruBackButton(
        style: YaruBackButtonStyle.rounded,
        onPressed: onTap,
      );
    }
    return Center(
      child: BackButton(
        onPressed: onTap,
      ),
    );
  }
}
