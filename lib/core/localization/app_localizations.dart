import 'package:flutter/widgets.dart';

import '../../l10n/generated/scan_leno_localizations.dart';

export '../../l10n/generated/scan_leno_localizations.dart';

extension AppLocalizationsX on BuildContext {
  ScanLenoLocalizations get l10n => ScanLenoLocalizations.of(this)!;
}
