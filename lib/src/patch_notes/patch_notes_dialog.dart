import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

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
          Text(
            kRecentPatchNotes,
            style: context.t.textTheme.bodyLarge,
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

Future<void> showPatchNotes(BuildContext context, WidgetRef ref) {
  final settingsModel = ref.read(settingsModelProvider);
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
