import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants/app_constants.dart';

class RewardsScreen extends ConsumerStatefulWidget {
  const RewardsScreen({super.key});

  @override
  ConsumerState<RewardsScreen> createState() => _RewardsScreenState();
}

class _RewardsScreenState extends ConsumerState<RewardsScreen>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late List<Animation<double>> _fadeAnimations;
  late List<Animation<Offset>> _slideAnimations;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1400),
      vsync: this,
    );

    // Create staggered animations for each section
    _fadeAnimations = List.generate(8, (index) {
      return Tween<double>(
        begin: 0.0,
        end: 1.0,
      ).animate(CurvedAnimation(
        parent: _animationController,
        curve: Interval(
          index * 0.08,
          0.5 + (index * 0.08),
          curve: Curves.easeOutCubic,
        ),
      ));
    });

    _slideAnimations = List.generate(8, (index) {
      return Tween<Offset>(
        begin: const Offset(0, 0.4),
        end: Offset.zero,
      ).animate(CurvedAnimation(
        parent: _animationController,
        curve: Interval(
          index * 0.08,
          0.5 + (index * 0.08),
          curve: Curves.easeOutCubic,
        ),
      ));
    });

    _scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0.0, 0.4, curve: Curves.easeOutBack),
    ));

    // Start animation after a brief delay
    Future.delayed(const Duration(milliseconds: 150), () {
      if (mounted) _animationController.forward();
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Widget _buildAnimatedSection(int index, Widget child, {bool useScale = false}) {
    if (useScale) {
      return ScaleTransition(
        scale: _scaleAnimation,
        child: SlideTransition(
          position: _slideAnimations[index],
          child: FadeTransition(
            opacity: _fadeAnimations[index],
            child: child,
          ),
        ),
      );
    }
    return SlideTransition(
      position: _slideAnimations[index],
      child: FadeTransition(
        opacity: _fadeAnimations[index],
        child: child,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppConstants.paddingL),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Section
              _buildAnimatedSection(0, _buildHeader(context)),
              const SizedBox(height: AppConstants.paddingL),

              // Wallet Balance Card
              _buildAnimatedSection(1, _buildWalletCard()),
              const SizedBox(height: AppConstants.paddingL),

              // Earning Stats
              _buildAnimatedSection(2, _buildEarningStats()),
              const SizedBox(height: AppConstants.paddingL),

              // Achievement Badges
              _buildAnimatedSection(3, _buildAchievements(context)),
              const SizedBox(height: AppConstants.paddingL),

              // Leaderboard Preview
              _buildAnimatedSection(4, _buildLeaderboard(context)),
              const SizedBox(height: AppConstants.paddingL),

              // Redemption Options
              _buildAnimatedSection(5, _buildRedemptionOptions()),
              const SizedBox(height: AppConstants.paddingL),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Rewards',
          style: theme.textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Text(
          'Your contribution to the sound map is rewarded',
          style: theme.textTheme.bodyLarge?.copyWith(color: theme.colorScheme.onSurfaceVariant),
        ),
      ],
    );
  }

  Widget _buildWalletCard() {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppConstants.paddingL),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDark
              ? [theme.colorScheme.primary, theme.colorScheme.secondary, theme.colorScheme.primary.withOpacity(0.8)]
              : [theme.colorScheme.primary, theme.colorScheme.secondary, theme.colorScheme.primary.withOpacity(0.8)],
          stops: const [0.0, 0.6, 1.0],
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.primary.withOpacity(0.25),
            blurRadius: 20,
            offset: const Offset(0, 10),
            spreadRadius: 2,
          ),
          BoxShadow(
            color: theme.colorScheme.secondary.withOpacity(0.15),
            blurRadius: 40,
            offset: const Offset(0, 20),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Background pattern
          Positioned(
            top: -20,
            right: -20,
            child: Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.05),
              ),
            ),
          ),
          Positioned(
            bottom: -30,
            left: -30,
            child: Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.03),
              ),
            ),
          ),
          // Main content
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'HUSH Wallet',
                        style: theme.textTheme.titleLarge?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Decentralized Rewards',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: Colors.white.withOpacity(0.7),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppConstants.accentGold.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: AppConstants.accentGold.withValues(alpha: 0.3),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: AppConstants.accentGold,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: AppConstants.accentGold.withValues(alpha: 0.6),
                                blurRadius: 4,
                                spreadRadius: 1,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          'Connected',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                            fontFamily: 'Funnel Sans',
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppConstants.paddingL),
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '2,847',
                    style: theme.textTheme.displayMedium?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w900,
                      height: 1.0,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppConstants.accentGold.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        '+12%',
                        style: theme.textTheme.bodySmall?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: theme.colorScheme.secondary,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              Text(
                '\$HUSH Tokens',
                style: theme.textTheme.titleMedium?.copyWith(
                  color: Colors.white.withOpacity(0.9),
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: AppConstants.paddingM),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: theme.cardColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '≈ \$142.35 USD • 24h: +\$16.80',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurface.withOpacity(0.8),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEarningStats() {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Earning Breakdown',
          style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600),
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
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(AppConstants.paddingM),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(AppConstants.radiusM),
        border: Border.all(
          color: color.withOpacity(0.2),
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
                  color: color.withOpacity(0.1),
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
                style: theme.textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.w500,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppConstants.paddingM),
          Text(
            value,
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
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
                  // HushHaptics.lightTap(); // TODO: Add haptic feedback
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
