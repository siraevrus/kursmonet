#!/bin/bash
# Скрипт для проверки использования нового API

echo "=== Проверка использования нового API ==="
echo ""

# Цвета для вывода
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo "1. Проверка кода на наличие старого API..."
if grep -r "fxratesapi" lib/ 2>/dev/null; then
    echo -e "${RED}❌ Найден старый API в коде!${NC}"
else
    echo -e "${GREEN}✅ Старый API не найден в коде${NC}"
fi

echo ""
echo "2. Проверка использования нового API в коде..."
if grep -r "conversor.onza.me" lib/ 2>/dev/null; then
    echo -e "${GREEN}✅ Новый API найден в коде${NC}"
    echo "URL:"
    grep -r "conversor.onza.me" lib/ | head -3
else
    echo -e "${RED}❌ Новый API не найден в коде!${NC}"
fi

echo ""
echo "3. Проверка доступности нового API..."
NEW_API_URL="https://conversor.onza.me/api/rates?base=USD"
if curl -s -f "$NEW_API_URL" > /dev/null 2>&1; then
    echo -e "${GREEN}✅ Новый API доступен${NC}"
    echo "Тестовый запрос:"
    curl -s "$NEW_API_URL" | head -c 200
    echo "..."
else
    echo -e "${RED}❌ Новый API недоступен!${NC}"
fi

echo ""
echo "4. Проверка формата ответа API..."
RESPONSE=$(curl -s "$NEW_API_URL")
if echo "$RESPONSE" | grep -q '"success"'; then
    echo -e "${GREEN}✅ API возвращает правильный формат (с полем success)${NC}"
else
    echo -e "${YELLOW}⚠️  API не возвращает поле success${NC}"
fi

if echo "$RESPONSE" | grep -q '"rates"'; then
    echo -e "${GREEN}✅ API возвращает поле rates${NC}"
else
    echo -e "${RED}❌ API не возвращает поле rates!${NC}"
fi

echo ""
echo "5. Для проверки логов приложения запустите:"
echo "   ./GET_APP_LOGS.sh"
echo ""
echo "   Или:"
echo "   flutter run"
echo ""
echo "   Ищите в логах:"
echo "   📡 [API] Запрос курсов валют: https://conversor.onza.me/api/rates"
echo ""





