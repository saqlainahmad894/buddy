import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:provider/provider.dart';

import 'screens/home_shell.dart';
import 'screens/onboarding_screen.dart';
import 'screens/splash_screen.dart';
import 'services/buddy_engine.dart';
import 'services/notification_service.dart';
import 'services/storage_service.dart';
import 'state/buddy_state.dart';
import 'theme/buddy_theme.dart';

Future<void> main() async {
  final widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);

  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  final storage = StorageService();
  await storage.init();

  final notifications = NotificationService();
  await notifications.init();

  final state = BuddyState(
    storage: storage,
    engine: BuddyEngine(),
    notifications: notifications,
  );
  await state.load();

  FlutterNativeSplash.remove();

  runApp(
    ChangeNotifierProvider.value(
      value: state,
      child: const BuddyApp(),
    ),
  );
}

class BuddyApp extends StatefulWidget {
  const BuddyApp({super.key});

  @override
  State<BuddyApp> createState() => _BuddyAppState();
}

class _BuddyAppState extends State<BuddyApp> {
  bool _showBrandSplash = true;

  @override
  Widget build(BuildContext context) {
    return Consumer<BuddyState>(
      builder: (context, state, _) {
        final dark = state.profile.darkMode;
        SystemChrome.setSystemUIOverlayStyle(
          dark ? SystemUiOverlayStyle.light : SystemUiOverlayStyle.dark,
        );

        Widget home;
        if (!state.ready || _showBrandSplash) {
          home = SplashScreen(
            onFinished: () {
              if (mounted) setState(() => _showBrandSplash = false);
            },
          );
        } else if (!state.profile.onboarded) {
          home = const OnboardingScreen();
        } else {
          home = const HomeShell();
        }

        return MaterialApp(
          title: 'Buddy',
          debugShowCheckedModeBanner: false,
          theme: BuddyTheme.light(),
          darkTheme: BuddyTheme.dark(),
          themeMode: dark ? ThemeMode.dark : ThemeMode.light,
          home: home,
        );
      },
    );
  }
}
