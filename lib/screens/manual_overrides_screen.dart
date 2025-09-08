import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../services/diet_service.dart';
import '../models/day_status.dart';

class ManualOverridesScreen extends StatefulWidget {
  @override
  _ManualOverridesScreenState createState() => _ManualOverridesScreenState();
}

class _ManualOverridesScreenState extends State<ManualOverridesScreen> {
  String _filter = 'all'; // all, future, past

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Manual Overrides'),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) {
              setState(() {
                _filter = value;
              });
            },
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'all',
                child: Row(
                  children: [
                    Icon(Icons.all_inclusive, size: 20),
                    SizedBox(width: 8),
                    Text('All Overrides'),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'future',
                child: Row(
                  children: [
                    Icon(Icons.schedule, size: 20),
                    SizedBox(width: 8),
                    Text('Future Only'),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'past',
                child: Row(
                  children: [
                    Icon(Icons.history, size: 20),
                    SizedBox(width: 8),
                    Text('Past Only'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: Consumer<DietService>(
        builder: (context, dietService, child) {
          final overrides = _getFilteredOverrides(dietService.manualOverrides);
          
          if (overrides.isEmpty) {
            return _buildEmptyState();
          }
          
          return Column(
            children: [
              // Filter Info
              if (_filter != 'all')
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(12),
                  color: Colors.blue.shade50,
                  child: Text(
                    'Showing ${_filter} overrides (${overrides.length} items)',
                    style: TextStyle(
                      color: Colors.blue.shade700,
                      fontWeight: FontWeight.w500,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              
              // Overrides List
              Expanded(
                child: ListView.builder(
                  padding: EdgeInsets.all(16),
                  itemCount: overrides.length,
                  itemBuilder: (context, index) {
                    final override = overrides[index];
                    return _buildOverrideCard(override);
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    String message;
    IconData icon;
    
    switch (_filter) {
      case 'future':
        message = 'No future overrides scheduled';
        icon = Icons.schedule;
        break;
      case 'past':
        message = 'No past overrides found';
        icon = Icons.history;
        break;
      default:
        message = 'No manual overrides found';
        icon = Icons.edit_off;
    }
    
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            size: 64,
            color: Colors.grey.shade400,
          ),
          SizedBox(height: 16),
          Text(
            message,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: Colors.grey.shade600,
            ),
          ),
          SizedBox(height: 8),
          Text(
            _filter == 'all' 
                ? 'Create overrides from the calendar or today\\'s status card'
                : 'Change filter to see other overrides',
            style: TextStyle(color: Colors.grey.shade500),
            textAlign: TextAlign.center,
          ),
          if (_filter != 'all') ...[
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  _filter = 'all';
                });
              },
              child: Text('Show All Overrides'),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildOverrideCard(ManualOverride override) {
    final isUpcoming = override.date.isAfter(DateTime.now());
    final isPast = override.date.isBefore(DateTime.now().subtract(Duration(days: 1)));
    final isToday = _isSameDay(override.date, DateTime.now());
    
    return Card(
      margin: EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Row
            Row(
              children: [
                // Override Icon
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: _getRestrictionColor(override.restriction).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: _getRestrictionColor(override.restriction),
                      width: 2,
                    ),
                  ),
                  child: Center(
                    child: Text(
                      _getRestrictionIcon(override.restriction),
                      style: TextStyle(fontSize: 20),
                    ),
                  ),
                ),
                
                SizedBox(width: 12),
                
                // Date and Status
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              DateFormat('EEEE, MMM d, yyyy').format(override.date),
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                color: isPast ? Colors.grey.shade600 : Colors.black87,
                              ),
                            ),
                          ),
                          if (isToday)
                            Container(
                              padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: Colors.orange.shade100,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                'Today',
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.orange.shade800,
                                ),
                              ),
                            )
                          else if (isUpcoming)
                            Container(
                              padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: Colors.green.shade100,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                'Upcoming',
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.green.shade800,
                                ),
                              ),
                            ),
                        ],
                      ),
                      SizedBox(height: 4),
                      Text(
                        _getRestrictionDisplayName(override.restriction),
                        style: TextStyle(
                          fontSize: 14,
                          color: _getRestrictionColor(override.restriction),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                
                // Action Menu
                PopupMenuButton<String>(
                  onSelected: (value) => _handleOverrideAction(value, override),
                  itemBuilder: (context) => [
                    PopupMenuItem(
                      value: 'edit',
                      child: Row(
                        children: [
                          Icon(Icons.edit, size: 20),
                          SizedBox(width: 8),
                          Text('Edit'),
                        ],
                      ),
                    ),
                    PopupMenuItem(
                      value: 'delete',
                      child: Row(
                        children: [
                          Icon(Icons.delete, size: 20, color: Colors.red),
                          SizedBox(width: 8),
                          Text('Delete', style: TextStyle(color: Colors.red)),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
            
            SizedBox(height: 12),
            
            // Reason
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Reason:',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                      color: Colors.grey.shade600,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    override.reason,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade800,
                    ),
                  ),
                ],
              ),
            ),
            
            // Notes (if available)
            if (override.notes != null && override.notes!.isNotEmpty) ...[
              SizedBox(height: 8),
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Notes:',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                        color: Colors.blue.shade600,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      override.notes!,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.blue.shade800,
                      ),
                    ),
                  ],
                ),
              ),
            ],
            
            // Metadata
            SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.access_time, size: 14, color: Colors.grey.shade500),
                SizedBox(width: 4),
                Text(
                  'Created ${_getRelativeTime(override.createdAt)}',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade500,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  List<ManualOverride> _getFilteredOverrides(List<ManualOverride> overrides) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    
    List<ManualOverride> filtered;
    
    switch (_filter) {
      case 'future':
        filtered = overrides.where((override) => override.date.isAfter(today)).toList();
        break;
      case 'past':
        filtered = overrides.where((override) => override.date.isBefore(today)).toList();
        break;
      default:
        filtered = overrides;
    }
    
    // Sort by date (most recent first)
    filtered.sort((a, b) => b.date.compareTo(a.date));
    return filtered;
  }

  bool _isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
           date1.month == date2.month &&
           date1.day == date2.day;
  }

  Color _getRestrictionColor(RestrictionType restriction) {
    switch (restriction) {
      case RestrictionType.vegOnly:
        return Colors.red;
      case RestrictionType.nonVegAllowed:
        return Colors.green;
      case RestrictionType.conditional:
        return Colors.orange;
    }
  }

  String _getRestrictionIcon(RestrictionType restriction) {
    switch (restriction) {
      case RestrictionType.vegOnly:
        return '❌';
      case RestrictionType.nonVegAllowed:
        return '✅';
      case RestrictionType.conditional:
        return '⚠️';
    }
  }

  String _getRestrictionDisplayName(RestrictionType restriction) {
    switch (restriction) {
      case RestrictionType.vegOnly:
        return 'Vegetarian Only';
      case RestrictionType.nonVegAllowed:
        return 'Non-Vegetarian Allowed';
      case RestrictionType.conditional:
        return 'Conditional';
    }
  }

  String _getRelativeTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);
    
    if (difference.inDays > 0) {
      return '${difference.inDays} day${difference.inDays == 1 ? '' : 's'} ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} hour${difference.inHours == 1 ? '' : 's'} ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} minute${difference.inMinutes == 1 ? '' : 's'} ago';
    } else {
      return 'Just now';
    }
  }

  void _handleOverrideAction(String action, ManualOverride override) {
    switch (action) {
      case 'edit':
        _editOverride(override);
        break;
      case 'delete':
        _deleteOverride(override);
        break;
    }
  }

  void _editOverride(ManualOverride override) {
    final dietService = context.read<DietService>();
    final dayStatus = dietService.getDayStatus(override.date);
    
    // Show the day detail dialog which contains the override dialog
    showDialog(
      context: context,
      builder: (context) => DayDetailDialog(
        date: override.date,
        dayStatus: dayStatus,
      ),
    );
  }

  void _deleteOverride(ManualOverride override) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Delete Override'),
        content: Text(
          'Are you sure you want to delete this override for ${DateFormat('MMM d, yyyy').format(override.date)}?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              context.read<DietService>().removeManualOverride(override.id);
              
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Override deleted successfully'),
                  backgroundColor: Colors.green,
                  action: SnackBarAction(
                    label: 'Undo',
                    textColor: Colors.white,
                    onPressed: () {
                      context.read<DietService>().addManualOverride(override);
                    },
                  ),
                ),
              );
            },
            child: Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}