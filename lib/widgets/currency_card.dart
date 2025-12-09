import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:intl/intl.dart';
import 'package:currency_pro/l10n/app_localizations.dart';
import '../providers/currency_provider.dart';
import '../models/currency_info.dart';
import '../theme/app_theme.dart';

class CurrencyCard extends ConsumerStatefulWidget {
  final String currencyCode;
  final bool isBaseCurrency;

  const CurrencyCard({
    super.key,
    required this.currencyCode,
    required this.isBaseCurrency,
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
      ref.read(currencyProvider.notifier).setBaseCurrency(widget.currencyCode);
    }
  }

  void _updateValue(CurrencyState state) {
    if (_focusNode.hasFocus) return;
    
    final convertedValue = CurrencyNotifier.convertCurrencyStatic(state, widget.currencyCode);
    
    final formatter = NumberFormat.currency(
      symbol: '',
      decimalDigits: 2,
      locale: 'en_US',
    );
    
    final formattedValue = formatter.format(convertedValue);
    
    if (_controller.text != formattedValue) {
      _controller.text = formattedValue;
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
      _lastBaseCurrency = state.baseCurrency;
      _lastAmount = state.amount;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted && !_focusNode.hasFocus) {
          _updateValue(state);
        }
      });
    }

    return GestureDetector(
      onTap: () {
        _focusNode.requestFocus();
      },
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
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
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
                  Text(
                    _getExchangeRateText(context, state, widget.currencyCode),
                    style: const TextStyle(
                      color: AppTheme.textSecondary,
                      fontSize: 12,
                      fontWeight: FontWeight.normal,
                      fontFamily: 'Inter',
                    ),
                  ),
                ],
              ),
            ),
            
            // Поле ввода
            Expanded(
              child: TextField(
                controller: _controller,
                focusNode: _focusNode,
                readOnly: !isBase,
                textAlign: TextAlign.right,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                style: const TextStyle(
                  color: AppTheme.textPrimary,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Inter',
                ),
                decoration: InputDecoration(
                  border: InputBorder.none,
                  suffix: Text(
                    currencyInfo.symbol,
                    style: TextStyle(
                      color: AppTheme.textPrimary.withValues(alpha: 0.5),
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  contentPadding: const EdgeInsets.only(left: 8),
                ),
                onChanged: (value) {
                  if (isBase && _focusNode.hasFocus) {
                    // Удаляем все символы кроме цифр и точки
                    final cleanValue = value.replaceAll(RegExp(r'[^\d.]'), '');
                    final amount = double.tryParse(cleanValue) ?? 0.0;
                    ref.read(currencyProvider.notifier).setAmount(amount);
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getExchangeRateText(BuildContext context, CurrencyState state, String currencyCode) {
    final l10n = AppLocalizations.of(context)!;
    
    if (state.rates.isEmpty || !state.rates.containsKey(state.baseCurrency) || 
        !state.rates.containsKey(currencyCode)) {
      return l10n.rateUnavailable;
    }

    final baseRate = state.rates[state.baseCurrency] ?? 1.0;
    final targetRate = state.rates[currencyCode] ?? 1.0;
    final rate = targetRate / baseRate;

    final formatter = NumberFormat.currency(
      symbol: '',
      decimalDigits: 4,
    );

    return l10n.exchangeRate(state.baseCurrency, formatter.format(rate), currencyCode);
  }
}

