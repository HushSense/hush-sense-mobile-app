import 'dart:async';
import 'dart:math';
import 'package:flutter/foundation.dart';

import '../../domain/models/user_profile.dart';
import '../../domain/models/noise_measurement.dart';
import '../../domain/models/venue.dart';
// TODO: Uncomment when Hive code is generated: import '../../domain/models/reward_transaction.dart';
import 'wallet_service.dart';
import 'hedera_wallet_types.dart';

/// Service for managing rewards and token distribution
/// Handles calculation, validation, and distribution of HUSH tokens
class RewardService {
  static final RewardService _instance = RewardService._internal();
  factory RewardService() => _instance;
  RewardService._internal();

  final WalletService _walletService = WalletService();
  final Random _random = Random();

  // Reward calculation constants
  static const double _baseRewardPerMeasurement = 10.0;
  static const double _venueCheckInReward = 50.0;
  static const double _dailyStreakMultiplier = 1.1;
  static const double _weeklyStreakMultiplier = 1.25;
  static const double _qualityBonusMultiplier = 1.5;
  static const double _rareBonusChance = 0.05; // 5% chance
  static const double _rareBonusMultiplier = 2.0;
  static const int _measurementDurationSeconds = 10;

  // RewardAchievement rewards
  static const Map<String, double> _achievementRewards = {
    'first_measurement': 100.0,
    'week_warrior': 250.0,
    'venue_explorer': 200.0,
    'data_champion': 500.0,
    'city_mapper': 1000.0,
    'consistency_king': 300.0,
    'early_bird': 150.0,
    'night_owl': 150.0,
  };

  /// Calculate rewards for a noise measurement
  Future<RewardCalculation> calculateMeasurementReward({
    required NoiseMeasurement measurement,
    required UserProfile userProfile,
    Venue? venue,
  }) async {
    try {
      double baseReward = _baseRewardPerMeasurement;
      List<RewardBonus> bonuses = [];

      // Quality bonus based on measurement accuracy and duration
      if (measurement.status == MeasurementStatus.completed) {
        double qualityScore = _calculateQualityScore(measurement);
        if (qualityScore > 0.8) {
          double qualityBonus = baseReward * (_qualityBonusMultiplier - 1);
          bonuses.add(RewardBonus(
            type: 'quality',
            amount: qualityBonus,
            description: 'High quality measurement',
          ));
          baseReward += qualityBonus;
        }
      }

      // Venue check-in bonus
      if (venue != null) {
        bonuses.add(RewardBonus(
          type: 'venue_checkin',
          amount: _venueCheckInReward,
          description: 'Venue check-in bonus',
        ));
        baseReward += _venueCheckInReward;
      }

      // Daily streak bonus
      int dailyStreak = _calculateDailyStreak(userProfile);
      if (dailyStreak > 1) {
        double streakMultiplier =
            min(_dailyStreakMultiplier + (dailyStreak * 0.02), 2.0);
        double streakBonus = baseReward * (streakMultiplier - 1);
        bonuses.add(RewardBonus(
          type: 'daily_streak',
          amount: streakBonus,
          description: '$dailyStreak day streak bonus',
        ));
        baseReward += streakBonus;
      }

      // Weekly streak bonus
      int weeklyStreak = _calculateWeeklyStreak(userProfile);
      if (weeklyStreak > 1) {
        double weeklyBonus = baseReward * (_weeklyStreakMultiplier - 1);
        bonuses.add(RewardBonus(
          type: 'weekly_streak',
          amount: weeklyBonus,
          description: '$weeklyStreak week streak bonus',
        ));
        baseReward += weeklyBonus;
      }

      // Rare bonus (random chance)
      if (_random.nextDouble() < _rareBonusChance) {
        double rareBonus = baseReward * (_rareBonusMultiplier - 1);
        bonuses.add(RewardBonus(
          type: 'rare_bonus',
          amount: rareBonus,
          description: 'Lucky bonus! 🍀',
        ));
        baseReward += rareBonus;
      }

      // Time-based bonuses
      DateTime now = DateTime.now();
      if (now.hour >= 6 && now.hour <= 9) {
        // Early bird bonus
        double earlyBirdBonus = baseReward * 0.1;
        bonuses.add(RewardBonus(
          type: 'early_bird',
          amount: earlyBirdBonus,
          description: 'Early bird bonus',
        ));
        baseReward += earlyBirdBonus;
      } else if (now.hour >= 22 || now.hour <= 5) {
        // Night owl bonus
        double nightOwlBonus = baseReward * 0.1;
        bonuses.add(RewardBonus(
          type: 'night_owl',
          amount: nightOwlBonus,
          description: 'Night owl bonus',
        ));
        baseReward += nightOwlBonus;
      }

      return RewardCalculation(
        totalAmount: baseReward,
        bonuses: bonuses,
        measurement: measurement,
        venue: venue,
      );
    } catch (e) {
      debugPrint('Error calculating measurement reward: $e');
      return RewardCalculation(
        totalAmount: _baseRewardPerMeasurement,
        bonuses: [],
        measurement: measurement,
        venue: venue,
      );
    }
  }

