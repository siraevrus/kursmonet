import 'dart:convert';
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
    try {
      final cachedData = ratesCache.get(ratesJsonKey);
      if (cachedData == null) {
        AppLogger.d('💾 [HIVE] Кэш курсов пуст');
        return null;
      }
      
      Map<String, dynamic>? ratesJson;
      
      // Обрабатываем разные форматы данных
      if (cachedData is String) {
        // Данные сохранены как JSON строка
        AppLogger.d('💾 [HIVE] Данные в формате JSON строки');
        ratesJson = jsonDecode(cachedData) as Map<String, dynamic>?;
      } else if (cachedData is Map) {
        // Данные в формате Map (старый формат)
        AppLogger.d('💾 [HIVE] Данные в формате Map');
        ratesJson = Map<String, dynamic>.from(cachedData);
      } else {
        AppLogger.e('❌ [HIVE] Неверный тип данных в кэше: ${cachedData.runtimeType}');
        return null;
      }
      
      if (ratesJson != null) {
        final ratesCount = (ratesJson['rates'] as Map<String, dynamic>?)?.length ?? 0;
        AppLogger.d('💾 [HIVE] Загружен кэш курсов: $ratesCount валют');
        AppLogger.d('   Тип исходных данных: ${cachedData.runtimeType}');
        return ratesJson;
      } else {
        AppLogger.e('❌ [HIVE] Не удалось распарсить данные из кэша');
        return null;
      }
    } catch (e) {
      AppLogger.e('❌ [HIVE] Ошибка при загрузке кэша курсов: $e');
      return null;
    }
  }

  static Future<void> saveRatesJson(Map<String, dynamic> ratesJson) async {
    try {
      final ratesCount = (ratesJson['rates'] as Map<String, dynamic>?)?.length ?? 0;
      AppLogger.d('💾 [HIVE] Сохранение кэша курсов: $ratesCount валют');
      
      // Сохраняем как JSON строку для надежности
      final jsonString = jsonEncode(ratesJson);
      await ratesCache.put(ratesJsonKey, jsonString);
      
      AppLogger.d('✅ [HIVE] Кэш курсов сохранен (размер JSON: ${jsonString.length} символов)');
      
      // Проверяем, что данные сохранились
      final saved = ratesCache.get(ratesJsonKey);
      if (saved != null) {
        AppLogger.d('✅ [HIVE] Проверка сохранения: данные в кэше присутствуют');
      } else {
        AppLogger.e('❌ [HIVE] Ошибка: данные не сохранились в кэш');
      }
    } catch (e) {
      AppLogger.e('❌ [HIVE] Ошибка при сохранении кэша курсов: $e');
      rethrow;
    }
  }

  static DateTime? getLastUpdated() {
    try {
      final timestamp = ratesCache.get(lastUpdatedKey);
      if (timestamp == null) {
        AppLogger.d('💾 [HIVE] Время обновления не найдено');
        return null;
      }
      
      DateTime? dateTime;
      if (timestamp is String) {
        dateTime = DateTime.tryParse(timestamp);
      } else if (timestamp is DateTime) {
        dateTime = timestamp;
      } else {
        dateTime = DateTime.tryParse(timestamp.toString());
      }
      
      AppLogger.d('💾 [HIVE] Загружено время обновления: $dateTime');
      return dateTime;
    } catch (e) {
      AppLogger.e('❌ [HIVE] Ошибка при загрузке времени обновления: $e');
      return null;
    }
  }

  static Future<void> saveLastUpdated(DateTime dateTime) async {
    AppLogger.d('💾 [HIVE] Сохранение времени обновления: $dateTime');
    await ratesCache.put(lastUpdatedKey, dateTime.toIso8601String());
    AppLogger.d('✅ [HIVE] Время обновления сохранено');
  }
}

