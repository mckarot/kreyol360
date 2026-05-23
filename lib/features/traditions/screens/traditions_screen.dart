import 'package:flutter/material.dart';
import '../../../core/theme/colors.dart';
import '../../../core/widgets/glass_panel.dart';
import '../../../core/widgets/ambient_glow.dart';
import 'montagne_pelee_screen.dart';

class TraditionsScreen extends StatefulWidget {
  const TraditionsScreen({super.key});

  @override
  State<TraditionsScreen> createState() => _TraditionsScreenState();
}

class _TraditionsScreenState extends State<TraditionsScreen> {
  int _selectedPeriodIndex = 0;
  int _selectedEventNodeIndex = 1;

  final List<String> _periods = [
    "Période Précolombienne",
    "Colonisation",
    "Esclavage",
    "Catastrophes"
  ];

  // Timeline events based on selected period index
  final List<List<Map<String, dynamic>>> _periodEvents = [
    // Precolombienne
    [
      {"year": "vers 400 av. J.-C.", "title": "Arrivée des Arawaks", "desc": "Premiers habitants amérindiens de l'île, peuple pacifique d'agriculteurs et potiers."},
      {"year": "vers 1000", "title": "Invasion des Caraïbes", "desc": "Les guerriers Caraïbes conquièrent l'île et la nomment 'Madinina' (l'île aux fleurs)."},
      {"year": "1502", "title": "Arrivée de Christophe Colomb", "desc": "Débarquement au Carbet lors de son quatrième voyage le 15 juin 1502."}
    ],
    // Colonisation
    [
      {"year": "1635", "title": "Arrivée d'Esnambuc", "desc": "Pierre Belain d'Esnambuc prend possession de l'île pour le roi de France et fonde Saint-Pierre."},
      {"year": "1658", "title": "Guerre des Caraïbes", "desc": "Les colons français expulsent définitivement les derniers autochtones caraïbes de l'île."}
    ],
    // Esclavage
    [
      {"year": "1685", "title": "Code Noir", "desc": "Promulgation du décret royal réglementant la vie et le traitement des esclaves dans les colonies françaises."},
      {"year": "1848", "title": "Abolition de l'Esclavage", "desc": "Décret d'émancipation nationale du 27 avril, hâté le 22 mai par l'insurrection populaire de Fort-de-France."}
    ],
    // Catastrophes
    [
      {"year": "1902", "title": "Éruption de la Montagne Pelée", "desc": "Destruction totale de la ville de Saint-Pierre en quelques minutes, faisant près de 30 000 victimes."},
      {"year": "2007", "title": "Ouragan Dean", "desc": "Un cyclone dévastateur de catégorie 4 frappe de plein fouet les cultures de bananes et de canne à sucre."}
    ]
  ];

  final List<Map<String, String>> _figures = [
    {
      "name": "Aimé Césaire",
      "years": "1913 - 2008",
      "imageUrl": "https://lh3.googleusercontent.com/aida-public/AB6AXuDDA17Kpt4he160GHztaKvqut_5Ebv4ET8QrBMLcv1DJEO6VNO457YKCGtDyxhFK-tIyMehryVDYVc6MyWaFeAWbOvduMovHB4AjcfFmtStSByvNV6ur27nkBrXTSq1H1LSWqUsz-_Db4SdlrVDd0Xh_LxMXSXMFS58xi9qBPdHBusfAt5qk3ICzvEf6-_pr5WrPeR3faekP_0n-3fH0ukqylFqyBEUo2qerx6Z9RwWgBLIzFvLf6K9JsogBNCEj-TXmblwv6-6Rg"
    },
    {
      "name": "Paulette Nardal",
      "years": "1896 - 1985",
      "imageUrl": "https://lh3.googleusercontent.com/aida-public/AB6AXuC4Pq7wDIPgGM5BF8ky16csm5Fnl7tgCaWbaLjwum-QuTghqqqJMipHMibNpofKl9xGDJ5TR4nAtPVQwMF1CacdFa77K6ObjhorZFZAfHZVnNaVRBwP267Rj31eDUwzKZ_A3q9_CSTR58_ly983uGEYVMQUOPhaZ2-73w2h8SY33-1tEM1XRGL2K6a_4wL6y1birZnuPmB9a0xOMp9xjfnCsnZToP9uhTI1oAA5qPMQpm_ids2CnVzB0pi4Cd9t0TR0him_vOl6iQ"
    }
  ];

