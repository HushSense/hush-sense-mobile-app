import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../core/constants/app_constants.dart';
import '../providers/app_providers.dart';
import '../widgets/noise_visualizer.dart';
import '../widgets/decibel_meter.dart';

class MeasureScreen extends ConsumerStatefulWidget {
  const MeasureScreen({super.key});

  @override
  ConsumerState<MeasureScreen> createState() => _MeasureScreenState();
}

class _MeasureScreenState extends ConsumerState<MeasureScreen>
    with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late AnimationController _breathingController;

  @override
  void initState() {
    super.initState();

    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );

    _breathingController = AnimationController(
      duration: const Duration(milliseconds: 3000),
      vsync: this,
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _breathingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final measurementState = ref.watch(measurementStateProvider);
    final locationState = ref.watch(locationProvider);

    return Scaffold(
      backgroundColor: AppConstants.backgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            _buildHeader(),

            // Main Content
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(AppConstants.paddingL),
                child: Column(
                  children: [
                    // Location Info
                    _buildLocationInfo(locationState),

                    const SizedBox(height: AppConstants.paddingXL),

                    // Decibel Meter
                    Expanded(child: _buildDecibelMeter(measurementState)),

                    const SizedBox(height: AppConstants.paddingL),

                    // Control Buttons
                    _buildControlButtons(measurementState),

                    const SizedBox(height: AppConstants.paddingL),

                    // Quick Actions
                    _buildQuickActions(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(AppConstants.paddingL),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(AppConstants.paddingS),
            decoration: BoxDecoration(
              color: AppConstants.primaryColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(AppConstants.radiusM),
            ),
            child: Icon(
              Icons.mic,
              color: AppConstants.primaryColor,
              size: AppConstants.iconSizeM,
            ),
          ),
          const SizedBox(width: AppConstants.paddingM),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Noise Measure',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppConstants.textPrimary,
                      ),
                ),
                Text(
                  'Measure ambient noise levels',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppConstants.textSecondary,
                      ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () {
              // TODO: Show settings or help
            },
            icon: Icon(Icons.help_outline, color: AppConstants.textSecondary),
          ),
        ],
      ),
    );
  }

  Widget _buildLocationInfo(LocationState locationState) {
    return Container(
      padding: const EdgeInsets.all(AppConstants.paddingM),
      decoration: BoxDecoration(
        color: AppConstants.surfaceColor,
        borderRadius: BorderRadius.circular(AppConstants.radiusL),
        boxShadow: [
          BoxShadow(
            color: AppConstants.textPrimary.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(
            Icons.location_on,
            color: AppConstants.primaryColor,
            size: AppConstants.iconSizeM,
          ),
          const SizedBox(width: AppConstants.paddingM),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Current Location',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppConstants.textTertiary,
                      ),
                ),
                Text(
                  locationState.address ?? 'Getting location...',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: AppConstants.textPrimary,
                      ),
                ),
              ],
            ),
          ),
          if (locationState.isLoading)
            const SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
        ],
      ),
    );
  }

  Widget _buildDecibelMeter(MeasurementState measurementState) {
    return Container(
      decoration: BoxDecoration(
        color: AppConstants.surfaceColor,
        borderRadius: BorderRadius.circular(AppConstants.radiusXL),
        boxShadow: [
          BoxShadow(
            color: AppConstants.textPrimary.withValues(alpha: 0.1),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Noise Visualizer
          Expanded(
            flex: 2,
            child: NoiseVisualizer(
              isActive: measurementState.isMeasuring,
              decibelLevel: measurementState.currentDecibelLevel,
            ),
          ),

          // Decibel Display
          Expanded(
            flex: 1,
            child: DecibelMeter(
              decibelLevel: measurementState.currentDecibelLevel,
              isMeasuring: measurementState.isMeasuring,
            ),
          ),

          // Measurement Status
          if (measurementState.isMeasuring)
            Padding(
              padding: const EdgeInsets.all(AppConstants.paddingM),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      color: AppConstants.successColor,
                      shape: BoxShape.circle,
                    ),
                  )
                      .animate(onPlay: (controller) => controller.repeat())
                      .fadeIn(duration: const Duration(milliseconds: 500))
                      .then()
                      .fadeOut(duration: const Duration(milliseconds: 500)),
                  const SizedBox(width: AppConstants.paddingS),
                  Text(
                    'Recording...',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppConstants.successColor,
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildControlButtons(MeasurementState measurementState) {
    return Row(
      children: [
        // Venue Check-in Button
        Expanded(
          child: OutlinedButton.icon(
            onPressed: measurementState.isMeasuring
                ? null
                : () {
                    // TODO: Navigate to venue check-in
                  },
            icon: const Icon(Icons.store),
            label: const Text('Venue Check-in'),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(
                vertical: AppConstants.paddingM,
              ),
            ),
          ),
        ),

        const SizedBox(width: AppConstants.paddingM),

        // Main Record Button
        Expanded(
          flex: 2,
          child: ElevatedButton(
            onPressed: () {
              if (measurementState.isMeasuring) {
                ref.read(measurementStateProvider.notifier).stopMeasurement();
              } else {
                ref.read(measurementStateProvider.notifier).startMeasurement();
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: measurementState.isMeasuring
                  ? AppConstants.errorColor
                  : AppConstants.primaryColor,
              padding: const EdgeInsets.symmetric(
                vertical: AppConstants.paddingL,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppConstants.radiusL),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  measurementState.isMeasuring ? Icons.stop : Icons.mic,
                  color: Colors.white,
                ),
                const SizedBox(width: AppConstants.paddingS),
                Text(
                  measurementState.isMeasuring ? 'Stop' : 'Start Recording',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),

        const SizedBox(width: AppConstants.paddingM),

        // Noise Report Button
        Expanded(
          child: OutlinedButton.icon(
            onPressed: measurementState.isMeasuring
                ? null
                : () {
                    // TODO: Navigate to noise report
                  },
            icon: const Icon(Icons.report),
            label: const Text('Report'),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(
                vertical: AppConstants.paddingM,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildQuickActions() {
    return Container(
      padding: const EdgeInsets.all(AppConstants.paddingM),
      decoration: BoxDecoration(
        color: AppConstants.surfaceColor,
        borderRadius: BorderRadius.circular(AppConstants.radiusL),
        boxShadow: [
          BoxShadow(
            color: AppConstants.textPrimary.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Quick Actions',
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppConstants.textPrimary,
                ),
          ),
          const SizedBox(height: AppConstants.paddingM),
          Row(
            children: [
              Expanded(
                child: _QuickActionCard(
                  icon: Icons.history,
                  title: 'History',
                  subtitle: 'View past measurements',
                  onTap: () {
                    // TODO: Navigate to history
                  },
                ),
              ),
              const SizedBox(width: AppConstants.paddingM),
              Expanded(
                child: _QuickActionCard(
                  icon: Icons.analytics,
                  title: 'Analytics',
                  subtitle: 'See your trends',
                  onTap: () {
                    // TODO: Navigate to analytics
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _QuickActionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _QuickActionCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(AppConstants.paddingM),
        decoration: BoxDecoration(
          color: AppConstants.backgroundColor,
          borderRadius: BorderRadius.circular(AppConstants.radiusM),
          border: Border.all(color: const Color(0xFFCBD5E1), width: 1),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              icon,
              color: AppConstants.primaryColor,
              size: AppConstants.iconSizeM,
            ),
            const SizedBox(height: AppConstants.paddingS),
            Text(
              title,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppConstants.textPrimary,
                  ),
            ),
            Text(
              subtitle,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppConstants.textSecondary,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}
