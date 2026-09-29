import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:webview_flutter/webview_flutter.dart';
import '../config/app_config.dart';
import '../utils/url_handler.dart';
import '../widgets/app_bottom_nav_bar.dart';
import 'error_screen.dart';
import 'splash_screen.dart';

/// High-performance screen hosting the Zolotoy Tour live website.
/// Uses a lazy multi-tab controller pool with IndexedStack to eliminate tab switching delays,
/// avoid page reloading freezes, and maintain scroll positions across all 5 navigation tabs.
class WebViewScreen extends StatefulWidget {
  const WebViewScreen({super.key});

  @override
  State<WebViewScreen> createState() => _WebViewScreenState();
}

class _WebViewScreenState extends State<WebViewScreen> {
  final Map<int, WebViewController> _controllers = <int, WebViewController>{};
  final Map<int, ValueNotifier<int>> _tabProgress = <int, ValueNotifier<int>>{};
  final Map<int, ValueNotifier<bool>> _tabIsLoading = <int, ValueNotifier<bool>>{};
  final Map<int, bool> _tabHasError = <int, bool>{};
  final Set<int> _tabInitialized = <int>{};

  bool _showSplash = true;
  bool _splashFading = false;

  int _currentTabIndex = 0;
  bool _isWebViewSupported = true;

  final Map<int, Timer> _tabTimeoutTimers = <int, Timer>{};
  final Set<int> _tabsLoaded = <int>{};
  bool _minSplashElapsed = false;
  Timer? _minSplashTimer;
  Timer? _maxSplashTimer;
  Timer? _renderBufferTimer;
  DateTime? _lastBackPressTime;
  bool _backgroundPreloadStarted = false;
  int _nextPreloadIndex = 1;
  Timer? _backgroundPreloadTimer;

  /// Detects whether the current environment is a desktop OS (Windows, macOS, Linux).
  bool get _isDesktopPlatform {
    if (kIsWeb) return false;
    return defaultTargetPlatform == TargetPlatform.windows ||
        defaultTargetPlatform == TargetPlatform.linux ||
        defaultTargetPlatform == TargetPlatform.macOS;
  }

  @override
  void initState() {
    super.initState();
    if (_isDesktopPlatform) {
      _isWebViewSupported = false;
      _showSplash = false;
    } else {
      // Step 1: Preload ONLY the main Home tab (index 0) during the splash screen.
      // This allocates 100% of bandwidth to the landing screen, preventing lag on initial launch.
      _initTabController(0);

      // Minimum splash duration: ~3.8 seconds.
      // Gives ample time for the luxury travel orbit and brand animation to shine
      // while the Home page finishes loading completely in the background.
      _minSplashTimer = Timer(const Duration(milliseconds: 3800), () {
        _minSplashElapsed = true;
        _checkSplashReadiness();
      });

      // Safety maximum splash timer: ~10.0 seconds to prevent hanging on dead or extremely slow connections.
      _maxSplashTimer = Timer(const Duration(milliseconds: 10000), () {
        if (mounted && _showSplash && !_splashFading) {
          _dismissSplash();
        }
      });
    }
  }

  @override
  void dispose() {
    _minSplashTimer?.cancel();
    _maxSplashTimer?.cancel();
    _renderBufferTimer?.cancel();
    _backgroundPreloadTimer?.cancel();
    for (final Timer timer in _tabTimeoutTimers.values) {
      timer.cancel();
    }
    for (final ValueNotifier<int> notifier in _tabProgress.values) {
      notifier.dispose();
    }
    for (final ValueNotifier<bool> notifier in _tabIsLoading.values) {
      notifier.dispose();
    }
    super.dispose();
  }

