import 'package:animated_emoji/animated_emoji.dart';
import 'package:flutter/material.dart';
import '../../get.dart';

import '../../build_context_x.dart';
import '../../settings.dart';
import '../l10n/l10n.dart';
import 'patch_notes.dart';
import 'sponsor_link.dart';

class PatchNotesDialog extends StatelessWidget {
  const PatchNotesDialog({
    super.key,
    required this.disposePatchNotes,
  });

  final Future<void> Function() disposePatchNotes;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text(kRecentPatchNotesTitle),
      scrollable: true,
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Align(
            alignment: Alignment.centerLeft,
            child: AnimatedEmoji(AnimatedEmojis.musicalNotes),
          ),
          Text(
            kRecentPatchNotes,
            style: context.t.textTheme.bodyLarge,
          ),
          const Align(
            alignment: Alignment.centerLeft,
            child: AnimatedEmoji(AnimatedEmojis.foldedHands),
          ),
          const Row(
            children: [
              Expanded(child: SponsorLink()),
            ],
          ),
        ],
      ),
      actions: [
        ElevatedButton(
          onPressed: () async {
            await disposePatchNotes()
                .then((value) => Navigator.of(context).pop());
          },
          child: Text(context.l10n.ok),
        ),
      ],
    );
  }
}

Future<void> showPatchNotes(BuildContext context) {
  final settingsModel = getIt<SettingsModel>();
  if (settingsModel.recentPatchNotesDisposed == true) return Future.value();
  return showDialog(
    barrierDismissible: false,
    context: context,
    builder: (context) {
      return PatchNotesDialog(
        disposePatchNotes: settingsModel.disposePatchNotes,
      );
    },
  );
}
