import 'package:flutter/material.dart';

import '../../build_context_x.dart';
import '../l10n/l10n.dart';
import 'patch_notes.dart';

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
      content: Text(
        kRecentPatchNotes,
        style: context.t.textTheme.bodyLarge,
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

Future<void> showPatchNotes(
  BuildContext context,
  Future<void> Function() disposePatchNotes,
) {
  return showDialog(
    barrierDismissible: false,
    context: context,
    builder: (context) {
      return PatchNotesDialog(
        disposePatchNotes: disposePatchNotes,
      );
    },
  );
}
