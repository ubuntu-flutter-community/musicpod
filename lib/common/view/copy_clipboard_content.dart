import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:yaru/yaru.dart';

import '../../extensions/build_context_x.dart';
import '../../l10n/l10n.dart';
import 'stream_provider_share_button.dart';

class CopyClipboardContent extends StatefulWidget {
  const CopyClipboardContent({
    super.key,
    required this.text,
    this.onSearch,
    this.showActions = true,
  });

  final String text;
  final void Function()? onSearch;
  final bool showActions;

  @override
  State<CopyClipboardContent> createState() => _CopyClipboardContentState();
}

class _CopyClipboardContentState extends State<CopyClipboardContent> {
  @override
  void initState() {
    super.initState();
    Clipboard.setData(ClipboardData(text: widget.text));
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final textColor = theme.snackBarTheme.contentTextStyle?.color?.withValues(
      alpha: 0.8,
    );
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                Text(
                  context.l10n.copiedToClipBoard,
                  style: TextStyle(color: textColor),
                ),
                Text(
                  widget.text,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
          if (widget.showActions)
            StreamProviderRow(
              iconColor: theme.snackBarTheme.backgroundColor != null
                  ? contrastColor(theme.snackBarTheme.backgroundColor!)
                  : theme.colorScheme.primary,
              onSearch: widget.onSearch,
              text: widget.text,
            ),
        ],
      ),
    );
  }
}
