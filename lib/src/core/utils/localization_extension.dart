import 'package:flutter/material.dart';
import '../i18n/app_localizations.dart';

extension LocalizationExtension on BuildContext {
  AppLocalizations get l10n => AppLocalizations.of(this);
}
