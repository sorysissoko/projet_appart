import 'package:admin/presentation/providers/user_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:service/service_locator.dart';
import 'package:service/session_activity_detector.dart';
import 'package:service/session_timeout_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'core/constants/color_constants.dart';
import 'presentation/controllers/menu_app_controller.dart';
import 'presentation/controllers/dashboard_controller.dart';
import 'routes.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // SUPABASE
  await Supabase.initialize(
    url: 'https://rcaujtlhfyumkuwdfpcm.supabase.co',
    publishableKey:
    'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InJjYXVqdGxoZnl1bWt1d2RmcGNtIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjAyMzM5MTEsImV4cCI6MjA3NTgwOTkxMX0.AAGqqVywuJ_0D4YT9_TcE6-CKs2b3A4TS60mSEGIgbE',
  );

  // SERVICES
  ServiceLocator.initialize();

  // SESSION ADMIN - 15 MINUTES
  await SessionTimeoutService().initialize();

  // APPLICATION
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => MenuAppController(),
        ),
        ChangeNotifierProvider(
          create: (_) => DashboardController(),
        ),
        ChangeNotifierProvider(
          create: (_) => UserProvider()..loadProfile(),
        ),
      ],
      child: const AdminApp(),
    ),
  );
}

class AdminApp extends StatelessWidget {
  const AdminApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(1920, 1080),
      minTextAdapt: true,
      splitScreenMode: true,
      useInheritedMediaQuery: true,

      builder: (_, child) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'ADS Administration',

          navigatorKey: ServiceLocator.navigation.navigatorKey,

          locale: const Locale('fr', 'FR'),

          supportedLocales: const [
            Locale('fr', 'FR'),
            Locale('en', 'US'),
          ],

          localizationsDelegates: const [
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],

          theme: ThemeData.dark().copyWith(
            scaffoldBackgroundColor: bgColor,
            textTheme: GoogleFonts.poppinsTextTheme(
              Theme.of(context).textTheme,
            ),
            canvasColor: secondaryColor,
          ),

          initialRoute: AppRoutes.home,
          onGenerateRoute: AppRoutes.generateRoute,

          builder: (context, child) {
            return SessionActivityDetector(
              child: child ?? const SizedBox.shrink(),
            );
          },
        );
      },
    );
  }
}