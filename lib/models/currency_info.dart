class CurrencyInfo {
  final String code;
  final String name;
  final String symbol;
  final String countryCode; // Код страны для флага

  CurrencyInfo({
    required this.code,
    required this.name,
    required this.symbol,
    required this.countryCode,
  });
  
  // Маппинг валют на коды стран для флагов
  static String getCountryCode(String currencyCode) {
    return _currencyToCountryMap[currencyCode] ?? currencyCode.substring(0, 2).toLowerCase();
  }
  
  static final Map<String, String> _currencyToCountryMap = {
    'USD': 'us', // США
    'EUR': 'eu', // Европейский союз
    'GBP': 'gb', // Великобритания
    'JPY': 'jp', // Япония
    'CNY': 'cn', // Китай
    'AUD': 'au', // Австралия
    'CAD': 'ca', // Канада
    'CHF': 'ch', // Швейцария
    'RUB': 'ru', // Россия
    'KZT': 'kz', // Казахстан
    'INR': 'in', // Индия
    'BRL': 'br', // Бразилия
    'ZAR': 'za', // Южная Африка
    'MXN': 'mx', // Мексика
    'SGD': 'sg', // Сингапур
    'HKD': 'hk', // Гонконг
    'NOK': 'no', // Норвегия
    'SEK': 'se', // Швеция
    'TRY': 'tr', // Турция
    'KRW': 'kr', // Южная Корея
    'NZD': 'nz', // Новая Зеландия
    'PLN': 'pl', // Польша
    'THB': 'th', // Таиланд
    'IDR': 'id', // Индонезия
    'MYR': 'my', // Малайзия
    'PHP': 'ph', // Филиппины
    'CZK': 'cz', // Чехия
    'DKK': 'dk', // Дания
    'HUF': 'hu', // Венгрия
    'ILS': 'il', // Израиль
    'CLP': 'cl', // Чили
    'PKR': 'pk', // Пакистан
    'BGN': 'bg', // Болгария
    'RON': 'ro', // Румыния
    'AED': 'ae', // ОАЭ
    'SAR': 'sa', // Саудовская Аравия
  };

  static Map<String, CurrencyInfo> get allCurrencies => {
    'USD': CurrencyInfo(code: 'USD', name: 'US Dollar', symbol: '\$', countryCode: 'us'),
    'EUR': CurrencyInfo(code: 'EUR', name: 'Euro', symbol: '€', countryCode: 'eu'),
    'GBP': CurrencyInfo(code: 'GBP', name: 'British Pound', symbol: '£', countryCode: 'gb'),
    'JPY': CurrencyInfo(code: 'JPY', name: 'Japanese Yen', symbol: '¥', countryCode: 'jp'),
    'CNY': CurrencyInfo(code: 'CNY', name: 'Chinese Yuan', symbol: '¥', countryCode: 'cn'),
    'AUD': CurrencyInfo(code: 'AUD', name: 'Australian Dollar', symbol: 'A\$', countryCode: 'au'),
    'CAD': CurrencyInfo(code: 'CAD', name: 'Canadian Dollar', symbol: 'C\$', countryCode: 'ca'),
    'CHF': CurrencyInfo(code: 'CHF', name: 'Swiss Franc', symbol: 'Fr', countryCode: 'ch'),
    'RUB': CurrencyInfo(code: 'RUB', name: 'Russian Ruble', symbol: '₽', countryCode: 'ru'),
    'KZT': CurrencyInfo(code: 'KZT', name: 'Kazakhstani Tenge', symbol: '₸', countryCode: 'kz'),
    'INR': CurrencyInfo(code: 'INR', name: 'Indian Rupee', symbol: '₹', countryCode: 'in'),
    'BRL': CurrencyInfo(code: 'BRL', name: 'Brazilian Real', symbol: 'R\$', countryCode: 'br'),
    'ZAR': CurrencyInfo(code: 'ZAR', name: 'South African Rand', symbol: 'R', countryCode: 'za'),
    'MXN': CurrencyInfo(code: 'MXN', name: 'Mexican Peso', symbol: '\$', countryCode: 'mx'),
    'SGD': CurrencyInfo(code: 'SGD', name: 'Singapore Dollar', symbol: 'S\$', countryCode: 'sg'),
    'HKD': CurrencyInfo(code: 'HKD', name: 'Hong Kong Dollar', symbol: 'HK\$', countryCode: 'hk'),
    'NOK': CurrencyInfo(code: 'NOK', name: 'Norwegian Krone', symbol: 'kr', countryCode: 'no'),
    'SEK': CurrencyInfo(code: 'SEK', name: 'Swedish Krona', symbol: 'kr', countryCode: 'se'),
    'TRY': CurrencyInfo(code: 'TRY', name: 'Turkish Lira', symbol: '₺', countryCode: 'tr'),
    'KRW': CurrencyInfo(code: 'KRW', name: 'South Korean Won', symbol: '₩', countryCode: 'kr'),
    'NZD': CurrencyInfo(code: 'NZD', name: 'New Zealand Dollar', symbol: 'NZ\$', countryCode: 'nz'),
    'PLN': CurrencyInfo(code: 'PLN', name: 'Polish Zloty', symbol: 'zł', countryCode: 'pl'),
    'THB': CurrencyInfo(code: 'THB', name: 'Thai Baht', symbol: '฿', countryCode: 'th'),
    'IDR': CurrencyInfo(code: 'IDR', name: 'Indonesian Rupiah', symbol: 'Rp', countryCode: 'id'),
    'MYR': CurrencyInfo(code: 'MYR', name: 'Malaysian Ringgit', symbol: 'RM', countryCode: 'my'),
    'PHP': CurrencyInfo(code: 'PHP', name: 'Philippine Peso', symbol: '₱', countryCode: 'ph'),
    'CZK': CurrencyInfo(code: 'CZK', name: 'Czech Koruna', symbol: 'Kč', countryCode: 'cz'),
    'DKK': CurrencyInfo(code: 'DKK', name: 'Danish Krone', symbol: 'kr', countryCode: 'dk'),
    'HUF': CurrencyInfo(code: 'HUF', name: 'Hungarian Forint', symbol: 'Ft', countryCode: 'hu'),
    'ILS': CurrencyInfo(code: 'ILS', name: 'Israeli Shekel', symbol: '₪', countryCode: 'il'),
    'CLP': CurrencyInfo(code: 'CLP', name: 'Chilean Peso', symbol: '\$', countryCode: 'cl'),
    'PKR': CurrencyInfo(code: 'PKR', name: 'Pakistani Rupee', symbol: 'Rs', countryCode: 'pk'),
    'BGN': CurrencyInfo(code: 'BGN', name: 'Bulgarian Lev', symbol: 'лв', countryCode: 'bg'),
    'RON': CurrencyInfo(code: 'RON', name: 'Romanian Leu', symbol: 'lei', countryCode: 'ro'),
    'AED': CurrencyInfo(code: 'AED', name: 'UAE Dirham', symbol: 'د.إ', countryCode: 'ae'),
    'SAR': CurrencyInfo(code: 'SAR', name: 'Saudi Riyal', symbol: 'ر.س', countryCode: 'sa'),
  };

  static List<String> get popularCurrencies => [
    'USD', 'EUR', 'GBP', 'JPY', 'CNY', 'AUD', 'CAD', 'CHF', 'RUB', 'KZT'
  ];
}

