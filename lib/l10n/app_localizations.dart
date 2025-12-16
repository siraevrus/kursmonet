import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_ru.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
      : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('ru')
  ];

  /// No description provided for @appTitle.
  ///
  /// In ru, this message translates to:
  /// **'Conversor'**
  String get appTitle;

  /// No description provided for @updateRates.
  ///
  /// In ru, this message translates to:
  /// **'Обновление курсов...'**
  String get updateRates;

  /// No description provided for @addCurrencies.
  ///
  /// In ru, this message translates to:
  /// **'Добавьте валюты для конвертации'**
  String get addCurrencies;

  /// No description provided for @addCurrency.
  ///
  /// In ru, this message translates to:
  /// **'Добавить валюту'**
  String get addCurrency;

  /// No description provided for @currencyRemoved.
  ///
  /// In ru, this message translates to:
  /// **'{currencyCode} удалена'**
  String currencyRemoved(String currencyCode);

  /// No description provided for @currencyAdded.
  ///
  /// In ru, this message translates to:
  /// **'{currencyCode} добавлена'**
  String currencyAdded(String currencyCode);

  /// No description provided for @updated.
  ///
  /// In ru, this message translates to:
  /// **'Обновлено: {time}'**
  String updated(String time);

  /// No description provided for @justNow.
  ///
  /// In ru, this message translates to:
  /// **'Только что'**
  String get justNow;

  /// No description provided for @minutesAgo.
  ///
  /// In ru, this message translates to:
  /// **'{count} мин назад'**
  String minutesAgo(int count);

  /// No description provided for @hoursAgo.
  ///
  /// In ru, this message translates to:
  /// **'{count} ч назад'**
  String hoursAgo(int count);

  /// No description provided for @rateUnavailable.
  ///
  /// In ru, this message translates to:
  /// **'Курс недоступен'**
  String get rateUnavailable;

  /// No description provided for @exchangeRate.
  ///
  /// In ru, this message translates to:
  /// **'1 {baseCurrency} / {rate} {targetCurrency}'**
  String exchangeRate(String baseCurrency, String rate, String targetCurrency);

  /// No description provided for @searchCurrency.
  ///
  /// In ru, this message translates to:
  /// **'Поиск валюты...'**
  String get searchCurrency;

  /// No description provided for @popular.
  ///
  /// In ru, this message translates to:
  /// **'Популярные'**
  String get popular;

  /// No description provided for @allCurrencies.
  ///
  /// In ru, this message translates to:
  /// **'Все валюты'**
  String get allCurrencies;

  /// No description provided for @offlineMode.
  ///
  /// In ru, this message translates to:
  /// **'Режим оффлайн. Используются сохраненные данные.'**
  String get offlineMode;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'ru'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'ru':
      return AppLocalizationsRu();
  }

  throw FlutterError(
      'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}
