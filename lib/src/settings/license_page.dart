import 'package:flutter/material.dart';
import 'package:yaru_widgets/yaru_widgets.dart';

class LicensePage extends StatelessWidget {
  const LicensePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.background,
        borderRadius: BorderRadius.circular(10),
      ),
      child: ClipRRect(
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(8.0),
          bottomRight: Radius.circular(8.0),
        ),
        child: Column(
          children: [
            const YaruDialogTitleBar(),
            Expanded(
              child: Theme(
                data: Theme.of(context).copyWith(
                  pageTransitionsTheme:
                      YaruMasterDetailTheme.of(context).landscapeTransitions,
                ),
                child: const Padding(
                  padding: EdgeInsets.all(kYaruPagePadding),
                  child: LicensePage(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
