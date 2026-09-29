import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../config/app_config.dart';
import 'webview_screen.dart';

/// Premium travel/tourism-themed luxury Splash Screen for Zolotoy Tour.
/// Features:
/// 1. Smooth entrance animation with gold ambient glow and logo scaling.
/// 2. Continuous rotating celestial travel orbit with a gliding airplane and flight trail.
/// 3. Compass cardinal points and concentric radar rings reflecting world exploration.
/// 4. Elegant brand typography ("ZOLOTOY TOUR" & "ТУРИСТИЧЕСКОЕ АГЕНТСТВО").
/// 5. Subtle voyage waypoints shimmer dots.
class SplashScreen extends StatefulWidget {
  final VoidCallback? onFinished;
  final bool isOverlay;

  const SplashScreen({
    super.key,
    this.onFinished,
    this.isOverlay = false,
  });

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late final AnimationController _entranceController;
  late final AnimationController _orbitController;
  late final AnimationController _pulseController;

  late final Animation<double> _scaleAnimation;
  late final Animation<double> _fadeAnimation;
  late final Animation<double> _glowScaleAnimation;
  late final Animation<double> _glowOpacityAnimation;
  late final Animation<double> _textFadeAnimation;
  late final Animation<Offset> _textSlideAnimation;

  Timer? _fallbackTimer;
  bool _hasNavigated = false;

