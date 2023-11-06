import 'package:flutter/material.dart';
import 'package:musicpod/src/common/common_widgets.dart';
import 'package:yaru_icons/yaru_icons.dart';
import 'package:yaru_widgets/yaru_widgets.dart';

import '../l10n/l10n.dart';

class OfflinePage extends StatelessWidget {
  const OfflinePage({super.key});

  @override
  Widget build(BuildContext context) {
    return YaruDetailPage(
      appBar: HeaderBar(
        title: Text(context.l10n.offline),
        backgroundColor: Colors.transparent,
      ),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            YaruAnimatedIcon(
              const YaruAnimatedNoNetworkIcon(),
              size: 200,
              color: Theme.of(context).disabledColor,
            ),
            Padding(
              padding: const EdgeInsets.only(
                top: kYaruPagePadding,
                left: 40,
                right: 40,
              ),
              child: Text(
                context.l10n.offlineDescription,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      color: Theme.of(context).disabledColor,
                    ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
