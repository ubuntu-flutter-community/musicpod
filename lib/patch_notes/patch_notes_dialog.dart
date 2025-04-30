import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:watch_it/watch_it.dart';

import '../app/app_model.dart';
import '../app_config.dart';
import '../common/view/progress.dart';
import '../l10n/l10n.dart';

class PatchNotesDialog extends StatefulWidget {
  const PatchNotesDialog({super.key, this.onClose});

  final VoidCallback? onClose;

  @override
  State<PatchNotesDialog> createState() => _PatchNotesDialogState();
}

class _PatchNotesDialogState extends State<PatchNotesDialog> {
  late Future<String?> _markdown;

  @override
  void initState() {
    super.initState();
    _markdown = DefaultAssetBundle.of(context).loadString('CHANGELOG.md');
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      scrollable: true,
      content: FutureBuilder(
        future: _markdown,
        builder: (context, snapshot) => snapshot.hasData
            ? MarkdownBody(
                onTapLink: (text, href, title) {
                  if (href == null) return;
                  final uri = Uri.tryParse(href);
                  if (uri == null) return;
                  launchUrl(uri);
                },
                data: snapshot.data!,
              )
            : const Center(
                child: Progress(),
              ),
      ),
      actionsPadding: const EdgeInsets.all(20),
      actions: [
        TextButton(
          onPressed: () {
            launchUrl(Uri.parse(AppConfig.sponsorLink));
            if (context.mounted) Navigator.of(context).pop();
            widget.onClose?.call();
          },
          child: const Text('Sponsor Me'),
        ),
        ElevatedButton(
          onPressed: () async {
            await di<AppModel>().disposePatchNotes();
            if (context.mounted) Navigator.of(context).pop();
            widget.onClose?.call();
          },
          child: Text(context.l10n.ok),
        ),
      ],
    );
  }
}
