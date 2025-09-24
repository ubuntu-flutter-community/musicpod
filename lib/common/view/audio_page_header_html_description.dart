import 'package:flutter/material.dart';
import 'package:yaru/yaru.dart';

import '../../extensions/build_context_x.dart';
import '../../extensions/theme_data_x.dart';
import 'html_text.dart';
import 'ui_constants.dart';

class AudioPageHeaderHtmlDescription extends StatelessWidget {
  const AudioPageHeaderHtmlDescription({
    super.key,
    required this.description,
    required this.title,
  });

  final String description;
  final String title;

  @override
  Widget build(BuildContext context) {
    final descriptionStyle = context.theme.pageHeaderDescription;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: kLargestSpace),
      child: ConstrainedBox(
        constraints: const BoxConstraints(
          minWidth: kAudioHeaderDescriptionWidth,
          maxWidth: kAudioHeaderDescriptionWidth,
          maxHeight: 100,
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(kYaruButtonRadius),
          onTap: () => showDialog(
            context: context,
            builder: (context) => _HtmlDialog(
              title: title,
              description: description,
              descriptionStyle: descriptionStyle,
            ),
          ),
          child: HtmlText(text: description, wrapInFakeScroll: true),
        ),
      ),
    );
  }
}

class _HtmlDialog extends StatelessWidget {
  const _HtmlDialog({
    required this.title,
    required this.description,
    required this.descriptionStyle,
  });

  final String title;
  final String? description;
  final TextStyle? descriptionStyle;

  @override
  Widget build(BuildContext context) {
    return SimpleDialog(
      titlePadding: EdgeInsets.zero,
      contentPadding: EdgeInsets.zero,
      title: YaruDialogTitleBar(
        title: Text(title),
        backgroundColor: Colors.transparent,
        border: BorderSide.none,
      ),
      children: [
        SizedBox(
          width: 400,
          child: Padding(
            padding: const EdgeInsets.all(kLargestSpace),
            child: HtmlText(
              text: description ?? '',
              color: context.colorScheme.onSurface,
            ),
          ),
        ),
      ],
    );
  }
}
