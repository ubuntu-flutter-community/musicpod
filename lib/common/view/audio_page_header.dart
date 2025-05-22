import 'package:flutter/material.dart';

import '../../extensions/build_context_x.dart';
import '../../extensions/theme_data_x.dart';
import '../../l10n/l10n.dart';
import 'ui_constants.dart';

class AudioPageHeader extends StatelessWidget {
  const AudioPageHeader({
    super.key,
    required this.title,
    this.image,
    this.label,
    this.subTitle,
    this.subTitleWidget,
    this.imageRadius,
    this.onSubTitleTab,
    this.onLabelTab,
    this.description,
    this.padding,
  });

  final String title;
  final Widget? description;
  final Widget? image;
  final String? label;
  final String? subTitle;
  final Widget? subTitleWidget;
  final void Function(String text)? onSubTitleTab;
  final void Function(String text)? onLabelTab;

  final BorderRadius? imageRadius;
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final radius = imageRadius ?? BorderRadius.circular(10);

    return Padding(
      padding: const EdgeInsets.only(
        bottom: kLargestSpace,
        left: kLargestSpace,
        right: kLargestSpace,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          if (image != null)
            SizedBox.square(
              dimension: kMaxAudioPageHeaderHeight,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  borderRadius: radius,
                  boxShadow: [
                    BoxShadow(
                      offset: const Offset(0, 0),
                      spreadRadius: 0.8,
                      blurRadius: 0,
                      color: theme.shadowColor.withValues(alpha: 0.1),
                    ),
                  ],
                ),
                child: ClipRRect(borderRadius: radius, child: image!),
              ),
            ),
          Padding(
            padding: const EdgeInsets.only(top: kLargestSpace, bottom: 5),
            child: Text(
              title,
              style: theme.pageHeaderStyle,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          if (subTitle != null)
            _AudioPageHeaderSubTitle(
              onLabelTab: onLabelTab,
              label: label,
              subTitle: subTitle,
              onSubTitleTab: onSubTitleTab,
            )
          else if (subTitleWidget != null)
            subTitleWidget!,
          if (description != null)
            Padding(
              padding: const EdgeInsets.only(top: 10),
              child: description!,
            ),
        ],
      ),
    );
  }
}

class _AudioPageHeaderSubTitle extends StatelessWidget {
  const _AudioPageHeaderSubTitle({
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
    final theme = context.theme;

    final style = theme.pageHeaderSubtitleStyle;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Flexible(
          child: InkWell(
            borderRadius: BorderRadius.circular(5),
            onTap: onLabelTab == null || label == null
                ? null
                : () => onLabelTab?.call(label!),
            child: Text(label ?? context.l10n.album, style: style, maxLines: 1),
          ),
        ),
        if (subTitle?.isNotEmpty == true)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 5),
            child: Text('·', style: style),
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
                style: style,
                maxLines: 1,
                overflow: TextOverflow.visible,
              ),
            ),
          ),
      ],
    );
  }
}
