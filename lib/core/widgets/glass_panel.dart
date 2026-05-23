import 'dart:ui';
import 'package:flutter/material.dart';

class GlassPanel extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final double borderRadius;
  final double blur;
  final double borderOpacity;
  final double surfaceOpacity;
  final Color? borderColor;
  final Color? surfaceColor;
  final double? width;
  final double? height;

  const GlassPanel({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(24.0),
    this.borderRadius = 24.0,
    this.blur = 32.0,
    this.borderOpacity = 0.08,
    this.surfaceOpacity = 0.03,
    this.borderColor,
    this.surfaceColor,
    this.width,
    this.height,
  });

  // Level 2 - Floating variant with higher blur & opacity
  factory GlassPanel.floating({
    required Widget child,
    EdgeInsetsGeometry? padding = const EdgeInsets.all(24.0),
    double borderRadius = 24.0,
    double? width,
    double? height,
  }) {
    return GlassPanel(
      padding: padding,
      borderRadius: borderRadius,
      blur: 64.0,
      borderOpacity: 0.12,
      surfaceOpacity: 0.06,
      width: width,
      height: height,
      child: child,
    );
  }

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
        child: Container(
          width: width,
          height: height,
          padding: padding,
          decoration: BoxDecoration(
            color: (surfaceColor ?? Colors.white).withOpacity(surfaceOpacity),
            borderRadius: BorderRadius.circular(borderRadius),
            border: Border.all(
              color: (borderColor ?? Colors.white).withOpacity(borderOpacity),
              width: 1.0,
            ),
          ),
          child: child,
        ),
      ),
    );
  }
}