  final List<Map<String, String>> _locations = [
    {
      "name": "Volcan de la Montagne Pelée",
      "subtitle": "Nord de la Martinique",
      "time": "20 hs",
      "imageUrl": "https://lh3.googleusercontent.com/aida-public/AB6AXuDJikaKmT87uwpNpPxMCQTkJDfUFpq5JTRD74nnqloOnE9EUkI6XaaPhWAvYVnfnkJYec9_QacZJLgXQEMAKSAANMTZvahKHB_XGe1DD62GCxNG7LbWs6VTS99P06YFu3E0_3A-EhHJ_Vgl9vUhVhQeJAOQca7aeoaYFpoYrhWd21MXrU2YYcCKI2RZSwjbYudn37C8ADQJZLZxfsZ-YGg0cpwTsOzfhIakZSgoH8ZYpvady9oMt4YZ6qv6KanBiz6eRIPurZB7AA"
    },
    {
      "name": "Habitation Clément",
      "subtitle": "Le François",
      "time": "11 mn",
      "imageUrl": "https://lh3.googleusercontent.com/aida-public/AB6AXuClj5n6f67Bylk0UGiztgKrExm3C7XoJh-UhHB9UvzBgHkppaEY4b1G5H1C3s1EGm7lw6XXtpaoUV1_T0C9QKKe7DMbJ1wA-MVV2IRmm4DcffDIpAtVKcrXu_j5wR2WPEmymjeAiN5NLFogorIDe0sbH3lztVe1Vh6VhC-SUguelccFfV6HNloFcLZsUIhMiFjP4UohlZyLlgp3NxLHFuZofoXWeBjyVCTS-xTPCvhNA82wtZ1uizyE7u7Vkp0BzUV3eSOGqa1wvw"
    },
    {
      "name": "Ruines de Saint-Pierre",
      "subtitle": "Saint-Pierre",
      "time": "20 mn",
      "imageUrl": "https://lh3.googleusercontent.com/aida-public/AB6AXuA7FcS-y3GWvTKISp7CVn_tgKuwm0BcxDujPnxxEtY7XjpQSt5vP9sS2NUoz7bLbIAo4GHQBJdiqrA7BWGsY6C-3w2iUzMjzAXMwfS68ZvI6nct6t_j_VnJQRsX_blLaiibPzkb6rz8OBEa8CB61XhIyoBESPx2zTFrYPlgwdxSceRC5Oz87yRq80oN7aie8bdQcgrW_Z0brBSbQQdqSsrQ0FWmUO72gbwh3TDwNM-04XDrcfUwd7sJ4zNgLF944RlwTsqicMWpcA"
    }
  ];

