import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';

import 'core/constants/app_constants.dart';
import 'core/theme/app_theme.dart';
import 'presentation/screens/splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase
  try {
    await Firebase.initializeApp();
  } catch (e) {
    // Firebase not configured yet, continue without it
    debugPrint('Firebase not configured: $e');
  }

  // Initialize Hive with error handling
  try {
    // Note: Hive initialization is commented out for now to avoid initialization issues
    // await Hive.initFlutter();
    // await Hive.openBox('noise_measurements');
    // await Hive.openBox('user_profiles');
    // await Hive.openBox('venues');
  } catch (e) {
    debugPrint('Hive initialization failed: $e');
  }

  runApp(const ProviderScope(child: HushSenseApp()));
}

final themeModeProvider = StateProvider<ThemeMode>((ref) => ThemeMode.light);

class HushSenseApp extends ConsumerWidget {
  const HushSenseApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);
    return MaterialApp(
      title: AppConstants.appName,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeMode,
      home: const SplashScreen(),
    );
  }
}
