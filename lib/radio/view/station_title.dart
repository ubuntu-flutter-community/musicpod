import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../extensions/build_context_x.dart';
import '../manager/station_manager.dart';

class StationTitle extends ConsumerWidget {
  const StationTitle({super.key, required this.uuid});

  final String uuid;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stationResults = ref.watch(stationNameManagerProvider(uuid));

    return stationResults.when(
      data: (station) => Text(station ?? '...'),
      loading: () => const Text('...'),
      error: (_, __) => Text(context.l10n.station),
    );
  }
}