  @override
  Widget build(BuildContext context) {
    // Current list of events for the active period
    final activeEvents = _periodEvents[_selectedPeriodIndex];
    if (_selectedEventNodeIndex >= activeEvents.length) {
      _selectedEventNodeIndex = activeEvents.length - 1;
    }
    final activeEvent = activeEvents[_selectedEventNodeIndex];

    return AmbientGlow(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: AppColors.onSurface),
            onPressed: () => Navigator.of(context).pop(),
          ),
          title: const Text(
            "Istwa & Patrimoine",
            style: TextStyle(
              color: AppColors.onSurface,
              fontFamily: 'Epilogue',
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.only(bottom: 40),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Interactive Timeline Section
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Interactive Timeline",
                      style: TextStyle(
                        color: AppColors.onSurface,
                        fontSize: 18,
                        fontFamily: 'Epilogue',
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    
                    // Period Tabs Carousel
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      physics: const BouncingScrollPhysics(),
                      child: Row(
                        children: List.generate(_periods.length, (index) {
                          final isSelected = _selectedPeriodIndex == index;
                          return Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: GestureDetector(
                              onTap: () {
                                setState(() {
                                  _selectedPeriodIndex = index;
                                  _selectedEventNodeIndex = 0;
                                });
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                decoration: BoxDecoration(
                                  color: isSelected 
                                      ? AppColors.primaryContainer.withOpacity(0.2) 
                                      : AppColors.surfaceContainer,
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(
                                    color: isSelected 
                                        ? AppColors.primary 
                                        : Colors.white.withOpacity(0.05),
                                  ),
                                ),
                                child: Text(
                                  _periods[index],
                                  style: TextStyle(
                                    color: isSelected ? AppColors.onSurface : AppColors.onSurface.withOpacity(0.6),
                                    fontSize: 12,
                                    fontFamily: 'Be Vietnam Pro',
                                    fontWeight: FontWeight.bold,
                                  ),
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
              const SizedBox(height: 24),

              // Visual Connecting Timeline Line & Nodes
              Stack(
                alignment: Alignment.center,
                children: [
                  // Horizontal Connecting Line
                  Positioned(
                    left: 40,
                    right: 40,
                    child: Container(
                      height: 2,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(1),
                      ),
                    ),
                  ),

                  // Nodes mapping
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 40),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: List.generate(activeEvents.length, (index) {
                        final isSelected = _selectedEventNodeIndex == index;
                        return GestureDetector(
                          onTap: () {
                            setState(() {
                              _selectedEventNodeIndex = index;
                            });
                          },
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              AnimatedContainer(
                                duration: const Duration(milliseconds: 300),
                                width: isSelected ? 20 : 12,
                                height: isSelected ? 20 : 12,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: isSelected ? AppColors.tertiary : Colors.white.withOpacity(0.2),
                                  border: Border.all(
                                    color: isSelected ? Colors.white : Colors.transparent,
                                    width: 2,
                                  ),
                                  boxShadow: isSelected
                                      ? [
                                          BoxShadow(
                                            color: AppColors.tertiary.withOpacity(0.6),
                                            blurRadius: 12,
                                            spreadRadius: 2,
                                          )
                                        ]
                                      : [],
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                activeEvents[index]["year"],
                                style: TextStyle(
                                  color: isSelected ? AppColors.tertiary : AppColors.onSurfaceVariant.withOpacity(0.6),
                                  fontSize: 10,
                                  fontFamily: 'Be Vietnam Pro',
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        );
                      }),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),

              // Selected Event detail glass card
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: GlassPanel(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        activeEvent["year"]?.toUpperCase() ?? "",
                        style: const TextStyle(
                          color: AppColors.primaryLight,
                          fontSize: 11,
                          fontFamily: 'Be Vietnam Pro',
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.0,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        activeEvent["title"] ?? "",
                        style: const TextStyle(
                          color: AppColors.onSurface,
                          fontSize: 18,
                          fontFamily: 'Epilogue',
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        activeEvent["desc"] ?? "",
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
              const SizedBox(height: 40),

              // 2. Figures Emblematiques Section
              const Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Text(
                  "Figures Emblématiques",
                  style: TextStyle(
                    color: AppColors.onSurface,
                    fontSize: 18,
                    fontFamily: 'Epilogue',
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Horizontal Portrait Carousel
              SizedBox(
                height: 280,
                child: ListView.separated(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  scrollDirection: Axis.horizontal,
                  physics: const BouncingScrollPhysics(),
                  itemCount: _figures.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 16),
                  itemBuilder: (context, index) {
                    final fig = _figures[index];
                    return ClipRRect(
                      borderRadius: BorderRadius.circular(24),
                      child: Container(
                        width: 200,
                        height: 280,
                        decoration: BoxDecoration(
                          color: AppColors.surfaceContainer,
                          border: Border.all(color: Colors.white.withOpacity(0.08)),
                        ),
                        child: Stack(
                          children: [
                            Positioned.fill(
                              child: Image.network(
                                fig["imageUrl"] ?? "",
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) => Container(color: AppColors.surfaceContainer),
                              ),
                            ),
                            // Dark gradient overlay for text legibility
                            Positioned.fill(
                              child: Container(
                                decoration: const BoxDecoration(
                                  gradient: LinearGradient(
                                    begin: Alignment.topCenter,
                                    end: Alignment.bottomCenter,
                                    colors: [
                                      Colors.transparent,
                                      Color(0x8A000000), // Colors.black54
                                      Color(0xE6000000), // Colors.black with 90% opacity
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            Positioned(
                              bottom: 20,
                              left: 20,
                              right: 20,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    fig["name"] ?? "",
                                    style: const TextStyle(
                                      color: AppColors.onSurface,
                                      fontSize: 18,
                                      fontFamily: 'Epilogue',
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    fig["years"] ?? "",
                                    style: TextStyle(
                                      color: AppColors.onSurfaceVariant.withOpacity(0.7),
                                      fontSize: 12,
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
                  },
                ),
              ),
              const SizedBox(height: 40),

              // 3. Lieux Historiques Section
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      "Lieux Historiques",
                      style: TextStyle(
                        color: AppColors.onSurface,
                        fontSize: 18,
                        fontFamily: 'Epilogue',
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceContainer,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.tertiary.withOpacity(0.2)),
                      ),
                      child: const Row(
                        children: [
                          Icon(Icons.location_on, color: AppColors.tertiary, size: 12),
                          SizedBox(width: 4),
                          Text(
                            "VOIR CARTE",
                            style: TextStyle(
                              color: AppColors.tertiary,
                              fontSize: 10,
                              fontFamily: 'Be Vietnam Pro',
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Locations List
              ListView.separated(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _locations.length,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final loc = _locations[index];
                  return GestureDetector(
                    onTap: () {
                      if (loc["name"]!.contains("Pelée")) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const MontagnePeleeScreen(),
                          ),
                        );
                      }
                    },
                    child: GlassPanel(
                      padding: const EdgeInsets.all(12),
                      child: Row(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(16),
                            child: SizedBox(
                              width: 80,
                              height: 80,
                              child: Image.network(
                                loc["imageUrl"] ?? "",
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) => Container(color: AppColors.surfaceContainer),
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  loc["name"] ?? "",
                                  style: const TextStyle(
                                    color: AppColors.onSurface,
                                    fontSize: 14,
                                    fontFamily: 'Epilogue',
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  loc["subtitle"] ?? "",
                                  style: TextStyle(
                                    color: AppColors.onSurfaceVariant.withOpacity(0.6),
                                    fontSize: 11,
                                    fontFamily: 'Be Vietnam Pro',
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Row(
                            children: [
                              Text(
                                loc["time"] ?? "",
                                style: TextStyle(
                                  color: AppColors.onSurfaceVariant.withOpacity(0.6),
                                  fontSize: 11,
                                  fontFamily: 'Be Vietnam Pro',
                                ),
                              ),
                              const SizedBox(width: 4),
                              Icon(
                                Icons.arrow_forward_ios,
                                color: AppColors.onSurfaceVariant.withOpacity(0.4),
                                size: 12,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
