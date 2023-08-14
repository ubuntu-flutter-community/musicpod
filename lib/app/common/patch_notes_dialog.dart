import 'package:flutter/material.dart';
import 'package:musicpod/constants.dart';
import 'package:musicpod/l10n/l10n.dart';

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
        style: Theme.of(context).textTheme.bodyLarge,
      ),
      actions: [
        ElevatedButton(
          onPressed: () async {
            await disposePatchNotes()
                .then((value) => Navigator.of(context).pop());
          },
          child: Text(context.l10n.ok),
        )
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
