import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

import '../app/app_config.dart';
import '../common/view/confirm.dart';
import '../common/view/progress.dart';
import '../extensions/build_context_x.dart';
import 'manager/recent_patch_notes_disposed_manager.dart';

class PatchNotesDialog extends ConsumerStatefulWidget {
  const PatchNotesDialog({super.key, required this.presentAsBottomSheet});

  final bool presentAsBottomSheet;

  static Future<void> show(BuildContext context) => ConfirmationDialog.show(
    context: context,
    builder: (context, asBottomSheet) =>
        PatchNotesDialog(presentAsBottomSheet: asBottomSheet),
  );

  @override
  ConsumerState<PatchNotesDialog> createState() => _PatchNotesDialogState();
}

class _PatchNotesDialogState extends ConsumerState<PatchNotesDialog> {
  late Future<String?> _markdown;

  @override
  void initState() {
    super.initState();
    _markdown = DefaultAssetBundle.of(context).loadString('CHANGELOG.md');
  }

  @override
  Widget build(BuildContext context) => ConfirmationDialog(
    barrierDismissible: false,
    presentAsBottomSheet: widget.presentAsBottomSheet,
    scrollable: true,
    content: FutureBuilder(
      future: _markdown,
      builder: (context, snapshot) => snapshot.hasError
          ? Center(child: Text(snapshot.error.toString()))
          : snapshot.hasData
          ? MarkdownBody(
              onTapLink: (text, href, title) {
                if (href == null) return;
                final uri = Uri.tryParse(href);
                if (uri == null) return;
                launchUrl(uri);
              },
              data: snapshot.data!,
            )
          : const Center(child: Progress()),
    ),
    onCancel: () {
      ref
          .read(recentPatchNotesDisposedManagerProvider.notifier)
          .disposeNotes();
      return launchUrl(Uri.parse(AppConfig.sponsorLink));
    },
    cancelLabel: 'Sponsor Me',
    onConfirm: () => ref
        .read(recentPatchNotesDisposedManagerProvider.notifier)
        .disposeNotes(),
    confirmLabel: context.l10n.ok,
  );
}
