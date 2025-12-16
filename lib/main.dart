import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:currency_pro/l10n/app_localizations.dart';
import 'screens/main_screen.dart';
import 'services/hive_service.dart';
import 'services/device_service.dart';
import 'services/currency_api_service.dart';
import 'theme/app_theme.dart';
import 'utils/app_logger.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  AppLogger.i('🚀 [APP] Запуск приложения Conversor...');
  
  // Инициализация Hive
  await HiveService.init();
  
  // Регистрация устройства при первом запуске
  final isDeviceRegistered = DeviceService.isDeviceRegistered();
  if (!isDeviceRegistered) {
    AppLogger.i('📱 [APP] Первый запуск - регистрация устройства...');
    try {
      await CurrencyApiService.registerDevice();
    } catch (e) {
      AppLogger.w('⚠️ [APP] Не удалось зарегистрировать устройство: $e');
      AppLogger.d('   Продолжаем работу без регистрации');
    }
  } else {
    AppLogger.d('📱 [APP] Устройство уже зарегистрировано');
  }
  
  AppLogger.i('✅ [APP] Приложение готово к запуску');
  
  runApp(
    const ProviderScope(
      child: ConversorApp(),
    ),
  );
}

class ConversorApp extends StatelessWidget {
  const ConversorApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Conversor',
      theme: AppTheme.darkTheme,
      debugShowCheckedModeBanner: false,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('en', ''),
        Locale('ru', ''),
        Locale('de', ''),
        Locale('fr', ''),
        Locale('es', ''),
        Locale('it', ''),
        Locale('pt', ''),
        Locale('zh', ''),
        Locale('ja', ''),
        Locale('ko', ''),
        Locale('ar', ''),
        Locale('tr', ''),
        Locale('pl', ''),
        Locale('uk', ''),
        Locale('cs', ''),
        Locale('nl', ''),
        Locale('sv', ''),
        Locale('no', ''),
        Locale('da', ''),
        Locale('fi', ''),
        Locale('el', ''),
        Locale('he', ''),
        Locale('hi', ''),
        Locale('th', ''),
        Locale('vi', ''),
        Locale('id', ''),
        Locale('ms', ''),
        Locale('tl', ''),
      ],
      home: const MainScreen(),
    );
  }
}

