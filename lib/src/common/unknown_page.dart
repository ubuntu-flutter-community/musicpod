import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:yaru/yaru.dart';

import '../../app.dart';
import '../../common.dart';
import '../../l10n.dart';

class UnknownPage extends StatelessWidget {
  const UnknownPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (context, ref, _) {
        final showWindowControls =
            ref.watch(appModelProvider.select((a) => a.showWindowControls));

        return YaruDetailPage(
          appBar: HeaderBar(
            style: showWindowControls
                ? YaruTitleBarStyle.normal
                : YaruTitleBarStyle.undecorated,
            title: isMobile ? null : Text(context.l10n.unknown),
            leading: Navigator.canPop(context)
                ? const NavBackButton()
                : const SizedBox.shrink(),
          ),
          body: Center(
            child: Text(context.l10n.unknown),
          ),
        );
      },
    );
  }
}
