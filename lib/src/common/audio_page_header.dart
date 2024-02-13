import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:yaru_widgets/yaru_widgets.dart';

import '../../build_context_x.dart';
import '../../constants.dart';
import '../../theme.dart';
import '../l10n/l10n.dart';

class AudioPageHeader extends StatelessWidget {
  const AudioPageHeader({
    super.key,
    required this.title,
    this.description,
    this.image,
    this.label,
    this.subTitle,
    this.height,
  });

  final String title;
  final String? description;
  final Widget? image;
  final String? label;
  final String? subTitle;
  final double? height;

  @override
  Widget build(BuildContext context) {
    final theme = context.t;
    final size = context.m.size;
    final smallWindow = size.width < kMasterDetailBreakPoint;
    final imageRadius = BorderRadius.circular(10);
    const kBigTextMitigation = 2.0;

    return Padding(
      padding: height != kMinAudioPageHeaderHeight
          ? const EdgeInsets.all(20)
          : const EdgeInsets.only(left: 20),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        height: height,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment:
              smallWindow ? MainAxisAlignment.center : MainAxisAlignment.start,
          children: [
            if (image != null)
              Padding(
                padding: EdgeInsets.only(
                  right:
                      smallWindow ? 0 : kYaruPagePadding - kBigTextMitigation,
                ),
                child: SizedBox.square(
                  dimension: height,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      borderRadius: imageRadius,
                      boxShadow: [
                        BoxShadow(
                          offset: const Offset(0, 0),
                          spreadRadius: 0.8,
                          blurRadius: 0,
                          color: theme.shadowColor.withOpacity(0.1),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: imageRadius,
                      child: image!,
                    ),
                  ),
                ),
              ),
            if (!smallWindow)
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Flexible(
                      fit: FlexFit.tight,
                      child: Text(
                        title,
                        style: theme.textTheme.headlineLarge?.copyWith(
                          fontWeight: FontWeight.w300,
                          letterSpacing: 0,
                          leadingDistribution:
                              TextLeadingDistribution.proportional,
                          fontSize: 30,
                          color: theme.colorScheme.onSurface.withOpacity(0.9),
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (height != kMinAudioPageHeaderHeight)
                      Flexible(
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const SizedBox(
                              width: kBigTextMitigation,
                            ),
                            Flexible(
                              child: Text(
                                label ?? context.l10n.album,
                                style: theme.textTheme.labelSmall,
                                maxLines: 1,
                              ),
                            ),
                            if (subTitle?.isNotEmpty == true)
                              const Padding(
                                padding: EdgeInsets.symmetric(horizontal: 5),
                                child: Text('·'),
                              ),
                            if (subTitle?.isNotEmpty == true)
                              Flexible(
                                child: Text(
                                  subTitle ?? '',
                                  style: theme.textTheme.labelSmall,
                                  maxLines: 1,
                                  overflow: TextOverflow.visible,
                                ),
                              ),
                          ],
                        ),
                      ),
                    Expanded(
                      flex: 3,
                      child: description != null &&
                              height != kMinAudioPageHeaderHeight
                          ? Padding(
                              padding: const EdgeInsets.only(
                                left: kBigTextMitigation,
                              ),
                              child: InkWell(
                                borderRadius:
                                    BorderRadius.circular(kYaruButtonRadius),
                                onTap: () => showDialog(
                                  context: context,
                                  builder: (context) => _DescriptionDialog(
                                    title: title,
                                    description: description!,
                                  ),
                                ),
                                child: SizedBox(
                                  height: 100,
                                  child: Html(
                                    data: description,
                                    onAnchorTap: (url, attributes, element) {
                                      if (url == null) return;
                                      launchUrl(Uri.parse(url));
                                    },
                                    style: {
                                      'img': Style(display: Display.none),
                                      'html': Style(
                                        margin: Margins.zero,
                                        padding: HtmlPaddings.zero,
                                        textAlign: TextAlign.start,
                                        maxLines: 20,
                                        textOverflow: TextOverflow.fade,
                                      ),
                                      'body': Style(
                                        margin: Margins.zero,
                                        textOverflow: TextOverflow.fade,
                                        maxLines: 20,
                                        textAlign: TextAlign.start,
                                      ),
                                    },
                                  ),
                                ),
                              ),
                            )
                          : const SizedBox.expand(),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _DescriptionDialog extends StatelessWidget {
  const _DescriptionDialog({
    required this.title,
    required this.description,
  });

  final String title;
  final String description;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: yaruStyled
          ? YaruDialogTitleBar(
              title: Text(title),
              backgroundColor: Colors.transparent,
              border: BorderSide.none,
            )
          : Text(title),
      titlePadding: yaruStyled ? EdgeInsets.zero : null,
      contentPadding: const EdgeInsets.only(
        top: 10,
        left: kYaruPagePadding,
        right: kYaruPagePadding,
        bottom: kYaruPagePadding,
      ),
      content: SizedBox(
        width: 400,
        height: 500,
        child: Html(
          onAnchorTap: (url, attributes, element) {
            if (url == null) return;
            launchUrl(Uri.parse(url));
          },
          data: description,
          style: {
            'html': Style(
              margin: Margins.zero,
              padding: HtmlPaddings.zero,
            ),
            'body': Style(
              margin: Margins.zero,
              padding: HtmlPaddings.zero,
            ),
          },
        ),
      ),
      scrollable: true,
    );
  }
}
