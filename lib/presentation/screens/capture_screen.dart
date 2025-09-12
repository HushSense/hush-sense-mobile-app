import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/app_constants.dart';
import '../providers/app_providers.dart';
import '../../core/animations/waveform_animation.dart';

class MeasureScreen extends ConsumerStatefulWidget {
  const MeasureScreen({super.key});

  @override
  ConsumerState<MeasureScreen> createState() => _MeasureScreenState();
}

class _MeasureScreenState extends ConsumerState<MeasureScreen>
    with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late AnimationController _rippleController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _rippleController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _rippleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final measurementState = ref.watch(measurementStateProvider);
    final locationState = ref.watch(locationProvider);

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 20),
                
                // Header
                _buildHeader(),
                
                const SizedBox(height: 24),
                
                // Location Card
                _buildLocationCard(locationState),
                
                const SizedBox(height: 40),
                
                // Main Measurement Circle
                _buildMeasurementCircle(measurementState),
                
                const SizedBox(height: 40),
                
                // Decibel Display
                _buildDecibelDisplay(measurementState),
                
                const SizedBox(height: 32),
                
                // Control Buttons
                _buildControlButtons(measurementState),
                
                const SizedBox(height: 32),
                
                // Quick Actions
                _buildQuickActions(),
                
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppConstants.primaryColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(
            Icons.mic,
            color: AppConstants.primaryColor,
            size: 20,
          ),
        ),
        const SizedBox(width: 16),
        const Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Noise Measure',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppConstants.textPrimary,
                ),
              ),
              Text(
                'Measure ambient noise levels',
                style: TextStyle(
                  fontSize: 14,
                  color: AppConstants.textSecondary,
                ),
              ),
            ],
          ),
        ),
        IconButton(
          onPressed: () {},
          icon: const Icon(
            Icons.help_outline,
            color: AppConstants.textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildLocationCard(LocationState locationState) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF8F9FA),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE9ECEF)),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.location_on,
            color: AppConstants.primaryColor,
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Current Location',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppConstants.textTertiary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  locationState.address ?? 'Getting location...',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppConstants.textPrimary,
                  ),
                ),
              ],
            ),
          ),
          if (locationState.isLoading)
            const SizedBox(
              width: 32,
              height: 24,
              child: WaveformAnimation(
                isActive: true,
                amplitude: 0.7,
                color: AppConstants.primaryTeal,
                height: 16,
                waveCount: 5,
                duration: Duration(milliseconds: 1200),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildMeasurementCircle(MeasurementState measurementState) {
    return Center(
      child: Container(
        width: 280,
        height: 280,
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Outer ripple circles
            if (measurementState.isMeasuring) ...[
              _buildRippleCircle(280, 0.1),
              _buildRippleCircle(240, 0.15),
              _buildRippleCircle(200, 0.2),
            ],
            
            // Main measurement circle
            Container(
              width: 160,
              height: 160,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    AppConstants.primaryColor.withOpacity(0.3),
                    AppConstants.primaryColor.withOpacity(0.1),
                    Colors.transparent,
                  ],
                ),
              ),
              child: Container(
                margin: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppConstants.primaryColor.withOpacity(0.1),
                  border: Border.all(
                    color: AppConstants.primaryColor,
                    width: 2,
                  ),
                ),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: const BoxDecoration(
                          color: AppConstants.primaryColor,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        width: 4,
                        height: 4,
                        decoration: const BoxDecoration(
                          color: AppConstants.primaryColor,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        width: 6,
                        height: 6,
                        decoration: const BoxDecoration(
                          color: AppConstants.primaryColor,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRippleCircle(double size, double opacity) {
    return AnimatedBuilder(
      animation: _rippleController,
      builder: (context, child) {
        return Container(
          width: size * (0.8 + 0.2 * _rippleController.value),
          height: size * (0.8 + 0.2 * _rippleController.value),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: AppConstants.primaryColor.withOpacity(
                opacity * (1 - _rippleController.value),
              ),
              width: 1,
            ),
          ),
        );
      },
    );
  }

  Widget _buildDecibelDisplay(MeasurementState measurementState) {
    return Column(
      children: [
        // Large decibel number
        RichText(
          text: TextSpan(
            children: [
              TextSpan(
                text: measurementState.currentDecibelLevel.toStringAsFixed(1),
                style: const TextStyle(
                  fontSize: 48,
                  fontWeight: FontWeight.bold,
                  color: AppConstants.textPrimary,
                ),
              ),
              const TextSpan(
                text: ' dB',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w500,
                  color: AppConstants.textSecondary,
                ),
              ),
            ],
          ),
        ),
        
        const SizedBox(height: 8),
        
        // Status indicator
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          decoration: BoxDecoration(
            color: _getNoiseColor(measurementState.currentDecibelLevel),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            _getNoiseLabel(measurementState.currentDecibelLevel),
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
        ),
      ],
    );
  }

  Color _getNoiseColor(double decibelLevel) {
    if (decibelLevel < 40) return AppConstants.noiseQuiet;
    if (decibelLevel < 55) return AppConstants.noiseModerate;
    if (decibelLevel < 70) return AppConstants.noiseLoud;
    return AppConstants.noiseVeryLoud;
  }

  String _getNoiseLabel(double decibelLevel) {
    if (decibelLevel < 40) return 'Quiet';
    if (decibelLevel < 55) return 'Moderate';
    if (decibelLevel < 70) return 'Loud';
    return 'Very Loud';
  }

  Widget _buildControlButtons(MeasurementState measurementState) {
    return Row(
      children: [
        // Venue Check-in Button
        Expanded(
          child: Container(
            height: 48,
            decoration: BoxDecoration(
              border: Border.all(color: AppConstants.primaryColor),
              borderRadius: BorderRadius.circular(24),
            ),
            child: TextButton.icon(
              onPressed: measurementState.isMeasuring ? null : () {},
              icon: const Icon(
                Icons.store,
                color: AppConstants.primaryColor,
                size: 16,
              ),
              label: const Text(
                'Venue\nCheck-in',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: AppConstants.primaryColor,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
              ),
              style: TextButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
              ),
            ),
          ),
        ),

        const SizedBox(width: 12),

        // Main Record Button
        Expanded(
          flex: 2,
          child: Container(
            height: 48,
            child: ElevatedButton(
              onPressed: () {
                if (measurementState.isMeasuring) {
                  ref.read(measurementStateProvider.notifier).stopMeasurement();
                  _rippleController.stop();
                } else {
                  ref.read(measurementStateProvider.notifier).startMeasurement();
                  _rippleController.repeat();
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppConstants.primaryColor,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
                elevation: 0,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    measurementState.isMeasuring ? Icons.stop : Icons.mic,
                    size: 18,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    measurementState.isMeasuring ? 'Stop' : 'Start Recording',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),

        const SizedBox(width: 12),

        // Report Button
        Expanded(
          child: Container(
            height: 48,
            decoration: BoxDecoration(
              border: Border.all(color: AppConstants.primaryColor),
              borderRadius: BorderRadius.circular(24),
            ),
            child: TextButton.icon(
              onPressed: measurementState.isMeasuring ? null : () {},
              icon: const Icon(
                Icons.report,
                color: AppConstants.primaryColor,
                size: 16,
              ),
              label: const Text(
                'Report',
                style: TextStyle(
                  color: AppConstants.primaryColor,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
              style: TextButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildQuickActions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Quick Actions',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AppConstants.textPrimary,
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _QuickActionCard(
                icon: Icons.history,
                title: 'History',
                subtitle: 'View past measurements',
                onTap: () {},
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _QuickActionCard(
                icon: Icons.analytics,
                title: 'Analytics',
                subtitle: 'See your trends',
                onTap: () {},
              ),
            ),
          ],
        ),
      ],
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
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFFF8F9FA),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFE9ECEF)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              icon,
              color: AppConstants.primaryColor,
              size: 24,
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppConstants.textPrimary,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              subtitle,
              style: const TextStyle(
                fontSize: 12,
                color: AppConstants.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