  /// Calculate rewards for achievements
  Future<double> calculateRewardAchievementReward(String achievementId) async {
    return _achievementRewards[achievementId] ?? 0.0;
  }

  /// Process and distribute rewards for a completed measurement
  Future<RewardResult> processReward({
    required RewardCalculation calculation,
    required UserProfile userProfile,
  }) async {
    try {
      // Update user profile with new tokens
      double newBalance =
          (userProfile.hushTokenBalance ?? 0.0) + calculation.totalAmount;
      userProfile.hushTokenBalance = newBalance;
      userProfile.totalRewardsEarned =
          (userProfile.totalRewardsEarned ?? 0.0) + calculation.totalAmount;
      userProfile.updatedAt = DateTime.now();

      // Save to local storage
      await userProfile.save();

      // TODO: Create reward transaction record when model is available
      // final rewardTransaction = RewardTransaction(
      //   id: 'reward_${DateTime.now().millisecondsSinceEpoch}',
      //   userId: userProfile.id,
      //   transactionId: 'local_${DateTime.now().millisecondsSinceEpoch}',
      //   amount: calculation.totalAmount,
      //   tokenType: 'HUSH',
      //   status: RewardTransactionStatus.completed,
      //   type: RewardTransactionType.measurement,
      //   description: 'Noise measurement reward',
      //   measurementId: calculation.measurement.id,
      //   venueId: calculation.venue?.id,
      //   metadata: {
      //     'bonuses': calculation.bonuses.map((b) => b.toJson()).toList(),
      //     'quality_score': _calculateQualityScore(calculation.measurement),
      //   },
      // );

      // TODO: Save transaction to Hive when model is available
      // final rewardTransactionsBox = Hive.box<RewardTransaction>('reward_transactions');
      // await rewardTransactionsBox.add(rewardTransaction);

      debugPrint('✅ Reward processed: ${calculation.totalAmount} HUSH tokens');

      return RewardResult(
        success: true,
        amount: calculation.totalAmount,
        newBalance: newBalance,
        bonuses: calculation.bonuses,
      );
    } catch (e) {
      debugPrint('❌ Error processing reward: $e');
      return RewardResult(
        success: false,
        amount: 0.0,
        newBalance: userProfile.hushTokenBalance ?? 0.0,
        bonuses: [],
        error: e.toString(),
      );
    }
  }

