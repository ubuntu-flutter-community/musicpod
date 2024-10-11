import 'package:flutter/material.dart';

import '../../common/view/header_bar.dart';
import '../../common/view/icons.dart';
import '../../common/view/progress.dart';
import '../../extensions/build_context_x.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const HeaderBar(adaptive: false, title: Text('')),
      body: Center(
        child: SingleChildScrollView(
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 250,
                  height: 250,
                  decoration: BoxDecoration(
                    color: context.colorScheme.primary,
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: Icon(
                    Iconz.musicNote,
                    size: 150,
                    color: Colors.white,
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.all(20),
                  child: Progress(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
