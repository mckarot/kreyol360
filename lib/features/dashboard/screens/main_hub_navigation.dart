import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/widgets/glass_panel.dart';
import '../../../core/widgets/ambient_glow.dart';
import '../../../core/theme/colors.dart';
import '../../../core/navigation/navigation_service.dart';
import 'home_screen.dart';
import '../../map/screens/map_outings_wrapper.dart';
import '../../music/screens/music_screen.dart';
import '../../language/screens/profile_screen.dart';

class MainHubNavigation extends StatelessWidget {
  const MainHubNavigation({super.key});

  final List<Widget> _screens = const [
    HomeScreen(),
    MapOutingsWrapper(),
    MusicScreen(),
    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final navService = Provider.of<NavigationService>(context);
    final currentIndex = navService.currentIndex;

    return AmbientGlow(
      child: Stack(
        children: [
          // Current Selected Screen Content
          Positioned.fill(
            child: IndexedStack(
              index: currentIndex,
              children: _screens,
            ),
          ),
          
          // Floating Glassmorphic Bottom Navigation Bar
          Positioned(
            left: 24,
            right: 24,
            bottom: 24,
            child: GlassPanel.floating(
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
              borderRadius: 30.0,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildNavItem(context, 0, Icons.home_filled, "Accueil", currentIndex),
                  _buildNavItem(context, 1, Icons.map_outlined, "Carte", currentIndex),
                  _buildNavItem(context, 2, Icons.music_note_outlined, "Musique", currentIndex),
                  _buildNavItem(context, 3, Icons.person_outline_rounded, "Profil", currentIndex),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem(BuildContext context, int index, IconData icon, String label, int currentIndex) {
    final isSelected = currentIndex == index;
    
    return GestureDetector(
      onTap: () {
        Provider.of<NavigationService>(context, listen: false).changeTab(index);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: isSelected
            ? BoxDecoration(
                color: AppColors.primaryContainer.withOpacity(0.2),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: AppColors.primaryLight.withOpacity(0.3),
                  width: 1,
                ),
              )
            : const BoxDecoration(),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: isSelected ? AppColors.primaryLight : AppColors.onSurface.withOpacity(0.6),
              size: 24,
            ),
            if (isSelected) ...[
              const SizedBox(width: 8),
              Text(
                label,
                style: const TextStyle(
                  color: AppColors.onSurface,
                  fontSize: 12,
                  fontFamily: 'Be Vietnam Pro',
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
