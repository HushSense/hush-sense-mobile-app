import 'package:flutter/material.dart';
import '../constants/app_constants.dart';
import '../utils/haptic_feedback.dart';
import '../animations/waveform_animation.dart';

/// Premium button widget with HushSense styling and haptic feedback
class PremiumButton extends StatefulWidget {
  final String text;
  final VoidCallback? onPressed;
  final PremiumButtonStyle style;
  final IconData? icon;
  final bool isLoading;
  final bool isExpanded;

  const PremiumButton({
    super.key,
    required this.text,
    this.onPressed,
    this.style = PremiumButtonStyle.primary,
    this.icon,
    this.isLoading = false,
    this.isExpanded = false,
  });

  @override
  State<PremiumButton> createState() => _PremiumButtonState();
}

class _PremiumButtonState extends State<PremiumButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: AppConstants.animationFast,
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.95,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: AppConstants.easeInOutCubic,
    ));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onTapDown(TapDownDetails details) {
    if (widget.onPressed != null && !widget.isLoading) {
      setState(() => _isPressed = true);
      _controller.forward();
      HushHaptics.lightTap();
    }
  }

  void _onTapUp(TapUpDetails details) {
    setState(() => _isPressed = false);
    _controller.reverse();
  }

  void _onTapCancel() {
    setState(() => _isPressed = false);
    _controller.reverse();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _scaleAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: GestureDetector(
            onTapDown: _onTapDown,
            onTapUp: _onTapUp,
            onTapCancel: _onTapCancel,
            onTap: widget.onPressed,
            child: AnimatedContainer(
              duration: AppConstants.animationNormal,
              curve: AppConstants.easeInOutCubic,
              width: widget.isExpanded ? double.infinity : null,
              padding: const EdgeInsets.symmetric(
                horizontal: 24,
                vertical: 16,
              ),
              decoration: BoxDecoration(
                color: _getBackgroundColor(),
                borderRadius: BorderRadius.circular(24),
                border: _getBorder(),
                boxShadow: _getShadow(),
              ),
              child: Row(
                mainAxisSize: widget.isExpanded 
                    ? MainAxisSize.max 
                    : MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (widget.isLoading) ...[
                    SizedBox(
                      width: 24,
                      height: 24,
                      child: WaveformAnimation(
                        isActive: true,
                        amplitude: 0.7,
                        color: _getTextColor(),
                        height: 18,
                        waveCount: 5,
                        duration: const Duration(milliseconds: 1200),
                      ),
                    ),
                    const SizedBox(width: 12),
                  ] else if (widget.icon != null) ...[
                    Icon(
                      widget.icon,
                      color: _getTextColor(),
                      size: 18,
                    ),
                    const SizedBox(width: 8),
                  ],
                  Text(
                    widget.text,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: _getTextColor(),
                      fontFamily: 'Poppins',
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Color _getBackgroundColor() {
    if (widget.onPressed == null || widget.isLoading) {
      return AppConstants.softGray.withOpacity(0.3);
    }

    switch (widget.style) {
      case PremiumButtonStyle.primary:
        return _isPressed 
            ? AppConstants.primaryTeal.withOpacity(0.8)
            : AppConstants.primaryTeal;
      case PremiumButtonStyle.secondary:
        return _isPressed
            ? AppConstants.mutedGreenBg.withOpacity(0.8)
            : AppConstants.pureWhite;
      case PremiumButtonStyle.ghost:
        return _isPressed
            ? AppConstants.primaryTeal.withOpacity(0.1)
            : Colors.transparent;
    }
  }

  Color _getTextColor() {
    if (widget.onPressed == null || widget.isLoading) {
      return AppConstants.softGray;
    }

    switch (widget.style) {
      case PremiumButtonStyle.primary:
        return AppConstants.pureWhite;
      case PremiumButtonStyle.secondary:
        return AppConstants.primaryTeal;
      case PremiumButtonStyle.ghost:
        return AppConstants.primaryTeal;
    }
  }

  Border? _getBorder() {
    if (widget.style == PremiumButtonStyle.secondary ||
        widget.style == PremiumButtonStyle.ghost) {
      return Border.all(
        color: widget.onPressed == null || widget.isLoading
            ? AppConstants.softGray.withOpacity(0.3)
            : AppConstants.primaryTeal,
        width: 1.5,
      );
    }
    return null;
  }

  List<BoxShadow>? _getShadow() {
    if (widget.style == PremiumButtonStyle.primary && 
        widget.onPressed != null && 
        !widget.isLoading) {
      return [
        BoxShadow(
          color: AppConstants.primaryTeal.withOpacity(0.3),
          blurRadius: 8,
          offset: const Offset(0, 4),
        ),
      ];
    }
    return null;
  }
}

enum PremiumButtonStyle {
  primary,   // Teal background, white text
  secondary, // White background, teal border and text
  ghost,     // Transparent background, teal border and text
}

/// Floating action button with HushSense styling
class PremiumFAB extends StatelessWidget {
  final VoidCallback? onPressed;
  final IconData icon;
  final bool isRecording;

  const PremiumFAB({
    super.key,
    this.onPressed,
    required this.icon,
    this.isRecording = false,
  });

  @override
  Widget build(BuildContext context) {
    return PulseAnimation(
      isActive: isRecording,
      child: Container(
        width: 64,
        height: 64,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: AppConstants.primaryTeal,
          boxShadow: [
            BoxShadow(
              color: AppConstants.primaryTeal.withOpacity(0.3),
              blurRadius: 16,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(32),
            onTap: () {
              HushHaptics.mediumTap();
              onPressed?.call();
            },
            child: Icon(
              icon,
              color: AppConstants.pureWhite,
              size: 28,
            ),
          ),
        ),
      ),
    );
  }
}

/// Premium card widget with HushSense styling
class PremiumCard extends StatelessWidget {
  final Widget child;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final bool hasShadow;

  const PremiumCard({
    super.key,
    required this.child,
    this.onTap,
    this.padding = const EdgeInsets.all(20),
    this.margin,
    this.hasShadow = true,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: margin,
      decoration: BoxDecoration(
        color: AppConstants.pureWhite,
        borderRadius: BorderRadius.circular(16),
        boxShadow: hasShadow ? [
          BoxShadow(
            color: AppConstants.deepBlue.withOpacity(0.08),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ] : null,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onTap != null ? () {
            HushHaptics.lightTap();
            onTap!();
          } : null,
          child: Padding(
            padding: padding ?? EdgeInsets.zero,
            child: child,
          ),
        ),
      ),
    );
  }
}
