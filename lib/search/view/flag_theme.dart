import 'package:flutter/material.dart';

class FlagTheme extends StatelessWidget {
  const FlagTheme({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: Theme.of(context).copyWith(
        textTheme: TextTheme.of(context).apply(fontFamily: 'NotoEmoji'),
      ),
      child: child,
    );
  }
}
