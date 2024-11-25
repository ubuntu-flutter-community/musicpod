import 'package:flutter/material.dart';
import 'package:watch_it/watch_it.dart';
import 'package:yaru/yaru.dart';

import '../../common/data/close_btn_action.dart';
import '../../common/view/drop_down_arrow.dart';
import '../../common/view/ui_constants.dart';
import '../../l10n/l10n.dart';
import '../settings_model.dart';

// TODO(#793): figure out how to show the window from clicking the dock icon in macos, windows and linux
// Also figure out how to show the window again, when the gtk window is triggered from the outside (open with)
// if we can not figure this out, we can not land this feature.
class CloseActionSection extends StatelessWidget with WatchItMixin {
  const CloseActionSection({super.key});

  @override
  Widget build(BuildContext context) {
    final model = di<SettingsModel>();

    final closeBtnAction =
        watchPropertyValue((SettingsModel m) => m.closeBtnActionIndex);
    return YaruSection(
      margin: const EdgeInsets.only(
        left: kLargestSpace,
        top: kLargestSpace,
        right: kLargestSpace,
      ),
      headline: Text(context.l10n.closeBtnAction),
      child: Column(
        children: [
          YaruTile(
            title: Text(context.l10n.whenCloseBtnClicked),
            trailing: YaruPopupMenuButton<CloseBtnAction>(
              icon: const DropDownArrow(),
              initialValue: closeBtnAction,
              child: Text(closeBtnAction.localize(context.l10n)),
              onSelected: (value) {
                model.setCloseBtnActionIndex(value);
              },
              itemBuilder: (context) {
                return [
                  for (var i = 0; i < CloseBtnAction.values.length; ++i)
                    PopupMenuItem(
                      value: CloseBtnAction.values[i],
                      child:
                          Text(CloseBtnAction.values[i].localize(context.l10n)),
                    ),
                ];
              },
            ),
          ),
        ],
      ),
    );
  }
}
