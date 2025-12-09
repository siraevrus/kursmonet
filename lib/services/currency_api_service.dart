import 'dart:convert';
import 'package:http/http.dart' as http;
import '../utils/app_logger.dart';

class CurrencyApiService {
  static const String baseUrl = 'https://api.fxratesapi.com/latest';

  static Future<Map<String, dynamic>?> fetchRates() async {
    AppLogger.i('📡 [API] Запрос курсов валют: $baseUrl');
    try {
      final startTime = DateTime.now();
      final response = await http.get(Uri.parse(baseUrl));
      final duration = DateTime.now().difference(startTime);
      
      AppLogger.d('   Статус ответа: ${response.statusCode}');
      AppLogger.d('   Время запроса: ${duration.inMilliseconds}ms');
      AppLogger.d('   Размер ответа: ${response.body.length} байт');
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body) as Map<String, dynamic>;
        final baseCurrency = data['base'] as String? ?? 'USD';
        final ratesCount = (data['rates'] as Map<String, dynamic>?)?.length ?? 0;
        AppLogger.i('✅ [API] Курсы получены успешно');
        AppLogger.d('   Базовая валюта API: $baseCurrency');
        AppLogger.d('   Количество валют: $ratesCount');
        return data;
      } else {
        AppLogger.e('❌ [API] Ошибка HTTP: ${response.statusCode}');
        throw Exception('Failed to load rates: ${response.statusCode}');
      }
    } catch (e) {
      AppLogger.e('❌ [API] Ошибка сети: $e');
      throw Exception('Network error: $e');
    }
  }

  static Map<String, double> parseRates(Map<String, dynamic> jsonData) {
    AppLogger.d('📊 [API] Парсинг курсов валют...');
    final rates = jsonData['rates'] as Map<String, dynamic>;
    final parsedRates = rates.map((key, value) => MapEntry(key, (value as num).toDouble()));
    
    AppLogger.d('   Распарсено валют: ${parsedRates.length}');
    
    // Добавляем базовую валюту API (обычно USD) с курсом 1.0, если её нет
    final baseCurrency = jsonData['base'] as String? ?? 'USD';
    if (!parsedRates.containsKey(baseCurrency)) {
      AppLogger.d('   Добавлена базовая валюта API: $baseCurrency = 1.0');
      parsedRates[baseCurrency] = 1.0;
    } else {
      AppLogger.d('   Базовая валюта API уже присутствует: $baseCurrency = ${parsedRates[baseCurrency]}');
    }
    
    AppLogger.d('   Итого валют после парсинга: ${parsedRates.length}');
    return parsedRates;
  }
}

