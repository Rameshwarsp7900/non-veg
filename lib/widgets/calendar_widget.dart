import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';
import '../services/diet_service.dart';
import '../models/day_status.dart';
import '../models/diet_event.dart';
import 'day_detail_dialog.dart';

class CalendarWidget extends StatefulWidget {
  @override
  _CalendarWidgetState createState() => _CalendarWidgetState();
}

class _CalendarWidgetState extends State<CalendarWidget> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  CalendarFormat _calendarFormat = CalendarFormat.month;

  @override
  void initState() {
    super.initState();
    _selectedDay = DateTime.now();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<DietService>(
      builder: (context, dietService, child) {
        return Card(
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: EdgeInsets.all(16.0),
            child: Column(
              children: [
                // Calendar header with legend
                _buildCalendarHeader(context),
                
                SizedBox(height: 16),
                
                // Table Calendar
                TableCalendar<DietEvent>(
                  firstDay: DateTime.utc(2020, 1, 1),
                  lastDay: DateTime.utc(2030, 12, 31),
                  focusedDay: _focusedDay,
                  selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
                  calendarFormat: _calendarFormat,
                  eventLoader: (day) => dietService.getEventsForMonth(day),
                  startingDayOfWeek: StartingDayOfWeek.monday,
                  headerStyle: HeaderStyle(
                    formatButtonVisible: true,
                    titleCentered: true,
                    formatButtonShowsNext: false,
                    formatButtonDecoration: BoxDecoration(
                      color: Theme.of(context).primaryColor,
                      borderRadius: BorderRadius.circular(12.0),
                    ),
                    formatButtonTextStyle: TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                    ),
                  ),
                  calendarStyle: CalendarStyle(
                    outsideDaysVisible: false,
                    weekendTextStyle: TextStyle(color: Colors.red.shade600),
                    holidayTextStyle: TextStyle(color: Colors.red.shade800),
                    selectedDecoration: BoxDecoration(
                      color: Theme.of(context).primaryColor,
                      shape: BoxShape.circle,
                    ),
                    todayDecoration: BoxDecoration(
                      color: Theme.of(context).primaryColor.withOpacity(0.5),
                      shape: BoxShape.circle,
                    ),
                    markerDecoration: BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                    ),
                    markersMaxCount: 1,
                  ),
                  calendarBuilders: CalendarBuilders(
                    defaultBuilder: (context, day, focusedDay) {
                      return _buildCalendarDay(context, day, dietService);
                    },
                    todayBuilder: (context, day, focusedDay) {
                      return _buildCalendarDay(context, day, dietService, isToday: true);
                    },
                    selectedBuilder: (context, day, focusedDay) {
                      return _buildCalendarDay(context, day, dietService, isSelected: true);
                    },
                  ),
                  onDaySelected: (selectedDay, focusedDay) {
                    setState(() {
                      _selectedDay = selectedDay;
                      _focusedDay = focusedDay;
                    });
                    
                    // Show day detail dialog
                    _showDayDetail(context, selectedDay, dietService);
                  },
                  onFormatChanged: (format) {
                    setState(() {
                      _calendarFormat = format;
                    });
                  },
                  onPageChanged: (focusedDay) {
                    setState(() {
                      _focusedDay = focusedDay;
                    });
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildCalendarHeader(BuildContext context) {
    return Column(
      children: [
        Text(
          'Dietary Calendar',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 8),
        _buildLegend(context),
      ],
    );
  }

  Widget _buildLegend(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildLegendItem('✅', 'Non-Veg OK', Colors.green),
          _buildLegendItem('❌', 'Veg Only', Colors.red),
          _buildLegendItem('⚠️', 'Conditional', Colors.orange),
        ],
      ),
    );
  }

  Widget _buildLegendItem(String icon, String label, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(icon, style: TextStyle(fontSize: 16)),
        SizedBox(width: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: color,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildCalendarDay(
    BuildContext context, 
    DateTime day, 
    DietService dietService, {
    bool isToday = false,
    bool isSelected = false,
  }) {
    final dayStatus = dietService.getDayStatus(day);
    final backgroundColor = _getDayBackgroundColor(dayStatus.restriction);
    final textColor = _getDayTextColor(dayStatus.restriction);
    
    return Container(
      margin: EdgeInsets.all(2),
      decoration: BoxDecoration(
        color: isSelected 
            ? Theme.of(context).primaryColor 
            : isToday 
                ? Theme.of(context).primaryColor.withOpacity(0.3)
                : backgroundColor,
        shape: BoxShape.circle,
        border: dayStatus.events.isNotEmpty
            ? Border.all(color: Colors.deepPurple, width: 2)
            : null,
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              '${day.day}',
              style: TextStyle(
                color: isSelected || isToday ? Colors.white : textColor,
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
            if (dayStatus.events.isNotEmpty)
              Text(
                dayStatus.iconText,
                style: TextStyle(fontSize: 8),
              ),
          ],
        ),
      ),
    );
  }

  Color _getDayBackgroundColor(RestrictionType restriction) {
    switch (restriction) {
      case RestrictionType.vegOnly:
        return Colors.red.shade100;
      case RestrictionType.nonVegAllowed:
        return Colors.green.shade100;
      case RestrictionType.conditional:
        return Colors.orange.shade100;
    }
  }

  Color _getDayTextColor(RestrictionType restriction) {
    switch (restriction) {
      case RestrictionType.vegOnly:
        return Colors.red.shade800;
      case RestrictionType.nonVegAllowed:
        return Colors.green.shade800;
      case RestrictionType.conditional:
        return Colors.orange.shade800;
    }
  }

  void _showDayDetail(BuildContext context, DateTime day, DietService dietService) {
    showDialog(
      context: context,
      builder: (context) => DayDetailDialog(
        date: day,
        dayStatus: dietService.getDayStatus(day),
      ),
    );
  }
}