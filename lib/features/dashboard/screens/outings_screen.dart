import 'package:flutter/material.dart';
import '../../../core/theme/colors.dart';
import '../../../core/widgets/glass_panel.dart';
import '../../../core/widgets/ambient_glow.dart';

class OutingsScreen extends StatefulWidget {
  final VoidCallback onToggleMap;

  const OutingsScreen({
    super.key,
    required this.onToggleMap,
  });

  @override
  State<OutingsScreen> createState() => _OutingsScreenState();
}

class _OutingsScreenState extends State<OutingsScreen> {
  int _selectedDayIndex = 0;
  String _selectedCommune = "Partout";
  String _selectedCategory = "Tous";

  final List<Map<String, String>> _days = [
    {"label": "Auj", "day": "15"},
    {"label": "Ven", "day": "16"},
    {"label": "Sam", "day": "17"},
    {"label": "Dim", "day": "18"},
    {"label": "Lun", "day": "19"},
    {"label": "Mar", "day": "20"},
  ];

  final List<String> _communes = [
    "Partout",
    "Fort-de-France",
    "Saint-Pierre",
    "Case-Pilote",
    "Le Diamant",
  ];

  final List<Map<String, dynamic>> _categories = [
    {"name": "Théâtre", "icon": Icons.theater_comedy, "color": AppColors.primary},
    {"name": "Concerts", "icon": Icons.music_note, "color": AppColors.tertiary},
    {"name": "Gastronomie", "icon": Icons.restaurant, "color": AppColors.secondary},
    {"name": "Plein air", "icon": Icons.beach_access, "color": AppColors.primaryLight},
    {"name": "Conférences", "icon": Icons.menu_book, "color": AppColors.tertiaryLight},
  ];

