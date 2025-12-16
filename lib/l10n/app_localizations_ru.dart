// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Russian (`ru`).
class AppLocalizationsRu extends AppLocalizations {
  AppLocalizationsRu([String locale = 'ru']) : super(locale);

  @override
  String get appTitle => 'Conversor';

  @override
  String get updateRates => 'Обновление курсов...';

  @override
  String get addCurrencies => 'Добавьте валюты для конвертации';

  @override
  String get addCurrency => 'Добавить валюту';

  @override
  String currencyRemoved(String currencyCode) {
    return '$currencyCode удалена';
  }

  @override
  String currencyAdded(String currencyCode) {
    return '$currencyCode добавлена';
  }

  @override
  String updated(String time) {
    return 'Обновлено: $time';
  }

  @override
  String get justNow => 'Только что';

  @override
  String minutesAgo(int count) {
    return '$count мин назад';
  }

  @override
  String hoursAgo(int count) {
    return '$count ч назад';
  }

  @override
  String get rateUnavailable => 'Курс недоступен';

  @override
  String exchangeRate(String baseCurrency, String rate, String targetCurrency) {
    return '1 $baseCurrency / $rate $targetCurrency';
  }

  @override
  String get searchCurrency => 'Поиск валюты...';

  @override
  String get popular => 'Популярные';

  @override
  String get allCurrencies => 'Все валюты';

  @override
  String get offlineMode => 'Режим оффлайн. Используются сохраненные данные.';
}
