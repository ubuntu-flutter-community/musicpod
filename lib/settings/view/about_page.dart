import 'package:flutter/material.dart';
import 'package:github/github.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:watch_it/watch_it.dart';
import 'package:yaru/yaru.dart';

import '../../app/app_model.dart';
import '../../app_config.dart';
import '../../common/view/progress.dart';
import '../../common/view/safe_network_image.dart';
import '../../common/view/tapable_text.dart';
import '../../common/view/ui_constants.dart';
import '../../extensions/build_context_x.dart';
import '../../l10n/l10n.dart';

const _kTileSize = 50.0;

class AboutDialog extends StatelessWidget {
  const AboutDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      titlePadding: EdgeInsets.zero,
      contentPadding: EdgeInsets.zero,
      title: YaruDialogTitleBar(
        border: BorderSide.none,
        backgroundColor: context.theme.dialogTheme.backgroundColor,
        title: Text(context.l10n.contributors),
      ),
      backgroundColor: context.theme.dialogTheme.backgroundColor,
      content: const SizedBox(height: 800, width: 600, child: _AboutPage()),
    );
  }
}

class _AboutPage extends StatefulWidget with WatchItStatefulWidgetMixin {
  const _AboutPage();

  @override
  State<StatefulWidget> createState() => _AboutPageState();
}

class _AboutPageState extends State<_AboutPage> {
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

    final linkStyle = theme.textTheme.bodyLarge?.copyWith(
      color: Colors.lightBlue,
      overflow: TextOverflow.visible,
    );
    const maxLines = 3;

    return Column(
      children: [
        Expanded(
          child: CustomScrollView(
            slivers: [
              FutureBuilder<List<Contributor>>(
                future: _contributors,
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return SliverFillRemaining(
                      hasScrollBody: false,
                      child: Center(child: Text(snapshot.error.toString())),
                    );
                  }
                  if (snapshot.hasData) {
                    return SliverPadding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: kLargestSpace,
                        vertical: kSmallestSpace,
                      ),
                      sliver: SliverGrid.builder(
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
                    return const SliverFillRemaining(
                      hasScrollBody: false,
                      child: Center(child: Progress()),
                    );
                  }
                },
              ),
              SliverPadding(
                padding: const EdgeInsets.only(
                  left: kLargestSpace,
                  right: kLargestSpace,
                  top: kLargestSpace,
                  bottom: kSmallestSpace,
                ),
                sliver: SliverToBoxAdapter(
                  child: Text(
                    'Sponsor us to keep this project alive!',
                    style: theme.textTheme.titleLarge,
                  ),
                ),
              ),
              ..._sponsor.entries.map(
                (e) => SliverPadding(
                  padding: const EdgeInsets.only(
                    left: kLargestSpace + kMediumSpace,
                    right: kLargestSpace,
                    top: kSmallestSpace,
                    bottom: kSmallestSpace,
                  ),
                  sliver: SliverToBoxAdapter(
                    child: Row(
                      spacing: kMediumSpace,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: kSmallestSpace,
                          height: kSmallestSpace,
                          decoration: BoxDecoration(
                            color: context.theme.colorScheme.onSurface,
                            borderRadius: BorderRadius.circular(
                              kYaruButtonRadius,
                            ),
                          ),
                        ),
                        Flexible(
                          child: TapAbleText(
                            wrapInFlexible: false,
                            text: e.key,
                            onTap: e.value == null
                                ? null
                                : () {
                                    final maybe = Uri.tryParse(e.value!);
                                    if (maybe != null) {
                                      launchUrl(maybe);
                                    }
                                  },
                            style: linkStyle,
                            maxLines: maxLines,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(
            left: kLargestSpace,
            right: kLargestSpace,
            bottom: kMediumSpace,
          ),
          child: TapAbleText(
            style: linkStyle,
            onTap: () => launchUrl(Uri.parse(AppConfig.repoUrl)),
            text:
                'Copyright by Frederik Feichtmeier 2023-2025 - all rights reserved.',
            maxLines: maxLines,
          ),
        ),
      ],
    );
  }
}

const _sponsor = <String, String?>{
  'Frederik Feichtmeier (MusicPod Creator/Designer)': AppConfig.sponsorLink,
  'Benn Hills (Dart Podcast Search)': 'https://ko-fi.com/amugofjava',
  'Clement Beal (Dart metadata reader)':
      'https://github.com/sponsors/ClementBeal',
  'Tomás Sasovsky (Dart implementation of radiobrowser-api) ':
      'https://github.com/tomassasovsky',
  'Stuart Jaggers (App Icon)': 'https://github.com/ubuntujaggers',
  'Hitesh Kumar Saini (MediaKit Dart MPV)':
      'https://github.com/sponsors/alexmercerind',
  'ThomasBurkhart (watch_it state management and get_it)':
      'https://github.com/sponsors/escamoteur',
  'Ken VanDine (snap packaging)': 'https://github.com/kenvandine',
};