  @override
  void initState() {
    super.initState();

    // 1. Entrance animation (scale-in, fade-in for logo and brand texts)
    _entranceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1600),
    );

    // 2. Continuous long-duration rotating travel orbit around the logo (airplane & flight trail)
    _orbitController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 6000),
    )..repeat();

    // 3. Gentle breathing ambient luxury gold glow
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2400),
    )..repeat(reverse: true);

    // Entrance transitions
    _scaleAnimation = Tween<double>(begin: 0.82, end: 1.0).animate(
      CurvedAnimation(
        parent: _entranceController,
        curve: const Interval(0.0, 0.65, curve: Curves.easeOutCubic),
      ),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _entranceController,
        curve: const Interval(0.0, 0.50, curve: Curves.easeOut),
      ),
    );

    _glowScaleAnimation = Tween<double>(begin: 0.70, end: 1.08).animate(
      CurvedAnimation(
        parent: _entranceController,
        curve: const Interval(0.1, 0.75, curve: Curves.easeOutCubic),
      ),
    );

    _glowOpacityAnimation = Tween<double>(begin: 0.0, end: 0.32).animate(
      CurvedAnimation(
        parent: _entranceController,
        curve: const Interval(0.1, 0.60, curve: Curves.easeOut),
      ),
    );

    _textFadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _entranceController,
        curve: const Interval(0.40, 0.95, curve: Curves.easeOut),
      ),
    );

    _textSlideAnimation = Tween<Offset>(
      begin: const Offset(0.0, 0.25),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _entranceController,
        curve: const Interval(0.40, 0.95, curve: Curves.easeOutCubic),
      ),
    );

    _entranceController.forward();

    // Fallback timer only needed for standalone splash screen mode
    if (!widget.isOverlay) {
      _fallbackTimer = Timer(const Duration(milliseconds: 3800), () {
        _navigateToHome();
      });
    }
  }

  void _navigateToHome() {
    if (_hasNavigated || !mounted) return;
    _hasNavigated = true;
    _fallbackTimer?.cancel();

    if (widget.onFinished != null) {
      widget.onFinished!();
      return;
    }

    Navigator.of(context).pushReplacement(
      PageRouteBuilder<void>(
        pageBuilder: (BuildContext context, Animation<double> animation,
            Animation<double> secondaryAnimation) {
          return const WebViewScreen();
        },
        transitionsBuilder: (BuildContext context,
            Animation<double> animation,
            Animation<double> secondaryAnimation,
            Widget child) {
          return FadeTransition(
            opacity: CurvedAnimation(
              parent: animation,
              curve: Curves.easeOut,
            ),
            child: child,
          );
        },
        transitionDuration: const Duration(milliseconds: 300),
      ),
    );
  }

  @override
  void dispose() {
    _fallbackTimer?.cancel();
    _entranceController.dispose();
    _orbitController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.dark,
        systemNavigationBarColor: AppConfig.darkBackgroundColor,
        systemNavigationBarIconBrightness: Brightness.light,
      ),
      child: Scaffold(
        backgroundColor: AppConfig.darkBackgroundColor,
        body: SafeArea(
          child: Center(
            child: LayoutBuilder(
              builder: (BuildContext context, BoxConstraints constraints) {
                final double shortestSide = constraints.biggest.shortestSide;
                // Proportional logo dimension adaptively constrained between 110 and 200
                final double logoSize = (shortestSide * 0.44).clamp(110.0, 200.0);
                final double orbitCanvasSize = logoSize * 1.68;
                final double glowSize = logoSize * 1.25;

                return SingleChildScrollView(
                  physics: const NeverScrollableScrollPhysics(),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        // 1. Celestial Travel Orbit Canvas + Logo Center
                        AnimatedBuilder(
                          animation: Listenable.merge(<Listenable>[
                            _entranceController,
                            _orbitController,
                            _pulseController,
                          ]),
                          child: Image.asset(
                            'assets/images/logo.png',
                            width: logoSize,
                            height: logoSize,
                            fit: BoxFit.contain,
                            errorBuilder: (BuildContext context, Object error,
                                StackTrace? stackTrace) {
                              return const Icon(
                                Icons.travel_explore_rounded,
                                size: 90,
                                color: AppConfig.primaryColor,
                              );
                            },
                          ),
                          builder: (BuildContext context, Widget? logoChild) {
                            final double entranceVal = _fadeAnimation.value;
                            final double scaleVal = _scaleAnimation.value;
                            final double pulseVal = _pulseController.value;
                            final double glowOpacity =
                                (_glowOpacityAnimation.value * (0.8 + 0.3 * pulseVal))
                                    .clamp(0.0, 1.0);

                            return Opacity(
                              opacity: entranceVal,
                              child: Stack(
                                alignment: Alignment.center,
                                children: <Widget>[
                                  // GPU-accelerated Tourism Orbit Painter (airplane + compass rings)
                                  CustomPaint(
                                    size: Size(orbitCanvasSize, orbitCanvasSize),
                                    painter: _TourismOrbitPainter(
                                      orbitProgress: _orbitController.value,
                                      pulseProgress: _pulseController.value,
                                      entranceProgress: _entranceController.value,
                                      primaryColor: AppConfig.primaryColor,
                                    ),
                                  ),

                                  // Ambient luxury gold radial glow aura
                                  Transform.scale(
                                    scale: _glowScaleAnimation.value *
                                        (0.96 + 0.08 * pulseVal),
                                    child: Container(
                                      width: glowSize,
                                      height: glowSize,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        gradient: RadialGradient(
                                          colors: <Color>[
                                            AppConfig.primaryColor
                                                .withValues(alpha: glowOpacity),
                                            AppConfig.primaryColor
                                                .withValues(alpha: glowOpacity * 0.3),
                                            Colors.transparent,
                                          ],
                                          stops: const <double>[0.0, 0.45, 1.0],
                                        ),
                                      ),
                                    ),
                                  ),

                                  // Official brand logo (reused cleanly)
                                  Transform.scale(
                                    scale: scaleVal,
                                    child: logoChild,
                                  ),
                                ],
                              ),
                            );
                          },
                        ),

                        const SizedBox(height: 18),

                        // 2. Elegant Brand Typography & Travel Slogan
                        AnimatedBuilder(
                          animation: _entranceController,
                          builder: (BuildContext context, Widget? _) {
                            final double textOpacity = _textFadeAnimation.value;
                            return Opacity(
                              opacity: textOpacity,
                              child: SlideTransition(
                                position: _textSlideAnimation,
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: <Widget>[
                                    // Brand Name
                                    const Text(
                                      'ZOLOTOY TOUR',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 22,
                                        fontWeight: FontWeight.w800,
                                        letterSpacing: 4.5,
                                        height: 1.2,
                                      ),
                                    ),
                                    const SizedBox(height: 6),

                                    // Tourism Tagline
                                    Text(
                                      'ТУРИСТИЧЕСКОЕ АГЕНТСТВО',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        color: AppConfig.primaryColor
                                            .withValues(alpha: 0.92),
                                        fontSize: 11.5,
                                        fontWeight: FontWeight.w600,
                                        letterSpacing: 2.4,
                                      ),
                                    ),
                                    const SizedBox(height: 4),

                                    Text(
                                      'Ваш надёжный гид по миру',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        color: Colors.white.withValues(alpha: 0.55),
                                        fontSize: 12.0,
                                        fontWeight: FontWeight.w400,
                                        letterSpacing: 0.8,
                                      ),
                                    ),

                                    const SizedBox(height: 22),

                                    // 3. Voyage Waypoints Pulse Shimmer
                                    _buildVoyageWaypoints(),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  /// Minimalist luxury voyage waypoints indicator (3 golden glowing dots)
  Widget _buildVoyageWaypoints() {
    return AnimatedBuilder(
      animation: _orbitController,
      builder: (BuildContext context, Widget? _) {
        final double t = _orbitController.value * 3.0;
        return Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: List<Widget>.generate(3, (int i) {
            // Wave pulse offset for each dot
            final double dotProgress = (t - i * 0.7) % 1.0;
            final double dotScale = 0.8 + 0.4 * math.sin(dotProgress * math.pi);
            final double dotAlpha = 0.35 + 0.65 * math.sin(dotProgress * math.pi);

            return Container(
              margin: const EdgeInsets.symmetric(horizontal: 4.5),
              width: 5.5 * dotScale,
              height: 5.5 * dotScale,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppConfig.primaryColor.withValues(alpha: dotAlpha),
                boxShadow: <BoxShadow>[
                  BoxShadow(
                    color: AppConfig.primaryColor.withValues(alpha: dotAlpha * 0.6),
                    blurRadius: 6.0,
                    spreadRadius: 1.0,
                  ),
                ],
              ),
            );
          }),
        );
      },
    );
  }
}

/// Custom GPU-accelerated painter that draws celestial travel orbit rings,
/// cardinal compass points, and a gliding golden airplane flight trail.
class _TourismOrbitPainter extends CustomPainter {
  final double orbitProgress; // 0.0 to 1.0 (from _orbitController)
  final double pulseProgress; // 0.0 to 1.0 (from _pulseController)
  final double entranceProgress; // 0.0 to 1.0 (from _entranceController)
  final Color primaryColor;

  _TourismOrbitPainter({
    required this.orbitProgress,
    required this.pulseProgress,
    required this.entranceProgress,
    required this.primaryColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (entranceProgress <= 0.05) return;

    final Offset center = Offset(size.width / 2, size.height / 2);
    final double baseRadius = (size.width / 2) * 0.90;

    // 1. Concentric ambient compass ring
    final Paint ringPaint = Paint()
      ..color = primaryColor.withValues(alpha: 0.14 * entranceProgress)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;
    canvas.drawCircle(center, baseRadius, ringPaint);

    // Subtle inner pulsing radar ripple ring
    final double rippleRadius = baseRadius * (0.80 + 0.10 * pulseProgress);
    final Paint ripplePaint = Paint()
      ..color = primaryColor.withValues(
          alpha: (0.16 - 0.09 * pulseProgress) * entranceProgress)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;
    canvas.drawCircle(center, rippleRadius, ripplePaint);

    // 2. Cardinal Compass Ticks (North, South, East, West)
    final Paint tickPaint = Paint()
      ..color = primaryColor.withValues(alpha: 0.38 * entranceProgress)
      ..strokeWidth = 1.5
      ..strokeCap = StrokeCap.round;

    const double tickLength = 7.0;
    // North tick
    canvas.drawLine(
      Offset(center.dx, center.dy - baseRadius - 2),
      Offset(center.dx, center.dy - baseRadius - 2 - tickLength),
      tickPaint,
    );
    // South tick
    canvas.drawLine(
      Offset(center.dx, center.dy + baseRadius + 2),
      Offset(center.dx, center.dy + baseRadius + 2 + tickLength),
      tickPaint,
    );
    // East tick
    canvas.drawLine(
      Offset(center.dx + baseRadius + 2, center.dy),
      Offset(center.dx + baseRadius + 2 + tickLength, center.dy),
      tickPaint,
    );
    // West tick
    canvas.drawLine(
      Offset(center.dx - baseRadius - 2, center.dy),
      Offset(center.dx - baseRadius - 2 - tickLength, center.dy),
      tickPaint,
    );

    // 3. Tilted Celestial Travel Orbit (Ellipse tilted at -22 degrees)
    const double tiltAngle = -22.0 * math.pi / 180.0;
    final double a = baseRadius * 1.06; // major axis
    final double b = baseRadius * 0.60; // minor axis

    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.rotate(tiltAngle);

    // Faint elliptical orbit guide
    final Rect orbitRect = Rect.fromCenter(
      center: Offset.zero,
      width: a * 2,
      height: b * 2,
    );
    final Paint orbitPathPaint = Paint()
      ..color = primaryColor.withValues(alpha: 0.18 * entranceProgress)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;
    canvas.drawOval(orbitRect, orbitPathPaint);

    // 4. Gliding Golden Flight Trail (an arc of the ellipse trailing behind current position)
    final double currentAngle = orbitProgress * 2 * math.pi;
    const int trailSegments = 24;
    const double trailSpan = 0.95; // in radians (~55 degrees trail)

    for (int i = 0; i < trailSegments; i++) {
      final double fraction = i / trailSegments;
      final double segAngle = currentAngle - trailSpan * (1.0 - fraction);
      final double nextAngle =
          currentAngle - trailSpan * (1.0 - (i + 1) / trailSegments);

      final Offset p1 = Offset(a * math.cos(segAngle), b * math.sin(segAngle));
      final Offset p2 = Offset(a * math.cos(nextAngle), b * math.sin(nextAngle));

      final double segAlpha = fraction * 0.75 * entranceProgress;
      final Paint trailPaint = Paint()
        ..color = primaryColor.withValues(alpha: segAlpha)
        ..strokeWidth = 1.0 + 1.8 * fraction
        ..strokeCap = StrokeCap.round;

      canvas.drawLine(p1, p2, trailPaint);
    }

    // 5. Golden Flight Airplane / Marker at the head of the orbit
    final double headX = a * math.cos(currentAngle);
    final double headY = b * math.sin(currentAngle);
    final Offset headPos = Offset(headX, headY);

    // Heading direction vector tangent to the ellipse
    final double tangentX = -a * math.sin(currentAngle);
    final double tangentY = b * math.cos(currentAngle);
    final double headingAngle = math.atan2(tangentY, tangentX);

    // Airplane glow
    final Paint planeGlowPaint = Paint()
      ..color = primaryColor.withValues(alpha: 0.55 * entranceProgress)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5.0);
    canvas.drawCircle(headPos, 4.5, planeGlowPaint);

    // Stylized miniature golden airplane
    canvas.save();
    canvas.translate(headX, headY);
    canvas.rotate(headingAngle);

    final Paint airplanePaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    final Path planePath = Path()
      ..moveTo(6.5, 0.0) // nose
      ..lineTo(-3.5, -4.8) // wing tip left
      ..lineTo(-1.5, -1.0)
      ..lineTo(-5.2, -2.6) // tail left
      ..lineTo(-4.0, 0.0)
      ..lineTo(-5.2, 2.6) // tail right
      ..lineTo(-1.5, 1.0)
      ..lineTo(-3.5, 4.8) // wing tip right
      ..close();

    canvas.drawPath(planePath, airplanePaint);

    // Gold core highlight on the airplane fuselage
    final Paint planeCore = Paint()..color = primaryColor;
    canvas.drawCircle(Offset.zero, 1.2, planeCore);

    canvas.restore();
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _TourismOrbitPainter oldDelegate) {
    return oldDelegate.orbitProgress != orbitProgress ||
        oldDelegate.pulseProgress != pulseProgress ||
        oldDelegate.entranceProgress != entranceProgress;
  }
}
