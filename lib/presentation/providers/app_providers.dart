import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:async';

import '../../domain/models/noise_measurement.dart';
import '../../domain/models/user_profile.dart';
import '../../domain/models/venue.dart';
// TODO: Uncomment when Hive code is generated: import '../../domain/models/reward_transaction.dart';
import '../../core/services/location_service.dart';
import '../../core/services/audio_service.dart';
import '../../core/services/wallet_service.dart';
import '../../core/services/reward_service.dart';
import '../../core/services/hedera_wallet_types.dart';

// Hive Box Providers
final noiseMeasurementsBoxProvider = Provider<Box<NoiseMeasurement>>((ref) {
  return Hive.box<NoiseMeasurement>('noise_measurements');
});

final userProfilesBoxProvider = Provider<Box<UserProfile>>((ref) {
  return Hive.box<UserProfile>('user_profiles');
});

final venuesBoxProvider = Provider<Box<Venue>>((ref) {
  return Hive.box<Venue>('venues');
});

// TODO: Uncomment when Hive code is generated:
// final rewardTransactionsBoxProvider = Provider<Box<RewardTransaction>>((ref) {
//   return Hive.box<RewardTransaction>('reward_transactions');
// });

// Firebase Auth Provider
final firebaseAuthProvider = Provider<FirebaseAuth>((ref) {
  return FirebaseAuth.instance;
});

// Wallet Service Provider
final walletServiceProvider = Provider<WalletService>((ref) {
  return WalletService();
});

// Reward Service Provider
final rewardServiceProvider = Provider<RewardService>((ref) {
  return RewardService();
});

// Current User Provider
final currentUserProvider = StreamProvider<User?>((ref) {
  final auth = ref.watch(firebaseAuthProvider);
  return auth.authStateChanges();
});

// User Profile Provider
final userProfileProvider = StreamProvider<UserProfile?>((ref) async* {
  final user = await ref.watch(currentUserProvider.future);
  if (user == null) {
    yield null;
    return;
  }

  final userProfilesBox = ref.watch(userProfilesBoxProvider);
  final userProfile = userProfilesBox.values
      .where((profile) => profile.id == user.uid)
      .firstOrNull;

  yield userProfile;
});

// Noise Measurements Provider
final noiseMeasurementsProvider = StreamProvider<List<NoiseMeasurement>>((
  ref,
) async* {
  final user = await ref.watch(currentUserProvider.future);
  if (user == null) {
    yield [];
    return;
  }

  final noiseMeasurementsBox = ref.watch(noiseMeasurementsBoxProvider);
  final measurements = noiseMeasurementsBox.values
      .where((measurement) => measurement.userId == user.uid)
      .toList()
    ..sort((a, b) => b.timestamp.compareTo(a.timestamp));

  yield measurements;
});

// Venues Provider
final venuesProvider = StreamProvider<List<Venue>>((ref) async* {
  final venuesBox = ref.watch(venuesBoxProvider);
  final venues = venuesBox.values.toList();
  yield venues;
});

// Measurement State Provider
final measurementStateProvider =
    StateNotifierProvider<MeasurementStateNotifier, MeasurementState>((ref) {
  return MeasurementStateNotifier();
});

// Location Provider
final locationProvider = StateNotifierProvider<LocationNotifier, LocationState>(
  (ref) {
    return LocationNotifier();
  },
);

// Rewards Provider
final rewardsProvider = StateNotifierProvider<RewardsNotifier, RewardsState>((
  ref,
) {
  return RewardsNotifier(ref);
});

// Theme Provider
final themeProvider = StateProvider<ThemeMode>((ref) {
  return ThemeMode.system;
});

// App State Provider
final appStateProvider = StateNotifierProvider<AppStateNotifier, AppState>((
  ref,
) {
  return AppStateNotifier();
});

// State Classes
class MeasurementState {
  final bool isMeasuring;
  final double currentDecibelLevel;
  final DateTime? measurementStartTime;
  final List<double> decibelHistory;

  const MeasurementState({
    this.isMeasuring = false,
    this.currentDecibelLevel = 0.0,
    this.measurementStartTime,
    this.decibelHistory = const [],
  });

