import 'package:flutter/material.dart';
import 'package:watch_it/watch_it.dart';

import '../../app/connectivity_model.dart';
import '../../common/data/audio.dart';
import '../../l10n/l10n.dart';
import '../radio_model.dart';

class StationTitle extends StatefulWidget with WatchItStatefulWidgetMixin {
  const StationTitle({super.key, required this.uuid});

  final String uuid;

  @override
  State<StationTitle> createState() => _StationTitleState();
}

class _StationTitleState extends State<StationTitle> {
  late Future<Audio?> _future;

  @override
  void initState() {
    super.initState();
    setFuture();
  }

  void setFuture() => _future = di<RadioModel>().getStationByUUID(widget.uuid);

  @override
  Widget build(BuildContext context) {
    watchPropertyValue((ConnectivityModel m) {
      setFuture();
      return m.isOnline;
    });
    return FutureBuilder(
      future: _future,
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Text('...');
        }

        if (snapshot.hasError) {
          return Text(context.l10n.station);
        }

        final station = snapshot.data!;

        return Text(station.title ?? context.l10n.station);
      },
    );
  }
}
