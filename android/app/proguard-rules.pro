# Flutter-specific ProGuard rules for release builds

# Keep Flutter engine classes
-keep class io.flutter.** { *; }
-keep class io.flutter.plugins.** { *; }
-keep class io.flutter.util.** { *; }
-keep class io.flutter.view.** { *; }
-keep class io.flutter.embedding.** { *; }

# Keep WebView classes (webview_flutter)
-keep class com.google.android.gms.** { *; }
-keepclassmembers class * {
    @android.webkit.JavascriptInterface <methods>;
}
-keep class android.webkit.** { *; }

# Keep url_launcher plugin
-keep class io.flutter.plugins.urllauncher.** { *; }

# Prevent obfuscation of classes referenced via reflection
-keepattributes *Annotation*
-keepattributes Signature
-keepattributes InnerClasses
-keepattributes EnclosingMethod

# Suppress warnings for common third-party libraries
-dontwarn com.google.android.play.core.**
-dontwarn kotlin.**
-dontwarn kotlinx.**
