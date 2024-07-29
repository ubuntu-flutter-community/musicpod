import 'package:flutter/material.dart';
import 'package:watch_it/watch_it.dart';
import 'package:yaru/theme.dart';

import '../../common/data/audio.dart';
import '../../common/view/header_bar.dart';
import '../../common/view/offline_page.dart';
import '../../common/view/search_button.dart';
import '../../common/view/snackbars.dart';
import '../../common/view/theme.dart';
import '../../constants.dart';
import '../../l10n/l10n.dart';
import '../../library/library_model.dart';
import '../../player/player_model.dart';
import '../../search/search_model.dart';
import '../radio_model.dart';
import 'radio_lib_page.dart';
import 'radio_reconnect_button.dart';

class RadioPage extends StatefulWidget with WatchItStatefulWidgetMixin {
  const RadioPage({super.key});

  @override
  State<RadioPage> createState() => _RadioPageState();
}

class _RadioPageState extends State<RadioPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final model = di<RadioModel>();
      final playerModel = di<PlayerModel>();
      model.init().then(
        (connectedHost) {
          if (!playerModel.isOnline) {
            return;
          }
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              buildConnectSnackBar(
                connectedHost: connectedHost,
                context: context,
              ),
            );
          }
        },
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final isOnline = watchPropertyValue((PlayerModel m) => m.isOnline);
    if (!isOnline) return const OfflinePage();
    final connectedHost = watchPropertyValue((RadioModel m) => m.connectedHost);

    return Scaffold(
      resizeToAvoidBottomInset: isMobile ? false : null,
      appBar: HeaderBar(
        adaptive: true,
        actions: [
          Flexible(
            child: Padding(
              padding: appBarSingleActionSpacing,
              child: connectedHost == null
                  ? const RadioReconnectButton()
                  : SearchButton(
                      active: false,
                      onPressed: () {
                        di<LibraryModel>().pushNamed(pageId: kSearchPageId);
                        di<SearchModel>()
                          ..setAudioType(AudioType.radio)
                          ..search();
                      },
                    ),
            ),
          ),
        ],
        title: Text('${context.l10n.radio} ${context.l10n.collection}'),
      ),
      body: const RadioLibPage(),
    );
  }
}