  /// Lazy-initializes and caches a WebViewController for a given bottom nav tab index.
  WebViewController? _initTabController(int index) {
    if (_isDesktopPlatform) return null;
    if (_tabInitialized.contains(index) && _controllers.containsKey(index)) {
      return _controllers[index];
    }

    _tabInitialized.add(index);
    _tabProgress[index] = ValueNotifier<int>(0);
    _tabIsLoading[index] = ValueNotifier<bool>(!kIsWeb);
    _tabHasError[index] = false;

    try {
      final WebViewController controller = WebViewController();

      if (!kIsWeb) {
        controller
          ..setJavaScriptMode(JavaScriptMode.unrestricted)
          ..setBackgroundColor(AppConfig.lightBackgroundColor)
          ..setNavigationDelegate(
            NavigationDelegate(
              onProgress: (int progress) {
                _tabProgress[index]?.value = progress;
                if (progress >= 100 && (_tabIsLoading[index]?.value ?? false)) {
                  _tabIsLoading[index]?.value = false;
                }
              },
              onPageStarted: (String url) {
                _tabProgress[index]?.value = 0;
                _tabIsLoading[index]?.value = true;
                if ((_tabHasError[index] ?? false) && mounted) {
                  setState(() {
                    _tabHasError[index] = false;
                  });
                }
                // Watchdog: safeguard against silent hangs or stalled TCP connections
                _tabTimeoutTimers[index]?.cancel();
                _tabTimeoutTimers[index] = Timer(AppConfig.pageTimeout, () {
                  if (mounted && (_tabIsLoading[index]?.value ?? false)) {
                    _tabIsLoading[index]?.value = false;
                    setState(() {
                      _tabHasError[index] = true;
                    });
                  }
                });
              },
              onPageFinished: (String url) {
                _tabTimeoutTimers[index]?.cancel();
                _tabProgress[index]?.value = 100;
                _tabIsLoading[index]?.value = false;
                _tabsLoaded.add(index);

                // Inject high-performance stylesheet optimizations without thread-blocking JS
                _injectMobileOptimizations(controller);

                // Notify readiness checker that a tab has finished rendering
                _checkSplashReadiness();

                // If splash has already concluded and user is on the main screen:
                if (!_showSplash || _splashFading) {
                  if (!_backgroundPreloadStarted) {
                    _startBackgroundPreloading();
                  } else if (index == _nextPreloadIndex) {
                    // Previous background tab finished loading! Advance cleanly to the next tab.
                    _backgroundPreloadTimer?.cancel();
                    _nextPreloadIndex++;
                    Timer(const Duration(milliseconds: 250), () {
                      if (mounted) {
                        _triggerNextBackgroundPreload();
                      }
                    });
                  }
                }
              },
              onWebResourceError: (WebResourceError error) {
                // Ignore cancelled, redirected, prevented, or non-fatal errors:
                // - iOS WKWebView error code -999 (NSURLErrorCancelled) when switching tabs or external scheme launch
                // - Android Chromium error code -3 (ERR_ABORTED) / -1 / net::ERR_ABORTED when navigation is redirected or prevented
                // - net::ERR_UNKNOWN_URL_SCHEME (code -10) when custom scheme is handled externally
                // - Non-fatal subresource blocks: ERR_BLOCKED_BY_CLIENT, ERR_CACHE_MISS
                if (error.errorCode == -999 ||
                    error.errorCode == -3 ||
                    error.errorCode == -10 ||
                    error.description.contains('ERR_ABORTED') ||
                    error.description.contains('net::ERR_ABORTED') ||
                    error.description.contains('ERR_UNKNOWN_URL_SCHEME') ||
                    error.description.contains('ERR_BLOCKED_BY_CLIENT') ||
                    error.description.contains('ERR_CACHE_MISS')) {
                  return;
                }

                _tabTimeoutTimers[index]?.cancel();

                // Check if failure belongs to main frame or is a critical network disconnect
                final bool isMainFrame = error.isForMainFrame ?? false;
                final bool isCriticalNetworkFailure = error.errorCode == -2 || // ERR_NAME_NOT_RESOLVED
                    error.errorCode == -6 || // ERR_CONNECTION_REFUSED
                    error.errorCode == -8 || // ERR_CONNECTION_TIMED_OUT
                    error.errorCode == -1009 || // NSURLErrorNotConnectedToInternet
                    error.errorCode == -1003 || // NSURLErrorCannotFindHost
                    error.errorCode == -1004; // NSURLErrorCannotConnectToHost

                if (isMainFrame || (error.isForMainFrame == null && isCriticalNetworkFailure)) {
                  _tabIsLoading[index]?.value = false;
                  if (mounted) {
                    setState(() {
                      _tabHasError[index] = true;
                    });
                  }
                  // If home tab fails with network error, dismiss splash immediately so user sees ErrorScreen
                  if (index == 0) {
                    _dismissSplash();
                  }
                }
              },
              onNavigationRequest: (NavigationRequest request) {
                return UrlHandler.handleNavigationRequest(
                  request,
                  context: context,
                );
              },
            ),
          );
      } else {
        _tabIsLoading[index]?.value = false;
      }

      final String targetUrl = AppBottomNavBar.navItems[index].url;
      controller.loadRequest(Uri.parse(targetUrl));
      _controllers[index] = controller;
      _isWebViewSupported = true;
      return controller;
    } catch (_) {
      _isWebViewSupported = false;
      _tabIsLoading[index]?.value = false;
      return null;
    }
  }

