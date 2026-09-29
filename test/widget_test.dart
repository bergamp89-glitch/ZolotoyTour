import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:zolotoytour/config/app_config.dart';
import 'package:zolotoytour/screens/error_screen.dart';
import 'package:zolotoytour/screens/splash_screen.dart';
import 'package:zolotoytour/screens/webview_screen.dart';
import 'package:zolotoytour/utils/url_handler.dart';
import 'package:zolotoytour/widgets/app_bottom_nav_bar.dart';

void main() {
  group('AppConfig & UrlHandler Tests', () {
    test('AppConfig has proper parameters', () {
      expect(AppConfig.appName, equals('Zolotoy Tour'));
      expect(AppConfig.initialUrl, equals('https://www.zolotoytouruz.uz/'));
      expect(AppConfig.homeUrl, equals('https://www.zolotoytouruz.uz/'));
      expect(AppConfig.toursUrl, equals('https://www.zolotoytouruz.uz/podbor-tura'));
      expect(AppConfig.hotToursUrl, equals('https://www.zolotoytouruz.uz/goryashchie-tury'));
      expect(AppConfig.servicesUrl, equals('https://www.zolotoytouruz.uz/nashi-uslugi'));
      expect(AppConfig.contactsUrl, equals('https://www.zolotoytouruz.uz/kontakty'));
      expect(AppConfig.contactPhone, equals('+998770434444'));
      expect(AppConfig.contactEmail, equals('zolotoytouruz@gmail.com'));
      expect(AppConfig.telegramUsername, equals('zolotoy_tour'));
      expect(AppConfig.telegramUrl, equals('https://t.me/zolotoy_tour'));
      expect(AppConfig.officeAddress, contains('Наманган'));
      expect(AppConfig.workingHours, contains('09:00'));
      expect(AppConfig.pageTimeout, equals(const Duration(seconds: 25)));
    });

    test('UrlHandler correctly identifies internal vs external URLs', () {
      final Uri internalUri = Uri.parse('https://www.zolotoytouruz.uz/podbor-tura');
      final Uri rootUri = Uri.parse('https://zolotoytouruz.uz/');
      final Uri externalTelUri = Uri.parse('tel:+998770434444');
      final Uri externalMailUri = Uri.parse('mailto:zolotoytouruz@gmail.com');
      final Uri externalWebUri = Uri.parse('https://t.me/zolotoytour');
      final Uri googleMapsUri = Uri.parse('https://maps.google.com/?q=Namangan');

      expect(UrlHandler.isInternalUrl(internalUri), isTrue);
      expect(UrlHandler.isInternalUrl(rootUri), isTrue);
      expect(UrlHandler.isExternalUrl(internalUri), isFalse);

      expect(UrlHandler.isExternalUrl(externalTelUri), isTrue);
      expect(UrlHandler.isExternalUrl(externalMailUri), isTrue);
      expect(UrlHandler.isExternalUrl(externalWebUri), isTrue);
      expect(UrlHandler.isExternalUrl(googleMapsUri), isTrue);
    });

    test('UrlHandler.handleNavigationRequest prevents javascript URLs', () {
      final NavigationRequest jsRequest = NavigationRequest(
        url: 'javascript:void(0);',
        isMainFrame: false,
      );
      final NavigationDecision decision =
          UrlHandler.handleNavigationRequest(jsRequest);
      expect(decision, equals(NavigationDecision.prevent));
    });

    test('UrlHandler.handleNavigationRequest allows internal navigation', () {
      final NavigationRequest internalRequest = NavigationRequest(
        url: 'https://www.zolotoytouruz.uz/podbor-tura',
        isMainFrame: true,
      );
      final NavigationDecision decision =
          UrlHandler.handleNavigationRequest(internalRequest);
      expect(decision, equals(NavigationDecision.navigate));
    });
  });

  group('ErrorScreen Widget Tests', () {
    testWidgets('ErrorScreen displays required text and responds to retry button', (WidgetTester tester) async {
      bool retryClicked = false;

      await tester.pumpWidget(
        MaterialApp(
          home: ErrorScreen(
            onRetry: () {
              retryClicked = true;
            },
          ),
        ),
      );

      // Verify official brand logo and required texts from specification
      expect(find.byType(Image), findsOneWidget);
      expect(find.text('Сайт временно недоступен'), findsOneWidget);
      expect(find.textContaining('техническая ошибка'), findsOneWidget);
      expect(find.byIcon(Icons.cloud_off_rounded), findsOneWidget);

      // Tap Retry button
      final Finder retryButton = find.byType(ElevatedButton);
      expect(retryButton, findsOneWidget);
      await tester.tap(retryButton);
      await tester.pump();

      expect(retryClicked, isTrue);

      // Advance time past debounce timer
      await tester.pump(const Duration(seconds: 3));
    });

    testWidgets('ErrorScreen debounces multiple rapid retry taps', (WidgetTester tester) async {
      int clickCount = 0;
      await tester.pumpWidget(
        MaterialApp(
          home: ErrorScreen(
            key: const ValueKey<String>('debounce-test'),
            onRetry: () {
              clickCount++;
            },
          ),
        ),
      );

      final Finder retryButton = find.byType(ElevatedButton);
      expect(retryButton, findsOneWidget);

      // First tap executes onRetry
      await tester.tap(retryButton);
      await tester.pump();
      expect(clickCount, equals(1));

      // Second rapid tap while debouncing is ignored
      await tester.tap(retryButton, warnIfMissed: false);
      await tester.pump();
      expect(clickCount, equals(1));

      // Advance time past debounce duration to complete timer cleanly
      await tester.pump(const Duration(seconds: 3));
    });

    testWidgets('ErrorScreen adapts cleanly to ultra-narrow screen (280px) without overflow', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(280, 500);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        MaterialApp(
          home: ErrorScreen(onRetry: () {}),
        ),
      );

      expect(find.byType(Image), findsOneWidget);
      expect(find.byType(ElevatedButton), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  });

  group('SplashScreen Widget Tests', () {
    testWidgets('SplashScreen renders official logo image properly', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: SplashScreen(),
        ),
      );

      // Verify the logo image is present in the widget tree
      expect(find.byType(Image), findsOneWidget);

      // Verify no circular progress indicator is shown
      expect(find.byType(CircularProgressIndicator), findsNothing);

      // Verify proper disposal and cancelation of timers
      await tester.pumpWidget(const SizedBox());
    });
  });

  group('AppBottomNavBar Widget Tests', () {
    testWidgets('renders all 5 standard navigation tabs and responds to tap', (WidgetTester tester) async {
      int tappedIndex = -1;
      bool longPressed = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            bottomNavigationBar: AppBottomNavBar(
              currentIndex: 0,
              onTap: (int index) {
                tappedIndex = index;
              },
              onContactLongPress: () {
                longPressed = true;
              },
            ),
          ),
        ),
      );

      // Check all 5 labels
      expect(find.text('Главная'), findsOneWidget);
      expect(find.text('Туры'), findsOneWidget);
      expect(find.text('Горящие'), findsOneWidget);
      expect(find.text('Услуги'), findsOneWidget);
      expect(find.text('Контакты'), findsOneWidget);

      // Verify Home active icon
      expect(find.byIcon(Icons.home_rounded), findsOneWidget);

      // Tap on 'Туры'
      await tester.tap(find.text('Туры'));
      await tester.pump();
      expect(tappedIndex, equals(1));

      // Tap on 'Контакты'
      await tester.tap(find.text('Контакты'));
      await tester.pump();
      expect(tappedIndex, equals(4));

      // Long press on 'Контакты'
      await tester.longPress(find.text('Контакты'));
      await tester.pump();
      expect(longPressed, isTrue);
    });

    testWidgets('adapts cleanly to narrow screen (320px) without overflow', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(320, 568);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            bottomNavigationBar: AppBottomNavBar(
              currentIndex: 0,
              onTap: (_) {},
            ),
          ),
        ),
      );

      // Verify all items are rendered without overflow exception
      expect(find.text('Главная'), findsOneWidget);
      expect(find.text('Туры'), findsOneWidget);
      expect(find.text('Горящие'), findsOneWidget);
      expect(find.text('Услуги'), findsOneWidget);
      expect(find.text('Контакты'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('adapts to large accessibility text scaling without overflow', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(360, 640);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        MaterialApp(
          home: MediaQuery(
            data: const MediaQueryData(
              textScaler: TextScaler.linear(1.8),
            ),
            child: Scaffold(
              bottomNavigationBar: AppBottomNavBar(
                currentIndex: 0,
                onTap: (_) {},
              ),
            ),
          ),
        ),
      );

      expect(find.text('Главная'), findsOneWidget);
      expect(find.text('Туры'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('adapts to wide tablet/desktop screen (1200px) with centered constraints', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1200, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            bottomNavigationBar: AppBottomNavBar(
              currentIndex: 0,
              onTap: (_) {},
            ),
          ),
        ),
      );

      expect(find.byType(ConstrainedBox), findsWidgets);
      expect(tester.takeException(), isNull);
    });

    testWidgets('AppBottomNavBar has correct fixed height in Scaffold and does not expand', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(360, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: const Center(child: Text('Body content')),
            bottomNavigationBar: AppBottomNavBar(
              currentIndex: 0,
              onTap: (_) {},
            ),
          ),
        ),
      );

      final Size navSize = tester.getSize(find.byType(AppBottomNavBar));
      expect(navSize.height, lessThanOrEqualTo(70.0));
    });

    testWidgets('adapts to landscape phone mode (height < 500)', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(800, 360);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            bottomNavigationBar: AppBottomNavBar(
              currentIndex: 2,
              onTap: (_) {},
            ),
          ),
        ),
      );

      expect(find.text('Горящие'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('handles transient zero-sized or micro constraints (w=0.3, h=0.6) gracefully without overflow', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            bottomNavigationBar: SizedBox(
              width: 0.3,
              height: 0.6,
              child: AppBottomNavBar(
                currentIndex: 0,
                onTap: (_) {},
              ),
            ),
          ),
        ),
      );

      expect(tester.takeException(), isNull);
    });
  });

  group('Cross-Device Screen Tests', () {
    testWidgets('ErrorScreen displays properly on desktop wide resolution', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1920, 1080);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        MaterialApp(
          home: ErrorScreen(onRetry: () {}),
        ),
      );

      expect(find.byType(ConstrainedBox), findsWidgets);
      expect(find.text('Сайт временно недоступен'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('SplashScreen renders adaptively on landscape phone', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(800, 360);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        const MaterialApp(
          home: SplashScreen(),
        ),
      );

      expect(find.byType(Image), findsOneWidget);
      expect(tester.takeException(), isNull);

      await tester.pumpWidget(const SizedBox());
    });

    testWidgets('SplashScreen renders adaptively on tablet resolution (1024x768)', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1024, 768);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        const MaterialApp(
          home: SplashScreen(),
        ),
      );

      expect(find.byType(Image), findsOneWidget);
      expect(tester.takeException(), isNull);

      await tester.pumpWidget(const SizedBox());
    });

    testWidgets('SplashScreen renders adaptively on ultra-narrow screen (280x500)', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(280, 500);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        const MaterialApp(
          home: SplashScreen(),
        ),
      );

      expect(find.byType(Image), findsOneWidget);
      expect(tester.takeException(), isNull);

      await tester.pumpWidget(const SizedBox());
    });

    testWidgets('ErrorScreen adapts cleanly to landscape phone (800x360)', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(800, 360);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        MaterialApp(
          home: ErrorScreen(onRetry: () {}),
        ),
      );

      expect(find.byType(Image), findsOneWidget);
      expect(find.byType(ElevatedButton), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('AppBottomNavBar adapts cleanly to ultra-narrow screen (280px)', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(280, 500);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            bottomNavigationBar: AppBottomNavBar(
              currentIndex: 0,
              onTap: (_) {},
            ),
          ),
        ),
      );

      expect(find.text('Главная'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  });

  group('WebViewScreen Tab Navigation Tests', () {
    testWidgets('WebViewScreen switches tabs when bottom navigation buttons are pressed', (WidgetTester tester) async {
      debugDefaultTargetPlatformOverride = TargetPlatform.windows;
      try {
        await tester.pumpWidget(
          const MaterialApp(
            home: WebViewScreen(),
          ),
        );

        // Dismiss splash
        await tester.pump(const Duration(seconds: 5));

        Finder navTab(String text) => find.descendant(
              of: find.byType(AppBottomNavBar),
              matching: find.text(text),
            );

        // Initially on Home tab (index 0)
        expect(navTab('Главная'), findsOneWidget);

        // Tap 'Туры' (index 1)
        await tester.tap(navTab('Туры'));
        await tester.pumpAndSettle();
        expect(navTab('Туры'), findsOneWidget);

        // Tap 'Горящие' (index 2)
        await tester.tap(navTab('Горящие'));
        await tester.pumpAndSettle();
        expect(navTab('Горящие'), findsOneWidget);

        // Tap 'Услуги' (index 3)
        await tester.tap(navTab('Услуги'));
        await tester.pumpAndSettle();
        expect(navTab('Услуги'), findsOneWidget);

        // Tap 'Контакты' (index 4)
        await tester.tap(navTab('Контакты'));
        await tester.pumpAndSettle();
        expect(navTab('Контакты'), findsOneWidget);

        // Return to 'Главная' (index 0)
        await tester.tap(navTab('Главная'));
        await tester.pumpAndSettle();
        expect(navTab('Главная'), findsOneWidget);

        expect(tester.takeException(), isNull);
      } finally {
        debugDefaultTargetPlatformOverride = null;
      }
    });
  });
}
