import 'dart:convert';
import 'package:http/http.dart' as http;

class CurrencyApiService {
  static const String baseUrl = 'https://api.fxratesapi.com/latest';

  static Future<Map<String, dynamic>?> fetchRates() async {
    try {
      final response = await http.get(Uri.parse(baseUrl));
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body) as Map<String, dynamic>;
        return data;
      } else {
        throw Exception('Failed to load rates: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  static Map<String, double> parseRates(Map<String, dynamic> jsonData) {
    final rates = jsonData['rates'] as Map<String, dynamic>;
    final parsedRates = rates.map((key, value) => MapEntry(key, (value as num).toDouble()));
    
    // Добавляем базовую валюту API (обычно USD) с курсом 1.0, если её нет
    final baseCurrency = jsonData['base'] as String? ?? 'USD';
    if (!parsedRates.containsKey(baseCurrency)) {
      parsedRates[baseCurrency] = 1.0;
    }
    
    return parsedRates;
  }
}

