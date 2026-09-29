import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:webview_flutter/webview_flutter.dart';
import '../config/app_config.dart';

/// Utility class for evaluating and delegating URLs encountered in WebView navigation.
class UrlHandler {
  UrlHandler._();

  /// Checks whether a given URI belongs to the internal website domain.
  static bool isInternalUrl(Uri uri) {
    if (uri.scheme == 'about' || uri.scheme == 'data' || uri.scheme == 'blob') {
      return true;
    }
    if (uri.scheme != 'http' && uri.scheme != 'https') {
      return false;
    }
    final String host = uri.host.toLowerCase();
    if (host.isEmpty) {
      return true;
    }
    for (final String internalHost in AppConfig.internalHosts) {
      if (host == internalHost.toLowerCase() ||
          host.endsWith('.$internalHost')) {
        return true;
      }
    }
    return false;
  }

  /// Checks whether a given URI is an external link or service.
  static bool isExternalUrl(Uri uri) => !isInternalUrl(uri);

  /// Handles navigation decision for webview_flutter [NavigationRequest].
  /// Returns [NavigationDecision.prevent] if launched externally or ignored, or [NavigationDecision.navigate] otherwise.
  ///
  /// This method intentionally returns a synchronous [NavigationDecision] to prevent
  /// a race condition where the WebView starts loading the URL while awaiting an async result.
  static NavigationDecision handleNavigationRequest(
    NavigationRequest request, {
    BuildContext? context,
  }) {
    // Ignore javascript: pseudo-URLs (e.g. href="javascript:void(0)") to prevent erroneous external launch attempts
    if (request.url.startsWith('javascript:')) {
      return NavigationDecision.prevent;
    }

    final Uri? uri = Uri.tryParse(request.url);
    if (uri == null) {
      return NavigationDecision.prevent;
    }

    if (uri.scheme == 'javascript') {
      return NavigationDecision.prevent;
    }

    // Internal URLs stay in the WebView
    if (isInternalUrl(uri)) {
      return NavigationDecision.navigate;
    }

    // Sanitize tel: URIs by removing whitespaces and brackets that cause dialer launch failures
    Uri targetUri = uri;
    if (uri.scheme == 'tel') {
      final String sanitizedPath = uri.path.replaceAll(RegExp(r'[\s\-\(\)]'), '');
      targetUri = Uri(scheme: 'tel', path: sanitizedPath);
    }

    // External URL or scheme -> fire-and-forget external launch (no awaiting to avoid race conditions)
    _launchExternalWithFeedback(targetUri, request.url, context);

    return NavigationDecision.prevent;
  }

  /// Fires an external launch and shows a snackbar error if it fails.
  /// This is intentionally fire-and-forget to keep the navigation decision synchronous.
  static void _launchExternalWithFeedback(
    Uri targetUri,
    String originalUrl,
    BuildContext? context,
  ) {
    launchExternal(targetUri).then((bool launched) {
      if (!launched && context != null && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Не удалось открыть ссылку: $originalUrl'),
            duration: const Duration(seconds: 2),
          ),
        );
      }
    });
  }

  /// Attempts to launch an external URI via [url_launcher] with robust fallbacks for intent: schemes.
  static Future<bool> launchExternal(Uri uri) async {
    // Direct native launch for Telegram (e.g. t.me/zolotoy_tour -> tg://resolve?domain=zolotoy_tour)
    if (uri.host == 't.me' || uri.host == 'telegram.me') {
      final String cleanPath = uri.path.replaceAll('/', '');
      if (cleanPath.isNotEmpty) {
        final Uri tgAppUri = Uri.parse('tg://resolve?domain=$cleanPath');
        try {
          if (await canLaunchUrl(tgAppUri)) {
            final bool launched = await launchUrl(
              tgAppUri,
              mode: LaunchMode.externalNonBrowserApplication,
            );
            if (launched) return true;
          }
        } catch (_) {}
      }
    }

    try {
      if (await canLaunchUrl(uri)) {
        return await launchUrl(
          uri,
          mode: LaunchMode.externalApplication,
        );
      } else {
        // Fallback for intent: or schemes without strict query registration
        final bool nonBrowserLaunched = await launchUrl(
          uri,
          mode: LaunchMode.externalNonBrowserApplication,
        );
        if (nonBrowserLaunched) return true;
      }
    } catch (_) {
      // Continue to intent / web fallback
    }

    // Handle Android intent: fallback (e.g., intent://...#Intent;S.browser_fallback_url=...;end)
    if (uri.scheme == 'intent') {
      final Uri? fallbackUri = _extractIntentFallback(uri.toString());
      if (fallbackUri != null) {
        return launchExternal(fallbackUri);
      }
    }

    try {
      // Ultimate platformDefault fallback
      return await launchUrl(
        uri,
        mode: LaunchMode.platformDefault,
      );
    } catch (_) {
      return false;
    }
  }

  /// Extracts fallback web URL from Android intent: URI string.
  static Uri? _extractIntentFallback(String intentUrl) {
    try {
      // Look for S.browser_fallback_url= parameter
      final RegExp fallbackRegex = RegExp(r'S\.browser_fallback_url=([^;]+)');
      final Match? match = fallbackRegex.firstMatch(intentUrl);
      if (match != null && match.groupCount >= 1) {
        final String rawFallback = match.group(1)!;
        final String decoded = Uri.decodeComponent(rawFallback);
        return Uri.tryParse(decoded);
      }

      // Reconstruct https: from intent if scheme=https or scheme=http is specified
      final RegExp schemeRegex = RegExp(r'scheme=([^;]+)');
      final Match? schemeMatch = schemeRegex.firstMatch(intentUrl);
      if (schemeMatch != null && schemeMatch.groupCount >= 1) {
        final String scheme = schemeMatch.group(1)!;
        if (scheme == 'http' || scheme == 'https') {
          final String body = intentUrl
              .replaceFirst(RegExp(r'^intent:\/\/'), '')
              .split('#')[0];
          return Uri.tryParse('$scheme://$body');
        }
      }
    } catch (_) {}
    return null;
  }
}
