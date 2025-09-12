import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hush_sense/presentation/screens/capture_screen.dart';

import '../../core/constants/app_constants.dart';
import 'home_screen.dart';
import 'map_screen.dart';
import 'rewards_screen.dart';
import 'profile_screen.dart';

class MainNavigationScreen extends ConsumerStatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  ConsumerState<MainNavigationScreen> createState() =>
      _MainNavigationScreenState();
}

class _MainNavigationScreenState extends ConsumerState<MainNavigationScreen> {
  int _currentIndex = 2; // Start with Measure screen as it's the main feature

  final List<Widget> _screens = [
    const HomeScreen(),
    const MapScreen(),
    const MeasureScreen(),
    const RewardsScreen(),
    const ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _currentIndex, children: _screens),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: AppConstants.surfaceColor,
          boxShadow: [
            BoxShadow(
              color: AppConstants.textPrimary.withValues(alpha: 0.1),
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppConstants.paddingM,
              vertical: AppConstants.paddingS,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _NavigationItem(
                  icon: Icons.home_outlined,
                  activeIcon: Icons.home,
                  label: 'Home',
                  isActive: _currentIndex == 0,
                  onTap: () => _setIndex(0),
                ),
                _NavigationItem(
                  icon: Icons.map_outlined,
                  activeIcon: Icons.map,
                  label: 'Map',
                  isActive: _currentIndex == 1,
                  onTap: () => _setIndex(1),
                ),
                _NavigationItem(
                  icon: Icons.mic_outlined,
                  activeIcon: Icons.mic,
                  label: 'Measure',
                  isActive: _currentIndex == 2,
                  onTap: () => _setIndex(2),
                  isPrimary: true,
                ),
                _NavigationItem(
                  icon: Icons.card_giftcard_outlined,
                  activeIcon: Icons.card_giftcard,
                  label: 'Rewards',
                  isActive: _currentIndex == 3,
                  onTap: () => _setIndex(3),
                ),
                _NavigationItem(
                  icon: Icons.person_outline,
                  activeIcon: Icons.person,
                  label: 'Profile',
                  isActive: _currentIndex == 4,
                  onTap: () => _setIndex(4),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _setIndex(int index) {
    setState(() {
      _currentIndex = index;
    });
  }
}

class _NavigationItem extends StatelessWidget {
  final IconData icon;
  final IconData activeIcon;
  final String label;
  final bool isActive;
  final VoidCallback onTap;
  final bool isPrimary;

  const _NavigationItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
    required this.isActive,
    required this.onTap,
    this.isPrimary = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppConstants.paddingS,
          vertical: AppConstants.paddingS,
        ),
        decoration: BoxDecoration(
          color: isActive
              ? (isPrimary
                    ? AppConstants.primaryColor
                    : AppConstants.primaryColor.withValues(alpha: 0.1))
              : Colors.transparent,
          borderRadius: BorderRadius.circular(AppConstants.radiusM),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isActive ? activeIcon : icon,
              size: AppConstants.iconSizeM,
              color: isActive
                  ? (isPrimary ? Colors.white : AppConstants.primaryColor)
                  : AppConstants.textTertiary,
            ),
            const SizedBox(height: AppConstants.paddingXS),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
                color: isActive
                    ? (isPrimary ? Colors.white : AppConstants.primaryColor)
                    : AppConstants.textTertiary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

