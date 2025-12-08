import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/currency_api_service.dart';
import '../services/hive_service.dart';

class CurrencyState {
  final Map<String, double> rates;
  final String baseCurrency;
  final double amount;
  final List<String> selectedCurrencies;
  final DateTime? lastUpdated;
  final bool isLoading;
  final String? error;

  CurrencyState({
    required this.rates,
    required this.baseCurrency,
    required this.amount,
    required this.selectedCurrencies,
    this.lastUpdated,
    this.isLoading = false,
    this.error,
  });

  CurrencyState copyWith({
    Map<String, double>? rates,
    String? baseCurrency,
    double? amount,
    List<String>? selectedCurrencies,
    DateTime? lastUpdated,
    bool? isLoading,
    String? error,
  }) {
    return CurrencyState(
      rates: rates ?? this.rates,
      baseCurrency: baseCurrency ?? this.baseCurrency,
      amount: amount ?? this.amount,
      selectedCurrencies: selectedCurrencies ?? this.selectedCurrencies,
      lastUpdated: lastUpdated ?? this.lastUpdated,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }
}

class CurrencyNotifier extends StateNotifier<CurrencyState> {
  CurrencyNotifier() : super(CurrencyState(
    rates: {},
    baseCurrency: 'USD',
    amount: 1.0,
    selectedCurrencies: [],
  )) {
    _loadInitialData();
  }

  Future<void> _loadInitialData() async {
    // Загружаем сохраненные валюты
    final savedCurrencies = HiveService.getSelectedCurrencies();
    final savedBaseCurrency = HiveService.getLastBaseCurrency() ?? 
        (savedCurrencies.isNotEmpty ? savedCurrencies.first : 'USD');
    final savedAmount = HiveService.getLastAmount() ?? 1.0;

    state = state.copyWith(
      selectedCurrencies: savedCurrencies,
      baseCurrency: savedBaseCurrency,
      amount: savedAmount,
    );

    // Загружаем курсы из кэша
    final cachedRatesJson = HiveService.getRatesJson();
    final cachedLastUpdated = HiveService.getLastUpdated();

    if (cachedRatesJson != null) {
      final cachedRates = CurrencyApiService.parseRates(cachedRatesJson);
      state = state.copyWith(
        rates: cachedRates,
        lastUpdated: cachedLastUpdated,
      );
    }

    // Пытаемся обновить курсы из сети
    await refreshRates();
  }

  Future<void> refreshRates() async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final ratesJson = await CurrencyApiService.fetchRates();
      if (ratesJson != null) {
        final rates = CurrencyApiService.parseRates(ratesJson);
        
        // Сохраняем в кэш
        await HiveService.saveRatesJson(ratesJson);
        await HiveService.saveLastUpdated(DateTime.now());

        state = state.copyWith(
          rates: rates,
          lastUpdated: DateTime.now(),
          isLoading: false,
        );
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  void setBaseCurrency(String currency) {
    state = state.copyWith(baseCurrency: currency);
    HiveService.saveLastBaseCurrency(currency);
  }

  void setAmount(double amount) {
    state = state.copyWith(amount: amount);
    HiveService.saveLastAmount(amount);
  }

  double convertCurrency(String targetCurrency) {
    return CurrencyNotifier.convertCurrencyStatic(state, targetCurrency);
  }

  static double convertCurrencyStatic(CurrencyState state, String targetCurrency) {
    if (state.rates.isEmpty) {
      return 0.0;
    }

    // Если базовая валюта совпадает с целевой
    if (state.baseCurrency == targetCurrency) {
      return state.amount;
    }

    // API возвращает курсы относительно USD (обычно base = "USD")
    // Формула: result = (inputValue / rates[baseCurrency]) * rates[targetCurrency]
    // Это работает, потому что rates содержат курсы относительно USD
    
    final baseRate = state.rates[state.baseCurrency];
    final targetRate = state.rates[targetCurrency];

    if (baseRate == null || targetRate == null) {
      return 0.0;
    }

    // Если базовая валюта USD, то baseRate = 1.0 (обычно)
    // Для других валют baseRate - это курс относительно USD
    return (state.amount / baseRate) * targetRate;
  }

  void addCurrency(String currency) {
    if (!state.selectedCurrencies.contains(currency)) {
      final newList = [...state.selectedCurrencies, currency];
      state = state.copyWith(selectedCurrencies: newList);
      HiveService.saveSelectedCurrencies(newList);
    }
  }

  void removeCurrency(String currency) {
    if (state.selectedCurrencies.length > 1) {
      final newList = state.selectedCurrencies.where((c) => c != currency).toList();
      state = state.copyWith(selectedCurrencies: newList);
      HiveService.saveSelectedCurrencies(newList);
      
      // Если удалили базовую валюту, устанавливаем первую из списка
      if (state.baseCurrency == currency) {
        setBaseCurrency(newList.first);
      }
    }
  }

  void reorderCurrencies(int oldIndex, int newIndex) {
    final newList = List<String>.from(state.selectedCurrencies);
    if (newIndex > oldIndex) {
      newIndex -= 1;
    }
    final item = newList.removeAt(oldIndex);
    newList.insert(newIndex, item);
    state = state.copyWith(selectedCurrencies: newList);
    HiveService.saveSelectedCurrencies(newList);
  }
}

final currencyProvider = StateNotifierProvider<CurrencyNotifier, CurrencyState>((ref) {
  return CurrencyNotifier();
});

