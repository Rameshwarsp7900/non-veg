import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../services/diet_service.dart';
import '../models/diet_event.dart';
import '../widgets/event_form_dialog.dart';

class EventManagerScreen extends StatefulWidget {
  final bool showAddForm;

  const EventManagerScreen({Key? key, this.showAddForm = false}) : super(key: key);

  @override
  _EventManagerScreenState createState() => _EventManagerScreenState();
}

class _EventManagerScreenState extends State<EventManagerScreen> with TickerProviderStateMixin {
  late TabController _tabController;
  String _searchQuery = '';
  EventCategory? _filterCategory;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    
    // Show add form if requested
    if (widget.showAddForm) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _showAddEventDialog(context);
      });
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Consumer<DietService>(
        builder: (context, dietService, child) {
          return Column(
            children: [
              // Search and Filter Bar
              _buildSearchAndFilter(context),
              
              // Tab Bar
              _buildTabBar(context),
              
              // Tab Content
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    _buildAllEventsTab(dietService),
                    _buildFestivalsTab(dietService),
                    _buildPersonalEventsTab(dietService),
                    _buildFamilyEventsTab(dietService),
                  ],
                ),
              ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddEventDialog(context),
        backgroundColor: Theme.of(context).primaryColor,
        child: Icon(Icons.add, color: Colors.white),
        tooltip: 'Add New Event',
      ),
    );
  }

  Widget _buildSearchAndFilter(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade200,
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Search Bar
          TextField(
            onChanged: (value) {
              setState(() {
                _searchQuery = value;
              });
            },
            decoration: InputDecoration(
              hintText: 'Search events...',
              prefixIcon: Icon(Icons.search),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
              filled: true,
              fillColor: Colors.grey.shade50,
            ),
          ),
          
          SizedBox(height: 12),
          
          // Filter Chips
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildFilterChip('All', null),
                SizedBox(width: 8),
                _buildFilterChip('Festivals', EventCategory.festival),
                SizedBox(width: 8),
                _buildFilterChip('Eclipses', EventCategory.eclipse),
                SizedBox(width: 8),
                _buildFilterChip('Personal', EventCategory.personal),
                SizedBox(width: 8),
                _buildFilterChip('Family', EventCategory.family),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, EventCategory? category) {
    final isSelected = _filterCategory == category;
    
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        setState(() {
          _filterCategory = selected ? category : null;
        });
      },
      backgroundColor: Colors.grey.shade100,
      selectedColor: Theme.of(context).primaryColor.withOpacity(0.2),
      checkmarkColor: Theme.of(context).primaryColor,
    );
  }

  Widget _buildTabBar(BuildContext context) {
    return Container(
      color: Colors.white,
      child: TabBar(
        controller: _tabController,
        tabs: [
          Tab(text: 'All Events', icon: Icon(Icons.event)),
          Tab(text: 'Festivals', icon: Icon(Icons.celebration)),
          Tab(text: 'Personal', icon: Icon(Icons.person)),
          Tab(text: 'Family', icon: Icon(Icons.family_restroom)),
        ],
        labelColor: Theme.of(context).primaryColor,
        unselectedLabelColor: Colors.grey,
        indicatorColor: Theme.of(context).primaryColor,
      ),
    );
  }

  Widget _buildAllEventsTab(DietService dietService) {
    final filteredEvents = _getFilteredEvents(dietService.events);
    
    if (filteredEvents.isEmpty) {
      return _buildEmptyState('No events found', 'Try adjusting your search or filters');
    }
    
    return _buildEventsList(filteredEvents);
  }

  Widget _buildFestivalsTab(DietService dietService) {
    final festivals = dietService.events
        .where((event) => event.category == EventCategory.festival)
        .toList();
    final filteredFestivals = _getFilteredEvents(festivals);
    
    if (filteredFestivals.isEmpty) {
      return _buildEmptyState('No festivals found', 'Add your first festival event');
    }
    
    return _buildEventsList(filteredFestivals);
  }

  Widget _buildPersonalEventsTab(DietService dietService) {
    final personalEvents = dietService.events
        .where((event) => event.category == EventCategory.personal)
        .toList();
    final filteredPersonal = _getFilteredEvents(personalEvents);
    
    if (filteredPersonal.isEmpty) {
      return _buildEmptyState('No personal events', 'Add personal dietary events like birthdays or special occasions');
    }
    
    return _buildEventsList(filteredPersonal);
  }

  Widget _buildFamilyEventsTab(DietService dietService) {
    final familyEvents = dietService.events
        .where((event) => event.category == EventCategory.family)
        .toList();
    final filteredFamily = _getFilteredEvents(familyEvents);
    
    if (filteredFamily.isEmpty) {
      return _buildEmptyState('No family rules', 'Family members can add shared dietary rules here');
    }
    
    return _buildEventsList(filteredFamily);
  }

  Widget _buildEmptyState(String title, String subtitle) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.event_busy,
            size: 64,
            color: Colors.grey.shade400,
          ),
          SizedBox(height: 16),
          Text(
            title,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: Colors.grey.shade600,
            ),
          ),
          SizedBox(height: 8),
          Text(
            subtitle,
            style: TextStyle(color: Colors.grey.shade500),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 24),
          ElevatedButton(
            onPressed: () => _showAddEventDialog(context),
            child: Text('Add Event'),
          ),
        ],
      ),
    );
  }

  Widget _buildEventsList(List<DietEvent> events) {
    // Sort events by date
    final sortedEvents = List<DietEvent>.from(events)
      ..sort((a, b) => a.date.compareTo(b.date));
    
    return ListView.builder(
      padding: EdgeInsets.all(16),
      itemCount: sortedEvents.length,
      itemBuilder: (context, index) {
        final event = sortedEvents[index];
        return _buildEventCard(event);
      },
    );
  }

  Widget _buildEventCard(DietEvent event) {
    final isUpcoming = event.date.isAfter(DateTime.now());
    final isPast = event.date.isBefore(DateTime.now().subtract(Duration(days: 1)));
    
    return Card(
      margin: EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: () => _showEventDetails(event),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  // Event Icon
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: _getEventColor(event.restriction).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: _getEventColor(event.restriction),
                        width: 2,
                      ),
                    ),
                    child: Center(
                      child: Text(
                        event.iconText,
                        style: TextStyle(fontSize: 20),
                      ),
                    ),
                  ),
                  
                  SizedBox(width: 12),
                  
                  // Event Details
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                event.name,
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                  color: isPast ? Colors.grey.shade600 : Colors.black87,
                                ),
                              ),
                            ),
                            if (isUpcoming)
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
                          DateFormat('EEEE, MMM d, yyyy').format(event.date),
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey.shade600,
                          ),
                        ),
                        if (event.description != null && event.description!.isNotEmpty) ..[
                          SizedBox(height: 4),
                          Text(
                            event.description!,
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.grey.shade500,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ],
                    ),
                  ),
                  
                  // Action Menu
                  PopupMenuButton<String>(
                    onSelected: (value) => _handleEventAction(value, event),
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
                        value: 'duplicate',
                        child: Row(
                          children: [
                            Icon(Icons.copy, size: 20),
                            SizedBox(width: 8),
                            Text('Duplicate'),
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
              
              // Event Tags
              Row(
                children: [
                  _buildEventTag(event.category.name.toUpperCase(), _getCategoryColor(event.category)),
                  SizedBox(width: 8),
                  _buildEventTag(_getRestrictionText(event.restriction), _getEventColor(event.restriction)),
                  if (event.createdBy != null) ..[
                    SizedBox(width: 8),
                    _buildEventTag('BY ${event.createdBy!.toUpperCase()}', Colors.purple),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEventTag(String text, Color color) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }

  List<DietEvent> _getFilteredEvents(List<DietEvent> events) {
    List<DietEvent> filtered = events;
    
    // Apply search filter
    if (_searchQuery.isNotEmpty) {
      filtered = filtered.where((event) {
        return event.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
               (event.description?.toLowerCase().contains(_searchQuery.toLowerCase()) ?? false);
      }).toList();
    }
    
    // Apply category filter
    if (_filterCategory != null) {
      filtered = filtered.where((event) => event.category == _filterCategory).toList();
    }
    
    return filtered;
  }

  Color _getEventColor(RestrictionType restriction) {
    switch (restriction) {
      case RestrictionType.vegOnly:
        return Colors.red;
      case RestrictionType.nonVegAllowed:
        return Colors.green;
      case RestrictionType.conditional:
        return Colors.orange;
    }
  }

  Color _getCategoryColor(EventCategory category) {
    switch (category) {
      case EventCategory.festival:
        return Colors.purple;
      case EventCategory.eclipse:
        return Colors.indigo;
      case EventCategory.holiday:
        return Colors.blue;
      case EventCategory.personal:
        return Colors.teal;
      case EventCategory.weekly:
        return Colors.cyan;
      case EventCategory.family:
        return Colors.pink;
    }
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

  void _showAddEventDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => EventFormDialog(),
    );
  }

  void _showEventDetails(DietEvent event) {
    showDialog(
      context: context,
      builder: (context) => EventFormDialog(eventToEdit: event, isReadOnly: true),
    );
  }

  void _handleEventAction(String action, DietEvent event) {
    switch (action) {
      case 'edit':
        showDialog(
          context: context,
          builder: (context) => EventFormDialog(eventToEdit: event),
        );
        break;
      case 'duplicate':
        final duplicatedEvent = event.copyWith(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          name: '${event.name} (Copy)',
        );
        showDialog(
          context: context,
          builder: (context) => EventFormDialog(eventToEdit: duplicatedEvent),
        );
        break;
      case 'delete':
        _showDeleteConfirmation(event);
        break;
    }
  }

  void _showDeleteConfirmation(DietEvent event) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Delete Event'),
        content: Text('Are you sure you want to delete "${event.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              context.read<DietService>().deleteEvent(event.id);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Event deleted successfully'),
                  backgroundColor: Colors.green,
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