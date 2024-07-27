import '../../constants.dart';
import '../../extensions/build_context_x.dart';
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:phoenix_theme/phoenix_theme.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:yaru/yaru.dart';

class AudioPageHeaderHtmlDescription extends StatelessWidget {
  const AudioPageHeaderHtmlDescription({
    super.key,
    required this.description,
    required this.title,
  });

  final String? description;
  final String title;

  @override
  Widget build(BuildContext context) {
    final descriptionStyle = context.t.textTheme.labelSmall;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: kYaruPagePadding),
      child: SizedBox(
        width: kAudioHeaderDescriptionWidth,
        child: InkWell(
          borderRadius: BorderRadius.circular(kButtonRadius),
          onTap: () => showDialog(
            context: context,
            builder: (context) => SimpleDialog(
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
            ),
          ),
          child: SizedBox(
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
      ),
    );
  }
}
