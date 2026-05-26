import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/colors.dart';
import '../../../core/widgets/glass_panel.dart';
import '../../../core/widgets/ambient_glow.dart';
import '../../../core/network/pocketbase_client.dart';

class CalendarScreen extends StatefulWidget {
  final DateTime? initialSelectedDate;

  const CalendarScreen({
    super.key,
    this.initialSelectedDate,
  });

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  late DateTime _focusedMonth;
  DateTime? _selectedDate;
  List<Map<String, dynamic>> _allEvents = [];
  bool _isLoading = true;

  final List<String> _months = [
    "Janvier", "Février", "Mars", "Avril", "Mai", "Juin",
    "Juillet", "Août", "Septembre", "Octobre", "Novembre", "Décembre"
  ];

  final List<String> _weekDays = ["Lun", "Mar", "Mer", "Jeu", "Ven", "Sam", "Dim"];

  @override
  void initState() {
    super.initState();
    _selectedDate = widget.initialSelectedDate ?? DateTime.now();
    _focusedMonth = widget.initialSelectedDate ?? DateTime.now();
    _loadEvents();
  }

  Future<void> _loadEvents() async {
    final pbService = Provider.of<PocketBaseService>(context, listen: false);
    final events = await pbService.fetchEvents();
    setState(() {
      _allEvents = events;
      _isLoading = false;
    });
  }

  DateTime? _parseEventDate(dynamic dateVal) {
    if (dateVal == null) return null;
    final dateStr = dateVal.toString();
    if (dateStr.isEmpty) return null;
    return DateTime.tryParse(dateStr)?.toLocal();
  }

  List<Map<String, dynamic>> _getEventsForDay(DateTime day) {
    return _allEvents.where((event) {
      final date = _parseEventDate(event["date"]);
      if (date == null) return false;
      return date.year == day.year && date.month == day.month && date.day == day.day;
    }).toList();
  }

  bool _hasEventOnDay(DateTime day) {
    return _getEventsForDay(day).isNotEmpty;
  }

  List<DateTime> _generateCalendarDays() {
    final firstDayOfMonth = DateTime(_focusedMonth.year, _focusedMonth.month, 1);
    final prevMonthDaysCount = firstDayOfMonth.weekday - 1; // 1 = Monday
    final daysInMonth = DateTime(_focusedMonth.year, _focusedMonth.month + 1, 0).day;

    final List<DateTime> days = [];

    // Add days from previous month
    final prevMonth = DateTime(_focusedMonth.year, _focusedMonth.month, 0);
    for (int i = prevMonthDaysCount - 1; i >= 0; i--) {
      days.add(DateTime(prevMonth.year, prevMonth.month, prevMonth.day - i));
    }

    // Add days of current month
    for (int i = 1; i <= daysInMonth; i++) {
      days.add(DateTime(_focusedMonth.year, _focusedMonth.month, i));
    }

    // Add days of next month to complete the 42 cells grid (6 weeks)
    final totalCells = 42;
    final nextMonthDaysNeeded = totalCells - days.length;
    for (int i = 1; i <= nextMonthDaysNeeded; i++) {
      days.add(DateTime(_focusedMonth.year, _focusedMonth.month + 1, i));
    }

    return days;
  }

  void _previousMonth() {
    setState(() {
      _focusedMonth = DateTime(_focusedMonth.year, _focusedMonth.month - 1);
    });
  }

  void _nextMonth() {
    setState(() {
      _focusedMonth = DateTime(_focusedMonth.year, _focusedMonth.month + 1);
    });
  }

