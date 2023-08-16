import 'package:flutter/material.dart';
import 'package:musicpod/constants.dart';
import 'package:musicpod/l10n/l10n.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:yaru_widgets/yaru_widgets.dart';

class ShopRecommendations extends StatelessWidget {
  const ShopRecommendations({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final style = theme.textTheme.bodySmall?.copyWith(
      fontWeight: FontWeight.w100,
      color: theme.colorScheme.onSurface,
    );
    final linkStyle = theme.textTheme.bodySmall?.copyWith(
      fontWeight: FontWeight.w100,
      color: Colors.blueAccent,
    );
    final borderRadius = BorderRadius.circular(6);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: kYaruPagePadding),
          child: Text(
            context.l10n.buyMusicOnline,
            style: style,
            textAlign: TextAlign.center,
          ),
        ),
        for (final shop in shops.entries)
          InkWell(
            borderRadius: borderRadius,
            onTap: () => launchUrl(Uri.parse(shop.key)),
            child: Text(
              shop.value,
              style: linkStyle,
              textAlign: TextAlign.center,
            ),
          ),
        const SizedBox(
          height: kYaruPagePadding,
        )
      ],
    );
  }
}
