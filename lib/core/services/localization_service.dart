import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

final localizationServiceProvider = Provider<LocalizationService>((ref) {
  return LocalizationService();
});

class LocalizationService {
  final FlutterSecureStorage _storage = const FlutterSecureStorage();
  
  // RTL languages
  static const List<Locale> rtlLocales = [
    Locale('ar', 'SA'),
    Locale('he', 'IL'),
    Locale('fa', 'IR'),
    Locale('ur', 'PK'),
  ];

  // LTR languages
  static const List<Locale> ltrLocales = [
    Locale('en', 'US'),
    Locale('fr', 'FR'),
    Locale('es', 'ES'),
    Locale('de', 'DE'),
    Locale('it', 'IT'),
    Locale('pt', 'BR'),
    Locale('ru', 'RU'),
    Locale('ja', 'JP'),
    Locale('zh', 'CN'),
    Locale('ko', 'KR'),
  ];

  // Check if current locale is RTL
  bool isRTL(Locale locale) {
    return rtlLocales.any((rtlLocale) => 
        rtlLocale.languageCode == locale.languageCode);
  }

  // Check if current locale is LTR
  bool isLTR(Locale locale) {
    return !isRTL(locale);
  }

  // Get text direction for locale
  TextDirection getTextDirection(Locale locale) {
    return isRTL(locale) ? TextDirection.rtl : TextDirection.ltr;
  }

  // Get alignment for locale
  Alignment getAlignment(Locale locale) {
    return isRTL(locale) ? Alignment.centerRight : Alignment.centerLeft;
  }

  // Get cross axis alignment for locale
  CrossAxisAlignment getCrossAxisAlignment(Locale locale) {
    return isRTL(locale) ? CrossAxisAlignment.end : CrossAxisAlignment.start;
  }

  // Get text align for locale
  TextAlign getTextAlign(Locale locale) {
    return isRTL(locale) ? TextAlign.right : TextAlign.left;
  }

  // Get padding start for locale
  double getPaddingStart(Locale locale) {
    return isRTL(locale) ? 16.0 : 0.0;
  }

  // Get padding end for locale
  double getPaddingEnd(Locale locale) {
    return isRTL(locale) ? 0.0 : 16.0;
  }

  // Get margin start for locale
  double getMarginStart(Locale locale) {
    return isRTL(locale) ? 16.0 : 0.0;
  }

  // Get margin end for locale
  double getMarginEnd(Locale locale) {
    return isRTL(locale) ? 0.0 : 16.0;
  }

  // Get border radius for locale (for RTL flip)
  BorderRadius getBorderRadius(Locale locale, {
    double topLeft = 0.0,
    double topRight = 0.0,
    double bottomLeft = 0.0,
    double bottomRight = 0.0,
  }) {
    if (isRTL(locale)) {
      return BorderRadius.only(
        topLeft: Radius.circular(topRight),
        topRight: Radius.circular(topLeft),
        bottomLeft: Radius.circular(bottomRight),
        bottomRight: Radius.circular(bottomLeft),
      );
    } else {
      return BorderRadius.only(
        topLeft: Radius.circular(topLeft),
        topRight: Radius.circular(topRight),
        bottomLeft: Radius.circular(bottomLeft),
        bottomRight: Radius.circular(bottomRight),
      );
    }
  }

  // Get edge insets for locale
  EdgeInsets getEdgeInsets(Locale locale, {
    double left = 0.0,
    double right = 0.0,
    double top = 0.0,
    double bottom = 0.0,
  }) {
    if (isRTL(locale)) {
      return EdgeInsets.only(
        left: right,
        right: left,
        top: top,
        bottom: bottom,
      );
    } else {
      return EdgeInsets.only(
        left: left,
        right: right,
        top: top,
        bottom: bottom,
      );
    }
  }

  // Get symmetric edge insets for locale
  EdgeInsets getEdgeInsetsSymmetric(Locale locale, {
    double horizontal = 0.0,
    double vertical = 0.0,
  }) {
    return EdgeInsets.symmetric(
      horizontal: horizontal,
      vertical: vertical,
    );
  }

  // Get only edge insets for locale
  EdgeInsets getEdgeInsetsOnly(Locale locale, {
    double start = 0.0,
    double end = 0.0,
    double top = 0.0,
    double bottom = 0.0,
  }) {
    if (isRTL(locale)) {
      return EdgeInsets.only(
        left: end,
        right: start,
        top: top,
        bottom: bottom,
      );
    } else {
      return EdgeInsets.only(
        left: start,
        right: end,
        top: top,
        bottom: bottom,
      );
    }
  }