  final List<Map<String, dynamic>> _events = [
    {
      "title": "Soirée Bèlè Lakour",
      "location": "Place de la Mairie, Case-Pilote",
      "quote": "\"L'authenticité des tambours sous les étoiles.\"",
      "time": "19h00 - 23h30",
      "price": "Gratuit",
      "tag": "Tradition",
      "category": "Concerts",
      "commune": "Case-Pilote",
      "imageUrl": "https://lh3.googleusercontent.com/aida-public/AB6AXuAJFRaFUbn3vEUMweA5NGpNAh_DpnRzGTwzSaDolfrI9dfryshU0oTo3rQHuukTxnsb0nq14m6WcwM7F2nq_fSLBLXMkEJUkMuqWvf860utlLqEtaGbfJGnMaFK5wrwvq3q6BTJzFv2_LnMWoxjQnBjMJ9cMkjHoFOHDBDqN6mDbMCyacRx3Ke6hK3pJPQKdkyshS-zirgWeiIY9UuU72eC2ObQ77N-KecCzaRxn7pwWOpqy6RdgY5L4lRTzqVTEiE-Iv6icyaX-Q"
    },
    {
      "title": "Jazz sous les Filaos",
      "location": "Habitation Clément, Le François",
      "quote": "\"Une fusion parfaite entre notes cuivrées et brise tropicale.\"",
      "time": "20h00 - 01h00",
      "price": "25€",
      "tag": "Jazz Caribéen",
      "category": "Concerts",
      "commune": "Le François",
      "imageUrl": "https://lh3.googleusercontent.com/aida-public/AB6AXuDvtFzaZv5iOTtpW5PsKCtvBuPMDxdkTd4xgSDv0083j_36WUAWFG5eZZ57HLsLQwoUoZ2z5yk1j8qvwJdyhRRWqSL4PMGQaHdkftIVF006z1asBwXuhZg1Q8JYRKryOp5ymr5-98Pyw2mLHOGMeiSX3ziUprHwFnEC8adg1IvJX7humneU5pzd1ZSvfN4wuf1GBOj5I6KRmOIfZIoJZsiXK2Rn6SuGu9f6dn2lpEtGWSM47I3dQxFSXmZv5eDBGQeg4w1IZppqAQ"
    }
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          // 1. Ambient Background Glows
          Positioned(
            top: 100,
            left: MediaQuery.of(context).size.width * 0.1,
            child: Container(
              width: 320,
              height: 320,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    AppColors.primary.withOpacity(0.12),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            bottom: 150,
            right: -50,
            child: Container(
              width: 350,
              height: 350,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    AppColors.secondary.withOpacity(0.08),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),

          // 2. Scrollable Body
          SafeArea(
            child: CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                // Top Custom App Bar
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Weather Widget
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.06),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: Colors.white.withOpacity(0.08)),
                          ),
                          child: const Row(
                            children: [
                              Icon(Icons.wb_sunny_rounded, color: AppColors.tertiary, size: 14),
                              SizedBox(width: 6),
                              Text(
                                "28°C - FDF",
                                style: TextStyle(
                                  color: AppColors.onSurface,
                                  fontSize: 12,
                                  fontFamily: 'Be Vietnam Pro',
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                        // App Title
                        const Text(
                          "Sortir",
                          style: TextStyle(
                            color: AppColors.tertiary,
                            fontSize: 22,
                            fontFamily: 'Epilogue',
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        // Fire Button
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white.withOpacity(0.06),
                            border: Border.all(color: Colors.white.withOpacity(0.08)),
                          ),
                          child: const Icon(
                            Icons.local_fire_department_rounded,
                            color: AppColors.tertiary,
                            size: 20,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Date Picker Scroll
                SliverToBoxAdapter(
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                    child: Row(
                      children: List.generate(_days.length, (index) {
                        final isSelected = _selectedDayIndex == index;
                        final dayData = _days[index];

                        return Padding(
                          padding: const EdgeInsets.only(right: 12),
                          child: GestureDetector(
                            onTap: () {
                              setState(() {
                                _selectedDayIndex = index;
                              });
                            },
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 250),
                              width: 64,
                              height: 72,
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? AppColors.primaryContainer.withOpacity(0.25)
                                    : Colors.white.withOpacity(0.03),
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: isSelected
                                      ? AppColors.primary.withOpacity(0.5)
                                      : Colors.white.withOpacity(0.08),
                                ),
                                boxShadow: isSelected
                                    ? [
                                        BoxShadow(
                                          color: AppColors.primary.withOpacity(0.2),
                                          blurRadius: 12,
                                          spreadRadius: 1,
                                        )
                                      ]
                                    : null,
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    dayData["label"]!.toUpperCase(),
                                    style: TextStyle(
                                      color: isSelected
                                          ? AppColors.primaryLight
                                          : AppColors.onSurfaceVariant.withOpacity(0.6),
                                      fontSize: 10,
                                      fontFamily: 'Be Vietnam Pro',
                                      fontWeight: FontWeight.bold,
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    dayData["day"]!,
                                    style: TextStyle(
                                      color: AppColors.onSurface,
                                      fontSize: 20,
                                      fontFamily: 'Epilogue',
                                      fontWeight: FontWeight.bold,
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
                ),

                // Communes Filter Chips
                SliverToBoxAdapter(
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    child: Row(
                      children: _communes.map((commune) {
                        final isSelected = _selectedCommune == commune;

                        return Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: GestureDetector(
                            onTap: () {
                              setState(() {
                                _selectedCommune = commune;
                              });
                            },
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? AppColors.secondary.withOpacity(0.1)
                                    : Colors.white.withOpacity(0.03),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: isSelected
                                      ? AppColors.secondary.withOpacity(0.5)
                                      : Colors.white.withOpacity(0.08),
                                ),
                              ),
                              child: Row(
                                children: [
                                  if (commune == "Partout") ...[
                                    Icon(
                                      Icons.location_on,
                                      color: isSelected ? AppColors.secondary : AppColors.onSurfaceVariant.withOpacity(0.6),
                                      size: 14,
                                    ),
                                    const SizedBox(width: 4),
                                  ],
                                  Text(
                                    commune,
                                    style: TextStyle(
                                      color: isSelected ? AppColors.secondary : AppColors.onSurfaceVariant.withOpacity(0.8),
                                      fontSize: 12,
                                      fontFamily: 'Be Vietnam Pro',
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ),

                // Categories Row
                SliverToBoxAdapter(
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                    child: Row(
                      children: _categories.map((cat) {
                        final isSelected = _selectedCategory == cat["name"];
                        final catColor = cat["color"] as Color;

                        return Padding(
                          padding: const EdgeInsets.only(right: 20),
                          child: GestureDetector(
                            onTap: () {
                              setState(() {
                                _selectedCategory = isSelected ? "Tous" : cat["name"];
                              });
                            },
                            child: Column(
                              children: [
                                AnimatedContainer(
                                  duration: const Duration(milliseconds: 200),
                                  width: 64,
                                  height: 64,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: isSelected
                                        ? catColor.withOpacity(0.2)
                                        : Colors.white.withOpacity(0.04),
                                    border: Border.all(
                                      color: isSelected
                                          ? catColor
                                          : Colors.white.withOpacity(0.08),
                                    ),
                                  ),
                                  child: Icon(
                                    cat["icon"],
                                    color: isSelected ? catColor : Colors.white.withOpacity(0.7),
                                    size: 26,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  cat["name"],
                                  style: TextStyle(
                                    color: isSelected ? Colors.white : AppColors.onSurfaceVariant.withOpacity(0.8),
                                    fontSize: 11,
                                    fontFamily: 'Be Vietnam Pro',
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ),

                // Week-end à venir Section
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Row(
                          children: [
                            Text(
                              "Week-end à venir",
                              style: TextStyle(
                                color: AppColors.onSurface,
                                fontSize: 18,
                                fontFamily: 'Epilogue',
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(width: 8),
                            Icon(Icons.celebration, color: AppColors.tertiary, size: 18),
                          ],
                        ),
                        const SizedBox(height: 16),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(24),
                          child: Container(
                            height: 220,
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.03),
                              border: Border.all(color: Colors.white.withOpacity(0.08)),
                            ),
                            child: Stack(
                              children: [
                                // Background image
                                Positioned.fill(
                                  child: Image.network(
                                    'https://lh3.googleusercontent.com/aida-public/AB6AXuDSn9_wYgEGBuWYouZV3pCVK7swux0AnpW4vbIi25gkprKdDrNina-xoTfixoKXo0empN9oMMJthQ2dMTfakdbPo0jxktBdaghnJ8HjPXdnk7GwyU2K_r-tUCNb-j_OJlxwWO4yrxSC4_P-yEKSonMCjtYUTQkpGDY3O3Ys8LvJyfaOtha7WoD0AswUJe8DM4ibhGlbRoGHF_8Q2PNPEhepe-sFVlkldtcduvV7dQkhEyJUIh21nfzHPQrTLDL1QrpyLupMdXn7AA',
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
                                          const Color(0xE6000000),
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
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Container(
                                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                              decoration: BoxDecoration(
                                                color: AppColors.primary.withOpacity(0.2),
                                                borderRadius: BorderRadius.circular(12),
                                                border: Border.all(color: AppColors.primary.withOpacity(0.3)),
                                              ),
                                              child: const Text(
                                                "Top 5",
                                                style: TextStyle(
                                                  color: AppColors.primaryLight,
                                                  fontSize: 10,
                                                  fontFamily: 'Be Vietnam Pro',
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ),
                                            const SizedBox(height: 8),
                                            const Text(
                                              "Les incontournables du week-end",
                                              style: TextStyle(
                                                color: AppColors.onSurface,
                                                fontSize: 16,
                                                fontFamily: 'Epilogue',
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              "Notre sélection pour vibrer au rythme de l'île de vendredi à dimanche.",
                                              maxLines: 2,
                                              overflow: TextOverflow.ellipsis,
                                              style: TextStyle(
                                                color: AppColors.onSurfaceVariant.withOpacity(0.8),
                                                fontSize: 11,
                                                fontFamily: 'Be Vietnam Pro',
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Container(
                                        width: 44,
                                        height: 44,
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: Colors.white.withOpacity(0.12),
                                          border: Border.all(color: Colors.white.withOpacity(0.1)),
                                        ),
                                        child: const Icon(Icons.calendar_today, color: Colors.white, size: 18),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Outings/Events Grid Header
                const SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    child: Text(
                      "Soirées & Animations",
                      style: TextStyle(
                        color: AppColors.onSurface,
                        fontSize: 18,
                        fontFamily: 'Epilogue',
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),

                // Events Feed List
                SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final item = _events[index];

                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                        child: GlassPanel(
                          padding: EdgeInsets.zero,
                          borderRadius: 20,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Photo container
                              SizedBox(
                                height: 160,
                                child: Stack(
                                  fit: StackFit.expand,
                                  children: [
                                    Image.network(
                                      item["imageUrl"]!,
                                      fit: BoxFit.cover,
                                    ),
                                    // Gradient overlay
                                    Container(
                                      decoration: const BoxDecoration(
                                        gradient: LinearGradient(
                                          begin: Alignment.topCenter,
                                          end: Alignment.bottomCenter,
                                          colors: [
                                            Colors.transparent,
                                            Colors.black54,
                                            Colors.black87,
                                          ],
                                        ),
                                      ),
                                    ),
                                    // Price Badge
                                    Positioned(
                                      top: 12,
                                      left: 12,
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                        decoration: BoxDecoration(
                                          color: Colors.black.withOpacity(0.5),
                                          borderRadius: BorderRadius.circular(12),
                                          border: Border.all(color: AppColors.secondary.withOpacity(0.3)),
                                        ),
                                        child: Text(
                                          item["price"]!,
                                          style: const TextStyle(
                                            color: AppColors.secondary,
                                            fontSize: 10,
                                            fontFamily: 'Be Vietnam Pro',
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              // Description Content
                              Padding(
                                padding: const EdgeInsets.all(16),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Expanded(
                                          child: Text(
                                            item["title"]!,
                                            style: const TextStyle(
                                              color: AppColors.onSurface,
                                              fontSize: 16,
                                              fontFamily: 'Epilogue',
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                        const Icon(
                                          Icons.favorite_border,
                                          color: AppColors.onSurfaceVariant,
                                          size: 20,
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 6),
                                    Row(
                                      children: [
                                        const Icon(Icons.location_on, color: AppColors.onSurfaceVariant, size: 12),
                                        const SizedBox(width: 4),
                                        Expanded(
                                          child: Text(
                                            item["location"]!,
                                            style: TextStyle(
                                              color: AppColors.onSurfaceVariant.withOpacity(0.8),
                                              fontSize: 11,
                                              fontFamily: 'Be Vietnam Pro',
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 12),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                      decoration: BoxDecoration(
                                        border: const Border(
                                          left: BorderSide(color: AppColors.primary, width: 2),
                                        ),
                                        color: Colors.white.withOpacity(0.02),
                                      ),
                                      child: Text(
                                        item["quote"]!,
                                        style: TextStyle(
                                          color: AppColors.onSurface.withOpacity(0.9),
                                          fontSize: 12,
                                          fontStyle: FontStyle.italic,
                                          fontFamily: 'Be Vietnam Pro',
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 16),
                                    const Divider(color: Colors.white10, height: 1),
                                    const SizedBox(height: 12),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Row(
                                          children: [
                                            const Icon(Icons.schedule, color: AppColors.tertiary, size: 14),
                                            const SizedBox(width: 6),
                                            Text(
                                              item["time"]!,
                                              style: const TextStyle(
                                                color: AppColors.onSurface,
                                                fontSize: 11,
                                                fontFamily: 'Be Vietnam Pro',
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ],
                                        ),
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                          decoration: BoxDecoration(
                                            color: Colors.white.withOpacity(0.06),
                                            borderRadius: BorderRadius.circular(4),
                                          ),
                                          child: Text(
                                            item["tag"]!.toUpperCase(),
                                            style: TextStyle(
                                              color: AppColors.onSurfaceVariant.withOpacity(0.6),
                                              fontSize: 8,
                                              fontFamily: 'Be Vietnam Pro',
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                    childCount: _events.length,
                  ),
                ),
                const SliverToBoxAdapter(child: SizedBox(height: 120)),
              ],
            ),
          ),

          // 3. Floating MAP Toggle FAB
          Positioned(
            bottom: 110,
            right: 24,
            child: GestureDetector(
              onTap: widget.onToggleMap,
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
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    )
                  ],
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.map, color: Colors.white, size: 18),
                    SizedBox(width: 8),
                    Text(
                      "Carte",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontFamily: 'Be Vietnam Pro',
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