  /// Injects lightweight, hardware-accelerated CSS styling into the WebView.
  /// Avoids heavy DOM querySelector loops and setTimeouts that cause UI jank and freeze.
  void _injectMobileOptimizations(WebViewController controller) {
    controller.runJavaScript(r'''
      (function() {
        if (document.getElementById('flutter-mobile-opt-style')) return;

        var meta = document.querySelector('meta[name="viewport"]');
        if (!meta) {
          meta = document.createElement('meta');
          meta.name = 'viewport';
          document.getElementsByTagName('head')[0].appendChild(meta);
        }
        meta.content = 'width=device-width, initial-scale=1.0, maximum-scale=5.0, user-scalable=yes';

        var style = document.createElement('style');
        style.id = 'flutter-mobile-opt-style';
        style.textContent = '\
          html, body {\
            overflow-x: hidden !important;\
            -webkit-overflow-scrolling: touch !important;\
            scroll-behavior: smooth !important;\
          }\
          img {\
            content-visibility: auto !important;\
          }\
          /* Purge unwanted menu items instantaneously via GPU rendering */\
          .item-107,\
          .item-111,\
          .item-113,\
          .item-115,\
          .item-116,\
          .item-117,\
          .item-118,\
          .item-119,\
          .item-120 {\
            display: none !important;\
            visibility: hidden !important;\
            height: 0 !important;\
            min-height: 0 !important;\
            padding: 0 !important;\
            margin: 0 !important;\
            pointer-events: none !important;\
          }\
          /* Responsive Map Styling */\
          iframe[src*="yandex"],\
          iframe[src*="maps"],\
          iframe[src*="constructor"],\
          #map,\
          #ymap,\
          #yandex-map,\
          #yandex_map,\
          [id^="map-"],\
          [id^="ymap-"],\
          .map,\
          .ymap,\
          .yandex-map,\
          .map-container,\
          .map-responsive,\
          .contact-map,\
          .contacts-map,\
          ymaps.ymaps-2-1-79-map,\
          ymaps[class*="-map"] {\
            height: clamp(190px, 30vh, 240px) !important;\
            max-height: 240px !important;\
            min-height: 180px !important;\
            width: 100% !important;\
            max-width: 100% !important;\
            border-radius: 16px !important;\
            overflow: hidden !important;\
            margin: 10px auto 14px auto !important;\
            box-shadow: 0 4px 18px rgba(0,0,0,0.12) !important;\
            box-sizing: border-box !important;\
          }\
          /* Contact Details section */\
          .contact-address, .contact-info, .contact-details, .contacts, .contact, .custom_contacts {\
            padding: 14px 16px !important;\
            margin: 8px auto !important;\
            border-radius: 14px !important;\
            line-height: 1.5 !important;\
            box-sizing: border-box !important;\
          }\
          body, .container, .main-content, #content, .content-inner {\
            padding-bottom: 36px !important;\
          }\
          .reviews, .container.reviews, .module-wrapper .reviews {\
            padding-top: 15px !important;\
            padding-bottom: 15px !important;\
            margin-top: 0 !important;\
            margin-bottom: 0 !important;\
          }\
          .reviews h2, .reviews .moduletable h2 {\
            font-size: 20px !important;\
            line-height: 1.25 !important;\
            margin-top: 0 !important;\
            margin-bottom: 8px !important;\
            text-align: center !important;\
          }\
          .reviews h5, .reviews p, .reviews .custom {\
            font-size: 13px !important;\
            line-height: 1.4 !important;\
            margin-bottom: 10px !important;\
            text-align: center !important;\
          }\
          .reviews .swiper {\
            margin: 10px auto !important;\
          }\
          .reviews .swiper-wrapper:empty, .reviews .swiper:empty {\
            display: none !important;\
            height: 0 !important;\
            min-height: 0 !important;\
          }';
        document.head.appendChild(style);
      })();
    ''').catchError((_) {});
  }

