// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'CurrencyPro';

  @override
  String get updateRates => 'Updating rates...';

  @override
  String get addCurrencies => 'Add currencies for conversion';

  @override
  String get addCurrency => 'Add Currency';

  @override
  String currencyRemoved(String currencyCode) {
    return '$currencyCode removed';
  }

  @override
  String currencyAdded(String currencyCode) {
    return '$currencyCode added';
  }

  @override
  String updated(String time) {
    return 'Updated: $time';
  }

  @override
  String get justNow => 'Just now';

  @override
  String minutesAgo(int count) {
    return '$count min ago';
  }

  @override
  String hoursAgo(int count) {
    return '$count h ago';
  }

  @override
  String get rateUnavailable => 'Rate unavailable';

  @override
  String exchangeRate(String baseCurrency, String rate, String targetCurrency) {
    return '1 $baseCurrency = $rate $targetCurrency';
  }

  @override
  String get searchCurrency => 'Search currency...';

  @override
  String get popular => 'Popular';

  @override
  String get allCurrencies => 'All Currencies';

  @override
  String get offlineMode => 'Offline mode. Using saved data.';
}
