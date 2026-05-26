import 'package:flutter/material.dart';
import '../../../core/theme/colors.dart';
import '../../../core/widgets/glass_panel.dart';
import '../../../core/widgets/ambient_glow.dart';

class DailyEventsScreen extends StatelessWidget {
  final DateTime date;
  final List<Map<String, dynamic>> events;

  const DailyEventsScreen({
    super.key,
    required this.date,
    required this.events,
  });

  static const List<String> _months = [
    "Janvier", "Février", "Mars", "Avril", "Mai", "Juin",
    "Juillet", "Août", "Septembre", "Octobre", "Novembre", "Décembre"
  ];

  @override
  Widget build(BuildContext context) {
    final formattedDate = "${date.day} ${_months[date.month - 1]} ${date.year}";

    return AmbientGlow(
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: AppColors.onSurface),
            onPressed: () => Navigator.of(context).pop(),
          ),
          title: Text(
            "Événements du Jour",
            style: const TextStyle(
              color: AppColors.onSurface,
              fontFamily: 'Epilogue',
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        body: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.only(bottom: 40),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Date Header
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      formattedDate,
                      style: const TextStyle(
                        color: AppColors.primaryLight,
                        fontSize: 24,
                        fontFamily: 'Epilogue',
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      events.isEmpty
                          ? "Aucun événement prévu"
                          : "${events.length} événement${events.length > 1 ? 's' : ''} programmé${events.length > 1 ? 's' : ''}",
                      style: TextStyle(
                        color: AppColors.onSurfaceVariant.withOpacity(0.8),
                        fontSize: 14,
                        fontFamily: 'Be Vietnam Pro',
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 12),

              // Events List
              events.isEmpty
                  ? Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: GlassPanel(
                        padding: const EdgeInsets.symmetric(vertical: 48, horizontal: 24),
                        child: Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.event_busy_outlined,
                                color: AppColors.onSurfaceVariant.withOpacity(0.4),
                                size: 48,
                              ),
                              const SizedBox(height: 16),
                              Text(
                                "Il n'y a pas d'événement programmé pour cette date.",
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: AppColors.onSurfaceVariant.withOpacity(0.7),
                                  fontSize: 14,
                                  fontFamily: 'Be Vietnam Pro',
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    )
                  : ListView.separated(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: events.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 16),
                      itemBuilder: (context, index) {
                        final event = events[index];
                        final price = event["price"]?.toString() ?? "0";
                        final priceText = price == "0" || price == "0.0" ? "Gratuit" : "$price€";

                        return GlassPanel(
                          padding: EdgeInsets.zero,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (event["image_url"] != null)
                                ClipRRect(
                                  borderRadius: const BorderRadius.only(
                                    topLeft: Radius.circular(24),
                                    topRight: Radius.circular(24),
                                  ),
                                  child: SizedBox(
                                    height: 160,
                                    width: double.infinity,
                                    child: Image.network(
                                      event["image_url"],
                                      fit: BoxFit.cover,
                                      errorBuilder: (_, __, ___) => Container(color: AppColors.surfaceContainer),
                                    ),
                                  ),
                                ),
                              Padding(
                                padding: const EdgeInsets.all(20),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Expanded(
                                          child: Text(
                                            event["title"] ?? "",
                                            style: const TextStyle(
                                              color: AppColors.onSurface,
                                              fontSize: 18,
                                              fontFamily: 'Epilogue',
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                        const Icon(Icons.favorite_border, color: AppColors.onSurfaceVariant, size: 22),
                                      ],
                                    ),
                                    const SizedBox(height: 8),
                                    Row(
                                      children: [
                                        const Icon(Icons.location_on, color: AppColors.onSurfaceVariant, size: 14),
                                        const SizedBox(width: 6),
                                        Text(
                                          event["location_name"] ?? "",
                                          style: TextStyle(
                                            color: AppColors.onSurfaceVariant.withOpacity(0.8),
                                            fontSize: 12,
                                            fontFamily: 'Be Vietnam Pro',
                                          ),
                                        ),
                                      ],
                                    ),
                                    if (event["description"] != null && event["description"].toString().isNotEmpty) ...[
                                      const SizedBox(height: 16),
                                      Text(
                                        event["description"],
                                        style: TextStyle(
                                          color: AppColors.onSurface.withOpacity(0.9),
                                          fontSize: 14,
                                          fontFamily: 'Be Vietnam Pro',
                                          height: 1.4,
                                        ),
                                      ),
                                    ],
                                    const SizedBox(height: 16),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                          decoration: BoxDecoration(
                                            color: Colors.white.withOpacity(0.06),
                                            borderRadius: BorderRadius.circular(6),
                                          ),
                                          child: Text(
                                            priceText,
                                            style: const TextStyle(
                                              color: AppColors.secondaryLight,
                                              fontSize: 11,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                        if (event["category"] != null)
                                          Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                            decoration: BoxDecoration(
                                              color: AppColors.primaryContainer.withOpacity(0.1),
                                              borderRadius: BorderRadius.circular(6),
                                              border: Border.all(color: AppColors.primary.withOpacity(0.2)),
                                            ),
                                            child: Text(
                                              event["category"].toString().toUpperCase(),
                                              style: const TextStyle(
                                                color: AppColors.primaryLight,
                                                fontSize: 9,
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
