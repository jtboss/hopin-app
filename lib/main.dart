import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';

import 'constants/app_constants.dart';
import 'constants/app_colors.dart';
import 'services/auth_service.dart';
import 'services/analytics_service.dart';
import 'pages/splash_screen.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  
  // Set up Crashlytics
  FlutterError.onError = (errorDetails) {
    FirebaseCrashlytics.instance.recordFlutterFatalError(errorDetails);
  };
  
  runApp(const HopinApp());
}

class HopinApp extends StatelessWidget {
  const HopinApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthService()),
        Provider(create: (_) => AnalyticsService()),
      ],
      child: MaterialApp(
        title: AppConstants.appName,
        debugShowCheckedModeBanner: false,
        
        // Analytics
        navigatorObservers: [
          FirebaseAnalyticsObserver(analytics: FirebaseAnalytics.instance),
        ],
        
        // Theme Configuration
        theme: ThemeData(
          primarySwatch: MaterialColor(
            AppColors.primary.value,
            <int, Color>{
              50: AppColors.primary.withOpacity(0.1),
              100: AppColors.primary.withOpacity(0.2),
              200: AppColors.primary.withOpacity(0.3),
              300: AppColors.primary.withOpacity(0.4),
              400: AppColors.primary.withOpacity(0.5),
              500: AppColors.primary,
              600: AppColors.primary,
              700: AppColors.primary,
              800: AppColors.primary,
              900: AppColors.primary,
            },
          ),
          colorScheme: ColorScheme.fromSeed(
            seedColor: AppColors.primary,
            background: AppColors.background,
            surface: AppColors.surface,
            error: AppColors.error,
          ),
          useMaterial3: true,
          
          // Typography
          textTheme: GoogleFonts.interTextTheme(
            Theme.of(context).textTheme,
          ).copyWith(
            bodyLarge: GoogleFonts.inter(
              color: AppColors.textPrimary,
              fontSize: 16,
            ),
            bodyMedium: GoogleFonts.inter(
              color: AppColors.textSecondary,
              fontSize: 14,
            ),
            headlineMedium: GoogleFonts.inter(
              color: AppColors.textPrimary,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          
          // Component Themes
          appBarTheme: AppBarTheme(
            backgroundColor: AppColors.surface,
            foregroundColor: AppColors.textPrimary,
            elevation: 0,
            titleTextStyle: GoogleFonts.inter(
              color: AppColors.textPrimary,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              textStyle: GoogleFonts.inter(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          
          inputDecorationTheme: InputDecorationTheme(
            filled: true,
            fillColor: AppColors.surface,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: AppColors.textSecondary.withOpacity(0.3)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: AppColors.textSecondary.withOpacity(0.3)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: AppColors.primary, width: 2),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: AppColors.error),
            ),
            labelStyle: GoogleFonts.inter(
              color: AppColors.textSecondary,
              fontSize: 14,
            ),
            hintStyle: GoogleFonts.inter(
              color: AppColors.textSecondary.withOpacity(0.7),
              fontSize: 14,
            ),
          ),
        ),
        
        // Routes
        home: const SplashScreen(),
      ),
    );
  }
}