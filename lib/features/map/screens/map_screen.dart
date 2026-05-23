import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/colors.dart';
import '../../../core/widgets/glass_panel.dart';
import '../../../core/network/pocketbase_client.dart';

class MapScreen extends StatefulWidget {
  final VoidCallback? onToggleOutings;

  const MapScreen({
    super.key,
    this.onToggleOutings,
  });

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  Map<String, dynamic>? _selectedSpot;

  @override
  Widget build(BuildContext context) {
    final pbService = Provider.of<PocketBaseService>(context, listen: false);

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          // FlutterMap layer with CartoDB Dark Matter for beautiful dark-mode mapping
          FutureBuilder<List<Map<String, dynamic>>>(
            future: pbService.fetchMapMarkers(),
            builder: (context, snapshot) {
              final markersData = snapshot.data ?? [];

              return FlutterMap(
                options: const MapOptions(
                  initialCenter: LatLng(14.63, -61.02), // Center of Martinique
                  initialZoom: 10.5,
                  minZoom: 9.0,
                  maxZoom: 16.0,
                ),
                children: [
                  TileLayer(
                    urlTemplate: 'https://{s}.basemaps.cartocdn.com/dark_all/{z}/{x}/{y}{r}.png',
                    subdomains: const ['a', 'b', 'c', 'd'],
                  ),
                  
                  // Custom Marker Layer
                  MarkerLayer(
                    markers: markersData.map((spot) {
                      final lat = spot["latitude"] as double? ?? 14.6;
                      final lng = spot["longitude"] as double? ?? -61.0;
                      final isSelected = _selectedSpot != null && _selectedSpot!["id"] == spot["id"];

                      return Marker(
                        point: LatLng(lat, lng),
                        width: 48,
                        height: 48,
                        child: GestureDetector(
                          onTap: () {
                            setState(() {
                              _selectedSpot = spot;
                            });
                          },
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 300),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: isSelected 
                                  ? AppColors.primary 
                                  : AppColors.surfaceContainerHigh.withOpacity(0.9),
                              border: Border.all(
                                color: isSelected ? Colors.white : AppColors.primary,
                                width: 2,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.primary.withOpacity(isSelected ? 0.6 : 0.3),
                                  blurRadius: isSelected ? 16 : 8,
                                  spreadRadius: 2,
                                ),
                              ],
                            ),
                            child: Icon(
                              _getCategoryIcon(spot["category"]),
                              color: isSelected ? Colors.white : AppColors.primaryLight,
                              size: 20,
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ],
              );
            },
          ),
          
          // Header search/filter floating panel
          Positioned(
            top: 24,
            left: 24,
            right: 24,
            child: GlassPanel(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              borderRadius: 20,
              child: Row(
                children: [
                  const Icon(Icons.search, color: AppColors.onSurfaceVariant),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Text(
                      "Rechercher un lieu culturel...",
                      style: TextStyle(
                        color: AppColors.onSurfaceVariant,
                        fontSize: 14,
                        fontFamily: 'Be Vietnam Pro',
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.filter_list, color: AppColors.onSurface, size: 16),
                  ),
                ],
              ),
            ),
          ),

          // Detail Slide-up Glass Sheet when a spot is clicked
          if (_selectedSpot != null)
            Positioned(
              left: 24,
              right: 24,
              bottom: 110, // Sits above the navigation bar
              child: Dismissible(
                key: Key(_selectedSpot!["id"] ?? "spot_key"),
                direction: DismissDirection.down,
                onDismissed: (_) {
                  setState(() {
                    _selectedSpot = null;
                  });
                },
                child: GlassPanel.floating(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: AppColors.primaryContainer.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: AppColors.primary.withOpacity(0.2)),
                            ),
                            child: Text(
                              _selectedSpot!["category"]?.toUpperCase() ?? "PATRIMOINE",
                              style: const TextStyle(
                                color: AppColors.primaryLight,
                                fontSize: 10,
                                fontFamily: 'Be Vietnam Pro',
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1.0,
                              ),
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.close, color: AppColors.onSurfaceVariant, size: 20),
                            onPressed: () {
                              setState(() {
                                _selectedSpot = null;
                              });
                            },
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _selectedSpot!["name"] ?? "",
                        style: const TextStyle(
                          color: AppColors.onSurface,
                          fontSize: 20,
                          fontFamily: 'Epilogue',
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        _selectedSpot!["description"] ?? "",
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: AppColors.onSurfaceVariant.withOpacity(0.9),
                          fontSize: 14,
                          fontFamily: 'Be Vietnam Pro',
                          height: 1.4,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: () {
                                // Dynamic interaction (e.g. play audio guide)
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text("Lancement de l'audio guide..."),
                                    duration: Duration(seconds: 2),
                                  ),
                                );
                              },
                              icon: const Icon(Icons.volume_up, size: 16),
                              label: const Text(
                                "Écouter l'Audio Guide",
                                style: TextStyle(
                                  fontFamily: 'Be Vietnam Pro',
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.secondary,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(vertical: 12),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          
          // Floating AGENDA/OUTINGS Toggle FAB when no spot is selected (or overlaying nicely)
          if (_selectedSpot == null && widget.onToggleOutings != null)
            Positioned(
              bottom: 110,
              right: 24,
              child: GestureDetector(
                onTap: widget.onToggleOutings,
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
                      Icon(Icons.calendar_month, color: Colors.white, size: 18),
                      SizedBox(width: 8),
                      Text(
                        "Sortir",
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

  IconData _getCategoryIcon(String? category) {
    switch (category?.toLowerCase()) {
      case 'rhumerie':
        return Icons.local_bar;
      case 'nature':
        return Icons.forest;
      case 'monument':
        return Icons.account_balance;
      case 'patrimoine':
      default:
        return Icons.museum;
    }
  }
}
