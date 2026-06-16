import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'core/theme/app_theme_controller.dart';
import 'core/theme/app_theme.dart';
import 'core/storage/session_manager.dart';
import 'core/widgets/offline_connection_gate.dart';
import 'features/auth/presentation/pages/login_screen.dart';
import 'features/auth/presentation/pages/splash_screen.dart';
import 'features/auth/presentation/pages/signup_screen.dart';
import 'features/dashboard/presentation/pages/appearance_screen.dart';
import 'features/dashboard/presentation/pages/dashboard_screen.dart';
import 'features/scoring/presentation/pages/admin_scoring_screen.dart';
import 'injection_container.dart' as di;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await di.init();
  final themeController = di.sl<AppThemeController>();
  await themeController.load();

  // This app should always require a fresh login after a cold start.
  await di.sl<SessionManager>().clear();

  runApp(TurfScoreApp(themeController: themeController));
}

class TurfScoreApp extends StatelessWidget {
  final AppThemeController themeController;

  const TurfScoreApp({super.key, required this.themeController});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(390, 844),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        return AnimatedBuilder(
          animation: themeController,
          builder: (context, _) {
            return MaterialApp(
              title: 'Turf Score',
              debugShowCheckedModeBanner: false,
              theme: AppTheme.lightTheme,
              darkTheme: AppTheme.darkTheme,
              themeMode: themeController.themeMode,
              initialRoute: '/',
              builder: (context, child) {
                return OfflineConnectionGate(
                  child: child ?? const SizedBox.shrink(),
                );
              },
              routes: {
                '/': (context) => const SplashScreen(),
                '/login': (context) => const LoginScreen(),
                '/signup': (context) => const SignupScreen(),
                '/dashboard': (context) => const DashboardScreen(),
                '/appearance': (context) => const AppearanceScreen(),
                '/scoring': (context) => const AdminScoringScreen(matchId: 0),
              },
            );
          },
        );
      },
    );
  }
}
