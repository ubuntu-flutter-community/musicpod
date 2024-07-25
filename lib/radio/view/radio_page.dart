import 'package:flutter/material.dart';
import 'package:watch_it/watch_it.dart';
import 'package:yaru/yaru.dart';

import '../../app/app_model.dart';
import '../../common/view/common_widgets.dart';
import '../../common/view/icons.dart';
import '../../common/view/offline_page.dart';
import '../../constants.dart';
import '../../l10n/l10n.dart';
import '../../library/library_model.dart';
import '../../player/player_model.dart';
import '../radio_model.dart';
import 'radio_discover_page.dart';
import 'radio_lib_page.dart';

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
      final appModel = di<AppModel>();
      final playerModel = di<PlayerModel>();
      final libraryModel = di<LibraryModel>();
      final index = libraryModel.radioindex;
      model
          .init(
        countryCode: appModel.countryCode,
        index: index,
      )
          .then(
        (connectedHost) {
          if (!playerModel.isOnline) {
            return;
          }
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              _buildConnectSnackBar(
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

    return YaruDetailPage(
      appBar: HeaderBar(
        adaptive: true,
        actions: [
          Flexible(
            child: Padding(
              padding: appBarActionSpacing,
              child: connectedHost == null
                  ? const _RadioReconnectButton()
                  : SearchButton(
                      active: false,
                      onPressed: () {
                        di<AppModel>().setLockSpace(true);
                        di<LibraryModel>().push(
                          builder: (context) => const RadioDiscoverPage(),
                          pageId: kRadioPageId,
                        );
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

class _RadioReconnectButton extends StatelessWidget {
  const _RadioReconnectButton();

  @override
  Widget build(BuildContext context) {
    final model = di<RadioModel>();
    final libraryModel = di<LibraryModel>();
    final appModel = di<AppModel>();

    return IconButton(
      tooltip:
          '${context.l10n.noRadioServerFound}: ${context.l10n.tryReconnect}',
      onPressed: () => model
          .init(
        countryCode: appModel.countryCode,
        index: libraryModel.radioindex,
      )
          .then(
        (host) {
          ScaffoldMessenger.of(context).clearSnackBars();
          ScaffoldMessenger.of(context).showSnackBar(
            _buildConnectSnackBar(
              connectedHost: host,
              context: context,
            ),
          );
        },
      ),
      icon: const DisconnectedServerIcon(),
    );
  }
}

SnackBar _buildConnectSnackBar({
  required String? connectedHost,
  required BuildContext context,
}) {
  final appModel = di<AppModel>();
  final model = di<RadioModel>();
  final libraryModel = di<LibraryModel>();
  final index = libraryModel.radioindex;

  return SnackBar(
    duration: connectedHost != null
        ? const Duration(seconds: 1)
        : const Duration(seconds: 30),
    content: Text(
      connectedHost != null
          ? '${context.l10n.connectedTo}: $connectedHost'
          : context.l10n.noRadioServerFound,
    ),
    action: (connectedHost == null)
        ? SnackBarAction(
            onPressed: () {
              ScaffoldMessenger.of(context).clearSnackBars();
              model
                  .init(
                    countryCode: appModel.countryCode,
                    index: index,
                  )
                  .then(
                    (value) => ScaffoldMessenger.of(context).showSnackBar(
                      _buildConnectSnackBar(
                        connectedHost: value,
                        context: context,
                      ),
                    ),
                  );
            },
            label: context.l10n.tryReconnect,
          )
        : null,
  );
}
