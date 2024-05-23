import 'package:flutter/material.dart';
import 'package:yaru/yaru.dart';

class LicensesPage extends StatelessWidget {
  const LicensesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.background,
        borderRadius: BorderRadius.circular(kYaruContainerRadius),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(kYaruContainerRadius),
        child: Theme(
          data: Theme.of(context).copyWith(
            pageTransitionsTheme:
                YaruMasterDetailTheme.of(context).landscapeTransitions,
          ),
          child: const LicensePage(),
        ),
      ),
    );
  }
}
