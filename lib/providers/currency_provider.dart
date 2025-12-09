import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/currency_api_service.dart';
import '../services/hive_service.dart';
import '../utils/app_logger.dart';

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
    AppLogger.i('🚀 [INIT] Инициализация приложения...');
    
    // Загружаем сохраненные валюты
    final savedCurrencies = HiveService.getSelectedCurrencies();
    final savedBaseCurrency = HiveService.getLastBaseCurrency() ?? 
        (savedCurrencies.isNotEmpty ? savedCurrencies.first : 'USD');
    final savedAmount = HiveService.getLastAmount() ?? 1.0;

    AppLogger.d('📋 [INIT] Загружены сохраненные данные:');
    AppLogger.d('   Выбранные валюты: ${savedCurrencies.join(', ')}');
    AppLogger.d('   Базовая валюта: $savedBaseCurrency');
    AppLogger.d('   Последняя сумма: $savedAmount');

    state = state.copyWith(
      selectedCurrencies: savedCurrencies,
      baseCurrency: savedBaseCurrency,
      amount: savedAmount,
    );

    // Загружаем курсы из кэша
    final cachedRatesJson = HiveService.getRatesJson();
    final cachedLastUpdated = HiveService.getLastUpdated();
    final isFirstLaunch = cachedRatesJson == null;

    if (cachedRatesJson != null) {
      final cachedRates = CurrencyApiService.parseRates(cachedRatesJson);
      AppLogger.i('💾 [INIT] Загружены курсы из кэша: ${cachedRates.length} валют');
      AppLogger.d('   Время последнего обновления: $cachedLastUpdated');
      state = state.copyWith(
        rates: cachedRates,
        lastUpdated: cachedLastUpdated,
      );
    } else {
      AppLogger.w('⚠️ [INIT] Кэш курсов пуст - первый запуск приложения');
      // При первом запуске устанавливаем состояние загрузки
      state = state.copyWith(isLoading: true);
    }

    // Проверяем и обновляем курсы при каждом запуске приложения
    AppLogger.i('🔄 [INIT] Проверка курсов валют при запуске приложения...');
    
    if (isFirstLaunch) {
      AppLogger.i('   🆕 Первый запуск - обязательная загрузка курсов из сети');
      // При первом запуске обязательно загружаем курсы
      await refreshRates();
    } else if (cachedLastUpdated != null) {
      final timeSinceUpdate = DateTime.now().difference(cachedLastUpdated);
      final minutesSinceUpdate = timeSinceUpdate.inMinutes;
      AppLogger.d('   Время с последнего обновления: $minutesSinceUpdate минут');
      
      // Если прошло больше 5 минут, обновляем курсы
      if (minutesSinceUpdate >= 5) {
        AppLogger.i('   ⏰ Прошло $minutesSinceUpdate минут, обновляем курсы...');
        await refreshRates();
      } else {
        AppLogger.d('   ✅ Курсы актуальны (обновлены $minutesSinceUpdate минут назад), пропускаем обновление');
      }
    } else {
      // Если кэша нет, но это не первый запуск (странная ситуация), все равно загружаем
      AppLogger.w('   ⚠️ Кэш отсутствует, но это не первый запуск. Загружаем курсы...');
      await refreshRates();
    }
    
    AppLogger.i('✅ [INIT] Инициализация завершена');
  }

  Future<void> refreshRates() async {
    AppLogger.i('🔄 [RATES_REFRESH] Начало обновления курсов валют...');
    state = state.copyWith(isLoading: true, error: null);

    try {
      AppLogger.d('📡 [RATES_REFRESH] Запрос к API...');
      final ratesJson = await CurrencyApiService.fetchRates();
      if (ratesJson != null) {
        final rates = CurrencyApiService.parseRates(ratesJson);
        AppLogger.i('✅ [RATES_REFRESH] Курсы получены: ${rates.length} валют');
        AppLogger.d('   Примеры курсов: ${rates.entries.take(5).map((e) => '${e.key}: ${e.value}').join(', ')}');
        
        // Сохраняем в кэш
        await HiveService.saveRatesJson(ratesJson);
        await HiveService.saveLastUpdated(DateTime.now());
        AppLogger.d('💾 [RATES_REFRESH] Курсы сохранены в кэш');

        state = state.copyWith(
          rates: rates,
          lastUpdated: DateTime.now(),
          isLoading: false,
        );
        AppLogger.i('✅ [RATES_REFRESH] Курсы обновлены успешно. Будет пересчет всех валют...');
      }
    } catch (e) {
      AppLogger.e('❌ [RATES_REFRESH] Ошибка при обновлении курсов: $e');
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  void setBaseCurrency(String currency) {
    final previousBaseCurrency = state.baseCurrency;
    AppLogger.i('🔄 [CURRENCY_SELECTION] Выбор базовой валюты: $previousBaseCurrency → $currency');
    AppLogger.d('   Текущая сумма: ${state.amount}');
    AppLogger.d('   Доступные курсы: ${state.rates.keys.length} валют');
    
    // Если переключаемся на другую валюту, сбрасываем сумму
    if (previousBaseCurrency != currency) {
      AppLogger.i('   Сброс суммы при переключении валюты: ${state.amount} → 0.0');
      state = state.copyWith(
        baseCurrency: currency,
        amount: 0.0,
      );
      HiveService.saveLastBaseCurrency(currency);
      HiveService.saveLastAmount(0.0);
    } else {
      state = state.copyWith(baseCurrency: currency);
      HiveService.saveLastBaseCurrency(currency);
    }
    
    AppLogger.i('✅ [CURRENCY_SELECTION] Базовая валюта установлена: $currency, сумма сброшена');
  }

  void setAmount(double amount) {
    final previousAmount = state.amount;
    AppLogger.i('💰 [AMOUNT_CHANGE] Изменение суммы: $previousAmount → $amount');
    AppLogger.d('   Базовая валюта: ${state.baseCurrency}');
    
    state = state.copyWith(amount: amount);
    HiveService.saveLastAmount(amount);
    
    AppLogger.i('✅ [AMOUNT_CHANGE] Сумма обновлена. Будет пересчет всех валют...');
  }

  double convertCurrency(String targetCurrency) {
    return CurrencyNotifier.convertCurrencyStatic(state, targetCurrency);
  }

  static double convertCurrencyStatic(CurrencyState state, String targetCurrency) {
    if (state.rates.isEmpty) {
      AppLogger.w('⚠️ [CONVERSION] Курсы валют пусты, возвращаем 0.0');
      return 0.0;
    }

    // Если базовая валюта совпадает с целевой
    if (state.baseCurrency == targetCurrency) {
      AppLogger.d('📊 [CONVERSION] Базовая валюта = целевая ($targetCurrency), возвращаем сумму: ${state.amount}');
      return state.amount;
    }

    // API возвращает курсы относительно USD (обычно base = "USD")
    // Формула: result = (inputValue / rates[baseCurrency]) * rates[targetCurrency]
    // Это работает, потому что rates содержат курсы относительно USD
    
    final baseRate = state.rates[state.baseCurrency];
    final targetRate = state.rates[targetCurrency];

    if (baseRate == null || targetRate == null) {
      AppLogger.w('⚠️ [CONVERSION] Курс не найден для базовой ($baseRate) или целевой ($targetRate) валюты');
      return 0.0;
    }

    // Если базовая валюта USD, то baseRate = 1.0 (обычно)
    // Для других валют baseRate - это курс относительно USD
    final result = (state.amount / baseRate) * targetRate;
    
    AppLogger.i('🧮 [CONVERSION] Расчет конвертации:');
    AppLogger.d('   Базовая валюта: ${state.baseCurrency}');
    AppLogger.d('   Целевая валюта: $targetCurrency');
    AppLogger.d('   Введенная сумма: ${state.amount}');
    AppLogger.d('   Курс базовой валюты (относительно USD): $baseRate');
    AppLogger.d('   Курс целевой валюты (относительно USD): $targetRate');
    AppLogger.d('   Формула: result = (amount / baseRate) * targetRate');
    AppLogger.d('   Расчет: result = (${state.amount} / $baseRate) * $targetRate');
    AppLogger.d('   Промежуточный результат: ${state.amount / baseRate}');
    AppLogger.d('   ✅ Итоговый результат: $result $targetCurrency');
    
    return result;
  }

  void addCurrency(String currency) {
    if (!state.selectedCurrencies.contains(currency)) {
      AppLogger.i('➕ [CURRENCY_MANAGEMENT] Добавление валюты: $currency');
      AppLogger.d('   Текущий список: ${state.selectedCurrencies.join(', ')}');
      final newList = [...state.selectedCurrencies, currency];
      state = state.copyWith(selectedCurrencies: newList);
      HiveService.saveSelectedCurrencies(newList);
      AppLogger.i('✅ [CURRENCY_MANAGEMENT] Валюта добавлена. Новый список: ${newList.join(', ')}');
    } else {
      AppLogger.d('⚠️ [CURRENCY_MANAGEMENT] Валюта $currency уже в списке');
    }
  }

  void removeCurrency(String currency) {
    if (state.selectedCurrencies.length > 1) {
      AppLogger.i('➖ [CURRENCY_MANAGEMENT] Удаление валюты: $currency');
      AppLogger.d('   Текущий список: ${state.selectedCurrencies.join(', ')}');
      final newList = state.selectedCurrencies.where((c) => c != currency).toList();
      state = state.copyWith(selectedCurrencies: newList);
      HiveService.saveSelectedCurrencies(newList);
      
      // Если удалили базовую валюту, устанавливаем первую из списка
      if (state.baseCurrency == currency) {
        AppLogger.w('⚠️ [CURRENCY_MANAGEMENT] Удалена базовая валюта, переключаем на: ${newList.first}');
        setBaseCurrency(newList.first);
      }
      AppLogger.i('✅ [CURRENCY_MANAGEMENT] Валюта удалена. Новый список: ${newList.join(', ')}');
    } else {
      AppLogger.w('⚠️ [CURRENCY_MANAGEMENT] Нельзя удалить последнюю валюту');
    }
  }

  void reorderCurrencies(int oldIndex, int newIndex) {
    AppLogger.i('🔄 [CURRENCY_MANAGEMENT] Изменение порядка валют: $oldIndex → $newIndex');
    AppLogger.d('   До: ${state.selectedCurrencies.join(', ')}');
    final newList = List<String>.from(state.selectedCurrencies);
    if (newIndex > oldIndex) {
      newIndex -= 1;
    }
    final item = newList.removeAt(oldIndex);
    newList.insert(newIndex, item);
    state = state.copyWith(selectedCurrencies: newList);
    HiveService.saveSelectedCurrencies(newList);
    AppLogger.d('   После: ${newList.join(', ')}');
    AppLogger.i('✅ [CURRENCY_MANAGEMENT] Порядок изменен');
  }
}

final currencyProvider = StateNotifierProvider<CurrencyNotifier, CurrencyState>((ref) {
  return CurrencyNotifier();
});

