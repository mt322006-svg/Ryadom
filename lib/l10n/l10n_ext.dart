import 'package:flutter/widgets.dart';

import 'app_localizations.dart';

export 'ryadom_l10n_helpers.dart';

extension RyadomL10nContext on BuildContext {
  AppLocalizations get l10n => AppLocalizations.of(this);
}
