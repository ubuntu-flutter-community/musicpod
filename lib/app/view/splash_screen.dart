import 'package:flutter/material.dart';

import '../../common/view/header_bar.dart';
import '../../common/view/progress.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: const HeaderBar(adaptive: false, title: Text('')),
        body: Center(
          child: SingleChildScrollView(
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Image.asset(
                    'assets/icon.png',
                    height: 250,
                    width: 250,
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
