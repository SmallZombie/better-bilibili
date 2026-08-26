import 'package:better_bilibili/l10n/generated/app_localizations.dart';
import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';

extension L10nUtil on BuildContext {
  AppLocalizations get l => AppLocalizations.of(this)!;

  String formatCompactNumber(int num) {
    final format = NumberFormat.compact(
      locale: Localizations.localeOf(this).languageCode,
    )..maximumFractionDigits = 1;

    return format.format(num);
  }
}
