import 'package:flutter/material.dart';
import 'package:yaru/yaru.dart';

import '../../app_config.dart';

class LicensesPage extends StatelessWidget {
  const LicensesPage({super.key});

  @override
  Widget build(BuildContext context) {
    if (AppConfig.isMobilePlatform) {
      return const LicensePage();
    }

    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(kYaruContainerRadius),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(kYaruContainerRadius),
        child: const LicensePage(),
      ),
    );
  }
}
