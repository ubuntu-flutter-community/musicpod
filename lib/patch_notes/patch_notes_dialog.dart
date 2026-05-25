import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_it/flutter_it.dart';

import '../app/app_manager.dart';
import '../app/app_config.dart';
import '../common/view/progress.dart';
import '../extensions/build_context_x.dart';
import '../l10n/l10n.dart';

class PatchNotesDialog extends StatefulWidget {
  const PatchNotesDialog({
    super.key,
    this.onClose,
    this.contentPadding,
    this.actionsPadding,
    this.insetPadding,
  });

  final VoidCallback? onClose;
  final EdgeInsetsGeometry? contentPadding;
  final EdgeInsetsGeometry? actionsPadding;
  final EdgeInsets? insetPadding;

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
      contentPadding: widget.contentPadding,
      insetPadding: widget.insetPadding,
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
      actionsPadding: widget.actionsPadding ?? const EdgeInsets.all(20),
      actions: [
        TextButton(
          onPressed: () {
            launchUrl(Uri.parse(AppConfig.sponsorLink));
            if (context.mounted) context.pop();
            widget.onClose?.call();
          },
          child: const Text('Sponsor Me'),
        ),
        ElevatedButton(
          onPressed: () async {
            await di<AppManager>().disposePatchNotes();
            if (context.mounted) context.pop();
            widget.onClose?.call();
          },
          child: Text(context.l10n.ok),
        ),
      ],
    );
  }
}