  // Save user's preferred language
  Future<void> saveLanguagePreference(String languageCode) async {
    await _storage.write(key: 'preferred_language', value: languageCode);
  }

  // Get user's preferred language
  Future<String?> getLanguagePreference() async {
    return await _storage.read(key: 'preferred_language');
  }

  // Change app language
  Future<void> changeLanguage(BuildContext context, String languageCode) async {
    final locale = Locale(languageCode);
    await context.setLocale(locale);
    await saveLanguagePreference(languageCode);
  }

  // Get current locale
  Locale getCurrentLocale(BuildContext context) {
    return context.locale;
  }

  // Get localized string with fallback
  String getLocalizedString(BuildContext context, String key, {String? fallback}) {
    try {
      final localized = key.tr();
      return localized != key ? localized : (fallback ?? key);
    } catch (e) {
      return fallback ?? key;
    }
  }

  // Format number for locale
  String formatNumber(Locale locale, num number) {
    final formatter = NumberFormat.decimalPattern(locale.languageCode);
    return formatter.format(number);
  }

  // Format currency for locale
  String formatCurrency(Locale locale, num amount, String currencyCode) {
    final formatter = NumberFormat.currency(
      locale: locale.languageCode,
      symbol: _getCurrencySymbol(currencyCode),
    );
    return formatter.format(amount);
  }

  // Format date for locale
  String formatDate(Locale locale, DateTime date, {String? pattern}) {
    if (pattern != null) {
      final formatter = DateFormat(pattern, locale.languageCode);
      return formatter.format(date);
    } else {
      final formatter = DateFormat.yMd(locale.languageCode);
      return formatter.format(date);
    }
  }

  // Format time for locale
  String formatTime(Locale locale, DateTime time) {
    final formatter = DateFormat.Hms(locale.languageCode);
    return formatter.format(time);
  }

  // Format date time for locale
  String formatDateTime(Locale locale, DateTime dateTime) {
    final formatter = DateFormat.yMd(locale.languageCode).add_Hms();
    return formatter.format(dateTime);
  }

  // Get currency symbol
  String _getCurrencySymbol(String currencyCode) {
    final symbols = {
      'USD': '\$',
      'EUR': '€',
      'GBP': '£',
      'JPY': '¥',
      'CNY': '¥',
      'SAR': '﷼',
      'AED': 'د.إ',
      'KWD': 'د.ك',
      'QAR': 'ر.ق',
      'BHD': 'د.ب',
      'OMR': 'ر.ع',
      'JOD': 'د.ا',
      'LBP': 'ل.ل',
      'EGP': 'ج.م',
      'MAD': 'د.م',
      'TND': 'د.ت',
      'LYD': 'د.ل',
      'SDD': 'د.س',
      'YER': 'ر.ي',
      'IQD': 'د.ع',
      'IRR': '﷼',
      'AFN': '؋',
      'PKR': '₨',
      'INR': '₹',
      'BDT': '৳',
      'LKR': 'රු',
      'NPR': 'रू',
      'BTN': 'Nu.',
      'MVR': 'Rf',
      'KGS': 'с',
      'TJS': 'с',
      'UZS': 'сўм',
      'KZT': '₸',
      'AZN': '₼',
      'GEL': '₾',
      'AMD': '֏',
      'RUB': '₽',
      'UAH': '₴',
      'BYN': 'Br',
      'MDL': 'L',
      'RON': 'lei',
      'BGN': 'лв',
      'HRK': 'kn',
      'RSD': 'дин',
      'BAM': 'KM',
      'MKD': 'ден',
      'ALL': 'L',
      'HUF': 'Ft',
      'CZK': 'Kč',
      'SKK': 'Sk',
      'PLN': 'zł',
      'SEK': 'kr',
      'NOK': 'kr',
      'DKK': 'kr',
      'ISK': 'kr',
      'CHF': 'Fr',
      'NOK': 'kr',
      'TRY': '₺',
      'CYP': '£',
      'MTL': '₤',
      'SIT': 'SIT',
      'EEK': 'kr',
      'LVL': 'Ls',
      'LTL': 'Lt',
      'ZAR': 'R',
      'NAD': 'N$',
      'BWP': 'P',
      'SZL': 'E',
      'LSL': 'L',
      'ZMW': 'ZK',
      'MWK': 'MK',
      'BWP': 'P',
      'SZL': 'E',
      'NAD': 'N$',
      'AOA': 'Kz',
      'XAF': 'FCFA',
      'XOF': 'CFA',
      'XPF': 'FCFP',
      'CDF': 'FC',
      'GNF': 'FG',
      'LRD': 'L$',
      'SLL': 'Le',
      'GHS': 'GH₵',
      'NGN': '₦',
      'XOF': 'CFA',
      'XAF': 'FCFA',
      'RWF': 'FRw',
      'BIF': 'FBu',
      'DJF': 'Fdj',
      'ERN': 'Nfk',
      'ETB': 'Br',
      'KES': 'KSh',
      'SOS': 'S',
      'TZS': 'TSh',
      'UGX': 'USh',
      'MGA': 'Ar',
      'SCR': '₨',
      'MUR': '₨',
      'CVE': '$',
      'GIP': '£',
      'FKP': '£',
      'SHP': '£',
      'XCD': '$',
      'BBD': '$',
      'BSD': '$',
      'BZD': '$',
      'CAD': '$',
      'KYD': '$',
      'CLP': '$',
      'COP': '$',
      'CRC': '₡',
      'CUP': '$',
      'DOP': '$',
      'GTQ': 'Q',
      'HNL': 'L',
      'HTG': 'G',
      'JMD': '$',
      'MXN': '$',
      'NIO': 'C$',
      'PAB': 'B/.',
      'PEN': 'S/',
      'UYU': '$',
      'VEF': 'Bs',
      'XCD': '$',
      'AUD': '$',
      'FJD': '$',
      'KID': '$',
      'NRL': '$',
      'NZD': '$',
      'PGK': 'K',
      'SBD': '$',
      'SLB': '$',
      'TOP': 'T$',
      'TVD': '$',
      'VUV': 'VT',
      'WST': 'WS$',
    };
    return symbols[currencyCode] ?? currencyCode;
  }

