import 'package:intl/intl.dart';

import '../locale/app_locale.dart';

/// Currency Formatter dependent on [AppLocale]
class CurrencyFormatter {
  CurrencyFormatter._();

  static const int defaultDecimalDigits = 0;

  static String format(num data, {int? decimalDigits}) {
    return NumberFormat.currency(
      locale: AppLocale.defaultLocale.countryCode,
      symbol: AppLocale.defaultCurrencyCode,
      decimalDigits: decimalDigits ?? defaultDecimalDigits,
    ).format(data);
  }

  static String compact(num data, {int? decimalDigits, bool withSymbol = true}) {
    return NumberFormat.compactCurrency(
      locale: AppLocale.defaultLocale.countryCode,
      symbol: withSymbol ? AppLocale.defaultCurrencyCode : '',
      decimalDigits: decimalDigits ?? defaultDecimalDigits,
    ).format(data);
  }

  static String withoutSymbol(num data, {int? decimalDigits}) {
    return NumberFormat.currency(
      locale: AppLocale.defaultLocale.countryCode,
      decimalDigits: decimalDigits ?? defaultDecimalDigits,
      symbol: "",
    ).format(data);
  }

  static String currencySymbol() {
    return AppLocale.defaultCurrencyCode;
  }
}
