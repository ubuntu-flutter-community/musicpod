import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:yaru_widgets/yaru_widgets.dart';

import '../../build_context_x.dart';
import '../../constants.dart';
import '../common/common_widgets.dart';
import '../l10n/l10n.dart';

class ShopRecommendations extends StatelessWidget {
  const ShopRecommendations({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = context.t;
    final style = theme.textTheme.bodySmall?.copyWith(
      fontWeight: smallTextFontWeight,
      color: theme.colorScheme.onSurface,
    );
    final linkStyle = theme.textTheme.bodySmall?.copyWith(
      fontWeight: smallTextFontWeight,
      color: theme.colorScheme.primary,
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
        ),
      ],
    );
  }
}
