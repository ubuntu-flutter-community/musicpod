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
  });

  final String title;
  final String? description;
  final Widget? image;
  final String? label;
  final String? subTitle;

  @override
  Widget build(BuildContext context) {
    final theme = context.t;
    final size = context.m.size;
    final smallWindow = size.width < 600.0;

    return Container(
      height: kAudioPageHeaderHeight,
      padding: const EdgeInsets.all(20),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment:
            smallWindow ? MainAxisAlignment.center : MainAxisAlignment.start,
        children: [
          if (image != null)
            Padding(
              padding: EdgeInsets.only(right: smallWindow ? 0 : 20),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: image!,
              ),
            ),
          if (!smallWindow)
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Flexible(
                    child: Text(
                      label ?? context.l10n.album,
                      style: theme.textTheme.labelSmall,
                    ),
                  ),
                  Flexible(
                    child: Text(
                      title,
                      style: theme.textTheme.headlineLarge?.copyWith(
                        fontWeight: FontWeight.w300,
                        fontSize: 35,
                        color: theme.colorScheme.onSurface.withOpacity(0.9),
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (subTitle?.isNotEmpty == true)
                    Flexible(
                      child: Text(
                        subTitle!,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ),
                  description == null
                      ? const SizedBox.expand()
                      : Expanded(
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
                                ),
                                'body': Style(
                                  margin: Margins.zero,
                                  padding: HtmlPaddings.only(top: 5),
                                  textOverflow: TextOverflow.ellipsis,
                                  maxLines: 20,
                                  textAlign: TextAlign.start,
                                ),
                              },
                            ),
                          ),
                        ),
                ],
              ),
            ),
        ],
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
    final theme = context.t;
    return SizedBox(
      height: 400,
      width: 400,
      child: AlertDialog(
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
          height: 200,
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
                color: theme.hintColor,
              ),
            },
          ),
        ),
        scrollable: true,
      ),
    );
  }
}
