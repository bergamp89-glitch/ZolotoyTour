import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../config/app_config.dart';

/// A modern, responsive brand-tailored Top App Bar for Zolotoy Tour.
/// Positions the app comfortably below camera notches, punch-holes, dynamic islands, and status bars.
/// Features interactive brand logo with hidden tap-to-refresh action, dynamic section title,
/// quick hotline action, and an integrated smooth loading progress indicator.
class AppTopBar extends StatelessWidget implements PreferredSizeWidget {
  final int currentIndex;
  final VoidCallback? onRefresh;
  final VoidCallback onCall;
  final VoidCallback? onCallLongPress;
  final bool showRefreshAction;
  final ValueNotifier<bool>? isLoadingNotifier;
  final ValueNotifier<int>? progressNotifier;

  const AppTopBar({
    super.key,
    required this.currentIndex,
    this.onRefresh,
    required this.onCall,
    this.onCallLongPress,
    this.showRefreshAction = false,
    this.isLoadingNotifier,
    this.progressNotifier,
  });

  /// Section subtitles matching bottom nav items for contextual awareness.
  static const List<String> sectionSubtitles = <String>[
    'Главная страница',
    'Подбор и поиск тура',
    'Горящие спецпредложения',
    'Все туристические услуги',
    'Контакты и адрес офиса',
  ];

  @override
  Size get preferredSize => const Size.fromHeight(56.0);

  @override
  Widget build(BuildContext context) {
    final double screenHeight = MediaQuery.sizeOf(context).height;
    final bool isCompact = screenHeight < 600;
    final double contentHeight = isCompact ? 48.0 : 52.0;

    final String currentSubtitle = (currentIndex >= 0 && currentIndex < sectionSubtitles.length)
        ? sectionSubtitles[currentIndex]
        : 'Туристическое агентство';

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.white,
        statusBarIconBrightness: Brightness.dark,
        statusBarBrightness: Brightness.light,
        systemNavigationBarColor: Colors.white,
        systemNavigationBarIconBrightness: Brightness.dark,
      ),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: <BoxShadow>[
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: SafeArea(
          bottom: false,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              // Main Top Bar Content (centered & constrained for tablets)
              SizedBox(
                height: contentHeight,
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 640),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 14.0),
                      child: Row(
                        children: <Widget>[
                          // Brand Logo with elegant gold ambient ring & hidden tap-to-refresh
                          Tooltip(
                            message: 'Обновить / Yangilash',
                            child: Container(
                              width: isCompact ? 34.0 : 38.0,
                              height: isCompact ? 34.0 : 38.0,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: AppConfig.primaryColor.withValues(alpha: 0.45),
                                  width: 1.2,
                                ),
                                boxShadow: <BoxShadow>[
                                  BoxShadow(
                                    color: AppConfig.primaryColor.withValues(alpha: 0.25),
                                    blurRadius: 6,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Material(
                                color: AppConfig.darkBackgroundColor,
                                shape: const CircleBorder(),
                                clipBehavior: Clip.antiAlias,
                                child: InkWell(
                                  customBorder: const CircleBorder(),
                                  splashColor: AppConfig.primaryColor.withValues(alpha: 0.35),
                                  highlightColor: AppConfig.primaryColor.withValues(alpha: 0.15),
                                  onTap: onRefresh != null
                                      ? () {
                                          HapticFeedback.selectionClick();
                                          onRefresh!();
                                        }
                                      : null,
                                  child: Padding(
                                    padding: const EdgeInsets.all(4.5),
                                    child: Image.asset(
                                      'assets/images/logo.png',
                                      fit: BoxFit.contain,
                                      filterQuality: FilterQuality.high,
                                      isAntiAlias: true,
                                      errorBuilder: (
                                        BuildContext context,
                                        Object error,
                                        StackTrace? stackTrace,
                                      ) {
                                        return const Icon(
                                          Icons.travel_explore_rounded,
                                          color: AppConfig.primaryColor,
                                          size: 18,
                                        );
                                      },
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 10.0),

                          // Brand Name & Dynamic Section Indicator
                          Expanded(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                const Text(
                                  AppConfig.appName,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontSize: 15.5,
                                    fontWeight: FontWeight.w800,
                                    color: AppConfig.darkBackgroundColor,
                                    letterSpacing: -0.3,
                                    height: 1.15,
                                  ),
                                ),
                                const SizedBox(height: 2.0),
                                Text(
                                  currentSubtitle,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontSize: 11.5,
                                    fontWeight: FontWeight.w600,
                                    color: AppConfig.primaryColor,
                                    letterSpacing: -0.1,
                                    height: 1.15,
                                  ),
                                ),
                              ],
                            ),
                          ),

                          // Quick Action: Call Hotline
                          Tooltip(
                            message: 'Позвонить / Aloqa: ${AppConfig.contactPhone}',
                            child: Material(
                              color: Colors.transparent,
                              child: InkWell(
                                borderRadius: BorderRadius.circular(20),
                                onTap: () {
                                  HapticFeedback.selectionClick();
                                  onCall();
                                },
                                onLongPress: onCallLongPress != null
                                    ? () {
                                        HapticFeedback.mediumImpact();
                                        onCallLongPress!();
                                      }
                                    : null,
                                child: Container(
                                  padding: const EdgeInsets.all(7.0),
                                  decoration: BoxDecoration(
                                    color: AppConfig.primaryColor.withValues(alpha: 0.12),
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.phone_in_talk_rounded,
                                    color: AppConfig.primaryColor,
                                    size: 19.0,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          // Quick Action: Refresh Current Tab (optional if floating button used)
                          if (showRefreshAction && onRefresh != null) ...<Widget>[
                            const SizedBox(width: 8.0),
                            Tooltip(
                              message: 'Обновить / Yangilash',
                              child: Material(
                                color: Colors.transparent,
                                child: InkWell(
                                  borderRadius: BorderRadius.circular(20),
                                  onTap: () {
                                    HapticFeedback.selectionClick();
                                    onRefresh!();
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.all(7.0),
                                    decoration: const BoxDecoration(color: Color(0xFFF3F3F3), shape: BoxShape.circle),
                                    child: const Icon(
                                      Icons.refresh_rounded,
                                      color: AppConfig.darkBackgroundColor,
                                      size: 19.0,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                ),
              ),

              // Bottom 1px Divider
              Container(
                height: 1.0,
                color: const Color(0xFFEEEEEE),
              ),

              // Integrated Loading Progress Indicator
              if (isLoadingNotifier != null && progressNotifier != null)
                ValueListenableBuilder<bool>(
                  valueListenable: isLoadingNotifier!,
                  builder: (BuildContext context, bool isLoading, _) {
                    if (!isLoading) {
                      return const SizedBox(height: 2.5);
                    }
                    return SizedBox(
                      height: 2.5,
                      child: ValueListenableBuilder<int>(
                        valueListenable: progressNotifier!,
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
                )
              else
                const SizedBox(height: 2.5),
            ],
          ),
        ),
      ),
    );
  }
}

