import 'package:flutter/material.dart';
import '../theme/colors.dart';

class AmbientGlow extends StatelessWidget {
  final Widget child;

  const AmbientGlow({
    super.key,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          // Orange Sunset Glow (top center/left)
          Positioned(
            top: -150,
            left: -50,
            child: Container(
              width: size.width * 1.2,
              height: 450,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  center: Alignment.center,
                  radius: 0.5,
                  colors: [
                    AppColors.primary.withOpacity(0.12),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
          
          // Emerald Tropical Glow (bottom right)
          Positioned(
            bottom: -200,
            right: -100,
            child: Container(
              width: size.width * 1.3,
              height: 550,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  center: Alignment.center,
                  radius: 0.5,
                  colors: [
                    AppColors.secondary.withOpacity(0.12),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
          
          // Foreground Content
          SafeArea(
            bottom: false,
            child: child,
          ),
        ],
      ),
    );
  }
}
