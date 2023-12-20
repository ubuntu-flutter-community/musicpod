import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';

import 'package:url_launcher/url_launcher.dart';
import 'package:yaru_widgets/yaru_widgets.dart';

import '../../build_context_x.dart';
import '../../constants.dart';
import '../common/icons.dart';
import '../l10n/l10n.dart';

class AboutTile extends StatelessWidget {
  const AboutTile({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = context.t;
    final linkColor = theme.colorScheme.primary;
    final content = [
      Padding(
        padding: const EdgeInsets.only(
          right: 20,
          bottom: 10,
        ),
        child: InkWell(
          onTap: () => launchUrl(Uri.parse('https://github.com/Feichtmeier')),
          child: Text(
            'Copyright by Frederik Feichtmeier 2023 and onwards - all rights reserved',
            style: TextStyle(color: linkColor),
          ),
        ),
      ),
      InkWell(
        onTap: () => launchUrl(Uri.parse('https://github.com/kenvandine')),
        child: Text(
          'Snap packaging by Ken VanDine',
          style: TextStyle(color: linkColor),
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
              child: Markdown(
                data: 'Contributors:\n ${snapshot.data!}',
                onTapLink: (text, href, title) =>
                    href != null ? launchUrl(Uri.parse(href)) : null,
                styleSheet: MarkdownStyleSheet(
                  a: TextStyle(color: linkColor),
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
              style: context.t.textTheme.bodyMedium?.copyWith(
                color: linkColor,
              ),
            ),
            const SizedBox(
              width: 5,
            ),
            Icon(
              Iconz().external,
              color: linkColor,
              size: 18,
            ),
          ],
        ),
      ),
    ];

    return TextButton.icon(
      label: Text('${context.l10n.about} $kAppName'),
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
    );
  }

  Future<String> loadAsset(BuildContext context) async {
    return await DefaultAssetBundle.of(context)
        .loadString('assets/contributors.md');
  }
}
