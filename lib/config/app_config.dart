import 'package:flutter/material.dart';

/// Central configuration for the Zolotoy Tour application.
/// Modify these values as needed to adapt the app for different environments or branding.
class AppConfig {
  AppConfig._();

  /// The human-readable application name.
  static const String appName = 'Zolotoy Tour';

  /// Primary live website URL to be loaded in the WebView.
  static const String initialUrl = 'https://www.zolotoytouruz.uz/';

  /// Navigation URLs for bottom navigation bar tabs.
  static const String homeUrl = 'https://www.zolotoytouruz.uz/';
  static const String toursUrl = 'https://www.zolotoytouruz.uz/podbor-tura';
  static const String hotToursUrl = 'https://www.zolotoytouruz.uz/goryashchie-tury';
  static const String servicesUrl = 'https://www.zolotoytouruz.uz/nashi-uslugi';
  static const String contactsUrl = 'https://www.zolotoytouruz.uz/kontakty';

  /// Allowed hostnames for internal navigation inside the WebView.
  /// Any navigation within these hosts will stay inside the WebView.
  static const List<String> internalHosts = <String>[
    'www.zolotoytouruz.uz',
    'zolotoytouruz.uz',
  ];

  /// Brand gold accent color (matching website primary action buttons).
  static const Color primaryColor = Color(0xFFD2A258);

  /// Brand dark header/footer background color.
  static const Color darkBackgroundColor = Color(0xFF1E1E1E);

  /// Light theme background color.
  static const Color lightBackgroundColor = Color(0xFFF8F9FA);

  /// Brand secondary text color.
  static const Color textMutedColor = Color(0xFF777777);

  /// Contact phone number displayed in error states or about dialogs.
  static const String contactPhone = '+998770434444';

  /// Contact email address.
  static const String contactEmail = 'zolotoytouruz@gmail.com';

  /// Official Telegram channel / username for direct messaging.
  static const String telegramUsername = 'zolotoy_tour';
  static const String telegramUrl = 'https://t.me/zolotoy_tour';

  /// Physical office address in Namangan, Uzbekistan.
  static const String officeAddress = 'г. Наманган, МСГ Оби Хаёт, ул. Хамрох, 5';

  /// Customer service working hours.
  static const String workingHours = 'Пн–Сб: 09:00 – 19:00';

  /// Network loading timeout for page requests.
  static const Duration pageTimeout = Duration(seconds: 25);
}
