import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../services/diet_service.dart';
import '../models/diet_event.dart';

class EventFormDialog extends StatefulWidget {
  final DietEvent? eventToEdit;
  final bool isReadOnly;

  const EventFormDialog({
    Key? key,
    this.eventToEdit,
    this.isReadOnly = false,
  }) : super(key: key);

  @override
  _EventFormDialogState createState() => _EventFormDialogState();
}

class _EventFormDialogState extends State<EventFormDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _reasonController = TextEditingController();

  DateTime _selectedDate = DateTime.now();
  EventCategory _selectedCategory = EventCategory.festival;
  RestrictionType _selectedRestriction = RestrictionType.vegOnly;
  bool _isRecurring = false;

  @override
  void initState() {
    super.initState();
    if (widget.eventToEdit != null) {
      _loadEventData(widget.eventToEdit!);
    }
  }

  void _loadEventData(DietEvent event) {
    _nameController.text = event.name;
    _descriptionController.text = event.description ?? '';
    _reasonController.text = event.reason ?? '';
    _selectedDate = event.date;
    _selectedCategory = event.category;
    _selectedRestriction = event.restriction;
    _isRecurring = event.isRecurring;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _reasonController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.9,
          maxWidth: MediaQuery.of(context).size.width * 0.9,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            _buildHeader(context),
            
            // Form Content
            Flexible(
              child: SingleChildScrollView(
                padding: EdgeInsets.all(20),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Event Name
                      _buildTextField(
                        controller: _nameController,
                        label: 'Event Name',
                        hint: 'e.g., Ganesh Chaturthi, Birthday',
                        icon: Icons.event,
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Please enter an event name';
                          }
                          return null;
                        },
                      ),

                      SizedBox(height: 16),

                      // Date Selection
                      _buildDateSelector(context),

                      SizedBox(height: 16),

                      // Category Selection
                      _buildCategorySelector(),

                      SizedBox(height: 16),

                      // Restriction Selection
                      _buildRestrictionSelector(),

                      SizedBox(height: 16),

                      // Description
                      _buildTextField(
                        controller: _descriptionController,
                        label: 'Description (Optional)',
                        hint: 'Brief description of the event',
                        icon: Icons.description,
                        maxLines: 3,
                      ),

                      SizedBox(height: 16),

                      // Reason
                      _buildTextField(
                        controller: _reasonController,
                        label: 'Reason (Optional)',
                        hint: 'Why this dietary restriction applies',
                        icon: Icons.info,
                        maxLines: 2,
                      ),

                      SizedBox(height: 16),

                      // Recurring Option
                      if (!widget.isReadOnly)
                        _buildRecurringOption(),
                    ],
                  ),
                ),
              ),
            ),
            
            // Action Buttons
            if (!widget.isReadOnly) _buildActionButtons(context),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final isEditing = widget.eventToEdit != null && !widget.isReadOnly;
    final title = widget.isReadOnly 
        ? 'Event Details'
        : isEditing 
            ? 'Edit Event' 
            : 'Add New Event';

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Theme.of(context).primaryColor,
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      padding: EdgeInsets.all(20),
      child: Row(
        children: [
          Icon(
            widget.isReadOnly ? Icons.visibility : Icons.edit,
            color: Colors.white,
            size: 24,
          ),
          SizedBox(width: 12),
          Expanded(
            child: Text(
              title,
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          IconButton(
            onPressed: () => Navigator.of(context).pop(),
            icon: Icon(Icons.close, color: Colors.white),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 14,
            color: Colors.grey.shade700,
          ),
        ),
        SizedBox(height: 8),
        TextFormField(
          controller: controller,
          enabled: !widget.isReadOnly,
          maxLines: maxLines,
          validator: validator,
          decoration: InputDecoration(
            hintText: hint,
            prefixIcon: Icon(icon, color: Theme.of(context).primaryColor),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Theme.of(context).primaryColor),
            ),
            filled: true,
            fillColor: widget.isReadOnly ? Colors.grey.shade100 : Colors.white,
          ),
        ),
      ],
    );
  }

  Widget _buildDateSelector(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Date',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 14,
            color: Colors.grey.shade700,
          ),
        ),
        SizedBox(height: 8),
        InkWell(
          onTap: widget.isReadOnly ? null : () => _selectDate(context),
          child: Container(
            width: double.infinity,
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade300),
              borderRadius: BorderRadius.circular(12),
              color: widget.isReadOnly ? Colors.grey.shade100 : Colors.white,
            ),
            child: Row(
              children: [
                Icon(
                  Icons.calendar_today,
                  color: Theme.of(context).primaryColor,
                ),
                SizedBox(width: 12),
                Text(
                  DateFormat('EEEE, MMMM d, yyyy').format(_selectedDate),
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.black87,
                  ),
                ),
                Spacer(),
                if (!widget.isReadOnly)
                  Icon(Icons.arrow_drop_down, color: Colors.grey),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCategorySelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Category',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 14,
            color: Colors.grey.shade700,
          ),
        ),
        SizedBox(height: 8),
        Container(
          width: double.infinity,
          padding: EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade300),
            borderRadius: BorderRadius.circular(12),
            color: widget.isReadOnly ? Colors.grey.shade100 : Colors.white,
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<EventCategory>(
              value: _selectedCategory,
              onChanged: widget.isReadOnly ? null : (value) {
                setState(() {
                  _selectedCategory = value!;
                });
              },
              items: EventCategory.values.map((category) {
                return DropdownMenuItem(
                  value: category,
                  child: Row(
                    children: [
                      Icon(
                        _getCategoryIcon(category),
                        color: _getCategoryColor(category),
                        size: 20,
                      ),
                      SizedBox(width: 8),
                      Text(_getCategoryDisplayName(category)),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildRestrictionSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Dietary Restriction',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 14,
            color: Colors.grey.shade700,
          ),
        ),
        SizedBox(height: 8),
        ...RestrictionType.values.map((restriction) {
          return RadioListTile<RestrictionType>(
            value: restriction,
            groupValue: _selectedRestriction,
            onChanged: widget.isReadOnly ? null : (value) {
              setState(() {
                _selectedRestriction = value!;
              });
            },
            title: Row(
              children: [
                Text(
                  _getRestrictionIcon(restriction),
                  style: TextStyle(fontSize: 18),
                ),
                SizedBox(width: 8),
                Text(_getRestrictionDisplayName(restriction)),
              ],
            ),
            subtitle: Text(_getRestrictionDescription(restriction)),
            activeColor: Theme.of(context).primaryColor,
            tileColor: widget.isReadOnly ? Colors.grey.shade50 : null,
          );
        }).toList(),
      ],
    );
  }

  Widget _buildRecurringOption() {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blue.shade200),
      ),
      child: Row(
        children: [
          Icon(Icons.repeat, color: Colors.blue.shade600),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Recurring Event',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: Colors.blue.shade800,
                  ),
                ),
                Text(
                  'This event will repeat annually',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.blue.shade600,
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: _isRecurring,
            onChanged: (value) {
              setState(() {
                _isRecurring = value;
              });
            },
            activeColor: Colors.blue.shade600,
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(16)),
      ),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton(
              onPressed: () => Navigator.of(context).pop(),
              style: OutlinedButton.styleFrom(
                padding: EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text('Cancel'),
            ),
          ),
          SizedBox(width: 12),
          Expanded(
            child: ElevatedButton(
              onPressed: _saveEvent,
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).primaryColor,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text(widget.eventToEdit != null ? 'Update' : 'Save'),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: Theme.of(context).primaryColor,
            ),
          ),
          child: child!,
        );
      },
    );
    
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  void _saveEvent() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final event = DietEvent(
      id: widget.eventToEdit?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
      name: _nameController.text.trim(),
      date: _selectedDate,
      category: _selectedCategory,
      restriction: _selectedRestriction,
      description: _descriptionController.text.trim().isEmpty 
          ? null 
          : _descriptionController.text.trim(),
      reason: _reasonController.text.trim().isEmpty 
          ? null 
          : _reasonController.text.trim(),
      isRecurring: _isRecurring,
      createdBy: widget.eventToEdit?.createdBy,
    );

    final dietService = context.read<DietService>();
    
    if (widget.eventToEdit != null) {
      dietService.updateEvent(event);
    } else {
      dietService.addEvent(event);
    }

    Navigator.of(context).pop();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          widget.eventToEdit != null 
              ? 'Event updated successfully' 
              : 'Event added successfully'
        ),
        backgroundColor: Colors.green,
      ),
    );
  }

  // Helper methods
  IconData _getCategoryIcon(EventCategory category) {
    switch (category) {
      case EventCategory.festival:
        return Icons.celebration;
      case EventCategory.eclipse:
        return Icons.brightness_2;
      case EventCategory.holiday:
        return Icons.holiday_village;
      case EventCategory.personal:
        return Icons.person;
      case EventCategory.weekly:
        return Icons.repeat;
      case EventCategory.family:
        return Icons.family_restroom;
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

  String _getCategoryDisplayName(EventCategory category) {
    switch (category) {
      case EventCategory.festival:
        return 'Festival';
      case EventCategory.eclipse:
        return 'Eclipse';
      case EventCategory.holiday:
        return 'Holiday';
      case EventCategory.personal:
        return 'Personal';
      case EventCategory.weekly:
        return 'Weekly';
      case EventCategory.family:
        return 'Family';
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

  String _getRestrictionDescription(RestrictionType restriction) {
    switch (restriction) {
      case RestrictionType.vegOnly:
        return 'Only vegetarian food is allowed';
      case RestrictionType.nonVegAllowed:
        return 'Both vegetarian and non-vegetarian food allowed';
      case RestrictionType.conditional:
        return 'Some restrictions may apply';
    }
  }
}