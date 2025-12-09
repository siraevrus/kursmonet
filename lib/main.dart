import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:currency_pro/l10n/app_localizations.dart';
import 'screens/main_screen.dart';
import 'services/hive_service.dart';
import 'theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Инициализация Hive
  await Hive.initFlutter();
  await HiveService.init();
  
  runApp(
    const ProviderScope(
      child: CurrencyProApp(),
    ),
  );
}

class CurrencyProApp extends StatelessWidget {
  const CurrencyProApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'CurrencyPro',
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

