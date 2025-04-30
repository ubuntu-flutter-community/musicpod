import '../../l10n/l10n.dart';

enum CloseBtnAction {
  alwaysAsk,
  hideToTray,
  close;

  @override
  String toString() => name;

  String localize(AppLocalizations l10n) => switch (this) {
        alwaysAsk => l10n.alwaysAsk,
        hideToTray => l10n.hideToTray,
        close => l10n.closeApp,
      };
}
