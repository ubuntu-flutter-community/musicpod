import 'package:flutter/material.dart';
import 'package:flutter_it/flutter_it.dart';

import '../../app/connectivity_model.dart';
import '../../common/data/audio.dart';
import '../../common/view/icons.dart';
import '../../common/view/safe_network_image.dart';
import '../../common/view/side_bar_fall_back_image.dart';
import '../../common/view/theme.dart';
import '../../extensions/build_context_x.dart';
import '../radio_model.dart';

class StationPageIcon extends StatefulWidget with WatchItStatefulWidgetMixin {
  const StationPageIcon({
    super.key,
    required this.uuid,
    required this.selected,
  });

  final String uuid;
  final bool selected;

  @override
  State<StationPageIcon> createState() => _StationPageIconState();
}

class _StationPageIconState extends State<StationPageIcon> {
  late Future<Audio?> _future;
  late Color fallBackColor;

  @override
  void initState() {
    super.initState();
    fallBackColor = getAlphabetColor(widget.uuid);
    setFuture();
  }

  void setFuture() => _future = di<RadioModel>().getStationByUUID(widget.uuid);

  @override
  Widget build(BuildContext context) {
    watchPropertyValue((ConnectivityModel m) {
      setFuture();
      return m.isOnline;
    });
    return ClipRRect(
      borderRadius: BorderRadius.circular(6),
      child: Container(
        color: context.theme.cardColor,
        height: sideBarImageSize,
        width: sideBarImageSize,
        child: FutureBuilder(
          future: _future,
          builder: (context, snapshot) {
            if (!snapshot.hasData || snapshot.hasError) {
              return SideBarFallBackImage(
                color: fallBackColor,
                child: widget.selected
                    ? Icon(Iconz.starFilled)
                    : Icon(Iconz.star),
              );
            }

            final station = snapshot.data!;

            return SafeNetworkImage(
              fallBackIcon: SideBarFallBackImage(
                color: fallBackColor,
                child: widget.selected
                    ? Icon(Iconz.starFilled)
                    : Icon(Iconz.star),
              ),
              errorIcon: SideBarFallBackImage(
                color: fallBackColor,
                child: widget.selected
                    ? Icon(Iconz.starFilled)
                    : Icon(Iconz.star),
              ),
              fit: BoxFit.fitHeight,
              url: station.imageUrl,
              filterQuality: FilterQuality.medium,
            );
          },
        ),
      ),
    );
  }
}
