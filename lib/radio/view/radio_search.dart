import '../../l10n/l10n.dart';

enum RadioSearch {
  name,
  tag,
  country,
  state,
  language;

  String localize(AppLocalizations l10n) {
    return switch (this) {
      name => l10n.name,
      tag => l10n.tag,
      country => l10n.country,
      state => l10n.state,
      language => l10n.language,
    };
  }
}
