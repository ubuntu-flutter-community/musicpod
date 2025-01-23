import 'package:flutter/material.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';
import 'package:yaru/yaru.dart';
import '../../common/view/theme.dart';
import '../../extensions/build_context_x.dart';
import '../../l10n/l10n.dart';

class DiscordConnectContent extends StatelessWidget {
  const DiscordConnectContent({super.key, required this.connected});

  final bool connected;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: space(
        widthGap: 10,
        children: [
          Text(
            '${connected ? l10n.connectedTo : l10n.disconnectedFrom}'
            ' ${l10n.exposeToDiscordTitle}',
          ),
          Icon(
            TablerIcons.brand_discord_filled,
            color: context.theme.snackBarTheme.backgroundColor != null
                ? contrastColor(context.theme.snackBarTheme.backgroundColor!)
                : null,
          ),
        ],
      ),
    );
  }
}