  @override
  Widget build(BuildContext context) {
    final calendarDays = _generateCalendarDays();
    final selectedEvents = _selectedDate != null ? _getEventsForDay(_selectedDate!) : <Map<String, dynamic>>[];

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
          title: const Text(
            "Calendrier Événements",
            style: TextStyle(
              color: AppColors.onSurface,
              fontFamily: 'Epilogue',
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        body: _isLoading
            ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
            : SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.only(bottom: 40),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Month Navigation Header
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "${_months[_focusedMonth.month - 1]} ${_focusedMonth.year}",
                            style: const TextStyle(
                              color: AppColors.onSurface,
                              fontSize: 20,
                              fontFamily: 'Epilogue',
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Row(
                            children: [
                              IconButton(
                                icon: const Icon(Icons.chevron_left, color: AppColors.onSurface),
                                onPressed: _previousMonth,
                              ),
                              IconButton(
                                icon: const Icon(Icons.chevron_right, color: AppColors.onSurface),
                                onPressed: _nextMonth,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    // Calendar Grid Container
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: GlassPanel(
                        padding: const EdgeInsets.all(16),
                        borderRadius: 24,
                        child: Column(
                          children: [
                            // Week days row header
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: _weekDays.map((day) {
                                return SizedBox(
                                  width: 38,
                                  child: Text(
                                    day,
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      color: AppColors.onSurfaceVariant.withOpacity(0.5),
                                      fontSize: 12,
                                      fontFamily: 'Be Vietnam Pro',
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                );
                              }).toList(),
                            ),
                            const SizedBox(height: 16),
                            // Days Grid
                            GridView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 7,
                                mainAxisSpacing: 10,
                                crossAxisSpacing: 6,
                                childAspectRatio: 1.0,
                              ),
                              itemCount: calendarDays.length,
                              itemBuilder: (context, index) {
                                final day = calendarDays[index];
                                final isCurrentMonth = day.month == _focusedMonth.month;
                                final isSelected = _selectedDate != null &&
                                    day.year == _selectedDate!.year &&
                                    day.month == _selectedDate!.month &&
                                    day.day == _selectedDate!.day;
                                final hasEvent = _hasEventOnDay(day);

                                return GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      _selectedDate = day;
                                    });
                                  },
                                  child: AnimatedContainer(
                                    duration: const Duration(milliseconds: 200),
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: isSelected
                                          ? AppColors.primary.withOpacity(0.2)
                                          : Colors.transparent,
                                      border: isSelected
                                          ? Border.all(color: AppColors.primary, width: 1.5)
                                          : null,
                                    ),
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Text(
                                          day.day.toString(),
                                          style: TextStyle(
                                            color: isSelected
                                                ? AppColors.primaryLight
                                                : isCurrentMonth
                                                    ? AppColors.onSurface
                                                    : AppColors.onSurfaceVariant.withOpacity(0.3),
                                            fontSize: 14,
                                            fontFamily: 'Be Vietnam Pro',
                                            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                          ),
                                        ),
                                        if (hasEvent) ...[
                                          const SizedBox(height: 3),
                                          Container(
                                            width: 5,
                                            height: 5,
                                            decoration: const BoxDecoration(
                                              shape: BoxShape.circle,
                                              color: AppColors.secondary,
                                              boxShadow: [
                                                BoxShadow(
                                                  color: AppColors.secondary,
                                                  blurRadius: 4,
                                                  spreadRadius: 1,
                                                )
                                              ],
                                            ),
                                          ),
                                        ],
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
                    const SizedBox(height: 32),

                    // Selected Date Events Header
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Text(
                        _selectedDate == null
                            ? "Sélectionnez une date"
                            : "Événements du ${_selectedDate!.day} ${_months[_selectedDate!.month - 1]}",
                        style: const TextStyle(
                          color: AppColors.onSurface,
                          fontSize: 18,
                          fontFamily: 'Epilogue',
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Events List for selected date
                    selectedEvents.isEmpty
                        ? Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 24),
                            child: GlassPanel(
                              padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 16),
                              child: Center(
                                child: Column(
                                  children: [
                                    Icon(
                                      Icons.calendar_today_outlined,
                                      color: AppColors.onSurfaceVariant.withOpacity(0.4),
                                      size: 32,
                                    ),
                                    const SizedBox(height: 12),
                                    Text(
                                      "Aucun événement prévu à cette date.",
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        color: AppColors.onSurfaceVariant.withOpacity(0.6),
                                        fontSize: 13,
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
                            itemCount: selectedEvents.length,
                            separatorBuilder: (_, __) => const SizedBox(height: 12),
                            itemBuilder: (context, index) {
                              final event = selectedEvents[index];
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
                                          height: 140,
                                          width: double.infinity,
                                          child: Image.network(
                                            event["image_url"],
                                            fit: BoxFit.cover,
                                            errorBuilder: (_, __, ___) => Container(color: AppColors.surfaceContainer),
                                          ),
                                        ),
                                      ),
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
                                                  event["title"] ?? "",
                                                  style: const TextStyle(
                                                    color: AppColors.onSurface,
                                                    fontSize: 16,
                                                    fontFamily: 'Epilogue',
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                              ),
                                              const Icon(Icons.favorite_border, color: AppColors.onSurfaceVariant, size: 20),
                                            ],
                                          ),
                                          const SizedBox(height: 6),
                                          Row(
                                            children: [
                                              const Icon(Icons.location_on, color: AppColors.onSurfaceVariant, size: 12),
                                              const SizedBox(width: 4),
                                              Text(
                                                event["location_name"] ?? "",
                                                style: TextStyle(
                                                  color: AppColors.onSurfaceVariant.withOpacity(0.8),
                                                  fontSize: 11,
                                                  fontFamily: 'Be Vietnam Pro',
                                                ),
                                              ),
                                            ],
                                          ),
                                          if (event["description"] != null && event["description"].toString().isNotEmpty) ...[
                                            const SizedBox(height: 12),
                                            Text(
                                              event["description"],
                                              style: TextStyle(
                                                color: AppColors.onSurface.withOpacity(0.9),
                                                fontSize: 13,
                                                fontFamily: 'Be Vietnam Pro',
                                                height: 1.4,
                                              ),
                                            ),
                                          ],
                                          const SizedBox(height: 12),
                                          Row(
                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                            children: [
                                              Container(
                                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                                decoration: BoxDecoration(
                                                  color: Colors.white.withOpacity(0.06),
                                                  borderRadius: BorderRadius.circular(4),
                                                ),
                                                child: Text(
                                                  priceText,
                                                  style: const TextStyle(
                                                    color: AppColors.secondaryLight,
                                                    fontSize: 10,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                              ),
                                              if (event["category"] != null)
                                                Container(
                                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                                  decoration: BoxDecoration(
                                                    color: AppColors.primaryContainer.withOpacity(0.1),
                                                    borderRadius: BorderRadius.circular(4),
                                                    border: Border.all(color: AppColors.primary.withOpacity(0.2)),
                                                  ),
                                                  child: Text(
                                                    event["category"].toString().toUpperCase(),
                                                    style: const TextStyle(
                                                      color: AppColors.primaryLight,
                                                      fontSize: 8,
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
