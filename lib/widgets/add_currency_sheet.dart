import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:currency_pro/l10n/app_localizations.dart';
import '../providers/currency_provider.dart';
import '../models/currency_info.dart';
import '../theme/app_theme.dart';

class AddCurrencySheet extends ConsumerStatefulWidget {
  const AddCurrencySheet({super.key});

  @override
  ConsumerState<AddCurrencySheet> createState() => _AddCurrencySheetState();
}

class _AddCurrencySheetState extends ConsumerState<AddCurrencySheet> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final state = ref.watch(currencyProvider);
    final allCurrencies = CurrencyInfo.allCurrencies;
    final popularCurrencies = CurrencyInfo.popularCurrencies;

    // Фильтрация валют по поисковому запросу
    final filteredCurrencies = allCurrencies.entries.where((entry) {
      final query = _searchQuery.toLowerCase();
      return entry.key.toLowerCase().contains(query) ||
          entry.value.name.toLowerCase().contains(query);
    }).toList();

    // Разделение на популярные и остальные
    final popularFiltered = filteredCurrencies
        .where((entry) => popularCurrencies.contains(entry.key))
        .toList();
    final otherFiltered = filteredCurrencies
        .where((entry) => !popularCurrencies.contains(entry.key))
        .toList();

    return DraggableScrollableSheet(
      initialChildSize: 0.9,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      expand: false,
      builder: (context, scrollController) {
        return Column(
          children: [
            // Заголовок и поиск
            Container(
              padding: const EdgeInsets.all(16),
              decoration: const BoxDecoration(
                color: AppTheme.backgroundHeader,
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
              ),
              child: Column(
                children: [
                  Container(
                    width: 40,
                    height: 4,
                    margin: const EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(
                      color: AppTheme.dividerBorder,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  TextField(
                    controller: _searchController,
                    style: const TextStyle(color: AppTheme.textPrimary),
                    decoration: InputDecoration(
                      hintText: l10n.searchCurrency,
                      hintStyle: const TextStyle(color: AppTheme.textSecondary),
                      prefixIcon: const Icon(
                        Icons.search,
                        color: AppTheme.textSecondary,
                      ),
                      filled: true,
                      fillColor: AppTheme.backgroundCard,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                    ),
                    onChanged: (value) {
                      setState(() {
                        _searchQuery = value;
                      });
                    },
                  ),
                ],
              ),
            ),
            
            // Список валют
            Expanded(
              child: ListView(
                controller: scrollController,
                padding: const EdgeInsets.all(16),
                children: [
                  if (popularFiltered.isNotEmpty) ...[
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Text(
                        l10n.popular,
                        style: TextStyle(
                          color: AppTheme.textSecondary,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    ...popularFiltered.map((entry) => _buildCurrencyItem(
                      context,
                      entry.key,
                      entry.value,
                      state.selectedCurrencies.contains(entry.key),
                    )),
                    const SizedBox(height: 16),
                  ],
                  if (otherFiltered.isNotEmpty) ...[
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Text(
                        l10n.allCurrencies,
                        style: TextStyle(
                          color: AppTheme.textSecondary,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    ...otherFiltered.map((entry) => _buildCurrencyItem(
                      context,
                      entry.key,
                      entry.value,
                      state.selectedCurrencies.contains(entry.key),
                    )),
                  ],
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildCurrencyItem(
    BuildContext context,
    String code,
    CurrencyInfo info,
    bool isSelected,
  ) {
    final l10n = AppLocalizations.of(context)!;
    return InkWell(
      onTap: () {
        if (isSelected) {
          // Можно удалить валюту
          if (ref.read(currencyProvider).selectedCurrencies.length > 1) {
            ref.read(currencyProvider.notifier).removeCurrency(code);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(l10n.currencyRemoved(code)),
                duration: const Duration(seconds: 1),
              ),
            );
          }
        } else {
          // Добавить валюту
          ref.read(currencyProvider.notifier).addCurrency(code);
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(l10n.currencyAdded(code)),
              duration: const Duration(seconds: 1),
            ),
          );
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        margin: const EdgeInsets.only(bottom: 8),
        decoration: BoxDecoration(
          color: AppTheme.backgroundCard,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            // Флаг
            ClipOval(
              child: CachedNetworkImage(
                imageUrl: 'https://flagcdn.com/w80/${CurrencyInfo.getCountryCode(code)}.png',
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
            
            // Информация
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    code,
                    style: const TextStyle(
                      color: AppTheme.textPrimary,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    info.name,
                    style: const TextStyle(
                      color: AppTheme.textSecondary,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            
            // Чекбокс
            Icon(
              isSelected ? Icons.check_circle : Icons.circle_outlined,
              color: isSelected ? AppTheme.accentPrimary : AppTheme.textSecondary,
            ),
          ],
        ),
      ),
    );
  }
}

