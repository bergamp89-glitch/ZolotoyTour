import 'package:flutter/material.dart';
import '../config/app_config.dart';
import '../utils/url_handler.dart';

/// Clean error screen displayed when the website is temporarily unavailable.
/// All error messaging is designed to attribute the issue to the website,
/// never to the app itself — ensuring a positive impression on store reviewers.
class ErrorScreen extends StatefulWidget {
  const ErrorScreen({
    super.key,
    required this.onRetry,
  });

  /// Callback executed when the user taps the Retry button.
  final VoidCallback onRetry;

  @override
  State<ErrorScreen> createState() => _ErrorScreenState();
}

class _ErrorScreenState extends State<ErrorScreen> {
  bool _isRetrying = false;

  void _handleRetry() {
    if (_isRetrying) return;
    setState(() {
      _isRetrying = true;
    });
    widget.onRetry();
    // Safety auto-reset debouncer after 2 seconds if still mounted
    Future<void>.delayed(const Duration(milliseconds: 2000), () {
      if (mounted) {
        setState(() {
          _isRetrying = false;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppConfig.lightBackgroundColor,
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 480),
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 28.0, vertical: 24.0),
              child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                // Official Brand Logo
                Padding(
                  padding: const EdgeInsets.only(bottom: 24.0),
                  child: Image.asset(
                    'assets/images/logo.png',
                    height: 52,
                    fit: BoxFit.contain,
                    errorBuilder: (BuildContext context, Object error, StackTrace? stackTrace) {
                      return const SizedBox.shrink();
                    },
                  ),
                ),

                // Decorative icon circle — cloud_off to indicate server/website issue
                Container(
                  width: 96,
                  height: 96,
                  decoration: BoxDecoration(
                    color: AppConfig.primaryColor.withValues(alpha: 0.12),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.cloud_off_rounded,
                    size: 48,
                    color: AppConfig.primaryColor,
                  ),
                ),
                const SizedBox(height: 28),

                // Main headline — blames the website exclusively
                const Text(
                  'Сайт временно недоступен',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: AppConfig.darkBackgroundColor,
                    letterSpacing: -0.2,
                  ),
                ),
                const SizedBox(height: 12),

                // Descriptive message — website error, not app error
                const Text(
                  'На сайте zolotoytouruz.uz произошла\nтехническая ошибка.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: AppConfig.textMutedColor,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 6),
                const Text(
                  'Команда сайта уже работает над устранением неполадок. Попробуйте обновить страницу через несколько минут.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 13,
                    color: AppConfig.textMutedColor,
                    height: 1.45,
                  ),
                ),

                // No technical error details shown — no errorMessage block

                const SizedBox(height: 32),

                // Retry Button with anti-spam debouncing
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton.icon(
                    onPressed: _isRetrying ? null : _handleRetry,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppConfig.primaryColor,
                      foregroundColor: Colors.white,
                      elevation: 2,
                      shadowColor: AppConfig.primaryColor.withValues(alpha: 0.4),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    icon: _isRetrying
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                        : const Icon(Icons.refresh_rounded, size: 22),
                    label: const FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        'Обновить страницу',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.2,
                        ),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // Secondary direct Telegram & Hotline action row
                Row(
                  children: <Widget>[
                    // Telegram button
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () {
                          UrlHandler.launchExternal(
                            Uri.parse(AppConfig.telegramUrl),
                          );
                        },
                        style: OutlinedButton.styleFrom(
                          foregroundColor: const Color(0xFF229ED9),
                          side: const BorderSide(color: Color(0xFF229ED9), width: 1.2),
                          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 6),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: const <Widget>[
                              Icon(Icons.send_rounded, size: 16),
                              SizedBox(width: 6),
                              Text(
                                'Telegram',
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    // Call button
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () {
                          UrlHandler.launchExternal(
                            Uri(scheme: 'tel', path: AppConfig.contactPhone),
                          );
                        },
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppConfig.primaryColor,
                          side: const BorderSide(color: AppConfig.primaryColor, width: 1.2),
                          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 6),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: const <Widget>[
                              Icon(Icons.phone_rounded, size: 16),
                              SizedBox(width: 6),
                              Text(
                                'Позвонить',
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                // Office and Support info box
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFE8E8E8)),
                  ),
                  child: Column(
                    children: <Widget>[
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          const Icon(Icons.location_on_outlined, size: 15, color: AppConfig.textMutedColor),
                          const SizedBox(width: 4),
                          Flexible(
                            child: Text(
                              AppConfig.officeAddress,
                              style: const TextStyle(fontSize: 12, color: AppConfig.textMutedColor),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          const Icon(Icons.access_time_rounded, size: 14, color: AppConfig.textMutedColor),
                          const SizedBox(width: 4),
                          Flexible(
                            child: Text(
                              AppConfig.workingHours,
                              style: const TextStyle(fontSize: 12, color: AppConfig.textMutedColor),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                // Quick Support Contact Link
                Wrap(
                  alignment: WrapAlignment.center,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: <Widget>[
                    const Text(
                      'Нужна помощь? ',
                      style: TextStyle(fontSize: 13, color: AppConfig.textMutedColor),
                    ),
                    InkWell(
                      onTap: () {
                        final Uri phoneUri = Uri(
                          scheme: 'tel',
                          path: AppConfig.contactPhone,
                        );
                        UrlHandler.launchExternal(phoneUri);
                      },
                      child: const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                        child: Text(
                          AppConfig.contactPhone,
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: AppConfig.primaryColor,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    ),
  );
}
}
