import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:intl/intl.dart';
import 'package:currency_pro/l10n/app_localizations.dart';
import '../providers/currency_provider.dart';
import '../models/currency_info.dart';
import '../theme/app_theme.dart';
import '../utils/app_logger.dart';

class CurrencyCard extends ConsumerStatefulWidget {
  final String currencyCode;
  final bool isBaseCurrency;
  final int index;

  const CurrencyCard({
    super.key,
    required this.currencyCode,
    required this.isBaseCurrency,
    required this.index,
  });

  @override
  ConsumerState<CurrencyCard> createState() => _CurrencyCardState();
}

class _CurrencyCardState extends ConsumerState<CurrencyCard> {
  late final TextEditingController _controller;
  final FocusNode _focusNode = FocusNode();
  bool _isFocused = false;

  String? _lastBaseCurrency;
  double _lastAmount = 0.0;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
    _focusNode.addListener(_onFocusChange);
    
    // Инициализируем значение при создании карточки
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final state = ref.read(currencyProvider);
      _lastBaseCurrency = state.baseCurrency;
      _lastAmount = state.amount;
      _updateValue(state);
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _onFocusChange() {
    setState(() {
      _isFocused = _focusNode.hasFocus;
    });

    if (_focusNode.hasFocus) {
      AppLogger.i('👆 [FOCUS] Получен фокус на валюте: ${widget.currencyCode}');
      
      // Сохраняем текущее значение перед переключением базовой валюты
      final currentState = ref.read(currencyProvider);
      AppLogger.d('   Текущая базовая валюта: ${currentState.baseCurrency}');
      AppLogger.d('   Текущая сумма в state: ${currentState.amount}');
      AppLogger.d('   Значение в поле ввода: ${_controller.text}');
      
      if (currentState.baseCurrency == widget.currencyCode) {
        // Если это уже базовая валюта, сохраняем введенное значение
        final currentValue = double.tryParse(_controller.text.replaceAll(RegExp(r'[^\d.]'), '')) ?? currentState.amount;
        AppLogger.d('   Это уже базовая валюта. Парсинг значения: $currentValue');
        if (currentValue != currentState.amount) {
          AppLogger.i('   Обновляем сумму в state: ${currentState.amount} → $currentValue');
          ref.read(currencyProvider.notifier).setAmount(currentValue);
        }
      } else {
        AppLogger.i('   Переключаем базовую валюту: ${currentState.baseCurrency} → ${widget.currencyCode}');
      }
      
      // Переключаем базовую валюту (это сбросит сумму на 0.0)
      ref.read(currencyProvider.notifier).setBaseCurrency(widget.currencyCode);
      
      // Полностью очищаем поле ввода при активации карточки
      AppLogger.i('   🧹 Очистка поля ввода при активации карточки');
      _controller.clear();
      
      AppLogger.i('✅ [FOCUS] Валюта ${widget.currencyCode} теперь активна (базовая), поле очищено');
    } else {
      AppLogger.d('👋 [FOCUS] Потеря фокуса на валюте: ${widget.currencyCode}');
      
      // При потере фокуса, если это была базовая валюта, сохраняем введенное значение
      final currentState = ref.read(currencyProvider);
      if (currentState.baseCurrency == widget.currencyCode) {
        final currentValue = double.tryParse(_controller.text.replaceAll(RegExp(r'[^\d.]'), '')) ?? currentState.amount;
        AppLogger.d('   Это была базовая валюта. Сохраняем значение: $currentValue');
        if (currentValue != currentState.amount) {
          AppLogger.i('   Обновляем сумму при потере фокуса: ${currentState.amount} → $currentValue');
          ref.read(currencyProvider.notifier).setAmount(currentValue);
        }
      }
    }
  }

