#!/bin/bash
# Скрипт для просмотра логов приложения CurrencyPro

echo "=== Логи приложения CurrencyPro ==="
echo ""
echo "Очищаем старые логи..."
adb logcat -c

echo ""
echo "Запускаем просмотр логов Flutter приложения..."
echo "Нажмите Ctrl+C для остановки"
echo ""

# Показываем логи Flutter с нашими метками
adb logcat | grep -E "flutter|CURRENCY|CONVERSION|FOCUS|UPDATE|RATES|HIVE|API|AMOUNT|INIT|RECALC|APP|CURRENCY_MANAGEMENT" --color=always





