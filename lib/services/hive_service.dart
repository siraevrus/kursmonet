import 'package:hive_flutter/hive_flutter.dart';
import '../utils/app_logger.dart';

class HiveService {
  static const String appSettingsBox = 'app_settings';
  static const String ratesCacheBox = 'rates_cache';
  
  static const String selectedCurrenciesKey = 'selected_currencies';
  static const String lastBaseCurrencyKey = 'last_base_currency';
  static const String lastAmountKey = 'last_amount';
  static const String ratesJsonKey = 'rates_json';
  static const String lastUpdatedKey = 'last_updated';

  static Future<void> init() async {
    AppLogger.i('💾 [HIVE] Инициализация Hive...');
    await Hive.initFlutter();
    await Hive.openBox(appSettingsBox);
    AppLogger.d('   Открыт box: $appSettingsBox');
    await Hive.openBox(ratesCacheBox);
    AppLogger.d('   Открыт box: $ratesCacheBox');
    AppLogger.i('✅ [HIVE] Hive инициализирован');
  }

  // App Settings Box
  static Box get appSettings => Hive.box(appSettingsBox);
  
  static List<String> getSelectedCurrencies() {
    final currencies = appSettings.get(selectedCurrenciesKey, defaultValue: ['USD', 'EUR', 'RUB', 'KZT']);
    AppLogger.d('💾 [HIVE] Загружены выбранные валюты: ${currencies.join(', ')}');
    return List<String>.from(currencies);
  }

  static Future<void> saveSelectedCurrencies(List<String> currencies) async {
    AppLogger.d('💾 [HIVE] Сохранение выбранных валют: ${currencies.join(', ')}');
    await appSettings.put(selectedCurrenciesKey, currencies);
    AppLogger.d('✅ [HIVE] Валюты сохранены');
  }

  static String? getLastBaseCurrency() {
    final currency = appSettings.get(lastBaseCurrencyKey);
    AppLogger.d('💾 [HIVE] Загружена последняя базовая валюта: $currency');
    return currency;
  }

  static Future<void> saveLastBaseCurrency(String currency) async {
    AppLogger.d('💾 [HIVE] Сохранение базовой валюты: $currency');
    await appSettings.put(lastBaseCurrencyKey, currency);
    AppLogger.d('✅ [HIVE] Базовая валюта сохранена');
  }

  static double? getLastAmount() {
    final amount = appSettings.get(lastAmountKey);
    AppLogger.d('💾 [HIVE] Загружена последняя сумма: $amount');
    return amount;
  }

  static Future<void> saveLastAmount(double amount) async {
    AppLogger.d('💾 [HIVE] Сохранение суммы: $amount');
    await appSettings.put(lastAmountKey, amount);
    AppLogger.d('✅ [HIVE] Сумма сохранена');
  }

  // Rates Cache Box
  static Box get ratesCache => Hive.box(ratesCacheBox);
  
  static Map<String, dynamic>? getRatesJson() {
    final ratesJson = ratesCache.get(ratesJsonKey) as Map<String, dynamic>?;
    if (ratesJson != null) {
      final ratesCount = (ratesJson['rates'] as Map<String, dynamic>?)?.length ?? 0;
      AppLogger.d('💾 [HIVE] Загружен кэш курсов: $ratesCount валют');
    } else {
      AppLogger.d('💾 [HIVE] Кэш курсов пуст');
    }
    return ratesJson;
  }

  static Future<void> saveRatesJson(Map<String, dynamic> ratesJson) async {
    final ratesCount = (ratesJson['rates'] as Map<String, dynamic>?)?.length ?? 0;
    AppLogger.d('💾 [HIVE] Сохранение кэша курсов: $ratesCount валют');
    await ratesCache.put(ratesJsonKey, ratesJson);
    AppLogger.d('✅ [HIVE] Кэш курсов сохранен');
  }

  static DateTime? getLastUpdated() {
    final timestamp = ratesCache.get(lastUpdatedKey);
    final dateTime = timestamp != null ? DateTime.parse(timestamp.toString()) : null;
    AppLogger.d('💾 [HIVE] Загружено время обновления: $dateTime');
    return dateTime;
  }

  static Future<void> saveLastUpdated(DateTime dateTime) async {
    AppLogger.d('💾 [HIVE] Сохранение времени обновления: $dateTime');
    await ratesCache.put(lastUpdatedKey, dateTime.toIso8601String());
    AppLogger.d('✅ [HIVE] Время обновления сохранено');
  }
}

