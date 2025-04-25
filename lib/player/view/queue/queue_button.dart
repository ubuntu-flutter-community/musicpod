import 'package:flutter/material.dart';
import 'package:watch_it/watch_it.dart';

import '../../../app/app_model.dart';
import '../../../app/view/routing_manager.dart';
import '../../../common/data/audio_type.dart';
import '../../../common/page_ids.dart';
import '../../../common/view/icons.dart';
import '../../../common/view/modals.dart';
import '../../../extensions/build_context_x.dart';
import '../../../l10n/l10n.dart';
import '../../../radio/radio_model.dart';
import '../../player_model.dart';
import 'queue_body.dart';
import 'queue_dialog.dart';

class QueueButton extends StatelessWidget with WatchItMixin {
  const QueueButton({
    super.key,
    this.color,
    this.isSelected,
    this.onTap,
  }) : _mode = _QueueButtonMode.icon;

  const QueueButton.text({
    super.key,
    this.color,
    this.isSelected,
    this.onTap,
  }) : _mode = _QueueButtonMode.text;

  final Color? color;
  final bool? isSelected;
  final void Function()? onTap;

  final _QueueButtonMode _mode;

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final radio = watchPropertyValue(
      (PlayerModel m) => m.audio?.audioType == AudioType.radio,
    );

    final content = ModalMode.platformModalMode == ModalMode.bottomSheet
        ? QueueBody(
            selectedColor: theme.colorScheme.onSurface,
          )
        : const QueueDialog();

    void Function() onPressed = onTap ??
        () {
          if (di<PlayerModel>().audio?.audioType == AudioType.radio) {
            di<RadioModel>()
                .setRadioCollectionView(RadioCollectionView.history);
            if (di<RoutingManager>().selectedPageId != PageIDs.radio) {
              di<RoutingManager>().push(pageId: PageIDs.radio);
            }
          } else {
            showModal(
              context: context,
              isScrollControlled: true,
              showDragHandle: true,
              content: content,
              mode: ModalMode.platformModalMode,
            );
          }
        };

    return switch (_mode) {
      _QueueButtonMode.icon => IconButton(
          isSelected: isSelected ??
              watchPropertyValue((AppModel m) => m.showQueueOverlay),
          color: color ?? theme.colorScheme.onSurface,
          padding: EdgeInsets.zero,
          tooltip: radio ? context.l10n.hearingHistory : context.l10n.queue,
          icon: Icon(
            radio ? Iconz.radioHistory : Iconz.playlist,
            color: color ?? theme.colorScheme.onSurface,
          ),
          onPressed: onPressed,
        ),
      _QueueButtonMode.text => TextButton(
          onPressed: onPressed,
          child: Text(
            radio ? context.l10n.hearingHistory : context.l10n.queue,
            style: context.textTheme.bodyLarge?.copyWith(
              color: context.colorScheme.onSurface,
            ),
          ),
        )
    };
  }
}

enum _QueueButtonMode {
  icon,
  text;
}
