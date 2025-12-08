import 'package:hive_flutter/hive_flutter.dart';

class HiveService {
  static const String appSettingsBox = 'app_settings';
  static const String ratesCacheBox = 'rates_cache';
  
  static const String selectedCurrenciesKey = 'selected_currencies';
  static const String lastBaseCurrencyKey = 'last_base_currency';
  static const String lastAmountKey = 'last_amount';
  static const String ratesJsonKey = 'rates_json';
  static const String lastUpdatedKey = 'last_updated';

  static Future<void> init() async {
    await Hive.openBox(appSettingsBox);
    await Hive.openBox(ratesCacheBox);
  }

  // App Settings Box
  static Box get appSettings => Hive.box(appSettingsBox);
  
  static List<String> getSelectedCurrencies() {
    final currencies = appSettings.get(selectedCurrenciesKey, defaultValue: ['USD', 'EUR', 'RUB', 'KZT']);
    return List<String>.from(currencies);
  }

  static Future<void> saveSelectedCurrencies(List<String> currencies) async {
    await appSettings.put(selectedCurrenciesKey, currencies);
  }

  static String? getLastBaseCurrency() {
    return appSettings.get(lastBaseCurrencyKey);
  }

  static Future<void> saveLastBaseCurrency(String currency) async {
    await appSettings.put(lastBaseCurrencyKey, currency);
  }

  static double? getLastAmount() {
    return appSettings.get(lastAmountKey);
  }

  static Future<void> saveLastAmount(double amount) async {
    await appSettings.put(lastAmountKey, amount);
  }

  // Rates Cache Box
  static Box get ratesCache => Hive.box(ratesCacheBox);
  
  static Map<String, dynamic>? getRatesJson() {
    return ratesCache.get(ratesJsonKey) as Map<String, dynamic>?;
  }

  static Future<void> saveRatesJson(Map<String, dynamic> ratesJson) async {
    await ratesCache.put(ratesJsonKey, ratesJson);
  }

  static DateTime? getLastUpdated() {
    final timestamp = ratesCache.get(lastUpdatedKey);
    return timestamp != null ? DateTime.parse(timestamp.toString()) : null;
  }

  static Future<void> saveLastUpdated(DateTime dateTime) async {
    await ratesCache.put(lastUpdatedKey, dateTime.toIso8601String());
  }
}

