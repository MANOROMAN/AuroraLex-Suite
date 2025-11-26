import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

final localeProvider =
    StateNotifierProvider<LocaleController, Locale>((ref) {
  return LocaleController();
});

class LocaleController extends StateNotifier<Locale> {
  LocaleController() : super(const Locale('tr')) {
    _loadLocale();
  }

  Future<void> _loadLocale() async {
    final prefs = await SharedPreferences.getInstance();
    final languageCode = prefs.getString('locale') ?? 'tr';
    state = Locale(languageCode);
  }

  Future<void> update(Locale locale) async {
    state = locale;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('locale', locale.languageCode);
  }
}
