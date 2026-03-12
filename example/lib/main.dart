import 'package:flutter/material.dart';
import 'package:adrop_ads_flutter/adrop_ads_flutter.dart';
import 'screens/main_screen.dart';
import 'services/ad_manager.dart';
import 'theme/colors.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  // 1. SDK initialize
  Adrop.initialize(false);

  // 2. Preload startup popup & exit interstitial
  AdManager.instance.preloadStartupPopup();
  AdManager.instance.preloadExitInterstitial();

  runApp(const AdropExampleApp());
}

class AdropExampleApp extends StatelessWidget {
  const AdropExampleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Adrop Ads',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: AdropColors.primary,
        scaffoldBackgroundColor: AdropColors.background,
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.white,
          foregroundColor: AdropColors.textPrimary,
          elevation: 0,
        ),
      ),
      home: const MainScreen(),
    );
  }
}
