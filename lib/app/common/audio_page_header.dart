import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:musicpod/data/audio.dart';
import 'package:musicpod/l10n/l10n.dart';
import 'package:yaru_widgets/yaru_widgets.dart';

class AudioPageHeader extends StatelessWidget {
  const AudioPageHeader({
    super.key,
    required this.title,
    required this.sortedAudios,
    this.description,
    this.image,
    this.label,
    this.subTitle,
  });

  final String title;
  final List<Audio> sortedAudios;
  final String? description;
  final Widget? image;
  final String? label;
  final String? subTitle;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final light = theme.brightness == Brightness.light;
    return Container(
      height: 240,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.bottomCenter,
          end: Alignment.topCenter,
          colors: [
            light ? Colors.white : Colors.transparent,
            light ? const Color(0xFFfafafa) : theme.cardColor
          ],
        ),
      ),
      padding: const EdgeInsets.all(20),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (image != null)
            Padding(
              padding: const EdgeInsets.only(right: 20),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: image!,
              ),
            ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  label ?? context.l10n.album,
                  style: theme.textTheme.labelSmall,
                ),
                Text(
                  title,
                  style: theme.textTheme.headlineLarge?.copyWith(
                    fontWeight: FontWeight.w300,
                    fontSize: 50,
                    color: theme.colorScheme.onSurface.withOpacity(0.8),
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(
                  height: 5,
                ),
                Text(
                  subTitle ?? sortedAudios.firstOrNull?.artist ?? '',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.hintColor,
                    fontStyle: FontStyle.italic,
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(top: 15),
                    child: description == null
                        ? const SizedBox.expand()
                        : SizedBox(
                            width: 800,
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
                                style: {
                                  'html': Style(
                                    margin: Margins.zero,
                                    padding: HtmlPaddings.zero,
                                  ),
                                  'body': Style(
                                    margin: Margins.zero,
                                    padding: HtmlPaddings.zero,
                                    color: theme.hintColor,
                                    textOverflow: TextOverflow.ellipsis,
                                    maxLines: 4,
                                  )
                                },
                              ),
                            ),
                          ),
                  ),
                )
              ],
            ),
          )
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
    final theme = Theme.of(context);
    return SizedBox(
      height: 400,
      width: 400,
      child: AlertDialog(
        title: YaruDialogTitleBar(
          title: Text(title),
          backgroundColor: Colors.transparent,
          border: BorderSide.none,
        ),
        titlePadding: EdgeInsets.zero,
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
              )
            },
          ),
        ),
        scrollable: true,
      ),
    );
  }
}
