import 'package:flutter/material.dart';
import 'package:github/github.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:watch_it/watch_it.dart';
import 'package:yaru/yaru.dart';

import '../../app/app_model.dart';

import '../../common/view/header_bar.dart';
import '../../common/view/progress.dart';
import '../../common/view/safe_network_image.dart';
import '../../common/view/tapable_text.dart';
import '../../common/view/ui_constants.dart';
import '../../constants.dart';
import '../../extensions/build_context_x.dart';
import '../../l10n/l10n.dart';

const _kTileSize = 50.0;

class AboutPage extends StatefulWidget with WatchItStatefulWidgetMixin {
  const AboutPage({super.key});

  @override
  State<StatefulWidget> createState() => _AboutPageState();
}

class _AboutPageState extends State<AboutPage> {
  late Future<List<Contributor>> _contributors;

  @override
  void initState() {
    super.initState();
    _contributors = di<AppModel>().getContributors();
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    const radius = Radius.circular(8);

    final linkStyle = theme.textTheme.bodyLarge
        ?.copyWith(color: Colors.lightBlue, overflow: TextOverflow.visible);
    const maxLines = 3;

    final body = Padding(
      padding: const EdgeInsets.all(kLargestSpace),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TapAbleText(
            text:
                'MusicPod is made by Frederik Feichtmeier. If you like MusicPod, please sponsor me!',
            onTap: () => launchUrl(Uri.parse(kSponsorLink)),
            style: linkStyle,
            maxLines: maxLines,
          ),
          const SizedBox(
            height: kLargestSpace,
          ),
          TapAbleText(
            onTap: () => launchUrl(Uri.parse('https://ko-fi.com/amugofjava')),
            text:
                'MusicPod uses Podcast Search to find podcasts which is made by Ben Hills, please sponsor him!',
            style: linkStyle,
            maxLines: maxLines,
          ),
          const SizedBox(
            height: kLargestSpace,
          ),
          TapAbleText(
            onTap: () => launchUrl(
              Uri.parse('https://github.com/sponsors/alexmercerind'),
            ),
            text:
                'MusicPod uses MediaKit to play Media which is made by Hitesh Kumar Saini, please sponsor him!',
            style: linkStyle,
            maxLines: maxLines,
          ),
          const SizedBox(
            height: kLargestSpace,
          ),
          TapAbleText(
            onTap: () => launchUrl(Uri.parse('https://github.com/kenvandine')),
            text:
                'MusicPod Snap packaging is made by Ken VanDine, please sponsor him!',
            style: linkStyle,
            maxLines: maxLines,
          ),
          const SizedBox(
            height: kLargestSpace,
          ),
          TapAbleText(
            onTap: () => launchUrl(
              Uri.parse(
                'https://github.com/sponsors/ClementBeal',
              ),
            ),
            text:
                'MusicPod metadata reading is enabled by Clement Beal, please sponsor him!',
            style: linkStyle,
            maxLines: maxLines,
          ),
          const SizedBox(
            height: 2 * kLargestSpace,
          ),
          Text(
            context.l10n.contributors,
            style: theme.textTheme.bodyLarge,
          ),
          Expanded(
            child: FutureBuilder<List<Contributor>>(
              future: _contributors,
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  return SizedBox(
                    height: 300,
                    child: GridView.builder(
                      padding: const EdgeInsets.only(
                        bottom: kLargestSpace,
                        top: 10,
                      ),
                      gridDelegate:
                          const SliverGridDelegateWithMaxCrossAxisExtent(
                        maxCrossAxisExtent: _kTileSize,
                        mainAxisSpacing: 5,
                        crossAxisSpacing: 5,
                      ),
                      itemCount: snapshot.data!.length,
                      itemBuilder: (context, index) {
                        final e = snapshot.data!.elementAt(index);
                        return Tooltip(
                          message: e.login,
                          child: YaruBanner(
                            padding: EdgeInsets.zero,
                            onTap: e.htmlUrl == null
                                ? null
                                : () => launchUrl(Uri.parse(e.htmlUrl!)),
                            child: SizedBox.square(
                              dimension: _kTileSize,
                              child: ClipRRect(
                                borderRadius: const BorderRadius.all(radius),
                                child: SafeNetworkImage(
                                  fit: BoxFit.cover,
                                  url: e.avatarUrl,
                                  fallBackIcon: const YaruPlaceholderIcon(
                                    borderRadius:
                                        BorderRadiusDirectional.vertical(
                                      top: radius,
                                      bottom: radius,
                                    ),
                                    size: Size.square(_kTileSize),
                                  ),
                                ),
                              ),
                            ),
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
          ),
          TapAbleText(
            style: linkStyle,
            onTap: () => launchUrl(Uri.parse(kRepoUrl)),
            text:
                'Copyright by Frederik Feichtmeier 2023 and onwards - all rights reserved.',
            maxLines: maxLines,
          ),
        ],
      ),
    );

    final title = Text('${context.l10n.about} $kAppTitle');

    if (isMobile) {
      return Scaffold(
        appBar: HeaderBar(
          adaptive: false,
          title: title,
        ),
        body: body,
      );
    }

    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          YaruDialogTitleBar(
            border: BorderSide.none,
            backgroundColor: context.theme.dialogBackgroundColor,
            title: title,
            leading: YaruBackButton(
              style: YaruBackButtonStyle.rounded,
              onPressed: () => Navigator.of(context).pop(),
            ),
          ),
          Expanded(
            child: body,
          ),
        ],
      ),
    );
  }
}
