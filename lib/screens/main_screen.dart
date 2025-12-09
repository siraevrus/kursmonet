import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:currency_pro/l10n/app_localizations.dart';
import '../providers/currency_provider.dart';
import '../widgets/currency_card.dart';
import '../widgets/add_currency_sheet.dart';
import '../theme/app_theme.dart';

class MainScreen extends ConsumerWidget {
  const MainScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(currencyProvider);
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/earth.png'),
            fit: BoxFit.cover,
            opacity: 0.15,
          ),
        ),
        child: Scaffold(
          backgroundColor: Colors.transparent,
          appBar: AppBar(
            backgroundColor: AppTheme.backgroundHeader.withValues(alpha: 0.9),
        title: Text(l10n.appTitle),
        actions: [
          if (state.lastUpdated != null)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Center(
                child: Text(
                  _formatLastUpdated(context, state.lastUpdated!),
                  style: const TextStyle(
                    color: AppTheme.textSecondary,
                    fontSize: 12,
                  ),
                ),
              ),
            ),
          IconButton(
            icon: state.isLoading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(AppTheme.textPrimary),
                    ),
                  )
                : const Icon(Icons.refresh),
            onPressed: state.isLoading
                ? null
                : () {
                    ref.read(currencyProvider.notifier).refreshRates();
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(l10n.updateRates),
                        duration: const Duration(seconds: 1),
                      ),
                    );
                  },
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: state.selectedCurrencies.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          l10n.addCurrencies,
                          style: const TextStyle(color: AppTheme.textSecondary),
                        ),
                        const SizedBox(height: 24),
                        _buildAddButton(context),
                      ],
                    ),
                  )
                : Column(
                    children: [
                      // Время обновления над первой карточкой
                      if (state.lastUpdated != null)
                        Padding(
                          padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
                          child: Row(
                            children: [
                              Icon(
                                Icons.update,
                                size: 14,
                                color: AppTheme.textSecondary,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                l10n.updated(_formatLastUpdated(context, state.lastUpdated!)),
                                style: const TextStyle(
                                  color: AppTheme.textSecondary,
                                  fontSize: 12,
                                  fontWeight: FontWeight.normal,
                                ),
                              ),
                            ],
                          ),
                        ),
                      // Список валют
                      Expanded(
                        child: ReorderableListView.builder(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          itemCount: state.selectedCurrencies.length,
                          onReorder: (oldIndex, newIndex) {
                            ref.read(currencyProvider.notifier).reorderCurrencies(oldIndex, newIndex);
                          },
                          itemBuilder: (context, index) {
                            final currencyCode = state.selectedCurrencies[index];
                            final isBase = currencyCode == state.baseCurrency;

                            return Dismissible(
                              key: Key(currencyCode),
                              direction: DismissDirection.endToStart,
                              background: Container(
                                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                padding: const EdgeInsets.only(right: 20),
                                decoration: BoxDecoration(
                                  color: AppTheme.deleteButton,
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                alignment: Alignment.centerRight,
                                child: const Icon(
                                  Icons.delete,
                                  color: AppTheme.textPrimary,
                                ),
                              ),
                              onDismissed: (direction) {
                                ref.read(currencyProvider.notifier).removeCurrency(currencyCode);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(l10n.currencyRemoved(currencyCode)),
                                    duration: const Duration(seconds: 2),
                                  ),
                                );
                              },
                              child: CurrencyCard(
                                key: Key(currencyCode),
                                currencyCode: currencyCode,
                                isBaseCurrency: isBase,
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
          ),
          // Кнопка добавления всегда внизу
          Padding(
            padding: const EdgeInsets.all(16),
            child: _buildAddButton(context),
          ),
        ],
      ),
        ),
      ),
    );
  }

  Widget _buildAddButton(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return GestureDetector(
      onTap: () {
        showModalBottomSheet(
          context: context,
          backgroundColor: AppTheme.backgroundHeader,
          isScrollControlled: true,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          builder: (context) => const AddCurrencySheet(),
        );
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: AppTheme.backgroundCard,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: AppTheme.dividerBorder,
            width: 1,
            style: BorderStyle.solid,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.add,
              color: AppTheme.textSecondary,
            ),
            const SizedBox(width: 8),
            Text(
              l10n.addCurrency,
              style: TextStyle(
                color: AppTheme.textSecondary,
                fontSize: 16,
                fontWeight: FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatLastUpdated(BuildContext context, DateTime dateTime) {
    final l10n = AppLocalizations.of(context)!;
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inMinutes < 1) {
      return l10n.justNow;
    } else if (difference.inHours < 1) {
      return l10n.minutesAgo(difference.inMinutes);
    } else if (difference.inDays < 1) {
      return l10n.hoursAgo(difference.inHours);
    } else {
      return DateFormat('dd.MM.yyyy HH:mm').format(dateTime);
    }
  }
}

