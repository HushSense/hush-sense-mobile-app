import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants/app_constants.dart';
import '../../core/utils/haptic_feedback.dart';

class RewardsScreen extends ConsumerWidget {
  const RewardsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: AppConstants.backgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppConstants.paddingL),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Section
              _buildHeader(context),
              const SizedBox(height: AppConstants.paddingXL),
              
              // Wallet Balance Card
              _buildWalletCard(),
              const SizedBox(height: AppConstants.paddingXL),
              
              // Earning Stats
              _buildEarningStats(),
              const SizedBox(height: AppConstants.paddingXL),
              
              // Achievement Badges
              _buildAchievements(context),
              const SizedBox(height: AppConstants.paddingXL),
              
              // Leaderboard Preview
              _buildLeaderboard(context),
              const SizedBox(height: AppConstants.paddingXL),
              
              // Redemption Options
              _buildRedemptionOptions(),
              const SizedBox(height: AppConstants.paddingL),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Rewards',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: AppConstants.textPrimary,
            fontFamily: 'Funnel Sans',
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Your contribution to the sound map is rewarded',
          style: TextStyle(
            fontSize: 16,
            color: AppConstants.textSecondary,
            fontFamily: 'Funnel Sans',
          ),
        ),
      ],
    );
  }

  Widget _buildWalletCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppConstants.paddingL),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppConstants.primaryTeal,
            AppConstants.primaryTeal.withValues(alpha: 0.8),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(AppConstants.radiusL),
        boxShadow: [
          BoxShadow(
            color: AppConstants.primaryTeal.withValues(alpha: 0.3),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.account_balance_wallet,
                color: AppConstants.surfaceColor,
                size: 24,
              ),
              const SizedBox(width: 8),
              Text(
                'HUSH Wallet',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: AppConstants.surfaceColor.withValues(alpha: 0.9),
                  fontFamily: 'Funnel Sans',
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: AppConstants.surfaceColor.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  'Connected',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: AppConstants.surfaceColor,
                    fontFamily: 'Funnel Sans',
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppConstants.paddingL),
          Text(
            '2,847',
            style: TextStyle(
              fontSize: 36,
              fontWeight: FontWeight.bold,
              color: AppConstants.surfaceColor,
              fontFamily: 'Funnel Sans',
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '\$HUSH Tokens',
            style: TextStyle(
              fontSize: 16,
              color: AppConstants.surfaceColor.withValues(alpha: 0.8),
              fontFamily: 'Funnel Sans',
            ),
          ),
          const SizedBox(height: AppConstants.paddingM),
          Row(
            children: [
              Icon(
                Icons.trending_up,
                color: AppConstants.surfaceColor.withValues(alpha: 0.8),
                size: 16,
              ),
              const SizedBox(width: 4),
              Text(
                '+127 this week',
                style: TextStyle(
                  fontSize: 14,
                  color: AppConstants.surfaceColor.withValues(alpha: 0.8),
                  fontFamily: 'Funnel Sans',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEarningStats() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Earning Breakdown',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: AppConstants.textPrimary,
            fontFamily: 'Funnel Sans',
          ),
        ),
        const SizedBox(height: AppConstants.paddingM),
        Row(
          children: [
            Expanded(
              child: _buildEarningCard(
                'Measurements',
                '1,847',
                '+23 today',
                Icons.mic,
                AppConstants.primaryTeal,
              ),
            ),
            const SizedBox(width: AppConstants.paddingM),
            Expanded(
              child: _buildEarningCard(
                'Venue Check-ins',
                '892',
                '+5 today',
                Icons.location_on,
                AppConstants.primaryColor,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppConstants.paddingM),
        Row(
          children: [
            Expanded(
              child: _buildEarningCard(
                'Daily Streaks',
                '108',
                '12 day streak',
                Icons.local_fire_department,
                AppConstants.accentOrange,
              ),
            ),
            const SizedBox(width: AppConstants.paddingM),
            Expanded(
              child: _buildEarningCard(
                'Referrals',
                '0',
                'Invite friends',
                Icons.people,
                AppConstants.accentGold,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildEarningCard(String title, String value, String subtitle, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(AppConstants.paddingM),
      decoration: BoxDecoration(
        color: AppConstants.surfaceColor,
        borderRadius: BorderRadius.circular(AppConstants.radiusM),
        border: Border.all(
          color: color.withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  icon,
                  color: color,
                  size: 18,
                ),
              ),
              const Spacer(),
              Text(
                title,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: AppConstants.textSecondary,
                  fontFamily: 'Funnel Sans',
                ),
              ),
            ],
          ),
          const SizedBox(height: AppConstants.paddingM),
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppConstants.textPrimary,
              fontFamily: 'Funnel Sans',
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: TextStyle(
              fontSize: 11,
              color: AppConstants.textSecondary,
              fontFamily: 'Funnel Sans',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAchievements(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Achievements',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: AppConstants.textPrimary,
                fontFamily: 'Funnel Sans',
              ),
            ),
            TextButton(
              onPressed: () {
                // TODO: Navigate to full achievements
              },
              child: Text(
                'View All',
                style: TextStyle(
                  color: AppConstants.primaryTeal,
                  fontWeight: FontWeight.w500,
                  fontFamily: 'Funnel Sans',
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: AppConstants.paddingM),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              _buildAchievementBadge(
                'First Measurement',
                '🎤',
                true,
              ),
              const SizedBox(width: AppConstants.paddingM),
              _buildAchievementBadge(
                'Week Warrior',
                '🔥',
                true,
              ),
              const SizedBox(width: AppConstants.paddingM),
              _buildAchievementBadge(
                'Venue Explorer',
                '📍',
                true,
              ),
              const SizedBox(width: AppConstants.paddingM),
              _buildAchievementBadge(
                'Data Champion',
                '🏆',
                false,
              ),
              const SizedBox(width: AppConstants.paddingM),
              _buildAchievementBadge(
                'City Mapper',
                '🗺️',
                false,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildAchievementBadge(String title, String emoji, bool isEarned) {
    return Container(
      width: 100,
      padding: const EdgeInsets.all(AppConstants.paddingM),
      decoration: BoxDecoration(
        color: isEarned 
            ? AppConstants.accentGold.withValues(alpha: 0.1)
            : AppConstants.softGray.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppConstants.radiusM),
        border: Border.all(
          color: isEarned 
              ? AppConstants.accentGold.withValues(alpha: 0.3)
              : AppConstants.softGray.withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        children: [
          Text(
            emoji,
            style: TextStyle(
              fontSize: 24,
              color: isEarned ? null : AppConstants.textTertiary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            title,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: isEarned 
                  ? AppConstants.textPrimary 
                  : AppConstants.textTertiary,
              fontFamily: 'Funnel Sans',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLeaderboard(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'City Leaderboard',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: AppConstants.textPrimary,
                fontFamily: 'Funnel Sans',
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: AppConstants.primaryTeal.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                'Rank #47',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppConstants.primaryTeal,
                  fontFamily: 'Funnel Sans',
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: AppConstants.paddingM),
        Container(
          padding: const EdgeInsets.all(AppConstants.paddingM),
          decoration: BoxDecoration(
            color: AppConstants.surfaceColor,
            borderRadius: BorderRadius.circular(AppConstants.radiusM),
            border: Border.all(
              color: AppConstants.softGray.withValues(alpha: 0.2),
            ),
          ),
          child: Column(
            children: [
              _buildLeaderboardItem('🥇', 'SoundMaster', '15,847', '1'),
              const Divider(height: 24),
              _buildLeaderboardItem('🥈', 'NoiseNinja', '14,203', '2'),
              const Divider(height: 24),
              _buildLeaderboardItem('🥉', 'CityListener', '12,956', '3'),
              const Divider(height: 24),
              _buildLeaderboardItem('🎤', 'You (Sound Scout)', '2,847', '47', isCurrentUser: true),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildLeaderboardItem(String emoji, String name, String tokens, String rank, {bool isCurrentUser = false}) {
    return Row(
      children: [
        Text(
          emoji,
          style: const TextStyle(fontSize: 20),
        ),
        const SizedBox(width: AppConstants.paddingM),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                name,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: isCurrentUser ? FontWeight.w600 : FontWeight.w500,
                  color: isCurrentUser ? AppConstants.primaryTeal : AppConstants.textPrimary,
                  fontFamily: 'Funnel Sans',
                ),
              ),
              Text(
                '$tokens \$HUSH',
                style: TextStyle(
                  fontSize: 14,
                  color: AppConstants.textSecondary,
                  fontFamily: 'Funnel Sans',
                ),
              ),
            ],
          ),
        ),
        Text(
          '#$rank',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: isCurrentUser ? AppConstants.primaryTeal : AppConstants.textSecondary,
            fontFamily: 'Funnel Sans',
          ),
        ),
      ],
    );
  }

  Widget _buildRedemptionOptions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Redeem Rewards',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: AppConstants.textPrimary,
            fontFamily: 'Funnel Sans',
          ),
        ),
        const SizedBox(height: AppConstants.paddingM),
        _buildRedemptionCard(
          'Coffee Vouchers',
          '50 \$HUSH',
          'Get 10% off at partner cafes',
          Icons.local_cafe,
          AppConstants.accentOrange,
        ),
        const SizedBox(height: AppConstants.paddingM),
        _buildRedemptionCard(
          'Premium Features',
          '500 \$HUSH',
          'Unlock advanced analytics',
          Icons.star,
          AppConstants.accentGold,
        ),
        const SizedBox(height: AppConstants.paddingM),
        _buildRedemptionCard(
          'Merchandise',
          '1000 \$HUSH',
          'HushSense branded items',
          Icons.shopping_bag,
          AppConstants.primaryColor,
        ),
      ],
    );
  }

  Widget _buildRedemptionCard(String title, String cost, String description, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(AppConstants.paddingM),
      decoration: BoxDecoration(
        color: AppConstants.surfaceColor,
        borderRadius: BorderRadius.circular(AppConstants.radiusM),
        border: Border.all(
          color: AppConstants.softGray.withValues(alpha: 0.2),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(
              icon,
              color: color,
              size: 24,
            ),
          ),
          const SizedBox(width: AppConstants.paddingM),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppConstants.textPrimary,
                    fontFamily: 'Funnel Sans',
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 14,
                    color: AppConstants.textSecondary,
                    fontFamily: 'Funnel Sans',
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                cost,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: color,
                  fontFamily: 'Funnel Sans',
                ),
              ),
              const SizedBox(height: 4),
              GestureDetector(
                onTap: () {
                  HushHaptics.lightTap();
                  // TODO: Handle redemption
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    'Redeem',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: color,
                      fontFamily: 'Funnel Sans',
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
