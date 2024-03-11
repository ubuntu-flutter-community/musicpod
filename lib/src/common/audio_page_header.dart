import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:yaru/yaru.dart';

import '../../build_context_x.dart';
import '../../constants.dart';
import '../l10n/l10n.dart';

const _kBigTextMitigation = 2.0;

class AudioPageHeader extends StatelessWidget {
  const AudioPageHeader({
    super.key,
    required this.title,
    this.description,
    this.image,
    this.label,
    this.subTitle,
    this.imageRadius,
    this.onSubTitleTab,
    this.onLabelTab,
    this.content,
    this.padding,
  });

  final String title;
  final String? description;
  final Widget? content;
  final Widget? image;
  final String? label;
  final String? subTitle;
  final void Function(String text)? onSubTitleTab;
  final void Function(String text)? onLabelTab;

  final BorderRadius? imageRadius;
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    const height = kMaxAudioPageHeaderHeight;
    final theme = context.t;
    final size = context.m.size;
    final smallWindow = size.width < kMasterDetailBreakPoint;
    final radius = imageRadius ?? BorderRadius.circular(10);

    return Padding(
      padding: !smallWindow
          ? (padding ??
              const EdgeInsets.only(
                bottom: kYaruPagePadding,
                left: kYaruPagePadding,
              ))
          : const EdgeInsets.symmetric(vertical: kYaruPagePadding),
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
                      smallWindow ? 0 : kYaruPagePadding - _kBigTextMitigation,
                ),
                child: SizedBox.square(
                  dimension: height,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      borderRadius: radius,
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
                      borderRadius: radius,
                      child: image!,
                    ),
                  ),
                ),
              ),
            if (!smallWindow)
              Expanded(
                child: content ??
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Expanded(
                          child: AudioPageHeaderTitle(title: title),
                        ),
                        Expanded(
                          child: AudioPageHeaderSubTitle(
                            onLabelTab: onLabelTab,
                            label: label,
                            subTitle: subTitle,
                            onSubTitleTab: onSubTitleTab,
                          ),
                        ),
                        Expanded(
                          flex: 4,
                          child: (description != null)
                              ? Padding(
                                  padding: const EdgeInsets.only(
                                    left: _kBigTextMitigation,
                                  ),
                                  child: SingleChildScrollView(
                                    padding: const EdgeInsets.only(
                                      right: kYaruPagePadding,
                                    ),
                                    child: Html(
                                      data: description,
                                      onAnchorTap: (url, attributes, element) {
                                        if (url == null) return;
                                        launchUrl(Uri.parse(url));
                                      },
                                      style: {
                                        // 'height': Style(height: Height.auto()),
                                        'img': Style(display: Display.none),
                                        'html': Style(
                                          margin: Margins.zero,
                                          padding: HtmlPaddings.zero,
                                          textAlign: TextAlign.start,
                                          textOverflow: TextOverflow.fade,
                                        ),
                                        'body': Style(
                                          margin: Margins.zero,
                                          padding: HtmlPaddings.zero,
                                          textOverflow: TextOverflow.fade,
                                          textAlign: TextAlign.start,
                                        ),
                                      },
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

class AudioPageHeaderSubTitle extends StatelessWidget {
  const AudioPageHeaderSubTitle({
    super.key,
    this.onLabelTab,
    required this.label,
    required this.subTitle,
    this.onSubTitleTab,
  });

  final void Function(String text)? onLabelTab;
  final String? label;
  final String? subTitle;
  final void Function(String text)? onSubTitleTab;

  @override
  Widget build(BuildContext context) {
    final theme = context.t;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        const SizedBox(
          width: _kBigTextMitigation,
        ),
        Flexible(
          child: InkWell(
            borderRadius: BorderRadius.circular(5),
            onTap: onLabelTab == null || label == null
                ? null
                : () => onLabelTab?.call(label!),
            child: Text(
              label ?? context.l10n.album,
              style: theme.textTheme.labelMedium,
              maxLines: 1,
            ),
          ),
        ),
        if (subTitle?.isNotEmpty == true)
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 5),
            child: Text('·'),
          ),
        if (subTitle?.isNotEmpty == true)
          Flexible(
            child: InkWell(
              borderRadius: BorderRadius.circular(5),
              onTap: onSubTitleTab == null || subTitle == null
                  ? null
                  : () => onSubTitleTab?.call(subTitle!),
              child: Text(
                subTitle ?? '',
                style: theme.textTheme.labelMedium,
                maxLines: 1,
                overflow: TextOverflow.visible,
              ),
            ),
          ),
      ],
    );
  }
}

class AudioPageHeaderTitle extends StatelessWidget {
  const AudioPageHeaderTitle({
    super.key,
    required this.title,
  });

  final String title;

  @override
  Widget build(BuildContext context) {
    final theme = context.t;
    final size = context.m.size;
    final smallWindow = size.width < kMasterDetailBreakPoint;

    return Padding(
      padding: smallWindow
          ? EdgeInsets.zero
          : const EdgeInsets.only(right: kYaruPagePadding),
      child: Text(
        title,
        style: theme.textTheme.headlineLarge?.copyWith(
          fontWeight: FontWeight.w300,
          letterSpacing: 0,
          leadingDistribution: TextLeadingDistribution.proportional,
          fontSize: 30,
          color: theme.colorScheme.onSurface.withOpacity(0.9),
        ),
        overflow: TextOverflow.ellipsis,
      ),
    );
  }
}
