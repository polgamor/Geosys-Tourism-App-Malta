import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:arcgis_maps/arcgis_maps.dart';

import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:geosys_app/localization/generated/app_localizations.dart';

import 'package:geosys_app/features/splash/splash_screen.dart';
import 'package:geosys_app/colors.dart';
import 'package:geosys_app/localization/locale_provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await dotenv.load(fileName: ".env");

  await Supabase.initialize(
    url: dotenv.env['SUPABASE_URL'] ?? '',
    anonKey: dotenv.env['SUPABASE_ANON_KEY'] ?? '',
  );

  await _configureArcGIS();

  runApp(
    ChangeNotifierProvider(
      create: (context) => LocaleProvider(),
      child: const MyApp(),
    ),
  );
}

Future<void> _configureArcGIS() async {
  try {
    const String apiKey = 'AAPTxy8BH1VEsoebNVZXo8HurI26VsBlOV7HslCVNl-XGEyB-8JxTxkmmV8vkfevV5vrP5Ml2p5Pyu66mC0sTRBuNara33ocBwgOqwswzyNG8mpbYsb287QGZFCK4sfZaD19k57jymmtZ7zT4RdTr0HZ6LIlp014JavaxU8gHIx8ObgQJrJ1y11qIW9Xg2Ku5JJc7Ay7wVJ80bBldhFggGnTA7K0ElyhsMuyyVDVaPpVdGk.AT1_wHMofka6';
    ArcGISEnvironment.apiKey = apiKey;
  } catch (e) {
    debugPrint('Failed to configure ArcGIS environment: $e');
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final localeProvider = Provider.of<LocaleProvider>(context);

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      onGenerateTitle: (context) => AppLocalizations.of(context)!.appTitle,
      locale: localeProvider.locale,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('en'),
        Locale('es'),
        Locale('mt'),
        Locale('fr'),
        Locale('it'),
        Locale('de'),
      ],
      theme: _buildTheme(),
      home: const SplashScreen(),
    );
  }

  ThemeData _buildTheme() {
    return ThemeData(
      primarySwatch: AppColors.primarySwatch,
      scaffoldBackgroundColor: AppColors.background,
      brightness: Brightness.dark,
      appBarTheme: const AppBarTheme(
        elevation: 0,
        backgroundColor: AppColors.background,
        titleTextStyle: TextStyle(
          color: Colors.white,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
        iconTheme: IconThemeData(color: AppColors.primary),
      ),
      colorScheme: ColorScheme.dark(
        primary: AppColors.primary,
        secondary: AppColors.accent,
        surface: AppColors.background,
        error: Colors.red,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: Colors.white,
        onError: Colors.white,
      ),
    );
  }
}
