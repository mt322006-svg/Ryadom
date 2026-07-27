import 'package:flutter/widgets.dart';

import 'app_localizations.dart';

extension RyadomL10nContext on BuildContext {
  AppLocalizations get l10n => AppLocalizations.of(this);
}