import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

class AppLocale {
  // Prevents instantiation and extension
  AppLocale._();

  static Locale defaultLocale = const Locale('fr', 'FR');
  static String defaultPhoneCode = '+225';
  static String defaultCurrencyCode = 'FCFA';

  static const List<Locale> supportedLocales = [
    Locale('fr', 'FR'),
  ];

  static const List<LocalizationsDelegate> localizationsDelegates = [
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];
}
