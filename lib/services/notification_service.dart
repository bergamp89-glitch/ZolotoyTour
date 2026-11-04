import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import '../config/app_config.dart';

/// Central service managing local notifications and weekly automated travel reminders.
/// Follows modern 2026 Android 13+ (POST_NOTIFICATIONS) and iOS standards.
class NotificationService {
  NotificationService._internal();

  /// Singleton instance
  static final NotificationService instance = NotificationService._internal();

  final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();

  bool _isInitialized = false;

  /// Notification channel details for Android
  static const String channelId = 'weekly_travel_deals';
  static const String channelName = 'Горящие туры и спецпредложения';
  static const String channelDescription =
      'Еженедельные уведомления о выгодных турах, скидках и акциях от Zolotoy Tour';

  /// Standard weekly notification ID
  static const int weeklyNotificationId = 777;

  /// Default weekly notification texts in Russian as requested
  static const String weeklyTitle = '✈️ Горящие туры недели от Zolotoy Tour!';
  static const String weeklyBody =
      'Новые спецпредложения на отдых в Турции, ОАЭ и Египте по суперценам. Откройте приложение, чтобы выбрать тур!';

  /// Initializes the local notification plugin and ensures weekly scheduling is active.
  Future<void> initialize({
    void Function(NotificationResponse)? onNotificationTapped,
  }) async {
    if (_isInitialized) return;

    tz.initializeTimeZones();

    // Local notifications are exclusively targeted for Android and iOS devices
    if (kIsWeb ||
        (defaultTargetPlatform != TargetPlatform.android &&
            defaultTargetPlatform != TargetPlatform.iOS)) {
      _isInitialized = true;
      return;
    }

    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings('@mipmap/launcher_icon');

    const DarwinInitializationSettings iosSettings =
        DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );

    const InitializationSettings initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    try {
      await _localNotifications.initialize(
        settings: initSettings,
        onDidReceiveNotificationResponse: onNotificationTapped,
      );
      _isInitialized = true;
    } catch (e) {
      // In test runner or non-host environments where platform channel is mocked or absent
      _isInitialized = true;
      if (!e.toString().contains('LateInitializationError')) {
        debugPrint('NotificationService initialization note: $e');
      }
    }
  }

  /// Prompts the user for notification permissions on Android 13+ (API 33+) and iOS.
  /// Automatically schedules the weekly notification once granted.
  Future<bool> requestPermission() async {
    if (kIsWeb) return false;

    bool granted = false;

    try {
      if (defaultTargetPlatform == TargetPlatform.android) {
        final AndroidFlutterLocalNotificationsPlugin? androidImplementation =
            _localNotifications.resolvePlatformSpecificImplementation<
                AndroidFlutterLocalNotificationsPlugin>();

        if (androidImplementation != null) {
          final bool? androidGranted =
              await androidImplementation.requestNotificationsPermission();
          granted = androidGranted ?? false;
        }
      } else if (defaultTargetPlatform == TargetPlatform.iOS) {
        final IOSFlutterLocalNotificationsPlugin? iosImplementation =
            _localNotifications.resolvePlatformSpecificImplementation<
                IOSFlutterLocalNotificationsPlugin>();

        if (iosImplementation != null) {
          final bool? iosGranted = await iosImplementation.requestPermissions(
            alert: true,
            badge: true,
            sound: true,
          );
          granted = iosGranted ?? false;
        }
      }

      // Schedule the automated weekly notification only if permission was granted
      if (granted) {
        await scheduleWeeklyNotification();
      }
    } catch (e) {
      debugPrint('Error requesting notification permission: $e');
    }

    return granted;
  }

  /// Calculates the next occurrence of Friday at exactly 08:00 AM local time.
  static tz.TZDateTime nextInstanceOfFridayEightAM() {
    try {
      tz.local;
    } catch (_) {
      tz.initializeTimeZones();
    }
    final tz.TZDateTime now = tz.TZDateTime.now(tz.local);
    tz.TZDateTime scheduledDate = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      8,
      0,
    );
    while (scheduledDate.isBefore(now) || scheduledDate.weekday != DateTime.friday) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }
    return scheduledDate;
  }

  /// Automatically schedules a weekly travel deals notification in Russian every Friday at 08:00 AM.
  Future<void> scheduleWeeklyNotification() async {
    if (kIsWeb) return;

    try {
      const AndroidNotificationDetails androidDetails =
          AndroidNotificationDetails(
        channelId,
        channelName,
        channelDescription: channelDescription,
        importance: Importance.high,
        priority: Priority.high,
        color: AppConfig.primaryColor,
        icon: '@mipmap/launcher_icon',
        styleInformation: BigTextStyleInformation(
          weeklyBody,
          contentTitle: weeklyTitle,
        ),
      );

      const DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      );

      const NotificationDetails platformDetails = NotificationDetails(
        android: androidDetails,
        iOS: iosDetails,
      );

      await _localNotifications.zonedSchedule(
        id: weeklyNotificationId,
        title: weeklyTitle,
        body: weeklyBody,
        scheduledDate: nextInstanceOfFridayEightAM(),
        notificationDetails: platformDetails,
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
        matchDateTimeComponents: DateTimeComponents.dayOfWeekAndTime,
      );

      debugPrint('Weekly Friday 08:00 AM travel notification scheduled successfully');
    } catch (e) {
      debugPrint('Error scheduling weekly notification: $e');
    }
  }
}