  /// Handles tab selection from bottom navigation bar.
  /// Transitions immediately to the target tab regardless of which section the user is currently in.
  Future<void> _onTabTapped(int index) async {
    if (_currentTabIndex == index) {
      // If user tapped the currently active tab:
      if (_tabHasError[index] == true) {
        _retryTab(index);
        return;
      }

      if (_isWebViewSupported && !kIsWeb) {
        final WebViewController? controller = _controllers[index];
        if (controller != null) {
          final String rootUrl = AppBottomNavBar.navItems[index].url;
          final String? currentUrl = await controller.currentUrl();
          if (currentUrl != null &&
              currentUrl != rootUrl &&
              currentUrl != '$rootUrl/') {
            // If user navigated deep inside this section, tapping the tab returns to its root page
            controller.loadRequest(Uri.parse(rootUrl));
            return;
          }
          // Already on the root page -> smoothly scroll to top
          controller
              .runJavaScript('window.scrollTo({top: 0, behavior: "smooth"});')
              .catchError((_) {});
        }
      }
      return;
    }

    // Immediately initialize target tab if not yet loaded
    if (!_tabInitialized.contains(index)) {
      _initTabController(index);
    } else if (_tabHasError[index] == true) {
      _retryTab(index);
    }

    setState(() {
      _currentTabIndex = index;
    });
  }

  /// Retries loading the active tab after an error occurs.
  void _retryTab(int index) {
    _tabTimeoutTimers[index]?.cancel();
    if (_tabHasError[index] == true) {
      setState(() {
        _tabHasError[index] = false;
      });
    }
    _tabProgress[index]?.value = 0;
    _tabIsLoading[index]?.value = !kIsWeb && _isWebViewSupported;
    final WebViewController? controller = _controllers[index];
    if (controller != null) {
      final String targetUrl = AppBottomNavBar.navItems[index].url;
      controller.loadRequest(Uri.parse(targetUrl));
    }
  }

  /// Refreshes the currently active tab.
  Future<void> _refreshCurrentTab() async {
    final int index = _currentTabIndex;
    final WebViewController? controller = _controllers[index];
    if (controller == null) return;

    _tabTimeoutTimers[index]?.cancel();
    if (_tabHasError[index] == true) {
      setState(() {
        _tabHasError[index] = false;
      });
      final String targetUrl = AppBottomNavBar.navItems[index].url;
      controller.loadRequest(Uri.parse(targetUrl));
      return;
    }

    _tabProgress[index]?.value = 0;
    _tabIsLoading[index]?.value = !kIsWeb && _isWebViewSupported;

    if (!kIsWeb) {
      try {
        await controller.reload();
      } catch (_) {
        final String targetUrl = AppBottomNavBar.navItems[index].url;
        await controller.loadRequest(Uri.parse(targetUrl));
      }
    } else {
      final String targetUrl = AppBottomNavBar.navItems[index].url;
      await controller.loadRequest(Uri.parse(targetUrl));
    }
  }

