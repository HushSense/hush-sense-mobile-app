import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'core/constants/app_constants.dart';
import 'core/theme/app_theme.dart';
import 'core/services/hedera_wallet_types.dart';
import 'presentation/screens/splash_screen.dart';
import 'domain/models/noise_measurement.dart';
import 'domain/models/user_profile.dart';
import 'domain/models/venue.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize environment variables
  try {
    await dotenv.load(fileName: '.env');
    debugPrint('✅ Environment variables loaded successfully');
  } catch (e) {
    debugPrint('⚠️ Failed to load .env file: $e');
    debugPrint('Using default environment configuration');
  }

  // Initialize Firebase
  try {
    await Firebase.initializeApp();
    debugPrint('✅ Firebase initialized successfully');
  } catch (e) {
    // Firebase not configured yet, continue without it
    debugPrint('⚠️ Firebase not configured: $e');
  }

  // Initialize Hedera WalletConnect
  try {
    final network = dotenv.env['HEDERA_NETWORK'] ?? 'testnet';
    await HederaWalletConnect.initialize(network: network);
    debugPrint('✅ Hedera WalletConnect initialized on $network network');
  } catch (e) {
    debugPrint('⚠️ Failed to initialize Hedera WalletConnect: $e');
    debugPrint('Wallet functionality will be limited');
  }

  // Initialize Hive with error handling
  try {
    await Hive.initFlutter();

    // Register adapters
    Hive.registerAdapter(NoiseMeasurementAdapter());
    Hive.registerAdapter(MeasurementTypeAdapter());
    Hive.registerAdapter(MeasurementStatusAdapter());
    Hive.registerAdapter(NoiseLevelAdapter());
    Hive.registerAdapter(UserProfileAdapter());
    Hive.registerAdapter(VenueAdapter());
    Hive.registerAdapter(VenueTypeAdapter());
    // TODO: Add when generated: Hive.registerAdapter(RewardTransactionAdapter());
    // TODO: Add when generated: Hive.registerAdapter(RewardTransactionStatusAdapter());
    // TODO: Add when generated: Hive.registerAdapter(RewardTransactionTypeAdapter());

    // Open boxes
    await Hive.openBox<NoiseMeasurement>('noise_measurements');
    await Hive.openBox<UserProfile>('user_profiles');
    await Hive.openBox<Venue>('venues');
    // TODO: Add when generated: await Hive.openBox<RewardTransaction>('reward_transactions');
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
