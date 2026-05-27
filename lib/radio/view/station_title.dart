import 'package:flutter/material.dart';
import 'package:flutter_it/flutter_it.dart';

import '../../extensions/build_context_x.dart';
import '../radio_manager.dart';

class StationTitle extends StatelessWidget with WatchItMixin {
  const StationTitle({super.key, required this.uuid});

  final String uuid;

  @override
  Widget build(BuildContext context) {
    final stationResults = watchValue(
      (RadioManager m) => m.getStationByUUIDCommand(uuid).results,
    );
    final station = stationResults.data;

    if (stationResults.error != null) {
      return Text(context.l10n.station);
    }

    if (station == null) {
      return const Text('...');
    }

    return Text(station.title ?? context.l10n.station);
  }
}