  // Get supported locales
  List<Locale> getSupportedLocales() {
    return [...rtlLocales, ...ltrLocales];
  }

  // Get locale display name
  String getLocaleDisplayName(Locale locale) {
    final names = {
      'en': 'English',
      'ar': 'العربية',
      'fr': 'Français',
      'es': 'Español',
      'de': 'Deutsch',
      'it': 'Italiano',
      'pt': 'Português',
      'ru': 'Русский',
      'ja': '日本語',
      'zh': '中文',
      'ko': '한국어',
      'he': 'עברית',
      'fa': 'فارسی',
      'ur': 'اردو',
    };
    return names[locale.languageCode] ?? locale.languageCode.toUpperCase();
  }

  // Check if locale is supported
  bool isLocaleSupported(Locale locale) {
    return getSupportedLocales().any((supportedLocale) =>
        supportedLocale.languageCode == locale.languageCode);
  }

  // Get default locale
  Locale getDefaultLocale() {
    return const Locale('en', 'US');
  }

  // Get system locale
  Locale getSystemLocale() {
    return EasyLocalization.of(PlatformDispatcher.instance.views.first)!.locale;
  }

  // Initialize localization
  Future<void> initializeLocalization(BuildContext context) async {
    final savedLanguage = await getLanguagePreference();
    if (savedLanguage != null) {
      final locale = Locale(savedLanguage);
      if (isLocaleSupported(locale)) {
        await context.setLocale(locale);
      }
    }
  }

  // Create localized widget builder
  Widget buildLocalized({
    required BuildContext context,
    required Widget Function(Locale locale) builder,
  }) {
    return Directionality(
      textDirection: getTextDirection(context.locale),
      child: builder(context.locale),
    );
  }

  // Create localized row
  Widget buildLocalizedRow({
    required BuildContext context,
    required List<Widget> children,
    MainAxisAlignment mainAxisAlignment = MainAxisAlignment.start,
    CrossAxisAlignment crossAxisAlignment = CrossAxisAlignment.center,
    MainAxisSize mainAxisSize = MainAxisSize.max,
  }) {
    return Row(
      textDirection: getTextDirection(context.locale),
      mainAxisAlignment: mainAxisAlignment,
      crossAxisAlignment: crossAxisAlignment,
      mainAxisSize: mainAxisSize,
      children: children,
    );
  }

  // Create localized column
  Widget buildLocalizedColumn({
    required BuildContext context,
    required List<Widget> children,
    MainAxisAlignment mainAxisAlignment = MainAxisAlignment.start,
    CrossAxisAlignment crossAxisAlignment = CrossAxisAlignment.center,
    MainAxisSize mainAxisSize = MainAxisSize.max,
  }) {
    return Column(
      textDirection: getTextDirection(context.locale),
      mainAxisAlignment: mainAxisAlignment,
      crossAxisAlignment: crossAxisAlignment,
      mainAxisSize: mainAxisSize,
      children: children,
    );
  }
}
