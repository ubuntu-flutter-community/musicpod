import 'package:flutter/material.dart';

import '../../build_context_x.dart';
import '../common/icons.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({
    super.key,
    this.color,
  });

  final Color? color;

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      value: 0,
      vsync: this,
      duration: const Duration(seconds: 5),
      lowerBound: 0,
      upperBound: 1,
    );

    _animationController.addListener(() => setState(() {}));
    _animationController.repeat();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.t;
    return Material(
      color: widget.color ?? theme.scaffoldBackgroundColor,
      child: Center(
        child: AnimatedOpacity(
          duration: const Duration(milliseconds: 100),
          curve: Curves.bounceIn,
          opacity: _animationController.value,
          child: SizedBox(
            child: Container(
              width: 350,
              height: 350,
              decoration: BoxDecoration(
                color: theme.colorScheme.primary,
                borderRadius: BorderRadius.circular(30),
              ),
              child: Icon(
                Iconz().musicNote,
                size: 250,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
