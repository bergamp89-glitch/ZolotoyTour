import 'package:flutter/material.dart';
import 'config/app_config.dart';
import 'screens/webview_screen.dart';

/// The root widget of the Zolotoy Tour application.
class ZolotoyTourApp extends StatelessWidget {
  const ZolotoyTourApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: AppConfig.appName,
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppConfig.primaryColor,
          primary: AppConfig.primaryColor,
          surface: AppConfig.lightBackgroundColor,
        ),
        scaffoldBackgroundColor: AppConfig.lightBackgroundColor,
        appBarTheme: const AppBarTheme(
          backgroundColor: AppConfig.darkBackgroundColor,
          foregroundColor: Colors.white,
          elevation: 0,
        ),
      ),
      home: const WebViewScreen(),
    );
  }
}
