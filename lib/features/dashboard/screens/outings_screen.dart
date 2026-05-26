import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../../../core/theme/colors.dart';
import '../../../core/widgets/glass_panel.dart';
import '../../../core/widgets/ambient_glow.dart';
import '../../../core/network/pocketbase_client.dart';
import 'calendar_screen.dart';

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
  String _selectedZone = "Partout";
  List<Map<String, dynamic>> _allEvents = [];
  bool _isLoading = true;

  final Map<String, List<String>> _zoneCommunes = {
    "Centre": ["Fort-de-France", "Le Lamentin", "Schœlcher", "Saint-Joseph"],
    "Nord Caraïbe": ["Case-Pilote", "Bellefontaine", "Le Carbet", "Saint-Pierre", "Le Prêcheur", "Le Morne-Vert", "Fonds-Saint-Denis"],
    "Nord Atlantique": ["La Trinité", "Sainte-Marie", "Le Robert", "Gros-Morne", "Le Lorrain", "Le Marigot", "Basse-Pointe", "Grand'Rivière", "Macouba", "L'Ajoupa-Bouillon", "Le Morne-Rouge"],
    "Sud": ["Les Trois-Îlets", "Les Anses-d'Arlet", "Le Diamant", "Sainte-Luce", "Le Marin", "Sainte-Anne", "Le Vauclin", "Le François", "Rivière-Salée", "Rivière-Pilote", "Saint-Esprit", "Ducos"]
  };

  List<Map<String, dynamic>> get _dynamicDays {
    final now = DateTime.now();
    final List<String> weekdays = ["Dim", "Lun", "Mar", "Mer", "Jeu", "Ven", "Sam"];
    return List.generate(7, (index) {
      final date = now.add(Duration(days: index));
      final label = index == 0 ? "Auj" : weekdays[date.weekday % 7];
      return {
        "label": label,
        "day": date.day.toString().padLeft(2, '0'),
        "date": date,
      };
    });
  }

  List<String> get _filteredCommunes {
    if (_selectedZone == "Partout") {
      return [
        "Partout",
        "Fort-de-France",
        "Saint-Pierre",
        "Case-Pilote",
        "Le Diamant",
        "Le François",
        "Sainte-Marie"
      ];
    }
    return ["Partout", ...(_zoneCommunes[_selectedZone] ?? [])];
  }

  final List<Map<String, dynamic>> _categories = [
    {"name": "Théâtre", "icon": Icons.theater_comedy, "color": AppColors.primary},
    {"name": "Concerts", "icon": Icons.music_note, "color": AppColors.tertiary},
    {"name": "Gastronomie", "icon": Icons.restaurant, "color": AppColors.secondary},
    {"name": "Plein air", "icon": Icons.beach_access, "color": AppColors.primaryLight},
    {"name": "Conférences", "icon": Icons.menu_book, "color": AppColors.tertiaryLight},
  ];

  @override
  void initState() {
    super.initState();
    _loadEvents();
  }

  Future<void> _loadEvents() async {
    try {
      final pbService = Provider.of<PocketBaseService>(context, listen: false);
      final events = await pbService.fetchEvents();
      if (mounted) {
        setState(() {
          _allEvents = events;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  List<Map<String, dynamic>> get _filteredEvents {
    final dynamicDays = _dynamicDays;
    if (_selectedDayIndex >= dynamicDays.length) return [];
    final selectedDate = dynamicDays[_selectedDayIndex]["date"] as DateTime;

    return _allEvents.where((e) {
      // 1. Date correlation
      if (e["date"] != null) {
        try {
          final eventDate = DateTime.parse(e["date"].toString());
          if (eventDate.year != selectedDate.year ||
              eventDate.month != selectedDate.month ||
              eventDate.day != selectedDate.day) {
            return false;
          }
        } catch (_) {
          return false;
        }
      } else {
        return false;
      }

      // 2. Commune / Zone correlation
      final loc = (e["location_name"] ?? "").toString().toLowerCase();
      if (_selectedZone != "Partout") {
        final allowedCommunes = _zoneCommunes[_selectedZone] ?? [];
        if (_selectedCommune != "Partout") {
          final comm = _selectedCommune.toLowerCase();
          if (!loc.contains(comm)) {
            return false;
          }
        } else {
          bool matchesAny = allowedCommunes.any((c) => loc.contains(c.toLowerCase()));
          if (!matchesAny) {
            return false;
          }
        }
      } else {
        if (_selectedCommune != "Partout") {
          final comm = _selectedCommune.toLowerCase();
          if (!loc.contains(comm)) {
            return false;
          }
        }
      }

      // 3. Category correlation
      if (_selectedCategory != "Tous") {
        final cat = (e["category"] ?? "").toString().toLowerCase();
        final selectedCat = _selectedCategory.toLowerCase();
        
        String normalize(String s) {
          return s.replaceAll('é', 'e').replaceAll('â', 'a');
        }
        final nCat = normalize(cat);
        final nSel = normalize(selectedCat);
        
        if (!nCat.contains(nSel) && !nSel.contains(nCat)) {
          return false;
        }
      }

      return true;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final days = _dynamicDays;
    final filteredEvents = _filteredEvents;
    final communes = _filteredCommunes;

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
                        Row(
                          children: [
                            if (Navigator.canPop(context)) ...[
                              GestureDetector(
                                onTap: () => Navigator.of(context).pop(),
                                child: Container(
                                  width: 40,
                                  height: 40,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Colors.white.withOpacity(0.06),
                                    border: Border.all(color: Colors.white.withOpacity(0.08)),
                                  ),
                                  child: const Icon(Icons.arrow_back, color: AppColors.onSurface, size: 20),
                                ),
                              ),
                              const SizedBox(width: 12),
                            ],
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
                          ],
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
                      children: List.generate(days.length, (index) {
                        final isSelected = _selectedDayIndex == index;
                        final dayData = days[index];

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
                                    style: const TextStyle(
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

                // Interactive Mini-Map Section
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                    child: GlassPanel(
                      padding: const EdgeInsets.all(16),
                      borderRadius: 24,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                "Localiser par Zone",
                                style: TextStyle(
                                  color: AppColors.onSurface,
                                  fontSize: 14,
                                  fontFamily: 'Epilogue',
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              if (_selectedZone != "Partout")
                                GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      _selectedZone = "Partout";
                                      _selectedCommune = "Partout";
                                    });
                                  },
                                  child: const Text(
                                    "Réinitialiser",
                                    style: TextStyle(
                                      color: AppColors.primaryLight,
                                      fontSize: 11,
                                      fontFamily: 'Be Vietnam Pro',
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Center(
                            child: MartiniqueMiniMap(
                              selectedZone: _selectedZone,
                              onZoneSelected: (zone) {
                                setState(() {
                                  _selectedZone = zone;
                                  _selectedCommune = "Partout"; // reset sub-commune on zone change
                                });
                              },
                            ),
                          ),
                        ],
                      ),
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
                      children: communes.map((commune) {
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
                                          Color(0xE6000000),
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
                                      GestureDetector(
                                        onTap: () {
                                          Navigator.of(context).push(
                                            MaterialPageRoute(
                                              builder: (context) => const CalendarScreen(),
                                            ),
                                          );
                                        },
                                        child: Container(
                                          width: 44,
                                          height: 44,
                                          decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            color: Colors.white.withOpacity(0.12),
                                            border: Border.all(color: Colors.white.withOpacity(0.1)),
                                          ),
                                          child: const Icon(Icons.calendar_today, color: Colors.white, size: 18),
                                        ),
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
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          "Soirées & Animations",
                          style: TextStyle(
                            color: AppColors.onSurface,
                            fontSize: 18,
                            fontFamily: 'Epilogue',
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) => const CalendarScreen(),
                              ),
                            );
                          },
                          child: const Text(
                            "Tout voir",
                            style: TextStyle(
                              color: Color(0xFF4CAF50),
                              fontSize: 13,
                              fontFamily: 'Be Vietnam Pro',
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Events Feed List
                _isLoading
                    ? const SliverToBoxAdapter(
                        child: Center(
                          child: Padding(
                            padding: EdgeInsets.all(40.0),
                            child: CircularProgressIndicator(color: AppColors.primary),
                          ),
                        ),
                      )
                    : filteredEvents.isEmpty
                        ? SliverToBoxAdapter(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                              child: GlassPanel(
                                padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 20),
                                child: Center(
                                  child: Column(
                                    children: [
                                      Icon(
                                        Icons.event_busy,
                                        color: AppColors.onSurfaceVariant.withOpacity(0.4),
                                        size: 40,
                                      ),
                                      const SizedBox(height: 12),
                                      Text(
                                        "Aucun événement pour ces critères.",
                                        style: TextStyle(
                                          color: AppColors.onSurfaceVariant.withOpacity(0.8),
                                          fontSize: 13,
                                          fontFamily: 'Be Vietnam Pro',
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          )
                        : SliverList(
                            delegate: SliverChildBuilderDelegate(
                              (context, index) {
                                final item = filteredEvents[index];
                                final priceText = item["price"] == null || item["price"] == 0
                                    ? "Gratuit"
                                    : "${item["price"]}€";

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
                                              if (item["image_url"] != null && item["image_url"].toString().isNotEmpty)
                                                Image.network(
                                                  item["image_url"],
                                                  fit: BoxFit.cover,
                                                  errorBuilder: (_, __, ___) => Container(color: AppColors.surfaceContainer),
                                                )
                                              else
                                                Container(color: AppColors.surfaceContainer),
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
                                                    priceText,
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
                                                      item["title"] ?? "",
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
                                                      item["location_name"] ?? "",
                                                      style: TextStyle(
                                                        color: AppColors.onSurfaceVariant.withOpacity(0.8),
                                                        fontSize: 11,
                                                        fontFamily: 'Be Vietnam Pro',
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              if (item["description"] != null && item["description"].toString().isNotEmpty) ...[
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
                                                    item["description"],
                                                    style: TextStyle(
                                                      color: AppColors.onSurface.withOpacity(0.9),
                                                      fontSize: 12,
                                                      fontStyle: FontStyle.italic,
                                                      fontFamily: 'Be Vietnam Pro',
                                                    ),
                                                  ),
                                                ),
                                              ],
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
                                                        item["date"] != null
                                                            ? "${DateTime.parse(item["date"]).hour.toString().padLeft(2, '0')}h${DateTime.parse(item["date"]).minute.toString().padLeft(2, '0')}"
                                                            : "19h00",
                                                        style: const TextStyle(
                                                          color: AppColors.onSurface,
                                                          fontSize: 11,
                                                          fontFamily: 'Be Vietnam Pro',
                                                          fontWeight: FontWeight.bold,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                  if (item["category"] != null)
                                                    Container(
                                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                                      decoration: BoxDecoration(
                                                        color: Colors.white.withOpacity(0.06),
                                                        borderRadius: BorderRadius.circular(4),
                                                      ),
                                                      child: Text(
                                                        item["category"].toString().toUpperCase(),
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
                              childCount: filteredEvents.length,
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

class MartiniqueMiniMap extends StatelessWidget {
  final String selectedZone;
  final Function(String) onZoneSelected;

  const MartiniqueMiniMap({
    super.key,
    required this.selectedZone,
    required this.onZoneSelected,
  });

  static const List<LatLng> _nordCaraibePoints = [
    LatLng(14.88, -61.18), // North tip
    LatLng(14.84, -61.23), // NW slope
    LatLng(14.79, -61.22), // Prêcheur
    LatLng(14.74, -61.18), // Saint-Pierre
    LatLng(14.70, -61.18), // Carbet
    LatLng(14.67, -61.17), // Bellefontaine
    LatLng(14.64, -61.14), // Case-Pilote
    LatLng(14.61, -61.11), // Schoelcher border
    LatLng(14.68, -61.08), // Inland Saint-Joseph border
    LatLng(14.78, -61.11), // Morne-Rouge area
  ];

  static const List<LatLng> _nordAtlantiquePoints = [
    LatLng(14.88, -61.18), // North tip
    LatLng(14.88, -61.12), // Basse-Pointe
    LatLng(14.84, -61.05), // Lorrain
    LatLng(14.79, -60.99), // Sainte-Marie
    LatLng(14.76, -60.97), // Caravelle neck
    LatLng(14.77, -60.88), // Caravelle tip
    LatLng(14.73, -60.91), // Caravelle South
    LatLng(14.68, -60.94), // Robert
    LatLng(14.63, -60.90), // Robert/François coast border
    LatLng(14.64, -60.96), // Triple junction point
    LatLng(14.68, -61.08), // Saint-Joseph area
    LatLng(14.78, -61.11), // Morne-Rouge area
  ];

  static const List<LatLng> _centrePoints = [
    LatLng(14.61, -61.11), // Schoelcher border
    LatLng(14.68, -61.08), // Saint-Joseph area
    LatLng(14.64, -60.96), // Triple junction point
    LatLng(14.59, -60.95), // Lamentin / Ducos border
    LatLng(14.60, -60.99), // Lamentin / Bay
    LatLng(14.60, -61.07), // Fort-de-France
  ];

  static const List<LatLng> _sudPoints = [
    LatLng(14.59, -60.95), // Lamentin / Ducos border
    LatLng(14.64, -60.96), // Triple junction point
    LatLng(14.63, -60.90), // Robert/François coast border
    LatLng(14.61, -60.88), // Le François
    LatLng(14.54, -60.83), // Le Vauclin
    LatLng(14.43, -60.84), // Salines / East
    LatLng(14.39, -60.88), // Sainte-Anne South tip
    LatLng(14.45, -60.88), // Sainte-Anne North
    LatLng(14.47, -60.87), // Le Marin
    LatLng(14.46, -60.93), // Sainte-Luce
    LatLng(14.45, -61.02), // Diamant
    LatLng(14.47, -61.09), // Anses-d'Arlet
    LatLng(14.55, -61.08), // Trois-Ilets West
    LatLng(14.54, -61.05), // Trois-Ilets
    LatLng(14.60, -60.99), // Lamentin / Bay
  ];

  bool _isPointInPolygon(LatLng point, List<LatLng> polygon) {
    int i, j = polygon.length - 1;
    bool oddNodes = false;
    double x = point.longitude;
    double y = point.latitude;

    for (i = 0; i < polygon.length; i++) {
      if ((polygon[i].latitude < y && polygon[j].latitude >= y ||
              polygon[j].latitude < y && polygon[i].latitude >= y) &&
          (polygon[i].longitude +
                  (y - polygon[i].latitude) /
                      (polygon[j].latitude - polygon[i].latitude) *
                      (polygon[j].longitude - polygon[i].longitude) <
              x)) {
        oddNodes = !oddNodes;
      }
      j = i;
    }
    return oddNodes;
  }

  void _handleTap(LatLng latLng) {
    if (_isPointInPolygon(latLng, _nordCaraibePoints)) {
      _toggleZone("Nord Caraïbe");
    } else if (_isPointInPolygon(latLng, _nordAtlantiquePoints)) {
      _toggleZone("Nord Atlantique");
    } else if (_isPointInPolygon(latLng, _centrePoints)) {
      _toggleZone("Centre");
    } else if (_isPointInPolygon(latLng, _sudPoints)) {
      _toggleZone("Sud");
    }
  }

  void _toggleZone(String zone) {
    if (selectedZone == zone) {
      onZoneSelected("Partout");
    } else {
      onZoneSelected(zone);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 250,
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.08)),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: FlutterMap(
          options: MapOptions(
            initialCenter: const LatLng(14.63, -61.01),
            initialZoom: 9.3,
            minZoom: 9.3,
            maxZoom: 9.3,
            interactionOptions: const InteractionOptions(
              flags: InteractiveFlag.none, // Disable all navigation/gestures
            ),
            onTap: (tapPosition, latLng) => _handleTap(latLng),
          ),
          children: [
            TileLayer(
              urlTemplate: 'https://{s}.basemaps.cartocdn.com/dark_all/{z}/{x}/{y}{r}.png',
              subdomains: const ['a', 'b', 'c', 'd'],
            ),
            PolygonLayer(
              polygons: [
                Polygon(
                  points: _nordCaraibePoints,
                  color: selectedZone == "Nord Caraïbe"
                      ? const Color(0xFF00E676).withOpacity(0.25)
                      : Colors.white.withOpacity(0.04),
                  borderColor: selectedZone == "Nord Caraïbe"
                      ? const Color(0xFF00E676)
                      : Colors.white.withOpacity(0.2),
                  borderStrokeWidth: selectedZone == "Nord Caraïbe" ? 2.5 : 1.2,
                ),
                Polygon(
                  points: _nordAtlantiquePoints,
                  color: selectedZone == "Nord Atlantique"
                      ? const Color(0xFF00B0FF).withOpacity(0.25)
                      : Colors.white.withOpacity(0.04),
                  borderColor: selectedZone == "Nord Atlantique"
                      ? const Color(0xFF00B0FF)
                      : Colors.white.withOpacity(0.2),
                  borderStrokeWidth: selectedZone == "Nord Atlantique" ? 2.5 : 1.2,
                ),
                Polygon(
                  points: _centrePoints,
                  color: selectedZone == "Centre"
                      ? const Color(0xFFFFD600).withOpacity(0.25)
                      : Colors.white.withOpacity(0.04),
                  borderColor: selectedZone == "Centre"
                      ? const Color(0xFFFFD600)
                      : Colors.white.withOpacity(0.2),
                  borderStrokeWidth: selectedZone == "Centre" ? 2.5 : 1.2,
                ),
                Polygon(
                  points: _sudPoints,
                  color: selectedZone == "Sud"
                      ? const Color(0xFFFF3D00).withOpacity(0.25)
                      : Colors.white.withOpacity(0.04),
                  borderColor: selectedZone == "Sud"
                      ? const Color(0xFFFF3D00)
                      : Colors.white.withOpacity(0.2),
                  borderStrokeWidth: selectedZone == "Sud" ? 2.5 : 1.2,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
