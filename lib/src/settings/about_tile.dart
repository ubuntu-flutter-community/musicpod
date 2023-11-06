import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:musicpod/constants.dart';
import 'package:musicpod/src/common/icons.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:yaru_widgets/yaru_widgets.dart';

import '../l10n/l10n.dart';

class AboutTile extends StatelessWidget {
  const AboutTile({super.key});

  @override
  Widget build(BuildContext context) {
    final content = [
      Padding(
        padding: const EdgeInsets.only(
          right: 20,
          bottom: 10,
        ),
        child: InkWell(
          onTap: () => launchUrl(Uri.parse('https://github.com/Feichtmeier')),
          child: const Text(
            'Copyright by Frederik Feichtmeier 2023 and onwards - all rights reserved',
            style: TextStyle(color: Colors.blue),
          ),
        ),
      ),
      InkWell(
        onTap: () => launchUrl(Uri.parse('https://github.com/kenvandine')),
        child: const Text(
          'Snap packaging by Ken VanDine',
          style: TextStyle(color: Colors.blue),
        ),
      ),
      const SizedBox(
        height: kYaruPagePadding,
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
      InkWell(
        borderRadius: BorderRadius.circular(5),
        onTap: () async => await launchUrl(Uri.parse(kRepoUrl)),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              context.l10n.findUsOnGitHub,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.blue,
                  ),
            ),
            const SizedBox(
              width: 5,
            ),
            Icon(
              Iconz().external,
              color: Colors.blue,
              size: 18,
            ),
          ],
        ),
      ),
    ];

    return Center(
      child: SizedBox(
        height: kYaruTitleBarItemHeight,
        width: kYaruTitleBarItemHeight,
        child: IconButton(
          icon: Icon(
            Iconz().musicNote,
          ),
          onPressed: () {
            return showAboutDialog(
              applicationIcon: Image.asset(
                'snap/gui/musicpod.png',
                width: 64,
                height: 64,
              ),
              applicationVersion: context.l10n.musicPodSubTitle,
              context: context,
              children: content,
            );
          },
        ),
      ),
    );
  }

  Future<String> loadAsset(BuildContext context) async {
    return await DefaultAssetBundle.of(context)
        .loadString('assets/contributors.md');
  }
}
