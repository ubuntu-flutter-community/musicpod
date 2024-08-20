import '../../constants.dart';
import '../../extensions/build_context_x.dart';
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:yaru/yaru.dart';

import '../../extensions/theme_data_x.dart';

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
    final descriptionStyle = context.t.pageHeaderDescription;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: kYaruPagePadding),
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
          child: Html(
            data: description,
            onAnchorTap: (url, attributes, element) {
              if (url == null) return;
              launchUrl(Uri.parse(url));
            },
            style: {
              'img': Style(display: Display.none),
              'body': Style(
                height: Height.auto(),
                margin: Margins.zero,
                padding: HtmlPaddings.zero,
                textOverflow: TextOverflow.ellipsis,
                maxLines: 4,
                textAlign: TextAlign.center,
                fontSize: FontSize(
                  descriptionStyle?.fontSize ?? 10,
                ),
                fontWeight: descriptionStyle?.fontWeight,
                fontFamily: descriptionStyle?.fontFamily,
              ),
            },
          ),
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
          child: Html(
            data: description,
            onAnchorTap: (url, attributes, element) {
              if (url == null) return;
              launchUrl(Uri.parse(url));
            },
            style: {
              'img': Style(display: Display.none),
              'body': Style(
                height: Height.auto(),
                textOverflow: TextOverflow.ellipsis,
                maxLines: 400,
                textAlign: TextAlign.center,
                fontSize: FontSize(
                  descriptionStyle?.fontSize ?? 10,
                ),
                fontWeight: descriptionStyle?.fontWeight,
                fontFamily: descriptionStyle?.fontFamily,
              ),
            },
          ),
        ),
      ],
    );
  }
}
