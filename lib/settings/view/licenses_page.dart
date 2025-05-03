import 'package:flutter/material.dart';
import 'package:yaru/yaru.dart';

import '../../extensions/build_context_x.dart';

class LicensesPage extends StatelessWidget {
  const LicensesPage({super.key});

  @override
  Widget build(BuildContext context) {
    if (isMobile) {
      return const LicensePage();
    }

    return Container(
      decoration: BoxDecoration(
        color: context.theme.dialogTheme.backgroundColor,
        borderRadius: BorderRadius.circular(kYaruContainerRadius),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(kYaruContainerRadius),
        child: const LicensePage(),
      ),
    );
  }
}
