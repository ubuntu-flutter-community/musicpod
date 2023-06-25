import 'package:file_selector/file_selector.dart';
import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:musicpod/app/responsive_master_tile.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:yaru_icons/yaru_icons.dart';

import '../common/constants.dart';

Future<String> loadAsset(BuildContext context) async {
  return await DefaultAssetBundle.of(context)
      .loadString('assets/contributors.md');
}

class SettingsTile extends StatelessWidget {
  const SettingsTile({super.key, required this.onDirectorySelected});

  final Future<void> Function(String? directoryPath) onDirectorySelected;

  @override
  Widget build(BuildContext context) {
    final content = [
      Padding(
        padding: const EdgeInsets.only(
          right: 20,
          bottom: 20,
        ),
        child: InkWell(
          onTap: () => launchUrl(Uri.parse('https://github.com/Feichtmeier')),
          child: const Text(
            'Copyright by Frederik Feichtmeier 2023 and onwards - all rights reserved',
            style: TextStyle(color: Colors.blue),
          ),
        ),
      ),
      Row(
        children: [
          ElevatedButton(
            onPressed: () async {
              final directoryPath = await getDirectoryPath();

              await onDirectorySelected(directoryPath)
                  .then((value) => Navigator.of(context).pop());
            },
            child: const Text('Pick your music collection'),
          ),
        ],
      ),
      Padding(
        padding: const EdgeInsets.only(
          top: 20,
          right: 20,
          bottom: 20,
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(5),
          onTap: () async => await launchUrl(Uri.parse(kRepoUrl)),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Find us on GitHub',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.blue,
                    ),
              ),
              const SizedBox(
                width: 5,
              ),
              const Icon(
                YaruIcons.external_link,
                color: Colors.blue,
                size: 18,
              )
            ],
          ),
        ),
      ),
      FutureBuilder<String>(
        future: loadAsset(context),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return SizedBox(
              height: 400,
              width: 300,
              child: MarkdownBody(
                data: 'Contributors:\n ${snapshot.data!}',
                onTapLink: (text, href, title) =>
                    href != null ? launchUrl(Uri.parse(href)) : null,
                styleSheet: MarkdownStyleSheet(
                  a: const TextStyle(color: Colors.blue),
                ),
              ),
            );
          } else {
            return const SizedBox();
          }
        },
      ),
    ];

    return LayoutBuilder(
      builder: (context, constraints) => ResponsiveMasterTile(
        title: const Text('Settings'),
        leading: const Icon(YaruIcons.settings),
        availableWidth: constraints.maxWidth,
        onTap: () {
          return showAboutDialog(
            applicationIcon: Image.asset(
              'snap/gui/musicpod.png',
              width: 64,
              height: 64,
            ),
            context: context,
            children: content,
          );
        },
      ),
    );
  }
}
