import 'dart:convert';
import 'package:http/http.dart' as http;
import '../utils/app_logger.dart';
import 'device_service.dart';

class CurrencyApiService {
  static const String baseUrl = 'https://conversor.onza.me/api';
  static const String ratesEndpoint = '/rates';
  
  /// Получить заголовки с device_id для API запросов
  static Future<Map<String, String>> _getHeaders() async {
    final deviceId = await DeviceService.getDeviceId();
    return {
      'Content-Type': 'application/json',
      'X-Device-ID': deviceId,
    };
  }

  /// Получить все курсы валют или конкретный курс
  /// 
  /// [base] - базовая валюта (по умолчанию USD)
  /// [target] - целевая валюта (опционально, для получения конкретного курса)
  static Future<Map<String, dynamic>?> fetchRates({
    String base = 'USD',
    String? target,
  }) async {
    final uri = Uri.parse(baseUrl + ratesEndpoint).replace(
      queryParameters: {
        'base': base,
        if (target != null) 'target': target,
      },
    );
    
    AppLogger.i('📡 [API] Запрос курсов валют: $uri');
    try {
      final headers = await _getHeaders();
      final startTime = DateTime.now();
      final response = await http.get(uri, headers: headers);
      final duration = DateTime.now().difference(startTime);
      
      AppLogger.d('   Статус ответа: ${response.statusCode}');
      AppLogger.d('   Время запроса: ${duration.inMilliseconds}ms');
      AppLogger.d('   Размер ответа: ${response.body.length} байт');
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body) as Map<String, dynamic>;
        
        // Проверяем успешность ответа
        final success = data['success'] as bool? ?? false;
        if (!success) {
          final error = data['error'] as String? ?? 'Unknown error';
          AppLogger.e('❌ [API] Ошибка в ответе: $error');
          throw Exception('API error: $error');
        }
        
        final baseCurrency = data['base'] as String? ?? 'USD';
        
        // Если запрошен конкретный курс (target), преобразуем в формат всех курсов
        if (target != null && data.containsKey('rate')) {
          // Преобразуем SingleRateResponse в формат AllRatesResponse для совместимости
          final rate = data['rate'] as num;
          final lastUpdated = data['last_updated'] as String? ?? '';
          data['rates'] = {
            target: {
              'rate': rate,
              'last_updated': lastUpdated,
            }
          };
        }
        
        final ratesCount = (data['rates'] as Map<String, dynamic>?)?.length ?? 0;
        AppLogger.i('✅ [API] Курсы получены успешно');
        AppLogger.d('   Базовая валюта API: $baseCurrency');
        AppLogger.d('   Количество валют: $ratesCount');
        return data;
      } else {
        final errorBody = response.body;
        AppLogger.e('❌ [API] Ошибка HTTP: ${response.statusCode}');
        AppLogger.d('   Тело ответа: $errorBody');
        
        // Пытаемся извлечь сообщение об ошибке
        try {
          final errorData = json.decode(errorBody) as Map<String, dynamic>;
          final error = errorData['error'] as String? ?? 'Unknown error';
          throw Exception('HTTP ${response.statusCode}: $error');
        } catch (_) {
          throw Exception('Failed to load rates: ${response.statusCode}');
        }
      }
    } catch (e) {
      AppLogger.e('❌ [API] Ошибка сети: $e');
      if (e is Exception) {
        rethrow;
      }
      throw Exception('Network error: $e');
    }
  }

  /// Парсинг курсов из нового формата API
  /// 
  /// Новый формат: rates содержит объекты {rate: number, last_updated: string}
  /// Старый формат (для совместимости): rates содержит числа напрямую
  static Map<String, double> parseRates(Map<String, dynamic> jsonData) {
    AppLogger.d('📊 [API] Парсинг курсов валют...');
    final rates = jsonData['rates'] as Map<String, dynamic>?;
    
    if (rates == null || rates.isEmpty) {
      AppLogger.w('⚠️ [API] Курсы отсутствуют в ответе');
      return {};
    }
    
    final parsedRates = <String, double>{};
    
    // Обрабатываем новый формат: rates содержит объекты с rate и last_updated
    rates.forEach((currency, value) {
      if (value is Map) {
        // Новый формат: {rate: 0.85, last_updated: "..."}
        final rateValue = value['rate'];
        if (rateValue != null) {
          parsedRates[currency] = (rateValue as num).toDouble();
        }
      } else if (value is num) {
        // Старый формат (для совместимости с кэшем): число напрямую
        parsedRates[currency] = value.toDouble();
      }
    });
    
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

  /// Конвертация валюты через API
  /// 
  /// [amount] - сумма для конвертации
  /// [from] - исходная валюта
  /// [to] - целевая валюта
  static Future<Map<String, dynamic>?> convertCurrency({
    required double amount,
    required String from,
    required String to,
    String base = 'USD',
  }) async {
    final uri = Uri.parse(baseUrl + '/convert').replace(
      queryParameters: {
        'amount': amount.toString(),
        'from': from,
        'to': to,
        'base': base,
      },
    );
    
    AppLogger.i('🔄 [API] Конвертация валюты: $amount $from → $to');
    try {
      final headers = await _getHeaders();
      final startTime = DateTime.now();
      final response = await http.get(uri, headers: headers);
      final duration = DateTime.now().difference(startTime);
      
      AppLogger.d('   Статус ответа: ${response.statusCode}');
      AppLogger.d('   Время запроса: ${duration.inMilliseconds}ms');
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body) as Map<String, dynamic>;
        
        final success = data['success'] as bool? ?? false;
        if (!success) {
          final error = data['error'] as String? ?? 'Unknown error';
          AppLogger.e('❌ [API] Ошибка конвертации: $error');
          throw Exception('API error: $error');
        }
        
        AppLogger.i('✅ [API] Конвертация выполнена успешно');
        AppLogger.d('   Результат: ${data['converted_amount']} $to');
        AppLogger.d('   Курс: ${data['rate']}');
        return data;
      } else {
        final errorBody = response.body;
        AppLogger.e('❌ [API] Ошибка HTTP при конвертации: ${response.statusCode}');
        AppLogger.d('   Тело ответа: $errorBody');
        
        try {
          final errorData = json.decode(errorBody) as Map<String, dynamic>;
          final error = errorData['error'] as String? ?? 'Unknown error';
          throw Exception('HTTP ${response.statusCode}: $error');
        } catch (_) {
          throw Exception('Failed to convert currency: ${response.statusCode}');
        }
      }
    } catch (e) {
      AppLogger.e('❌ [API] Ошибка сети при конвертации: $e');
      if (e is Exception) {
        rethrow;
      }
      throw Exception('Network error: $e');
    }
  }

  /// Регистрация устройства
  /// 
  /// Регистрирует устройство в системе при первом запуске или обновлении информации
  static Future<bool> registerDevice() async {
    try {
      AppLogger.i('📱 [API] Регистрация устройства...');
      
      final deviceData = await DeviceService.getDeviceInfo();
      final deviceId = deviceData['device_id'] as String;
      
      AppLogger.d('   device_id: $deviceId');
      AppLogger.d('   platform: ${deviceData['platform']}');
      AppLogger.d('   app_version: ${deviceData['app_version']}');
      
      final uri = Uri.parse(baseUrl + '/device/register');
      final headers = {
        'Content-Type': 'application/json',
        'X-Device-ID': deviceId,
      };
      
      final body = jsonEncode({
        'device_id': deviceId,
        if (deviceData['device_name'] != null) 'device_name': deviceData['device_name'],
        if (deviceData['device_type'] != null) 'device_type': deviceData['device_type'],
        if (deviceData['platform'] != null) 'platform': deviceData['platform'],
        if (deviceData['app_version'] != null) 'app_version': deviceData['app_version'],
      });
      
      final startTime = DateTime.now();
      final response = await http.post(uri, headers: headers, body: body);
      final duration = DateTime.now().difference(startTime);
      
      AppLogger.d('   Статус ответа: ${response.statusCode}');
      AppLogger.d('   Время запроса: ${duration.inMilliseconds}ms');
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body) as Map<String, dynamic>;
        
        final success = data['success'] as bool? ?? false;
        if (success) {
          final message = data['message'] as String? ?? 'Устройство зарегистрировано';
          AppLogger.i('✅ [API] $message');
          await DeviceService.markDeviceAsRegistered();
          return true;
        } else {
          final error = data['error'] as String? ?? 'Unknown error';
          AppLogger.e('❌ [API] Ошибка регистрации: $error');
          return false;
        }
      } else {
        final errorBody = response.body;
        AppLogger.e('❌ [API] Ошибка HTTP при регистрации: ${response.statusCode}');
        AppLogger.d('   Тело ответа: $errorBody');
        
        try {
          final errorData = json.decode(errorBody) as Map<String, dynamic>;
          final error = errorData['error'] as String? ?? 'Unknown error';
          AppLogger.e('   Ошибка: $error');
        } catch (_) {
          AppLogger.e('   Не удалось распарсить ошибку');
        }
        return false;
      }
    } catch (e) {
      AppLogger.e('❌ [API] Ошибка сети при регистрации устройства: $e');
      return false;
    }
  }
}

