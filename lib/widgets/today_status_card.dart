import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../services/diet_service.dart';
import '../models/day_status.dart';
import '../screens/day_detail_dialog.dart';

class TodayStatusCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<DietService>(
      builder: (context, dietService, child) {
        final today = DateTime.now();
        final dayStatus = dietService.getDayStatus(today);
        
        return Card(
          elevation: 6,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              gradient: _getGradientForStatus(dayStatus.restriction),
            ),
            child: Padding(
              padding: EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        dayStatus.iconText,
                        style: TextStyle(fontSize: 32),
                      ),
                      SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Today - ${DateFormat('EEEE, MMM d').format(today)}',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            SizedBox(height: 4),
                            Text(
                              dayStatus.statusText,
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  
                  SizedBox(height: 16),
                  
                  Container(
                    padding: EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Reason:',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          dayStatus.reason,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                          ),
                        ),
                        
                        if (dayStatus.events.isNotEmpty) ...[
                          SizedBox(height: 12),
                          Text(
                            'Special Events:',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          SizedBox(height: 4),
                          ...dayStatus.events.map((event) => Padding(
                            padding: EdgeInsets.only(bottom: 2),
                            child: Text(
                              '• ${event.name}',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                              ),
                            ),
                          )).toList(),
                        ],
                        
                        if (dayStatus.userNotes != null && dayStatus.userNotes!.isNotEmpty) ...[
                          SizedBox(height: 12),
                          Text(
                            'Personal Note:',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            dayStatus.userNotes!,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  
                  SizedBox(height: 16),
                  
                  Row(
                    children: [
                      Expanded(
                        child: _buildFoodRecommendation(context, dayStatus),
                      ),
                      SizedBox(width: 12),
                      _buildQuickActionButton(context, dayStatus),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  LinearGradient _getGradientForStatus(RestrictionType restriction) {
    switch (restriction) {
      case RestrictionType.vegOnly:
        return LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Colors.red.shade400, Colors.red.shade600],
        );
      case RestrictionType.nonVegAllowed:
        return LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Colors.green.shade400, Colors.green.shade600],
        );
      case RestrictionType.conditional:
        return LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Colors.orange.shade400, Colors.orange.shade600],
        );
    }
  }

  Widget _buildFoodRecommendation(BuildContext context, DayStatus dayStatus) {
    String recommendation;
    IconData icon;
    
    switch (dayStatus.restriction) {
      case RestrictionType.vegOnly:
        recommendation = 'Vegetarian meals recommended';
        icon = Icons.eco;
        break;
      case RestrictionType.nonVegAllowed:
        recommendation = 'All food types allowed';
        icon = Icons.restaurant;
        break;
      case RestrictionType.conditional:
        recommendation = 'Check specific restrictions';
        icon = Icons.help_outline;
        break;
    }
    
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.white, size: 16),
          SizedBox(width: 6),
          Expanded(
            child: Text(
              recommendation,
              style: TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActionButton(BuildContext context, DayStatus dayStatus) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(20),
      ),
      child: IconButton(
        onPressed: () {
          _showQuickActions(context, dayStatus);
        },
        icon: Icon(Icons.more_vert, color: Colors.white),
        tooltip: 'Quick Actions',
      ),
    );
  }

  void _showQuickActions(BuildContext context, DayStatus dayStatus) {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Quick Actions for Today',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 20),
            ListTile(
              leading: Icon(Icons.add_circle, color: Colors.green),
              title: Text('Add Personal Override'),
              subtitle: Text('Override today\'s restriction'),
              onTap: () {
                Navigator.pop(context);
                _showAddOverrideDialog(context, dayStatus.date);
              },
            ),
            ListTile(
              leading: Icon(Icons.chat, color: Colors.blue),
              title: Text('Ask Food Assistant'),
              subtitle: Text('Get personalized food recommendations'),
              onTap: () {
                Navigator.pop(context);
                // Navigate to chat assistant
              },
            ),
            ListTile(
              leading: Icon(Icons.share, color: Colors.orange),
              title: Text('Share Status'),
              subtitle: Text('Share today\'s dietary status'),
              onTap: () {
                Navigator.pop(context);
                _shareStatus(context, dayStatus);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showAddOverrideDialog(BuildContext context, DateTime date) {
    final dietService = context.read<DietService>();
    final dayStatus = dietService.getDayStatus(date);
    
    showDialog(
      context: context,
      builder: (context) => DayDetailDialog(
        date: date,
        dayStatus: dayStatus,
      ),
    ).then((_) {
      // Trigger a rebuild to show any changes
      if (context.mounted) {
        // The provider will automatically notify listeners
      }
    });
  }

  void _shareStatus(BuildContext context, DayStatus dayStatus) {
    final statusText = 'Today (${DateFormat('MMM d').format(dayStatus.date)}) is ${dayStatus.statusText}. ${dayStatus.reason}';
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Status copied: $statusText'),
        backgroundColor: Colors.green,
      ),
    );
  }
}