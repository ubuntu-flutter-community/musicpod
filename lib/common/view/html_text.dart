import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_widget_from_html_core/flutter_widget_from_html_core.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../extensions/build_context_x.dart';

class HtmlText extends StatelessWidget {
  const HtmlText({
    super.key,
    required this.text,
    this.color,
    this.onTapUrl,
    this.wrapInFakeScroll = false,
  });

  final String text;
  final Color? color;
  final FutureOr<bool> Function(String)? onTapUrl;
  final bool wrapInFakeScroll;

  @override
  Widget build(BuildContext context) {
    final theColor = color ?? context.colorScheme.onSurface;

    final htmlWidget = HtmlWidget(
      text,
      onTapUrl:
          onTapUrl ??
          (url) async {
            await launchUrl(Uri.parse(url));
            return true;
          },
      textStyle: TextStyle(color: color),
      customStylesBuilder: (element) {
        return {
          'color': '${theColor.toHexTriplet()}',
          if (wrapInFakeScroll) ...{
            'overflow': 'hidden',
            'text-overflow': 'ellipsis',
            'width': '100%',
            'display': '-webkit-box',
            '-webkit-line-clamp': '1',
            'ine-clamp': '1',
            '-webkit-box-orient': 'vertical',
          },
        };
      },
    );

    if (!wrapInFakeScroll) {
      return htmlWidget;
    }

    return ScrollConfiguration(
      behavior: ScrollConfiguration.of(context).copyWith(scrollbars: false),
      child: SingleChildScrollView(
        physics: const NeverScrollableScrollPhysics(),
        clipBehavior: Clip.antiAliasWithSaveLayer,
        child: htmlWidget,
      ),
    );
  }
}

extension ColorX on Color {
  String toHexTriplet() =>
      // ignore: deprecated_member_use
      '#${(value & 0xFFFFFF).toRadixString(16).padLeft(6, '0').toUpperCase()}';
}