  /// Claim accumulated rewards to Hedera wallet
  Future<ClaimResult> claimRewards({
    required UserProfile userProfile,
    double? specificAmount,
  }) async {
    try {
      if (!_walletService.isConnected()) {
        throw Exception('Wallet not connected');
      }

      double claimableAmount =
          specificAmount ?? (userProfile.hushTokenBalance ?? 0.0);

      if (claimableAmount <= 0) {
        throw Exception('No rewards to claim');
      }

      // Create transaction request
      final transactionRequest = HederaTransactionRequest(
        transactionId: 'claim_${DateTime.now().millisecondsSinceEpoch}',
        transactionBytes:
            'mock_transaction_bytes', // In real implementation, this would be prepared by server
        memo: 'HUSH token reward claim: ${claimableAmount.toStringAsFixed(2)}',
        fee: 0.001, // HBAR fee
      );

      // Sign transaction with wallet
      final result = await _walletService.signTransaction(transactionRequest);

      if (result.success) {
        // Update user profile - deduct claimed amount
        userProfile.hushTokenBalance =
            (userProfile.hushTokenBalance ?? 0.0) - claimableAmount;
        userProfile.totalRewardsClaimed =
            (userProfile.totalRewardsClaimed ?? 0.0) + claimableAmount;
        userProfile.lastWalletSync = DateTime.now();
        userProfile.updatedAt = DateTime.now();

        await userProfile.save();

        // TODO: Create claim transaction record when model is available
        // final claimTransaction = RewardTransaction(
        //   id: 'claim_${DateTime.now().millisecondsSinceEpoch}',
        //   userId: userProfile.id,
        //   transactionId: result.transactionId ?? 'unknown',
        //   amount: claimableAmount,
        //   tokenType: 'HUSH',
        //   status: RewardTransactionStatus.completed,
        //   type: RewardTransactionType.bonus,
        //   description: 'Reward claim to Hedera wallet',
        //   metadata: {
        //     'wallet_account_id': _walletService.getAccountId(),
        //     'signed_transaction': result.signedTransaction,
        //   },
        // );

        debugPrint('✅ Rewards claimed successfully: $claimableAmount HUSH');

        return ClaimResult(
          success: true,
          amount: claimableAmount,
          transactionId: transactionRequest.transactionId,
          newBalance: userProfile.hushTokenBalance ?? 0.0,
        );
      } else {
        throw Exception('Transaction signing failed');
      }
    } catch (e) {
      debugPrint('❌ Error claiming rewards: $e');
      return ClaimResult(
        success: false,
        amount: 0.0,
        transactionId: null,
        newBalance: userProfile.hushTokenBalance ?? 0.0,
        error: e.toString(),
      );
    }
  }

  /// Check for new achievements based on user activity
  Future<List<RewardAchievement>> checkForNewRewardAchievements(
      UserProfile userProfile) async {
    List<RewardAchievement> newRewardAchievements = [];
    Set<String> existingRewardAchievements =
        Set.from(userProfile.achievements ?? []);

    // First measurement achievement
    if (!existingRewardAchievements.contains('first_measurement') &&
        userProfile.totalMeasurements >= 1) {
      newRewardAchievements.add(RewardAchievement(
        id: 'first_measurement',
        title: 'First Measurement',
        description: 'Completed your first noise measurement',
        emoji: '🎤',
        reward: _achievementRewards['first_measurement']!,
      ));
    }

    // Week warrior achievement
    if (!existingRewardAchievements.contains('week_warrior') &&
        _calculateDailyStreak(userProfile) >= 7) {
      newRewardAchievements.add(RewardAchievement(
        id: 'week_warrior',
        title: 'Week Warrior',
        description: 'Measured noise for 7 consecutive days',
        emoji: '🔥',
        reward: _achievementRewards['week_warrior']!,
      ));
    }

    // Venue explorer achievement
    if (!existingRewardAchievements.contains('venue_explorer') &&
        (userProfile.venuesVisited ?? 0) >= 10) {
      newRewardAchievements.add(RewardAchievement(
        id: 'venue_explorer',
        title: 'Venue Explorer',
        description: 'Visited 10 different venues',
        emoji: '📍',
        reward: _achievementRewards['venue_explorer']!,
      ));
    }

    // Data champion achievement
    if (!existingRewardAchievements.contains('data_champion') &&
        userProfile.totalMeasurements >= 100) {
      newRewardAchievements.add(RewardAchievement(
        id: 'data_champion',
        title: 'Data Champion',
        description: 'Completed 100 noise measurements',
        emoji: '🏆',
        reward: _achievementRewards['data_champion']!,
      ));
    }

    // City mapper achievement
    if (!existingRewardAchievements.contains('city_mapper') &&
        userProfile.totalMeasurements >= 1000) {
      newRewardAchievements.add(RewardAchievement(
        id: 'city_mapper',
        title: 'City Mapper',
        description: 'Completed 1000 noise measurements',
        emoji: '🗺️',
        reward: _achievementRewards['city_mapper']!,
      ));
    }

    // Update user profile with new achievements
    if (newRewardAchievements.isNotEmpty) {
      List<String> updatedRewardAchievements =
          List.from(userProfile.achievements ?? []);
      for (RewardAchievement achievement in newRewardAchievements) {
        updatedRewardAchievements.add(achievement.id);
      }
      userProfile.achievements = updatedRewardAchievements;
      userProfile.updatedAt = DateTime.now();
      await userProfile.save();
    }

    return newRewardAchievements;
  }

