import 'package:flutter/material.dart';
import 'package:github/github.dart';
import 'package:ubuntu_service/ubuntu_service.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:yaru_icons/yaru_icons.dart';

import '../../build_context_x.dart';
import '../../common.dart';
import '../../constants.dart';
import '../l10n/l10n.dart';

const _kTileSize = 50.0;

class AboutTile extends StatelessWidget {
  const AboutTile({super.key});

  @override
  Widget build(BuildContext context) {
    final linkStyle = context.t.textTheme.bodyLarge
        ?.copyWith(color: Colors.lightBlue, overflow: TextOverflow.visible);
    const maxLines = 3;

    final content = [
      TapAbleText(
        text:
            'MusicPod is made by Frederik Feichtmeier. If you like MusicPod, please sponsor me!',
        onTap: () => launchUrl(Uri.parse(kSponsorLink)),
        style: linkStyle,
        maxLines: maxLines,
      ),
      TapAbleText(
        onTap: () => launchUrl(Uri.parse('https://ko-fi.com/amugofjava')),
        text:
            'The Podcast Dart Library is made by Ben Hills, please sponsor him!',
        style: linkStyle,
        maxLines: maxLines,
      ),
      TapAbleText(
        onTap: () => launchUrl(Uri.parse('https://github.com/kenvandine')),
        text: 'Snap packaging by Ken VanDine, please sponsor him!',
        style: linkStyle,
        maxLines: maxLines,
      ),
      const Padding(
        padding: EdgeInsets.only(top: 40),
        child: Text('Contributors:'),
      ),
      FutureBuilder<List<Contributor>>(
        future: _loadContributors(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return SizedBox(
              height: 300,
              width: 400,
              child: GridView.builder(
                padding: const EdgeInsets.only(bottom: 20, top: 10),
                gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                  maxCrossAxisExtent: _kTileSize,
                  mainAxisExtent: _kTileSize,
                  mainAxisSpacing: 10,
                  crossAxisSpacing: 10,
                ),
                itemCount: snapshot.data!.length,
                itemBuilder: (context, index) {
                  final e = snapshot.data!.elementAt(index);
                  return InkWell(
                    borderRadius: BorderRadius.circular(100),
                    onTap: e.htmlUrl == null
                        ? null
                        : () => launchUrl(Uri.parse(e.htmlUrl!)),
                    child: CircleAvatar(
                      backgroundImage: e.avatarUrl != null
                          ? NetworkImage(
                              e.avatarUrl!,
                            )
                          : null,
                      child: e.avatarUrl == null
                          ? const YaruPlaceholderIcon(
                              size: Size.square(_kTileSize),
                            )
                          : null,
                    ),
                  );
                },
              ),
            );
          } else {
            return const Center(
              child: Progress(),
            );
          }
        },
      ),
      TapAbleText(
        style: linkStyle,
        onTap: () => launchUrl(Uri.parse(kRepoUrl)),
        text:
            'Copyright by Frederik Feichtmeier 2023 and onwards - all rights reserved.',
        maxLines: maxLines,
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
          children: content
              .map(
                (e) => Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: e,
                ),
              )
              .toList(),
        );
      },
    );
  }

  Future<List<Contributor>> _loadContributors() async {
    final github = getService<GitHub>();
    return (await github.repositories
        .listContributors(
          RepositorySlug.full(kGitHubShortLink),
        )
        .where((c) => c.type == 'User')
        .toList());
  }
}
