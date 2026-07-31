import 'package:flutter/material.dart';

class SettingsSection extends StatelessWidget {
  const SettingsSection({
    super.key,
    required this.heading,
    required this.children,
  });

  final String heading;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ListTile(title: Text(heading)),
        Card(
          margin: const EdgeInsets.symmetric(horizontal: 15.0),
          child: Padding(
            padding: const EdgeInsets.only(bottom: 5, top: 5),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: children,
            ),
          ),
        ),
      ],
    );
  }
}
