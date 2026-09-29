import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../config/app_config.dart';

/// Representation of an individual navigation tab item.
class AppNavItem {
  final String label;
  final IconData activeIcon;
  final IconData inactiveIcon;
  final String url;

  const AppNavItem({
    required this.label,
    required this.activeIcon,
    required this.inactiveIcon,
    required this.url,
  });
}

/// A modern, brand-tailored Bottom Navigation Bar for Zolotoy Tour.
/// Features smooth animations, gold accents, haptic feedback, and accessibility.
class AppBottomNavBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;
  final VoidCallback? onContactLongPress;

  const AppBottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
    this.onContactLongPress,
  });

  /// Standard navigation items matching the website structure and user request.
  static const List<AppNavItem> navItems = <AppNavItem>[
    AppNavItem(
      label: 'Главная',
      activeIcon: Icons.home_rounded,
      inactiveIcon: Icons.home_outlined,
      url: AppConfig.homeUrl,
    ),
    AppNavItem(
      label: 'Туры',
      activeIcon: Icons.travel_explore_rounded,
      inactiveIcon: Icons.travel_explore_outlined,
      url: AppConfig.toursUrl,
    ),
    AppNavItem(
      label: 'Горящие',
      activeIcon: Icons.local_fire_department_rounded,
      inactiveIcon: Icons.local_fire_department_outlined,
      url: AppConfig.hotToursUrl,
    ),
    AppNavItem(
      label: 'Услуги',
      activeIcon: Icons.grid_view_rounded,
      inactiveIcon: Icons.grid_view_outlined,
      url: AppConfig.servicesUrl,
    ),
    AppNavItem(
      label: 'Контакты',
      activeIcon: Icons.phone_in_talk_rounded,
      inactiveIcon: Icons.phone_in_talk_outlined,
      url: AppConfig.contactsUrl,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final double screenHeight = MediaQuery.sizeOf(context).height;
    final bool isCompactHeight = screenHeight < 500;
    final double barHeight = isCompactHeight ? 52.0 : 62.0;
    final double iconSize = isCompactHeight ? 21.0 : 24.0;
    final double fontSize = isCompactHeight ? 9.5 : 10.5;

    return MediaQuery.withClampedTextScaling(
      maxScaleFactor: 1.1,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: <BoxShadow>[
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 12,
              offset: const Offset(0, -3),
            ),
          ],
          border: const Border(
            top: BorderSide(
              color: Color(0xFFEEEEEE),
              width: 1,
            ),
          ),
        ),
        child: SafeArea(
          top: false,
          child: SizedBox(
            height: barHeight,
            child: Center(
              child: ConstrainedBox(
                // Keep navigation bar neatly proportioned on tablets and wide screens
                constraints: const BoxConstraints(maxWidth: 640),
                child: LayoutBuilder(
                  builder: (BuildContext context, BoxConstraints constraints) {
                    if (constraints.maxWidth < 50 || constraints.maxHeight < 15) {
                      return const SizedBox.shrink();
                    }
                    final double tabWidth = constraints.maxWidth / navItems.length;
                    final double horizontalPadding = tabWidth < 70
                        ? 6.0
                        : (tabWidth < 85 ? 10.0 : 14.0);

                    return Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: List<Widget>.generate(navItems.length, (int index) {
                        final AppNavItem item = navItems[index];
                        final bool isSelected = currentIndex == index;

                        return Expanded(
                          child: Tooltip(
                            message: item.label,
                            waitDuration: const Duration(milliseconds: 600),
                            child: Semantics(
                              label: item.label,
                              selected: isSelected,
                              button: true,
                              child: InkWell(
                                onTap: () {
                                  HapticFeedback.selectionClick();
                                  onTap(index);
                                },
                                onLongPress: () {
                                  if (index == 4 && onContactLongPress != null) {
                                    HapticFeedback.mediumImpact();
                                    onContactLongPress!();
                                  }
                                },
                                splashColor: AppConfig.primaryColor.withValues(alpha: 0.12),
                                highlightColor: Colors.transparent,
                                child: Center(
                                  child: FittedBox(
                                    fit: BoxFit.scaleDown,
                                    alignment: Alignment.center,
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      mainAxisSize: MainAxisSize.min,
                                      children: <Widget>[
                                        // Indicator pill / icon wrapper
                                        AnimatedContainer(
                                          duration: const Duration(milliseconds: 220),
                                          curve: Curves.easeOutCubic,
                                          padding: EdgeInsets.symmetric(
                                            horizontal: horizontalPadding,
                                            vertical: isCompactHeight ? 2 : 3,
                                          ),
                                          decoration: BoxDecoration(
                                            color: isSelected
                                                ? AppConfig.primaryColor.withValues(alpha: 0.14)
                                                : Colors.transparent,
                                            borderRadius: BorderRadius.circular(16),
                                          ),
                                          child: Icon(
                                            isSelected ? item.activeIcon : item.inactiveIcon,
                                            color: isSelected
                                                ? AppConfig.primaryColor
                                                : const Color(0xFF757575),
                                            size: iconSize,
                                          ),
                                        ),
                                        SizedBox(height: isCompactHeight ? 2 : 3),

                                        // Tab Label with overflow protection
                                        Padding(
                                          padding: const EdgeInsets.symmetric(horizontal: 2.0),
                                          child: FittedBox(
                                            fit: BoxFit.scaleDown,
                                            child: AnimatedDefaultTextStyle(
                                              duration: const Duration(milliseconds: 200),
                                              style: TextStyle(
                                                fontSize: fontSize,
                                                fontWeight: isSelected
                                                    ? FontWeight.w700
                                                    : FontWeight.w500,
                                                color: isSelected
                                                    ? AppConfig.primaryColor
                                                    : const Color(0xFF757575),
                                                letterSpacing: 0.2,
                                              ),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                              child: Text(item.label),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        );
                      }),
                    );
                  },
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
