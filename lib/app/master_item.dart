import 'package:flutter/widgets.dart';

class MasterItem {
  MasterItem({
    required this.titleBuilder,
    required this.pageBuilder,
    this.iconBuilder,
  });

  final WidgetBuilder titleBuilder;
  final WidgetBuilder pageBuilder;
  final Widget Function(BuildContext context, bool selected)? iconBuilder;
}