  /// Calculate quality score for a measurement
  double _calculateQualityScore(NoiseMeasurement measurement) {
    double score = 0.0;

    // Base score for completion
    if (measurement.status == MeasurementStatus.completed) {
      score += 0.5;
    }

    // Duration score (longer measurements are better)
    if (measurement.duration != null &&
        measurement.duration! >= _measurementDurationSeconds) {
      score += 0.3;
    }

    // Location accuracy score
    if (measurement.locationAccuracy != null &&
        measurement.locationAccuracy! <= 10.0) {
      score += 0.2;
    }

    return min(score, 1.0);
  }

  /// Calculate daily streak for user
  int _calculateDailyStreak(UserProfile userProfile) {
    // TODO: Implement actual streak calculation based on measurement history
    // For now, return a mock value
    return userProfile.currentStreak ?? 0;
  }

  /// Calculate weekly streak for user
  int _calculateWeeklyStreak(UserProfile userProfile) {
    // TODO: Implement actual weekly streak calculation
    // For now, return a mock value based on daily streak
    int dailyStreak = _calculateDailyStreak(userProfile);
    return (dailyStreak / 7).floor();
  }
}

/// Data classes for reward calculations

class RewardCalculation {
  final double totalAmount;
  final List<RewardBonus> bonuses;
  final NoiseMeasurement measurement;
  final Venue? venue;

  RewardCalculation({
    required this.totalAmount,
    required this.bonuses,
    required this.measurement,
    this.venue,
  });
}

class RewardBonus {
  final String type;
  final double amount;
  final String description;

  RewardBonus({
    required this.type,
    required this.amount,
    required this.description,
  });

  Map<String, dynamic> toJson() {
    return {
      'type': type,
      'amount': amount,
      'description': description,
    };
  }
}

class RewardResult {
  final bool success;
  final double amount;
  final double newBalance;
  final List<RewardBonus> bonuses;
  final String? error;

  RewardResult({
    required this.success,
    required this.amount,
    required this.newBalance,
    required this.bonuses,
    this.error,
  });
}

class ClaimResult {
  final bool success;
  final double amount;
  final String? transactionId;
  final double newBalance;
  final String? error;

  ClaimResult({
    required this.success,
    required this.amount,
    required this.transactionId,
    required this.newBalance,
    this.error,
  });
}

class RewardAchievement {
  final String id;
  final String title;
  final String description;
  final String emoji;
  final double reward;

  RewardAchievement({
    required this.id,
    required this.title,
    required this.description,
    required this.emoji,
    required this.reward,
  });
}
