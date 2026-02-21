import 'package:flutter/material.dart';

class LocaleProvider extends ChangeNotifier {
  Locale _locale = const Locale('en');

  Locale get locale => _locale;

  void setLocale(Locale newLocale) {
    if (!L10n.all.contains(newLocale)) return;

    _locale = newLocale;
    notifyListeners(); 
  }
}

class L10n {
  static final all = [
    const Locale('en'), 
    const Locale('es'), 
    const Locale('mt'),
    const Locale('fr'), 
    const Locale('it'), 
    const Locale('de'), 
  ];
}