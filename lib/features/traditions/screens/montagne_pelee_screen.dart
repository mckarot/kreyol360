import 'package:flutter/material.dart';
import '../../../core/theme/colors.dart';
import '../../../core/widgets/glass_panel.dart';

class MontagnePeleeScreen extends StatelessWidget {
  const MontagnePeleeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          // 1. Custom Volcanic Magma Ambient Glow Background
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
                    AppColors.primary.withOpacity(0.18), // Hot volcanic orange
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
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
                    AppColors.tertiary.withOpacity(0.08), // Warm golden ash
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),

          // 2. Parallax Scrollable Content
          CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              // Beautiful Glassy Parallax Header
              SliverAppBar(
                expandedHeight: 320,
                backgroundColor: Colors.transparent,
                elevation: 0,
                pinned: true,
                leading: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.4),
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white.withOpacity(0.1)),
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.arrow_back, color: Colors.white, size: 20),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ),
                ),
                flexibleSpace: FlexibleSpaceBar(
                  background: Stack(
                    fit: StackFit.expand,
                    children: [
                      Image.network(
                        'https://lh3.googleusercontent.com/aida-public/AB6AXuDJikaKmT87uwpNpPxMCQTkJDfUFpq5JTRD74nnqloOnE9EUkI6XaaPhWAvYVnfnkJYec9_QacZJLgXQEMAKSAANMTZvahKHB_XGe1DD62GCxNG7LbWs6VTS99P06YFu3E0_3A-EhHJ_Vgl9vUhVhQeJAOQca7aeoaYFpoYrhWd21MXrU2YYcCKI2RZSwjbYudn37C8ADQJZLZxfsZ-YGg0cpwTsOzfhIakZSgoH8ZYpvady9oMt4YZ6qv6KanBiz6eRIPurZB7AA',
                        fit: BoxFit.cover,
                      ),
                      // Soft volcanic smoke gradient overlay
                      Container(
                        decoration: const BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.transparent,
                              Colors.black54,
                              AppColors.background,
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Volcanic details body
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Badge & Volcano status
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: AppColors.primaryContainer.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: AppColors.primary.withOpacity(0.3)),
                            ),
                            child: const Row(
                              children: [
                                Icon(Icons.warning_amber_rounded, color: AppColors.primaryLight, size: 14),
                                SizedBox(width: 4),
                                Text(
                                  "ACTIF",
                                  style: TextStyle(
                                    color: AppColors.primaryLight,
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 1.0,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.05),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: Colors.white.withOpacity(0.1)),
                            ),
                            child: const Text(
                              "NORD DE LA MARTINIQUE",
                              style: TextStyle(
                                color: AppColors.onSurfaceVariant,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Title
                      const Text(
                        "La Montagne Pelée",
                        style: TextStyle(
                          color: AppColors.onSurface,
                          fontSize: 32,
                          fontFamily: 'Epilogue',
                          fontWeight: FontWeight.w800,
                          height: 1.2,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        "L'obsidienne géante et la mémoire de Saint-Pierre",
                        style: TextStyle(
                          color: AppColors.onSurfaceVariant.withOpacity(0.8),
                          fontSize: 16,
                          fontFamily: 'Be Vietnam Pro',
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                      const SizedBox(height: 32),

                      // Key Specifications Grid
                      Row(
                        children: [
                          _buildStatCard("Altitude", "1 397 m", Icons.landscape),
                          const SizedBox(width: 12),
                          _buildStatCard("Type", "Péléen", Icons.volcano),
                          const SizedBox(width: 12),
                          _buildStatCard("Dernier réveil", "1929 - 1932", Icons.alarm),
                        ],
                      ),
                      const SizedBox(height: 32),

                      // Historical description
                      const Text(
                        "La Catastrophe du 8 mai 1902",
                        style: TextStyle(
                          color: AppColors.onSurface,
                          fontSize: 20,
                          fontFamily: 'Epilogue',
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      GlassPanel(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "À 7h52 le matin du 8 mai 1902, le flanc du volcan se déchire. Une nuée ardente phénoménale — un nuage de gaz surchauffés, de cendres et de roches à plus de 1000°C s'échappe à plus de 500 km/h vers la ville côtière de Saint-Pierre.",
                              style: TextStyle(
                                color: AppColors.onSurface.withOpacity(0.9),
                                fontSize: 14,
                                fontFamily: 'Be Vietnam Pro',
                                height: 1.5,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              "En moins de 3 minutes, la 'Pégase des Caraïbes', alors capitale culturelle et économique de la Martinique surnommée le 'Petit Paris des Antilles', est entièrement rasée. La catastrophe fait près de 30 000 victimes, devenant l'éruption volcanique la plus meurtrière du XXe siècle.",
                              style: TextStyle(
                                color: AppColors.onSurface.withOpacity(0.9),
                                fontSize: 14,
                                fontFamily: 'Be Vietnam Pro',
                                height: 1.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 32),

                      // Legend/Survivor: Cyparis
                      const Text(
                        "Louis-Auguste Cyparis : Le Survivant",
                        style: TextStyle(
                          color: AppColors.onSurface,
                          fontSize: 20,
                          fontFamily: 'Epilogue',
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      GlassPanel(
                        borderColor: AppColors.tertiary,
                        borderOpacity: 0.15,
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: AppColors.tertiary.withOpacity(0.1),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.shield_moon_outlined, color: AppColors.tertiary, size: 24),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    "Sauvé par son cachot",
                                    style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold),
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    "Parmi les rares rescapés directs figure Cyparis, un prisonnier enfermé dans un cachot aux murs de pierre extrêmement épais. Bien que grièvement brûlé par les gaz incandescents infiltrés sous la porte, il survit et sera retrouvé 3 jours après par les secouristes.",
                                    style: TextStyle(
                                      color: AppColors.onSurfaceVariant.withOpacity(0.9),
                                      fontSize: 13,
                                      height: 1.4,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 32),

                      // Exploring the volcano today
                      const Text(
                        "Explorer la Montagne aujourd'hui",
                        style: TextStyle(
                          color: AppColors.onSurface,
                          fontSize: 20,
                          fontFamily: 'Epilogue',
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      GlassPanel(
                        child: Text(
                          "Aujourd'hui, la Montagne Pelée est classée au patrimoine mondial de l'UNESCO. Elle offre des sentiers de randonnée somptueux mais sportifs (comme le sentier de l'Aileron), plongeant les randonneurs dans une forêt de nuages humide et dévoilant, par temps dégagé, des panoramas spectaculaires sur la mer des Caraïbes et l'Atlantique.",
                          style: TextStyle(
                            color: AppColors.onSurface.withOpacity(0.9),
                            fontSize: 14,
                            fontFamily: 'Be Vietnam Pro',
                            height: 1.5,
                          ),
                        ),
                      ),
                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String label, String value, IconData icon) {
    return Expanded(
      child: GlassPanel(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
        borderRadius: 16,
        child: Column(
          children: [
            Icon(icon, color: AppColors.primaryLight, size: 20),
            const SizedBox(height: 8),
            Text(
              label,
              style: const TextStyle(color: AppColors.onSurfaceVariant, fontSize: 10, fontFamily: 'Be Vietnam Pro'),
            ),
            const SizedBox(height: 4),
            Text(
              value,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 13,
                fontFamily: 'Epilogue',
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
