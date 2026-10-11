import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../common/data/retry_capsule.dart';
import '../../common/manager/retry_manager.dart';
import '../../common/util/family.dart';
import '../../common/view/error_retry_body.dart';
import '../manager/station_manager.dart';

class StationErrorPage extends ConsumerWidget {
  const StationErrorPage({super.key, required this.uuid, required this.error});

  final String uuid;
  final Object error;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ErrorRetryBody(
      error: error,
      stackTrace: StackTrace.current,
      retryCapsule: RetryCapsule(
        retryViewId: uuid,
        onRetry: () {
          Family.dispose<RetryManager>(uuid);
          ref.invalidate(stationManagerProvider(uuid));
        },
      ),
    );
  }
}
