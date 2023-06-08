import 'package:flutter/material.dart';
import 'package:musicpod/app/common/audio_page.dart';
import 'package:musicpod/app/common/offline_page.dart';
import 'package:musicpod/app/connectivity_notifier.dart';
import 'package:musicpod/app/radio/radio_model.dart';
import 'package:musicpod/l10n/l10n.dart';
import 'package:musicpod/service/radio_service.dart';
import 'package:provider/provider.dart';
import 'package:ubuntu_service/ubuntu_service.dart';

class RadioPage extends StatefulWidget {
  const RadioPage({super.key, this.showWindowControls = true});

  final bool showWindowControls;

  static Widget create(BuildContext context, [bool showWindowControls = true]) {
    return ChangeNotifierProvider(
      create: (_) => RadioModel(getService<RadioService>()),
      child: RadioPage(
        showWindowControls: showWindowControls,
      ),
    );
  }

  @override
  State<RadioPage> createState() => _RadioPageState();
}

class _RadioPageState extends State<RadioPage> {
  @override
  void initState() {
    super.initState();
    final code = WidgetsBinding.instance.platformDispatcher.locale.countryCode
        ?.toLowerCase();
    context.read<RadioModel>().init(code);
  }

  @override
  Widget build(BuildContext context) {
    final model = context.watch<RadioModel>();
    final isOnline = context.select((ConnectivityNotifier c) => c.isOnline);

    return isOnline
        ? AudioPage(
            title: Text(context.l10n.radio),
            audioPageType: AudioPageType.radio,
            placeTrailer: false,
            showTrack: false,
            editableName: false,
            deletable: false,
            controlPageButton: const SizedBox.shrink(),
            audios: model.stations,
            pageId: context.l10n.radio,
          )
        : const OfflinePage();
  }
}
