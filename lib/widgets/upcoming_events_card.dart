import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../services/diet_service.dart';
import '../models/diet_event.dart';

class UpcomingEventsCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<DietService>(
      builder: (context, dietService, child) {
        final upcomingEvents = dietService.getUpcomingEvents();
        
        return Card(
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.upcoming,
                      color: Theme.of(context).primaryColor,
                      size: 24,
                    ),
                    SizedBox(width: 8),
                    Text(
                      'Upcoming Events',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).primaryColor,
                      ),
                    ),
                  ],
                ),
                
                SizedBox(height: 12),
                
                if (upcomingEvents.isEmpty)
                  _buildNoEventsMessage(context)
                else
                  Column(
                    children: upcomingEvents
                        .take(5) // Show only next 5 events
                        .map((event) => _buildEventItem(context, event))
                        .toList(),
                  ),
                
                if (upcomingEvents.length > 5) ...[
                  SizedBox(height: 8),
                  Center(
                    child: TextButton(
                      onPressed: () {
                        _showAllUpcomingEvents(context, upcomingEvents);
                      },
                      child: Text('View All (${upcomingEvents.length})'),
                    ),
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildNoEventsMessage(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(20),
      child: Column(
        children: [
          Icon(
            Icons.event_busy,
            size: 48,
            color: Colors.grey.shade400,
          ),
          SizedBox(height: 12),
          Text(
            'No upcoming events',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey.shade600,
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Your next week looks clear!',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade500,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildEventItem(BuildContext context, DietEvent event) {
    final daysUntil = event.date.difference(DateTime.now()).inDays;
    final timeText = _getTimeText(daysUntil);
    
    return Container(
      margin: EdgeInsets.only(bottom: 8),
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: _getEventBackgroundColor(event.restriction),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: _getEventBorderColor(event.restriction),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          // Event Icon
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: _getEventBorderColor(event.restriction),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                event.iconText,
                style: TextStyle(fontSize: 18),
              ),
            ),
          ),
          
          SizedBox(width: 12),
          
          // Event Details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  event.name,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                    color: _getEventTextColor(event.restriction),
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  DateFormat('MMM d, yyyy').format(event.date),
                  style: TextStyle(
                    fontSize: 13,
                    color: _getEventTextColor(event.restriction).withOpacity(0.8),
                  ),
                ),
                if (event.description != null && event.description!.isNotEmpty) ...[
                  SizedBox(height: 4),
                  Text(
                    event.description!,
                    style: TextStyle(
                      fontSize: 12,
                      color: _getEventTextColor(event.restriction).withOpacity(0.7),
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ],
            ),
          ),
          
          // Time Until Event
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                timeText,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: _getEventTextColor(event.restriction),
                ),
              ),
              SizedBox(height: 4),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: _getEventBorderColor(event.restriction),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  _getRestrictionText(event.restriction),
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _getTimeText(int daysUntil) {
    if (daysUntil == 0) return 'Today';
    if (daysUntil == 1) return 'Tomorrow';
    if (daysUntil < 7) return 'In $daysUntil days';
    final weeks = (daysUntil / 7).floor();
    if (weeks == 1) return 'In 1 week';
    return 'In $weeks weeks';
  }

  String _getRestrictionText(RestrictionType restriction) {
    switch (restriction) {
      case RestrictionType.vegOnly:
        return 'VEG ONLY';
      case RestrictionType.nonVegAllowed:
        return 'NON-VEG OK';
      case RestrictionType.conditional:
        return 'CONDITIONAL';
    }
  }

  Color _getEventBackgroundColor(RestrictionType restriction) {
    switch (restriction) {
      case RestrictionType.vegOnly:
        return Colors.red.shade50;
      case RestrictionType.nonVegAllowed:
        return Colors.green.shade50;
      case RestrictionType.conditional:
        return Colors.orange.shade50;
    }
  }

  Color _getEventBorderColor(RestrictionType restriction) {
    switch (restriction) {
      case RestrictionType.vegOnly:
        return Colors.red.shade400;
      case RestrictionType.nonVegAllowed:
        return Colors.green.shade400;
      case RestrictionType.conditional:
        return Colors.orange.shade400;
    }
  }

  Color _getEventTextColor(RestrictionType restriction) {
    switch (restriction) {
      case RestrictionType.vegOnly:
        return Colors.red.shade800;
      case RestrictionType.nonVegAllowed:
        return Colors.green.shade800;
      case RestrictionType.conditional:
        return Colors.orange.shade800;
    }
  }

  void _showAllUpcomingEvents(BuildContext context, List<DietEvent> events) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        maxChildSize: 0.9,
        minChildSize: 0.5,
        builder: (context, scrollController) => Container(
          padding: EdgeInsets.all(20),
          child: Column(
            children: [
              // Handle
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              
              SizedBox(height: 20),
              
              Text(
                'All Upcoming Events',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              
              SizedBox(height: 16),
              
              Expanded(
                child: ListView.builder(
                  controller: scrollController,
                  itemCount: events.length,
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: EdgeInsets.only(bottom: 8),
                      child: _buildEventItem(context, events[index]),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}