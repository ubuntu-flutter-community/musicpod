import 'package:flutter/widgets.dart';

class MasterItem {
  MasterItem({
    required this.titleBuilder,
    this.subtitleBuilder,
    required this.pageBuilder,
    this.iconBuilder,
    required this.pageId,
  });

  final WidgetBuilder titleBuilder;
  final WidgetBuilder? subtitleBuilder;
  final WidgetBuilder pageBuilder;
  final Widget Function(BuildContext context, bool selected)? iconBuilder;
  final String pageId;
}