  void _updateValue(CurrencyState state) {
    if (_focusNode.hasFocus) {
      AppLogger.d('⏸️ [UPDATE] Пропускаем обновление ${widget.currencyCode} - поле в фокусе');
      return;
    }
    
    // Если это базовая валюта, используем введенное значение напрямую
    if (state.baseCurrency == widget.currencyCode) {
      AppLogger.d('📝 [UPDATE] Обновление базовой валюты ${widget.currencyCode}: ${state.amount}');
      final formatter = NumberFormat.currency(
        symbol: '',
        decimalDigits: 2,
        locale: 'en_US',
      );
      final formattedValue = formatter.format(state.amount);
      if (_controller.text != formattedValue) {
        AppLogger.d('   Форматирование: ${state.amount} → "$formattedValue"');
        _controller.text = formattedValue;
      }
      return;
    }
    
    // Для остальных валют пересчитываем значение
    AppLogger.d('🔄 [UPDATE] Пересчет валюты ${widget.currencyCode}...');
    final convertedValue = CurrencyNotifier.convertCurrencyStatic(state, widget.currencyCode);
    
    final formatter = NumberFormat.currency(
      symbol: '',
      decimalDigits: 2,
      locale: 'en_US',
    );
    
    final formattedValue = formatter.format(convertedValue);
    
    if (_controller.text != formattedValue) {
      AppLogger.d('   Обновление значения: "${_controller.text}" → "$formattedValue"');
      _controller.text = formattedValue;
    } else {
      AppLogger.d('   Значение не изменилось: "$formattedValue"');
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(currencyProvider);
    final currencyInfo = CurrencyInfo.allCurrencies[widget.currencyCode] ?? 
        CurrencyInfo(code: widget.currencyCode, name: widget.currencyCode, symbol: '', countryCode: widget.currencyCode.substring(0, 2).toLowerCase());
    
    final isBase = state.baseCurrency == widget.currencyCode || _isFocused;
    
    // Обновляем значение при изменении базовой валюты или суммы, если поле не в фокусе
    if (!_focusNode.hasFocus && 
        (_lastBaseCurrency != state.baseCurrency || _lastAmount != state.amount)) {
      final wasBaseCurrency = _lastBaseCurrency == widget.currencyCode;
      final isNowBaseCurrency = state.baseCurrency == widget.currencyCode;
      
      AppLogger.d('🔄 [RECALC] Триггер пересчета для ${widget.currencyCode}:');
      AppLogger.d('   Была базовой: $wasBaseCurrency');
      AppLogger.d('   Теперь базовая: $isNowBaseCurrency');
      AppLogger.d('   Изменилась базовая валюта: ${_lastBaseCurrency} → ${state.baseCurrency}');
      AppLogger.d('   Изменилась сумма: ${_lastAmount} → ${state.amount}');
      
      _lastBaseCurrency = state.baseCurrency;
      _lastAmount = state.amount;
      
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted && !_focusNode.hasFocus) {
          // Если это была базовая валюта и теперь стала другой, не обновляем значение
          // Оно должно остаться таким, каким его ввел пользователь
          if (wasBaseCurrency && !isNowBaseCurrency) {
            AppLogger.d('   ⏸️ Пропускаем обновление - это была базовая валюта, сохраняем введенное значение');
            return;
          }
          _updateValue(state);
        }
      });
    }

    return GestureDetector(
      onTap: () {
        _focusNode.requestFocus();
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
        child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppTheme.backgroundCard,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isBase ? AppTheme.accentPrimary : AppTheme.dividerBorder,
            width: 1,
          ),
        ),
        child: Row(
          children: [
            // Иконка перетаскивания с ReorderableDragStartListener (только эта область активирует перетаскивание)
            ReorderableDragStartListener(
              index: widget.index,
              child: Padding(
                padding: const EdgeInsets.only(right: 8),
                child: Icon(
                  Icons.drag_handle,
                  color: AppTheme.textSecondary.withValues(alpha: 0.5),
                  size: 20,
                ),
              ),
            ),
            // Флаг
            ClipOval(
              child: CachedNetworkImage(
                imageUrl: 'https://flagcdn.com/w80/${CurrencyInfo.getCountryCode(widget.currencyCode)}.png',
                width: 40,
                height: 40,
                fit: BoxFit.cover,
                placeholder: (context, url) => Container(
                  width: 40,
                  height: 40,
                  color: AppTheme.dividerBorder,
                  child: const Center(
                    child: SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(AppTheme.textSecondary),
                      ),
                    ),
                  ),
                ),
                errorWidget: (context, url, error) => Container(
                  width: 40,
                  height: 40,
                  color: AppTheme.dividerBorder,
                  child: const Icon(Icons.flag, color: AppTheme.textSecondary, size: 20),
                ),
              ),
            ),
            const SizedBox(width: 16),
            
            // Информация о валюте
            Flexible(
              flex: 2,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    widget.currencyCode,
                    style: const TextStyle(
                      color: AppTheme.textPrimary,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Inter',
                    ),
                  ),
                  const SizedBox(height: 4),
                  _buildExchangeRateText(context, state, widget.currencyCode),
                ],
              ),
            ),
            
            // Поле ввода
            Flexible(
              flex: 3,
              child: TextField(
                controller: _controller,
                focusNode: _focusNode,
                readOnly: !isBase,
                textAlign: TextAlign.right,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                inputFormatters: [
                  // Фильтруем запятые и разрешаем только цифры и одну точку
                  FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
                  // Валидация: только одна точка и максимум 2 символа после точки
                  TextInputFormatter.withFunction((oldValue, newValue) {
                    final text = newValue.text;
                    
                    // Подсчитываем количество точек
                    final dotCount = '.'.allMatches(text).length;
                    // Если точек больше одной, возвращаем старое значение
                    if (dotCount > 1) {
                      AppLogger.d('🚫 [INPUT_VALIDATION] Попытка ввести вторую точку, отклонено');
                      return oldValue;
                    }
                    
                    // Проверяем ограничение на количество символов после точки (максимум 2)
                    if (text.contains('.')) {
                      final parts = text.split('.');
                      if (parts.length == 2 && parts[1].length > 2) {
                        AppLogger.d('🚫 [INPUT_VALIDATION] Попытка ввести более 2 символов после точки, отклонено');
                        // Оставляем только первые 2 символа после точки
                        final limitedText = '${parts[0]}.${parts[1].substring(0, 2)}';
                        return TextEditingValue(
                          text: limitedText,
                          selection: TextSelection.collapsed(offset: limitedText.length),
                        );
                      }
                    }
                    
                    // Заменяем запятые на точки (на случай если они все же попали)
                    if (text.contains(',')) {
                      final replacedText = text.replaceAll(',', '.');
                      // Проверяем, что после замены не стало больше одной точки
                      if ('.'.allMatches(replacedText).length <= 1) {
                        // Также проверяем ограничение на символы после точки
                        if (replacedText.contains('.')) {
                          final parts = replacedText.split('.');
                          if (parts.length == 2 && parts[1].length > 2) {
                            final limitedText = '${parts[0]}.${parts[1].substring(0, 2)}';
                            return TextEditingValue(
                              text: limitedText,
                              selection: TextSelection.collapsed(offset: limitedText.length),
                            );
                          }
                        }
                        return TextEditingValue(
                          text: replacedText,
                          selection: TextSelection.collapsed(offset: replacedText.length),
                        );
                      }
                      return oldValue;
                    }
                    return newValue;
                  }),
                ],
                style: const TextStyle(
                  color: AppTheme.textPrimary,
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Inter',
                ),
                decoration: InputDecoration(
                  border: InputBorder.none,
                  suffix: Text(
                    currencyInfo.symbol,
                    style: TextStyle(
                      color: AppTheme.textPrimary.withValues(alpha: 0.5),
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  contentPadding: const EdgeInsets.only(left: 8),
                ),
                onChanged: (value) {
                  if (isBase && _focusNode.hasFocus) {
                    // Парсим значение (точка уже валидирована через inputFormatters)
                    final amount = double.tryParse(value) ?? 0.0;
                    AppLogger.d('💰 [AMOUNT_CHANGE] Ввод суммы для ${widget.currencyCode}: "$value" → $amount');
                    ref.read(currencyProvider.notifier).setAmount(amount);
                  }
                },
              ),
            ),
          ],
        ),
        ),
      ),
    );
  }

  Widget _buildExchangeRateText(BuildContext context, CurrencyState state, String currencyCode) {
    final l10n = AppLocalizations.of(context)!;
    
    if (state.rates.isEmpty || !state.rates.containsKey(state.baseCurrency) || 
        !state.rates.containsKey(currencyCode)) {
      return Text(
        l10n.rateUnavailable,
        style: const TextStyle(
          color: AppTheme.textSecondary,
          fontSize: 12,
          fontWeight: FontWeight.normal,
          fontFamily: 'Inter',
        ),
      );
    }

    final baseRate = state.rates[state.baseCurrency] ?? 1.0;
    final targetRate = state.rates[currencyCode] ?? 1.0;
    final rate = targetRate / baseRate;

    final formatter = NumberFormat.currency(
      symbol: '',
      decimalDigits: 4,
    );

    final formattedRate = formatter.format(rate);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '1 ${state.baseCurrency} /',
          style: const TextStyle(
            color: AppTheme.textSecondary,
            fontSize: 12,
            fontWeight: FontWeight.normal,
            fontFamily: 'Inter',
          ),
        ),
        Text(
          '$formattedRate ${currencyCode}',
          style: const TextStyle(
            color: AppTheme.textSecondary,
            fontSize: 12,
            fontWeight: FontWeight.normal,
            fontFamily: 'Inter',
          ),
        ),
      ],
    );
  }
}