  /// Shows quick contact modal bottom sheet for direct call or messaging.
  void _showQuickContactSheet() {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext ctx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Связаться с Zolotoy Tour',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: AppConfig.darkBackgroundColor,
                  ),
                ),
                const SizedBox(height: 16),
                ListTile(
                  leading: CircleAvatar(
                    backgroundColor: AppConfig.primaryColor.withValues(alpha: 0.15),
                    child: const Icon(
                      Icons.phone_rounded,
                      color: AppConfig.primaryColor,
                    ),
                  ),
                  title: const Text('Позвонить'),
                  subtitle: const Text(AppConfig.contactPhone),
                  onTap: () {
                    Navigator.pop(ctx);
                    UrlHandler.launchExternal(
                      Uri.parse('tel:${AppConfig.contactPhone}'),
                    );
                  },
                ),
                ListTile(
                  leading: CircleAvatar(
                    backgroundColor: const Color(0xFF229ED9).withValues(alpha: 0.15),
                    child: const Icon(
                      Icons.send_rounded,
                      color: Color(0xFF229ED9),
                    ),
                  ),
                  title: const Text('Написать в Telegram'),
                  subtitle: Text('@${AppConfig.telegramUsername}'),
                  onTap: () {
                    Navigator.pop(ctx);
                    UrlHandler.launchExternal(
                      Uri.parse(AppConfig.telegramUrl),
                    );
                  },
                ),
                ListTile(
                  leading: CircleAvatar(
                    backgroundColor: AppConfig.primaryColor.withValues(alpha: 0.15),
                    child: const Icon(
                      Icons.email_outlined,
                      color: AppConfig.primaryColor,
                    ),
                  ),
                  title: const Text('Отправить Email'),
                  subtitle: const Text(AppConfig.contactEmail),
                  onTap: () {
                    Navigator.pop(ctx);
                    UrlHandler.launchExternal(
                      Uri.parse('mailto:${AppConfig.contactEmail}'),
                    );
                  },
                ),
                ListTile(
                  leading: CircleAvatar(
                    backgroundColor: AppConfig.primaryColor.withValues(alpha: 0.15),
                    child: const Icon(
                      Icons.web_rounded,
                      color: AppConfig.primaryColor,
                    ),
                  ),
                  title: const Text('Страница контактов на сайте'),
                  subtitle: const Text('Адрес, форма, карта'),
                  onTap: () {
                    Navigator.pop(ctx);
                    _onTabTapped(4);
                  },
                ),
                const SizedBox(height: 8),
              ],
            ),
          ),
        );
      },
    );
  }

  /// Handles Android back button / predictive back gesture navigation.
  Future<bool> _handleBackNavigation() async {
    final int index = _currentTabIndex;

    if (_tabHasError[index] == true) {
      if (index != 0) {
        _onTabTapped(0);
        return false;
      }
      return _confirmExit();
    }

    final WebViewController? currentController = _controllers[index];
    if (_isWebViewSupported && !kIsWeb && currentController != null) {
      if (await currentController.canGoBack()) {
        await currentController.goBack();
        return false; // Prevent closing the app
      }
    }

    // If not on Home tab, return to Home tab first before closing app
    if (index != 0) {
      _onTabTapped(0);
      return false;
    }

    return _confirmExit();
  }

  /// Double-back to exit safeguard to prevent accidental app termination.
  bool _confirmExit() {
    final DateTime now = DateTime.now();
    if (_lastBackPressTime == null ||
        now.difference(_lastBackPressTime!) > const Duration(seconds: 2)) {
      _lastBackPressTime = now;
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Для выхода нажмите назад еще раз / Chiqish uchun yana bir bor bosing'),
            duration: Duration(seconds: 2),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
      return false;
    }
    return true; // Allow exiting the app
  }

  /// Checks whether splash screen can be dismissed.
  /// Dismisses when minimum splash duration has elapsed AND the main Home tab (0) is loaded.
  void _checkSplashReadiness() {
    if (!_showSplash || _splashFading || !mounted) return;

    final bool homeTabReady = _tabsLoaded.contains(0);

    if (_minSplashElapsed && homeTabReady) {
      // 300ms buffer after onPageFinished so WebView completely finishes painting
      // its layout to the GPU buffer, guaranteeing 0s instant display with no white flash.
      _renderBufferTimer?.cancel();
      _renderBufferTimer = Timer(const Duration(milliseconds: 300), () {
        if (mounted) {
          _dismissSplash();
        }
      });
    }
  }

  /// Gracefully fades out and dismisses the initial Splash Screen overlay.
  void _dismissSplash() {
    if (!_showSplash || _splashFading || !mounted) return;
    _minSplashTimer?.cancel();
    _maxSplashTimer?.cancel();
    _renderBufferTimer?.cancel();
    setState(() {
      _splashFading = true;
    });

    // Start background preloading of remaining tabs (1, 2, 3, 4) while user is on Home screen
    _startBackgroundPreloading();
  }

  /// Sequentially preloads remaining navigation tabs in the background
  /// one-by-one as each previous tab finishes loading, while the user
  /// is actively viewing the main Home screen.
  void _startBackgroundPreloading() {
    if (_backgroundPreloadStarted || _isDesktopPlatform || !mounted) return;
    _backgroundPreloadStarted = true;
    _triggerNextBackgroundPreload();
  }

  void _triggerNextBackgroundPreload() {
    if (!mounted) return;

    // Find the next uninitialized tab index (1 -> 2 -> 3 -> 4)
    while (_nextPreloadIndex < AppBottomNavBar.navItems.length &&
        _tabInitialized.contains(_nextPreloadIndex)) {
      _nextPreloadIndex++;
    }

    if (_nextPreloadIndex >= AppBottomNavBar.navItems.length) {
      return; // All tabs have finished loading in memory!
    }

    final int targetIndex = _nextPreloadIndex;
    _initTabController(targetIndex);

    // Safety watchdog: if a background tab takes longer than 4.0s,
    // advance to the next tab anyway so the queue never stalls.
    _backgroundPreloadTimer?.cancel();
    _backgroundPreloadTimer = Timer(const Duration(milliseconds: 4000), () {
      if (mounted && _nextPreloadIndex == targetIndex) {
        _nextPreloadIndex++;
        _triggerNextBackgroundPreload();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final double statusBarHeight = MediaQuery.paddingOf(context).top;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
        statusBarBrightness: Brightness.light,
        systemNavigationBarColor: Colors.white,
        systemNavigationBarIconBrightness: Brightness.dark,
      ),
      child: PopScope(
        canPop: false,
        onPopInvokedWithResult: (bool didPop, dynamic result) async {
          if (didPop) return;
          if (_showSplash) return; // Prevent back navigation while splash is active
          final bool shouldExit = await _handleBackNavigation();
          if (shouldExit && context.mounted) {
            SystemNavigator.pop();
          }
        },
        child: Stack(
          fit: StackFit.expand,
          children: <Widget>[
            Scaffold(
              backgroundColor: AppConfig.lightBackgroundColor,
              body: SafeArea(
                top: false,
                bottom: false,
                child: Stack(
                  fit: StackFit.expand,
                  children: <Widget>[
                    // Multi-tab lazy caching container: instant switching without reloading
                    if (!_isWebViewSupported)
                      SafeArea(child: _buildDesktopFallbackView(context))
                    else
                      IndexedStack(
                        index: _currentTabIndex,
                        children: List<Widget>.generate(
                          AppBottomNavBar.navItems.length,
                          (int index) {
                            if (!_tabInitialized.contains(index) ||
                                _controllers[index] == null) {
                              return KeyedSubtree(
                                key: ValueKey<int>(index),
                                child: const SizedBox.shrink(),
                              );
                            }

                            final bool hasError = _tabHasError[index] ?? false;
                            if (hasError) {
                              return KeyedSubtree(
                                key: ValueKey<int>(index),
                                child: SafeArea(
                                  child: ErrorScreen(
                                    onRetry: () => _retryTab(index),
                                  ),
                                ),
                              );
                            }

                            return KeyedSubtree(
                              key: ValueKey<int>(index),
                              child: SizedBox.expand(
                                child: WebViewWidget(controller: _controllers[index]!),
                              ),
                            );
                          },
                        ),
                      ),

                    // Top Progress Indicator isolated to current active tab
                    if (_isWebViewSupported &&
                        _tabIsLoading.containsKey(_currentTabIndex) &&
                        _tabProgress.containsKey(_currentTabIndex))
                      ValueListenableBuilder<bool>(
                        valueListenable: _tabIsLoading[_currentTabIndex]!,
                        builder: (BuildContext context, bool isLoading, _) {
                          if (!isLoading || (_tabHasError[_currentTabIndex] ?? false)) {
                            return const SizedBox.shrink();
                          }
                          return Positioned(
                            top: statusBarHeight,
                            left: 0,
                            right: 0,
                            child: ValueListenableBuilder<int>(
                              valueListenable: _tabProgress[_currentTabIndex]!,
                              builder: (BuildContext context, int progress, _) {
                                return LinearProgressIndicator(
                                  value: progress > 0 ? progress / 100.0 : null,
                                  backgroundColor: Colors.transparent,
                                  valueColor: const AlwaysStoppedAnimation<Color>(
                                    AppConfig.primaryColor,
                                  ),
                                  minHeight: 2.5,
                                );
                              },
                            ),
                          );
                        },
                      ),
                  ],
                ),
              ),
              // Floating refresh button: replaces non-functional RefreshIndicator
              // Shows only when WebView is loaded and there's no error
              floatingActionButton: (!_showSplash &&
                      _isWebViewSupported &&
                      !kIsWeb &&
                      !(_tabHasError[_currentTabIndex] ?? false))
                  ? Padding(
                      // Position lowered by ~1cm (~40dp) below status bar for better accessibility
                      padding: EdgeInsets.only(top: statusBarHeight + 44),
                      child: SizedBox(
                        width: 32,
                        height: 32,
                        child: FloatingActionButton(
                          heroTag: 'refresh_fab',
                          mini: true,
                          elevation: 2,
                          backgroundColor: Colors.white.withValues(alpha: 0.92),
                          onPressed: _refreshCurrentTab,
                          child: const Icon(
                            Icons.refresh_rounded,
                            color: AppConfig.primaryColor,
                            size: 18,
                          ),
                        ),
                      ),
                    )
                  : null,
              floatingActionButtonLocation: FloatingActionButtonLocation.endTop,
              bottomNavigationBar: AppBottomNavBar(
                currentIndex: _currentTabIndex,
                onTap: _onTabTapped,
                onContactLongPress: _showQuickContactSheet,
              ),
            ),

            // Splash Screen Overlay: full-screen coverage including status bar and bottom bar
            if (_showSplash)
              Positioned.fill(
                child: IgnorePointer(
                  ignoring: _splashFading,
                  child: AnimatedOpacity(
                    opacity: _splashFading ? 0.0 : 1.0,
                    duration: const Duration(milliseconds: 350),
                    curve: Curves.easeInOut,
                    onEnd: () {
                      if (mounted && _splashFading) {
                        setState(() {
                          _showSplash = false;
                        });
                      }
                    },
                    child: SplashScreen(
                      isOverlay: true,
                      onFinished: _dismissSplash,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  /// Presentation card for desktop platforms where mobile webview_flutter native engine is not supported.
  Widget _buildDesktopFallbackView(BuildContext context) {
    final AppNavItem currentItem = AppBottomNavBar.navItems[_currentTabIndex];

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 620),
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32.0),
          child: Container(
            padding: const EdgeInsets.all(32.0),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: <BoxShadow>[
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 20,
                  offset: const Offset(0, 4),
                ),
              ],
              border: Border.all(
                color: const Color(0xFFEBEBEB),
                width: 1,
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                // Brand Logo
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppConfig.darkBackgroundColor,
                    shape: BoxShape.circle,
                    boxShadow: <BoxShadow>[
                      BoxShadow(
                        color: AppConfig.primaryColor.withValues(alpha: 0.3),
                        blurRadius: 16,
                      ),
                    ],
                  ),
                  child: Image.asset(
                    'assets/images/logo.png',
                    width: 72,
                    height: 72,
                    fit: BoxFit.contain,
                  ),
                ),
                const SizedBox(height: 20),

                // App Title
                const Text(
                  AppConfig.appName,
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                    color: AppConfig.darkBackgroundColor,
                    letterSpacing: -0.3,
                  ),
                ),
                const SizedBox(height: 8),

                // Current Section Badge
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
                  decoration: BoxDecoration(
                    color: AppConfig.primaryColor.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Icon(
                        currentItem.activeIcon,
                        size: 16,
                        color: AppConfig.primaryColor,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        currentItem.label,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: AppConfig.primaryColor,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Friendly instructions
                const Text(
                  'Вы используете версию Zolotoy Tour для настольных компьютеров.\nНажмите ниже для перехода в выбранный раздел на сайте:',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    color: AppConfig.textMutedColor,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 24),

                // Open in Browser Button
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      UrlHandler.launchExternal(Uri.parse(currentItem.url));
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppConfig.primaryColor,
                      foregroundColor: Colors.white,
                      elevation: 2,
                      shadowColor: AppConfig.primaryColor.withValues(alpha: 0.4),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    icon: const Icon(Icons.open_in_browser_rounded, size: 22),
                    label: Text(
                      'Открыть "${currentItem.label}" в браузере',
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.2,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 14),

                // Telegram button
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: OutlinedButton.icon(
                    onPressed: () {
                      UrlHandler.launchExternal(Uri.parse(AppConfig.telegramUrl));
                    },
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFF229ED9),
                      side: const BorderSide(color: Color(0xFF229ED9), width: 1.2),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    icon: const Icon(Icons.send_rounded, color: Color(0xFF229ED9), size: 20),
                    label: const Text(
                      'Telegram: @zolotoy_tour',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 14),

                // Hotline button
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: OutlinedButton.icon(
                    onPressed: () {
                      UrlHandler.launchExternal(
                        Uri(scheme: 'tel', path: AppConfig.contactPhone),
                      );
                    },
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppConfig.darkBackgroundColor,
                      side: const BorderSide(color: Color(0xFFDDDDDD), width: 1.2),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    icon: const Icon(Icons.phone_rounded, color: AppConfig.primaryColor, size: 20),
                    label: const Text(
                      'Позвонить: ${AppConfig.contactPhone}',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Office info
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF9F9F9),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFEEEEEE)),
                  ),
                  child: Column(
                    children: <Widget>[
                      Text(
                        AppConfig.officeAddress,
                        textAlign: TextAlign.center,
                        style: const TextStyle(fontSize: 12, color: AppConfig.textMutedColor),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        AppConfig.workingHours,
                        textAlign: TextAlign.center,
                        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppConfig.textMutedColor),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
