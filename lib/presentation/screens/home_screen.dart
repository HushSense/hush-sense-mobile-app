import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants/app_constants.dart';
import '../widgets/stats_card.dart';
import '../widgets/quick_action_card.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

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
              
              // Stats Overview
              _buildStatsSection(),
              const SizedBox(height: AppConstants.paddingXL),
              
              // Quick Actions
              _buildQuickActions(),
              const SizedBox(height: AppConstants.paddingXL),
              
              // Recent Activity
              _buildRecentActivity(context),
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
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Good morning',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: AppConstants.textSecondary,
                      fontFamily: 'Funnel Sans',
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Sound Scout',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppConstants.textPrimary,
                      fontFamily: 'Funnel Sans',
                    ),
                  ),
                ],
              ),
            ),
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: AppConstants.primaryTeal.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Icon(
                Icons.person,
                color: AppConstants.primaryTeal,
                size: 24,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppConstants.paddingM),
        Text(
          'Ready to map the sound of your city?',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: AppConstants.textSecondary,
            fontFamily: 'Funnel Sans',
          ),
        ),
      ],
    );
  }

  Widget _buildStatsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Your Impact',
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
              child: StatsCard(
                title: 'Measurements',
                value: '127',
                subtitle: 'This month',
                icon: Icons.mic,
                color: AppConstants.primaryTeal,
              ),
            ),
            const SizedBox(width: AppConstants.paddingM),
            Expanded(
              child: StatsCard(
                title: '\$HUSH Earned',
                value: '2.4K',
                subtitle: 'Total rewards',
                icon: Icons.monetization_on,
                color: AppConstants.accentGold,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppConstants.paddingM),
        Row(
          children: [
            Expanded(
              child: StatsCard(
                title: 'Streak',
                value: '12',
                subtitle: 'Days active',
                icon: Icons.local_fire_department,
                color: AppConstants.accentOrange,
              ),
            ),
            const SizedBox(width: AppConstants.paddingM),
            Expanded(
              child: StatsCard(
                title: 'Rank',
                value: '#47',
                subtitle: 'In your city',
                icon: Icons.leaderboard,
                color: AppConstants.primaryColor,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildQuickActions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Quick Actions',
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
              child: QuickActionCard(
                title: 'Start\nMeasuring',
                subtitle: 'Capture noise data',
                icon: Icons.play_circle_fill,
                color: AppConstants.primaryTeal,
                onTap: () {
                  // TODO: Navigate to measure screen (index 2)
                },
              ),
            ),
            const SizedBox(width: AppConstants.paddingM),
            Expanded(
              child: QuickActionCard(
                title: 'Check-in\nVenue',
                subtitle: 'Rate a location',
                icon: Icons.location_on,
                color: AppConstants.primaryColor,
                onTap: () {
                  // TODO: Navigate to venue check-in flow
                },
              ),
            ),
          ],
        ),
        const SizedBox(height: AppConstants.paddingM),
        QuickActionCard(
          title: 'View Noise Map',
          subtitle: 'Explore your city\'s sound landscape',
          icon: Icons.map,
          color: AppConstants.accentGold,
          isWide: true,
          onTap: () {
            // TODO: Navigate to map screen (index 1)
          },
        ),
      ],
    );
  }

  Widget _buildRecentActivity(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Recent Activity',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: AppConstants.textPrimary,
                fontFamily: 'Funnel Sans',
              ),
            ),
            TextButton(
              onPressed: () {
                // TODO: Navigate to activity history screen
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
        _buildActivityItem(
          'Measurement at Central Park',
          '65 dB • 2 hours ago',
          Icons.mic,
          AppConstants.primaryTeal,
        ),
        _buildActivityItem(
          'Venue Check-in: Quiet Cafe',
          '42 dB • Yesterday',
          Icons.location_on,
          AppConstants.primaryColor,
        ),
        _buildActivityItem(
          'Earned 50 \$HUSH tokens',
          'Daily streak bonus • 2 days ago',
          Icons.monetization_on,
          AppConstants.accentGold,
        ),
      ],
    );
  }

  Widget _buildActivityItem(String title, String subtitle, IconData icon, Color color) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppConstants.paddingM),
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
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              color: color,
              size: 20,
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
                    fontWeight: FontWeight.w500,
                    color: AppConstants.textPrimary,
                    fontFamily: 'Funnel Sans',
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 14,
                    color: AppConstants.textSecondary,
                    fontFamily: 'Funnel Sans',
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

