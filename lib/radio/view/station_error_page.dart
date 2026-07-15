import 'package:flutter/material.dart';
import 'package:flutter_it/flutter_it.dart';

import '../../common/data/retry_capsule.dart';
import '../../common/manager/retry_manager.dart';
import '../../common/util/family.dart';
import '../../common/view/error_retry_body.dart';
import '../../extensions/command_x.dart';
import '../manager/station_manager.dart';

class StationErrorPage extends WatchingWidget {
  const StationErrorPage({super.key, required this.uuid, required this.error});

  final String uuid;
  final Object error;

  @override
  Widget build(BuildContext context) {
    registerHandler(
      select: (StationManager m) => m.command,
      param1: uuid,
      handler: (_, _, __) => Family.dispose<RetryManager>(uuid),
    );

    return ErrorRetryBody(
      error: error,
      stackTrace: StackTrace.current,
      retryCapsule: RetryCapsule(
        retryViewId: uuid,
        onRetry: () => di<StationManager>(
          param1: uuid,
        ).command.runRestricted(immediatelyClearErrors: true),
      ),
    );
  }
}
