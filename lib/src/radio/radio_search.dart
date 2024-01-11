import '../../l10n.dart';

enum RadioSearch {
  name,
  tag,
  country,
  state;

  String localize(AppLocalizations l10n) {
    return switch (this) {
      name => l10n.name,
      tag => l10n.tag,
      country => l10n.country,
      state => l10n.state,
    };
  }
}
