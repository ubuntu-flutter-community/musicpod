import 'package:flutter/widgets.dart';

import '../../data.dart';

class MasterItem {
  MasterItem({
    required this.titleBuilder,
    this.subtitleBuilder,
    required this.pageBuilder,
    this.iconBuilder,
    required this.content,
  });

  final WidgetBuilder titleBuilder;
  final WidgetBuilder? subtitleBuilder;
  final WidgetBuilder pageBuilder;
  final Widget Function(BuildContext context, bool selected)? iconBuilder;
  // TODO: lookup Set for pageID instead of copying it
  final (String, Set<Audio>) content;
}
