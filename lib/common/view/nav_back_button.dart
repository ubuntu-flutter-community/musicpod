import '../../library/library_model.dart';
import 'dart:io';
import 'icons.dart';
import 'package:flutter/material.dart';
import 'package:watch_it/watch_it.dart';
import 'package:yaru/yaru.dart';
import 'theme.dart';

class NavBackButton extends StatelessWidget {
  const NavBackButton({super.key});

  @override
  Widget build(BuildContext context) {
    void onTap() => di<LibraryModel>().pop();

    if (yaruStyled) {
      return YaruBackButton(
        style: YaruBackButtonStyle.rounded,
        onPressed: onTap,
      );
    } else {
      if (Platform.isMacOS) {
        return Padding(
          padding: const EdgeInsets.only(top: 16, left: 13),
          child: Center(
            child: SizedBox(
              height: 15,
              width: 15,
              child: InkWell(
                borderRadius: BorderRadius.circular(20),
                onTap: onTap,
                child: Icon(
                  Iconz().goBack,
                  size: 10,
                ),
              ),
            ),
          ),
        );
      } else {
        return Center(
          child: BackButton(
            onPressed: onTap,
          ),
        );
      }
    }
  }
}
