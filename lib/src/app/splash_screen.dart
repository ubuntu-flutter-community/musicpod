import 'package:flutter/material.dart';

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
      vsync: this,
      duration: const Duration(seconds: 1),
    );

    _animationController.addListener(() => setState(() {}));
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Material(
      color: widget.color,
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
                color: theme.primaryColor,
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