  MeasurementState copyWith({
    bool? isMeasuring,
    double? currentDecibelLevel,
    DateTime? measurementStartTime,
    List<double>? decibelHistory,
  }) {
    return MeasurementState(
      isMeasuring: isMeasuring ?? this.isMeasuring,
      currentDecibelLevel: currentDecibelLevel ?? this.currentDecibelLevel,
      measurementStartTime: measurementStartTime ?? this.measurementStartTime,
      decibelHistory: decibelHistory ?? this.decibelHistory,
    );
  }
}

class LocationState {
  final double? latitude;
  final double? longitude;
  final String? address;
  final bool isLoading;
  final String? error;

  const LocationState({
    this.latitude,
    this.longitude,
    this.address,
    this.isLoading = false,
    this.error,
  });

  LocationState copyWith({
    double? latitude,
    double? longitude,
    String? address,
    bool? isLoading,
    String? error,
  }) {
    return LocationState(
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      address: address ?? this.address,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }
}

class RewardsState {
  final int totalRewards;
  final int dailyStreak;
  final List<Achievement> achievements;
  final bool isLoading;

  const RewardsState({
    this.totalRewards = 0,
    this.dailyStreak = 0,
    this.achievements = const [],
    this.isLoading = false,
  });

  RewardsState copyWith({
    int? totalRewards,
    int? dailyStreak,
    List<Achievement>? achievements,
    bool? isLoading,
  }) {
    return RewardsState(
      totalRewards: totalRewards ?? this.totalRewards,
      dailyStreak: dailyStreak ?? this.dailyStreak,
      achievements: achievements ?? this.achievements,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

class AppState {
  final bool isInitialized;
  final bool isOnboardingComplete;
  final String? currentRoute;
  final Map<String, dynamic> settings;

  const AppState({
    this.isInitialized = false,
    this.isOnboardingComplete = false,
    this.currentRoute,
    this.settings = const {},
  });

  AppState copyWith({
    bool? isInitialized,
    bool? isOnboardingComplete,
    String? currentRoute,
    Map<String, dynamic>? settings,
  }) {
    return AppState(
      isInitialized: isInitialized ?? this.isInitialized,
      isOnboardingComplete: isOnboardingComplete ?? this.isOnboardingComplete,
      currentRoute: currentRoute ?? this.currentRoute,
      settings: settings ?? this.settings,
    );
  }
}

// Achievement Model
class Achievement {
  final String id;
  final String title;
  final String description;
  final String icon;
  final bool isUnlocked;
  final DateTime? unlockedAt;
  final int requiredValue;
  final AchievementType type;

  const Achievement({
    required this.id,
    required this.title,
    required this.description,
    required this.icon,
    this.isUnlocked = false,
    this.unlockedAt,
    required this.requiredValue,
    required this.type,
  });
}

enum AchievementType { measurements, streak, venues, rewards }

// State Notifiers
class MeasurementStateNotifier extends StateNotifier<MeasurementState> {
  final AudioService _audioService = AudioService();
  StreamSubscription<double>? _audioSubscription;

  MeasurementStateNotifier() : super(const MeasurementState());

  Future<void> startMeasurement() async {
    if (state.isMeasuring) return;

    try {
      // Check microphone permission
      bool hasPermission = await _audioService.hasMicrophonePermission();
      if (!hasPermission) {
        hasPermission = await _audioService.requestMicrophonePermission();
      }

      if (!hasPermission) {
        throw AudioServiceException('Microphone permission denied');
      }

      // Start audio measurement
      state = state.copyWith(
        isMeasuring: true,
        measurementStartTime: DateTime.now(),
        decibelHistory: [],
      );

      // Subscribe to audio stream
      _audioSubscription = _audioService.startMeasurement().listen(
        (decibelLevel) {
          updateDecibelLevel(decibelLevel);
        },
        onError: (error) {
          debugPrint('Audio measurement error: $error');
          stopMeasurement();
        },
      );
    } catch (e) {
      // Handle error - could emit error state here
      debugPrint('Error starting measurement: $e');
    }
  }

  void stopMeasurement() {
    _audioSubscription?.cancel();
    _audioSubscription = null;
    _audioService.stopMeasurement();

    state = state.copyWith(
      isMeasuring: false,
      measurementStartTime: null,
    );
  }

  void updateDecibelLevel(double level) {
    final newHistory = List<double>.from(state.decibelHistory)..add(level);
    state = state.copyWith(
      currentDecibelLevel: level,
      decibelHistory: newHistory,
    );
  }

  @override
  void dispose() {
    _audioSubscription?.cancel();
    _audioService.dispose();
    super.dispose();
  }
}

class LocationNotifier extends StateNotifier<LocationState> {
  final LocationService _locationService = LocationService();

  LocationNotifier() : super(const LocationState());

  Future<void> getCurrentLocation() async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final locationData = await _locationService.getCurrentLocation();
      state = state.copyWith(
        latitude: locationData.latitude,
        longitude: locationData.longitude,
        address: locationData.address,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  Future<bool> hasLocationPermission() async {
    return await _locationService.hasLocationPermission();
  }

  Future<bool> requestLocationPermission() async {
    return await _locationService.requestLocationPermission();
  }
}

class RewardsNotifier extends StateNotifier<RewardsState> {
  final Ref _ref;

  RewardsNotifier(this._ref) : super(const RewardsState());

  Future<void> loadRewards() async {
    state = state.copyWith(isLoading: true);

    try {
      final userProfile = await _ref.read(userProfileProvider.future);
      if (userProfile != null) {
        state = state.copyWith(
          totalRewards: userProfile.totalRewards,
          dailyStreak: 0, // Removed dailyStreak from UserProfile
          isLoading: false,
        );
      }
    } catch (e) {
      state = state.copyWith(isLoading: false);
    }
  }

  void addRewards(int amount) {
    state = state.copyWith(totalRewards: state.totalRewards + amount);
  }
}

class AppStateNotifier extends StateNotifier<AppState> {
  AppStateNotifier() : super(const AppState());

  void initialize() {
    state = state.copyWith(isInitialized: true);
  }

  void completeOnboarding() {
    state = state.copyWith(isOnboardingComplete: true);
  }

  void setCurrentRoute(String route) {
    state = state.copyWith(currentRoute: route);
  }

  void updateSetting(String key, dynamic value) {
    final newSettings = Map<String, dynamic>.from(state.settings);
    newSettings[key] = value;
    state = state.copyWith(settings: newSettings);
  }
}

// Wallet Connection State Provider
final walletConnectionProvider = StreamProvider<WalletConnectionStatus>((ref) {
  final walletService = ref.watch(walletServiceProvider);
  return walletService.connectionStream.map((connectionState) {
    return WalletConnectionStatus(
      isConnected: connectionState.isConnected,
      accountId: connectionState.accountId,
      walletName: connectionState.walletName,
      network: connectionState.network,
    );
  });
});

// Wallet Balance Provider
final walletBalanceProvider = FutureProvider<double?>((ref) async {
  final walletService = ref.watch(walletServiceProvider);

  if (!walletService.isConnected()) {
    return null;
  }

  try {
    return await walletService.getBalance();
  } catch (e) {
    // Return null if balance fetch fails
    return null;
  }
});

// Available Wallets Provider
final availableWalletsProvider =
    FutureProvider<List<AvailableWallet>>((ref) async {
  final walletService = ref.watch(walletServiceProvider);
  try {
    return await walletService.getAvailableWallets();
  } catch (e) {
    return [];
  }
});

// Wallet State Notifier
final walletStateProvider =
    StateNotifierProvider<WalletStateNotifier, WalletState>((ref) {
  return WalletStateNotifier(ref);
});

class WalletStateNotifier extends StateNotifier<WalletState> {
  final Ref _ref;
  StreamSubscription<WalletConnectionStatus>? _connectionSubscription;

  WalletStateNotifier(this._ref) : super(const WalletState()) {
    _initializeWalletState();
  }

  void _initializeWalletState() {
    final walletService = _ref.read(walletServiceProvider);
    final connectionStatus = walletService.getConnectionStatus();

    state = state.copyWith(
      isConnected: connectionStatus.isConnected,
      accountId: connectionStatus.accountId,
      walletName: connectionStatus.walletName,
      network: connectionStatus.network,
    );

    // Listen to connection changes
    _connectionSubscription = _ref.read(walletConnectionProvider.stream).listen(
      (connectionStatus) {
        state = state.copyWith(
          isConnected: connectionStatus.isConnected,
          accountId: connectionStatus.accountId,
          walletName: connectionStatus.walletName,
          network: connectionStatus.network,
          isConnecting: false,
          error: null,
        );
      },
      onError: (error) {
        state = state.copyWith(
          isConnecting: false,
          error: error.toString(),
        );
      },
    );
  }

  Future<void> connectWallet({String? preferredWallet}) async {
    state = state.copyWith(isConnecting: true, error: null);

    try {
      final walletService = _ref.read(walletServiceProvider);
      final accountInfo =
          await walletService.connect(preferredWallet: preferredWallet);

      if (accountInfo != null) {
        // Update user profile with wallet information
        await _updateUserProfileWallet(accountInfo.accountId);

        state = state.copyWith(
          isConnected: true,
          isConnecting: false,
          accountId: accountInfo.accountId,
          walletName: accountInfo.walletName,
          network: accountInfo.network,
          error: null,
        );
      }
    } catch (e) {
      state = state.copyWith(
        isConnecting: false,
        error: e.toString(),
      );
      rethrow;
    }
  }

  Future<void> disconnectWallet() async {
    try {
      final walletService = _ref.read(walletServiceProvider);
      await walletService.disconnect();

      // Clear wallet information from user profile
      await _updateUserProfileWallet(null);

      state = state.copyWith(
        isConnected: false,
        accountId: null,
        walletName: null,
        network: null,
        error: null,
      );
    } catch (e) {
      state = state.copyWith(error: e.toString());
      rethrow;
    }
  }

  Future<void> refreshBalance() async {
    if (!state.isConnected) return;

    try {
      final walletService = _ref.read(walletServiceProvider);
      final balance = await walletService.getBalance();

      // Update user profile with new balance
      final user = await _ref.read(currentUserProvider.future);
      if (user != null) {
        final userProfilesBox = _ref.read(userProfilesBoxProvider);
        final userProfile = userProfilesBox.values
            .where((profile) => profile.id == user.uid)
            .firstOrNull;

        if (userProfile != null) {
          userProfile.hbarBalance = balance;
          userProfile.lastWalletSync = DateTime.now();
          await userProfile.save();
        }
      }
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  Future<void> _updateUserProfileWallet(String? accountId) async {
    try {
      final user = await _ref.read(currentUserProvider.future);
      if (user != null) {
        final userProfilesBox = _ref.read(userProfilesBoxProvider);
        final userProfile = userProfilesBox.values
            .where((profile) => profile.id == user.uid)
            .firstOrNull;

        if (userProfile != null) {
          userProfile.walletAccountId = accountId;
          userProfile.lastWalletSync =
              accountId != null ? DateTime.now() : null;
          await userProfile.save();
        }
      }
    } catch (e) {
      // Log error but don't throw - wallet connection should still work
      debugPrint('Failed to update user profile with wallet info: $e');
    }
  }

  @override
  void dispose() {
    _connectionSubscription?.cancel();
    super.dispose();
  }
}

// Wallet State Data Class
class WalletState {
  final bool isConnected;
  final bool isConnecting;
  final String? accountId;
  final String? walletName;
  final String? network;
  final String? error;

  const WalletState({
    this.isConnected = false,
    this.isConnecting = false,
    this.accountId,
    this.walletName,
    this.network,
    this.error,
  });

  WalletState copyWith({
    bool? isConnected,
    bool? isConnecting,
    String? accountId,
    String? walletName,
    String? network,
    String? error,
  }) {
    return WalletState(
      isConnected: isConnected ?? this.isConnected,
      isConnecting: isConnecting ?? this.isConnecting,
      accountId: accountId ?? this.accountId,
      walletName: walletName ?? this.walletName,
      network: network ?? this.network,
      error: error ?? this.error,
    );
  }

  @override
  String toString() {
    return 'WalletState(isConnected: $isConnected, isConnecting: $isConnecting, accountId: $accountId, walletName: $walletName, network: $network, error: $error)';
  }
}
