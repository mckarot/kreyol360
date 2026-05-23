import 'package:flutter/material.dart';
import '../../../core/theme/colors.dart';
import '../../../core/widgets/glass_panel.dart';
import '../../../core/widgets/ambient_glow.dart';
import 'traditions_screen.dart';

class TraditionsFetesHubScreen extends StatefulWidget {
  const TraditionsFetesHubScreen({super.key});

  @override
  State<TraditionsFetesHubScreen> createState() => _TraditionsFetesHubScreenState();
}

class _TraditionsFetesHubScreenState extends State<TraditionsFetesHubScreen> {
  int _selectedCalendarIndex = 0;

  final List<Map<String, String>> _calendarEvents = [
    {"month": "Fév", "day": "11", "title": "Dimanche Gras"},
    {"month": "Mar", "day": "29", "title": "Vendredi Saint"},
    {"month": "Mai", "day": "22", "title": "Abolition"},
    {"month": "Août", "day": "15", "title": "Fête des Yoles"},
  ];

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          // 1. Ambient Glow Accents
          Positioned(
            top: -100,
            left: -100,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    AppColors.primary.withOpacity(0.15),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            top: size.height * 0.4,
            right: -150,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    AppColors.secondary.withOpacity(0.1),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),

          // 2. Custom Scrollable Content
          SafeArea(
            child: CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                // Top Custom Header App Bar
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Leading Avatar & Achievement Badge
                        Row(
                          children: [
                            Stack(
                              children: [
                                Container(
                                  width: 40,
                                  height: 40,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    border: Border.all(color: Colors.white.withOpacity(0.08)),
                                    image: const DecorationImage(
                                      image: NetworkImage(
                                        'https://lh3.googleusercontent.com/aida-public/AB6AXuBauHjZ1sKcU0sEov-RxrSndNmqijs2uxxlFe-QMl-y8XbgBr0BEc1MSFm_8nlrBaU0XaCCPOSIob9wZpMYyIEQt278I1X8v8RYN_NqrYZRLfMPGNaOy6MjnCQ_yrZuSYzThE0GFcdvNanIZWi8NsfSL-ISXNwGcxV_eZT58n55sJUJqgWkjUwru5MuzoLjGawQ9ZK98TVwEl7REuIsvZGziy8djUvev3Hcu1UDz-BQ63sb-OypWig_0pmQqYpuJzLpBbh8XHGoMA',
                                      ),
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                ),
                                Positioned(
                                  bottom: 0,
                                  right: 0,
                                  child: Container(
                                    width: 12,
                                    height: 12,
                                    decoration: const BoxDecoration(
                                      color: AppColors.tertiary,
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        // Main Title
                        const Text(
                          "Krèyol Heritage",
                          style: TextStyle(
                            color: AppColors.tertiary,
                            fontSize: 18,
                            fontFamily: 'Epilogue',
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        // Fire Button
                        IconButton(
                          icon: const Icon(Icons.local_fire_department, color: AppColors.onSurface, size: 20),
                          onPressed: () {},
                        ),
                      ],
                    ),
                  ),
                ),

                // Title Intro
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ShaderMask(
                          shaderCallback: (bounds) => const LinearGradient(
                            colors: [Color(0xFFFF4E50), Color(0xFFFFD700)],
                          ).createShader(bounds),
                          child: const Text(
                            "Traditions & Fêtes",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 32,
                              fontFamily: 'Epilogue',
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          "Plongez dans le rythme des célébrations caribéennes. Découvrez les événements qui façonnent notre culture.",
                          style: TextStyle(
                            color: AppColors.onSurfaceVariant.withOpacity(0.8),
                            fontSize: 14,
                            fontFamily: 'Be Vietnam Pro',
                            height: 1.4,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Interactive Cultural Calendar
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.only(top: 16, bottom: 8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 24),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                "Calendrier Culturel",
                                style: TextStyle(
                                  color: AppColors.onSurface,
                                  fontSize: 18,
                                  fontFamily: 'Epilogue',
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              TextButton(
                                onPressed: () {},
                                child: const Text(
                                  "Voir tout",
                                  style: TextStyle(
                                    color: AppColors.secondary,
                                    fontFamily: 'Be Vietnam Pro',
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          physics: const BouncingScrollPhysics(),
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                          child: Row(
                            children: List.generate(_calendarEvents.length, (index) {
                              final isSelected = _selectedCalendarIndex == index;
                              final cal = _calendarEvents[index];

                              return Padding(
                                padding: const EdgeInsets.only(right: 12),
                                child: GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      _selectedCalendarIndex = index;
                                    });
                                  },
                                  child: AnimatedContainer(
                                    duration: const Duration(milliseconds: 250),
                                    width: 120,
                                    padding: const EdgeInsets.all(16),
                                    decoration: BoxDecoration(
                                      color: isSelected
                                          ? AppColors.secondary.withOpacity(0.12)
                                          : Colors.white.withOpacity(0.03),
                                      borderRadius: BorderRadius.circular(16),
                                      border: Border.all(
                                        color: isSelected
                                            ? AppColors.secondary.withOpacity(0.5)
                                            : Colors.white.withOpacity(0.08),
                                      ),
                                      boxShadow: isSelected
                                          ? [
                                              BoxShadow(
                                                color: AppColors.secondary.withOpacity(0.15),
                                                blurRadius: 10,
                                              )
                                            ]
                                          : null,
                                    ),
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Text(
                                          cal["month"]!.toUpperCase(),
                                          style: TextStyle(
                                            color: isSelected ? AppColors.secondary : AppColors.onSurfaceVariant.withOpacity(0.6),
                                            fontSize: 11,
                                            fontFamily: 'Be Vietnam Pro',
                                            fontWeight: FontWeight.bold,
                                            letterSpacing: 1.5,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          cal["day"]!,
                                          style: const TextStyle(
                                            color: AppColors.onSurface,
                                            fontSize: 24,
                                            fontFamily: 'Epilogue',
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        const SizedBox(height: 6),
                                        Text(
                                          cal["title"]!,
                                          textAlign: TextAlign.center,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: TextStyle(
                                            color: AppColors.onSurfaceVariant.withOpacity(0.8),
                                            fontSize: 10,
                                            fontFamily: 'Be Vietnam Pro',
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            }),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Carnaval Hero Banner
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(24),
                      child: Container(
                        height: 380,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.03),
                          border: Border.all(color: Colors.white.withOpacity(0.08)),
                        ),
                        child: Stack(
                          children: [
                            // Background Image
                            Positioned.fill(
                              child: Image.network(
                                'https://lh3.googleusercontent.com/aida-public/AB6AXuBBMeAJROrPNbZGENYZstga1I9U1PlnrOelWvLGCjkbewZ1jOnJ5IN-w_583kco_7-rY3TQzIs4yg9iWNIZQW2bjiPNFo2p8-FavRx08rcHH55WZbpp0SvxJVY9UWxNkwrjiV5GagWltqfu9c_tRDaXr_llJuzIxTeVZfMdUcvIOjH7LlHp1rRpF6QNG9T8tfbGE0Ca8gzDhO7oEDYihbGG2LWMS-8R5G7VUPHHPsfSqvBQZa9b7gh-EupKNaGTXK2rRuJ7EwtXSA',
                                fit: BoxFit.cover,
                              ),
                            ),
                            // Gradient overlay
                            Positioned.fill(
                              child: Container(
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
                            ),
                            // Content
                            Positioned(
                              bottom: 20,
                              left: 20,
                              right: 20,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Row(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                        decoration: BoxDecoration(
                                          color: AppColors.primaryContainer.withOpacity(0.2),
                                          borderRadius: BorderRadius.circular(12),
                                          border: Border.all(color: AppColors.primary.withOpacity(0.3)),
                                        ),
                                        child: const Text(
                                          "En cours",
                                          style: TextStyle(
                                            color: AppColors.primaryLight,
                                            fontSize: 10,
                                            fontFamily: 'Be Vietnam Pro',
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                        decoration: BoxDecoration(
                                          color: Colors.white.withOpacity(0.08),
                                          borderRadius: BorderRadius.circular(12),
                                          border: Border.all(color: Colors.white.withOpacity(0.1)),
                                        ),
                                        child: const Text(
                                          "Événement Majeur",
                                          style: TextStyle(
                                            color: AppColors.onSurface,
                                            fontSize: 10,
                                            fontFamily: 'Be Vietnam Pro',
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 12),
                                  const Text(
                                    "Le Grand Carnaval",
                                    style: TextStyle(
                                      color: AppColors.onSurface,
                                      fontSize: 26,
                                      fontFamily: 'Epilogue',
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    "Vivez l'effervescence des vidés, admirez les costumes traditionnels et laissez-vous emporter par le rythme des groupes à pied dans les rues.",
                                    style: TextStyle(
                                      color: AppColors.onSurfaceVariant.withOpacity(0.9),
                                      fontSize: 12,
                                      fontFamily: 'Be Vietnam Pro',
                                      height: 1.4,
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                  GestureDetector(
                                    onTap: () {},
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                                      decoration: BoxDecoration(
                                        gradient: const LinearGradient(
                                          colors: [Color(0xFFFF4E50), Color(0xFFFFD700)],
                                        ),
                                        borderRadius: BorderRadius.circular(30),
                                        boxShadow: [
                                          BoxShadow(
                                            color: const Color(0xFFFF4E50).withOpacity(0.4),
                                            blurRadius: 15,
                                            offset: const Offset(0, 4),
                                          )
                                        ],
                                      ),
                                      child: const Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Text(
                                            "Découvrir le programme",
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 12,
                                              fontFamily: 'Be Vietnam Pro',
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          SizedBox(width: 6),
                                          Icon(Icons.arrow_forward, color: Colors.white, size: 14),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),

                // Célébrations Patrimoniales Header
                const SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    child: Text(
                      "Célébrations Patrimoniales",
                      style: TextStyle(
                        color: AppColors.onSurface,
                        fontSize: 18,
                        fontFamily: 'Epilogue',
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),

                // Bento Grid for traditions
                SliverPadding(
                  padding: const EdgeInsets.only(left: 24, right: 24, bottom: 40),
                  sliver: SliverGrid(
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      mainAxisSpacing: 16,
                      crossAxisSpacing: 16,
                      childAspectRatio: 1.1,
                    ),
                    delegate: SliverChildListDelegate([
                      // Chanté Nwel (Tall Bento-style)
                      _buildBentoItem(
                        title: "Chanté Nwel",
                        description: "Cantiques traditionnels revisités aux rythmes créoles.",
                        icon: Icons.music_note,
                        iconColor: AppColors.primary,
                        imageUrl: "https://lh3.googleusercontent.com/aida-public/AB6AXuBK0FrgWzRx6198xH7GiQti-An99aMpO6pW-oPyN1puwlw4w3L_5qDUfO7sq2XjM2H0yHSP0fk7XSDVKiW4Y7HVKRxesCVIylt90NN-lrFEahhBiZtOn1i5WLk0hZxHRJW-MeaPl1pqVXY9kllQRhfUOFKxIT4o4ueFkP-NRyMBLxH-69a60WqlUn6wnN6hBffngoeeTI00DuvHWHr-vOLFlc9XMUBNzl_msjy5xQ5lLONieXq4oZ2RxY7D_sDjgD6sb9hkClAOoQ",
                      ),

                      // Bèlè Lakour (Dances Bento-style)
                      _buildBentoItem(
                        title: "Bèlè Lakour",
                        description: "Cercles de tambours et danses ancestrales.",
                        icon: Icons.nightlife,
                        iconColor: AppColors.secondary,
                        imageUrl: "https://lh3.googleusercontent.com/aida-public/AB6AXuDVjFXiM2QR9ihJlIEibEmwBvpS7fPDcUShvKSE7tD8vuYdQh23ZrAJQl3tJTAIpVBKALw_Pel-VlTXe7I_-ESzUUo-LCBGLsf2hxvC_rkJT2kLDUVldwermcz7Q5aSaaG2ipkIb2n1y9AMb3zitKCYeNX_45v0UQP2ckT9IetVjx_ob1dGQET2bOMpgN8kNmGBR9-mjPtTktqxNbrDaJCLsHVjkyZa0X2eAEqnRBX_r_Yq2pngPptNcD9jWyvPHq4WRPY_Bj63mQ",
                      ),

                      // Fêtes Patronales (Simple Card-style)
                      _buildSimpleBentoCard(
                        title: "Fêtes Patronales",
                        description: "Festivals communaux et foires culinaires.",
                        icon: Icons.church,
                        iconColor: AppColors.tertiary,
                      ),

                      // Fêtes Maritimes (Simple Card-style)
                      _buildSimpleBentoCard(
                        title: "Fêtes Maritimes",
                        description: "Courses de yoles et patrimoine de la pêche.",
                        icon: Icons.sailing,
                        iconColor: AppColors.primaryLight,
                      ),

                      // Custom Link Card to Chronologie & Lieux (routes to the Timeline details!)
                      GestureDetector(
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(builder: (context) => const TraditionsScreen()),
                          );
                        },
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                AppColors.tertiary.withOpacity(0.15),
                                AppColors.primary.withOpacity(0.05),
                              ],
                            ),
                            border: Border.all(color: AppColors.tertiary.withOpacity(0.3)),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Container(
                                width: 36,
                                height: 36,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: AppColors.tertiary.withOpacity(0.15),
                                ),
                                child: const Icon(Icons.history_edu, color: AppColors.tertiary, size: 18),
                              ),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  const Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          "Chronologie",
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 14,
                                            fontFamily: 'Epilogue',
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        Text(
                                          "Ligne du temps & Lieux",
                                          style: TextStyle(
                                            color: AppColors.onSurfaceVariant,
                                            fontSize: 9,
                                            fontFamily: 'Be Vietnam Pro',
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Container(
                                    width: 24,
                                    height: 24,
                                    decoration: const BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: Colors.white10,
                                    ),
                                    child: const Icon(Icons.arrow_forward, color: Colors.white, size: 12),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ]),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBentoItem({
    required String title,
    required String description,
    required IconData icon,
    required Color iconColor,
    required String imageUrl,
  }) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.black38,
          border: Border.all(color: Colors.white.withOpacity(0.08)),
        ),
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Background Image
            Opacity(
              opacity: 0.35,
              child: Image.network(
                imageUrl,
                fit: BoxFit.cover,
              ),
            ),
            // Gradient Overlay
            Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.black87,
                  ],
                ),
              ),
            ),
            // Content
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Icon(icon, color: iconColor, size: 20),
                  const SizedBox(height: 6),
                  Text(
                    title,
                    style: const TextStyle(
                      color: AppColors.onSurface,
                      fontSize: 14,
                      fontFamily: 'Epilogue',
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    description,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: AppColors.onSurfaceVariant.withOpacity(0.8),
                      fontSize: 9,
                      fontFamily: 'Be Vietnam Pro',
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSimpleBentoCard({
    required String title,
    required String description,
    required IconData icon,
    required Color iconColor,
  }) {
    return GlassPanel(
      padding: const EdgeInsets.all(16),
      borderRadius: 20,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: iconColor.withOpacity(0.12),
              border: Border.all(color: iconColor.withOpacity(0.2)),
            ),
            child: Icon(icon, color: iconColor, size: 16),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: AppColors.onSurface,
                  fontSize: 13,
                  fontFamily: 'Epilogue',
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                description,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: AppColors.onSurfaceVariant.withOpacity(0.8),
                  fontSize: 9,
                  fontFamily: 'Be Vietnam Pro',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
