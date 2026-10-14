import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:owner_app/auth/login_page.dart';
import 'package:owner_app/profil/Documents/documentpage.dart';
import 'package:service/snackbar_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:service/service_locator.dart';

import 'acceuil/home1.dart';
import 'acceuil/home2.dart';
import 'acceuil/page_decouvrir.dart';
import 'auth/register.dart';
import 'core/theme/app_theme.dart';
import 'core/navigation/main_wrapper.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  FlutterError.onError = (FlutterErrorDetails details) {
    final exception = details.exception;

    // Ignorer les erreurs d'URI invalides (chemins Storage non-URL)
    if (exception is ArgumentError &&
        exception.message.toString().contains('No host specified in URI')) {
      debugPrint(
        'Image ignorée (chemin Storage non résolu) : '
            '${details.context ?? "inconnu"}',
      );
      return;
    }

    // Autres erreurs comportement par défaut
    FlutterError.presentError(details);
  };

  // SUPABASE
  await Supabase.initialize(
    url: 'https://rcaujtlhfyumkuwdfpcm.supabase.co',
    publishableKey:
    'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InJjYXVqdGxoZnl1bWt1d2RmcGNtIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjAyMzM5MTEsImV4cCI6MjA3NTgwOTkxMX0.AAGqqVywuJ_0D4YT9_TcE6-CKs2b3A4TS60mSEGIgbE',
  );

  // SERVICES
  ServiceLocator.initialize();

  // APPLICATION
  runApp(
    const OwnerApp(),
  );
}

class OwnerApp extends StatelessWidget {
  const OwnerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(390, 844),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'DS Pro',

          // NAVIGATION
          navigatorKey: ServiceLocator.navigation.navigatorKey,

          // SNACKBAR SERVICE
          scaffoldMessengerKey: SnackBarService.messengerKey,

          // THEME
          theme: AppTheme.lightTheme,

          locale: const Locale('fr', 'FR'),

          supportedLocales: const [
            Locale('fr', 'FR'),
          ],

          localizationsDelegates: const [
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],

          // ROUTES
          initialRoute: '/welcome',

          routes: {
            // ACCUEIL
            '/welcome': (context) => const WelcomeScreen(),
            '/onboarding': (context) => const OnboardingScreen(),
            '/home2': (context) => const Home2Page(),

            // AUTHENTIFICATION PROPRIÉTAIRE
            '/register': (context) => const RegisterPage(),
            '/connexion': (context) => const ConnexionWidget(),

            '/documents': (context) => const DocumentsPage(),

            // ESPACE PROPRIÉTAIRE
            '/owner-dashboard': (context) => const MainWrapper(),
          },
        );
      },
    );
  }
}