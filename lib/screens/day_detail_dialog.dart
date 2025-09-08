import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../models/day_status.dart';
import '../models/diet_event.dart';
import '../services/diet_service.dart';

class DayDetailDialog extends StatelessWidget {
  final DateTime date;
  final DayStatus dayStatus;

  const DayDetailDialog({
    Key? key,
    required this.date,
    required this.dayStatus,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                gradient: _getGradientForStatus(dayStatus.restriction),
                borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
              ),
              padding: EdgeInsets.all(20),
              child: Column(
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
                              DateFormat('EEEE, MMMM d, yyyy').format(date),
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
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
                      IconButton(
                        onPressed: () => Navigator.of(context).pop(),
                        icon: Icon(Icons.close, color: Colors.white),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            
            // Content
            Flexible(
              child: SingleChildScrollView(
                padding: EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Restriction Reason
                    _buildSectionTitle(context, 'Reason'),
                    _buildReasonCard(context),
                    
                    if (dayStatus.events.isNotEmpty) ...[
                      SizedBox(height: 20),
                      _buildSectionTitle(context, 'Special Events'),
                      ...dayStatus.events.map((event) => _buildEventCard(context, event)),
                    ],
                    
                    if (dayStatus.userNotes != null && dayStatus.userNotes!.isNotEmpty) ...[
                      SizedBox(height: 20),
                      _buildSectionTitle(context, 'Personal Notes'),
                      _buildNotesCard(context),
                    ],
                    
                    SizedBox(height: 20),
                    _buildFoodGuidelines(context),
                    
                    SizedBox(height: 20),
                    _buildActionButtons(context),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    return Padding(
      padding: EdgeInsets.only(bottom: 8),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
          fontWeight: FontWeight.bold,
          color: Colors.grey.shade700,
        ),
      ),
    );
  }

  Widget _buildReasonCard(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Text(
        dayStatus.reason,
        style: TextStyle(
          fontSize: 14,
          color: Colors.grey.shade700,
          height: 1.4,
        ),
      ),
    );
  }

  Widget _buildEventCard(BuildContext context, DietEvent event) {
    return Container(
      margin: EdgeInsets.only(bottom: 8),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _getEventBackgroundColor(event.restriction),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _getEventBorderColor(event.restriction)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                event.iconText,
                style: TextStyle(fontSize: 20),
              ),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  event.name,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: _getEventTextColor(event.restriction),
                  ),
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: _getEventBorderColor(event.restriction),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  event.category.name.toUpperCase(),
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
          if (event.description != null && event.description!.isNotEmpty) ...[
            SizedBox(height: 8),
            Text(
              event.description!,
              style: TextStyle(
                fontSize: 14,
                color: _getEventTextColor(event.restriction).withOpacity(0.8),
              ),
            ),
          ],
          if (event.reason != null && event.reason!.isNotEmpty) ...[
            SizedBox(height: 8),
            Text(
              event.reason!,
              style: TextStyle(
                fontSize: 13,
                color: _getEventTextColor(event.restriction).withOpacity(0.7),
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildNotesCard(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blue.shade200),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.note, color: Colors.blue.shade600, size: 20),
          SizedBox(width: 8),
          Expanded(
            child: Text(
              dayStatus.userNotes!,
              style: TextStyle(
                fontSize: 14,
                color: Colors.blue.shade800,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFoodGuidelines(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle(context, 'Food Guidelines'),
        Container(
          width: double.infinity,
          padding: EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: _getGuidelineBackgroundColor(),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: _getGuidelineBorderColor()),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    _getGuidelineIcon(),
                    color: _getGuidelineIconColor(),
                    size: 20,
                  ),
                  SizedBox(width: 8),
                  Text(
                    _getGuidelineTitle(),
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: _getGuidelineTextColor(),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 8),
              Text(
                _getGuidelineText(),
                style: TextStyle(
                  fontSize: 14,
                  color: _getGuidelineTextColor().withOpacity(0.8),
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: () {
              Navigator.of(context).pop();
              _addPersonalOverride(context);
            },
            style: OutlinedButton.styleFrom(
              foregroundColor: Theme.of(context).primaryColor,
              side: BorderSide(color: Theme.of(context).primaryColor),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: Text('Add Override'),
          ),
        ),
        SizedBox(width: 12),
        Expanded(
          child: ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              _askAssistant(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).primaryColor,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: Text('Ask Assistant'),
          ),
        ),
      ],
    );
  }

  // Helper methods for styling
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
        return Colors.red.shade300;
      case RestrictionType.nonVegAllowed:
        return Colors.green.shade300;
      case RestrictionType.conditional:
        return Colors.orange.shade300;
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

  Color _getGuidelineBackgroundColor() {
    switch (dayStatus.restriction) {
      case RestrictionType.vegOnly:
        return Colors.red.shade50;
      case RestrictionType.nonVegAllowed:
        return Colors.green.shade50;
      case RestrictionType.conditional:
        return Colors.orange.shade50;
    }
  }

  Color _getGuidelineBorderColor() {
    switch (dayStatus.restriction) {
      case RestrictionType.vegOnly:
        return Colors.red.shade200;
      case RestrictionType.nonVegAllowed:
        return Colors.green.shade200;
      case RestrictionType.conditional:
        return Colors.orange.shade200;
    }
  }

  Color _getGuidelineTextColor() {
    switch (dayStatus.restriction) {
      case RestrictionType.vegOnly:
        return Colors.red.shade800;
      case RestrictionType.nonVegAllowed:
        return Colors.green.shade800;
      case RestrictionType.conditional:
        return Colors.orange.shade800;
    }
  }

  Color _getGuidelineIconColor() {
    switch (dayStatus.restriction) {
      case RestrictionType.vegOnly:
        return Colors.red.shade600;
      case RestrictionType.nonVegAllowed:
        return Colors.green.shade600;
      case RestrictionType.conditional:
        return Colors.orange.shade600;
    }
  }

  IconData _getGuidelineIcon() {
    switch (dayStatus.restriction) {
      case RestrictionType.vegOnly:
        return Icons.block;
      case RestrictionType.nonVegAllowed:
        return Icons.check_circle;
      case RestrictionType.conditional:
        return Icons.help_outline;
    }
  }

  String _getGuidelineTitle() {
    switch (dayStatus.restriction) {
      case RestrictionType.vegOnly:
        return 'Vegetarian Food Only';
      case RestrictionType.nonVegAllowed:
        return 'All Food Types Allowed';
      case RestrictionType.conditional:
        return 'Conditional Restrictions';
    }
  }

  String _getGuidelineText() {
    switch (dayStatus.restriction) {
      case RestrictionType.vegOnly:
        return 'Today you should consume only vegetarian food. Avoid all meat, fish, and egg products. Focus on sattvic foods like fruits, vegetables, grains, and dairy products.';
      case RestrictionType.nonVegAllowed:
        return 'Today there are no dietary restrictions. You can enjoy both vegetarian and non-vegetarian foods according to your preference.';
      case RestrictionType.conditional:
        return 'Today has special conditions. Some non-vegetarian foods might be restricted while others are allowed. Check specific event guidelines for details.';
    }
  }

  void _addPersonalOverride(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => _ManualOverrideDialog(
        date: date,
        existingStatus: dayStatus,
      ),
    );
  }

  void _askAssistant(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Ask Assistant functionality will be implemented'),
        backgroundColor: Colors.green,
      ),
    );
  }
}

class _ManualOverrideDialog extends StatefulWidget {
  final DateTime date;
  final DayStatus existingStatus;

  const _ManualOverrideDialog({
    Key? key,
    required this.date,
    required this.existingStatus,
  }) : super(key: key);

  @override
  _ManualOverrideDialogState createState() => _ManualOverrideDialogState();
}

class _ManualOverrideDialogState extends State<_ManualOverrideDialog> {
  final _formKey = GlobalKey<FormState>();
  final _reasonController = TextEditingController();
  final _notesController = TextEditingController();
  
  late RestrictionType _selectedRestriction;

  @override
  void initState() {
    super.initState();
    _selectedRestriction = widget.existingStatus.restriction;
    
    // Pre-fill with existing user notes if available
    if (widget.existingStatus.userNotes != null) {
      _notesController.text = widget.existingStatus.userNotes!;
    }
  }

  @override
  void dispose() {
    _reasonController.dispose();
    _notesController.dispose();
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
          maxHeight: MediaQuery.of(context).size.height * 0.8,
          maxWidth: MediaQuery.of(context).size.width * 0.9,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            _buildOverrideHeader(context),
            
            // Form Content
            Flexible(
              child: SingleChildScrollView(
                padding: EdgeInsets.all(20),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Current Status Info
                      _buildCurrentStatusInfo(),
                      
                      SizedBox(height: 20),
                      
                      // New Restriction Selection
                      _buildRestrictionSelector(),
                      
                      SizedBox(height: 16),
                      
                      // Reason Field
                      _buildReasonField(),
                      
                      SizedBox(height: 16),
                      
                      // Notes Field
                      _buildNotesField(),
                      
                      SizedBox(height: 16),
                      
                      // Quick Reason Suggestions
                      _buildQuickReasons(),
                    ],
                  ),
                ),
              ),
            ),
            
            // Action Buttons
            _buildOverrideActionButtons(context),
          ],
        ),
      ),
    );
  }

  Widget _buildOverrideHeader(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.blue.shade600,
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      padding: EdgeInsets.all(20),
      child: Row(
        children: [
          Icon(
            Icons.edit,
            color: Colors.white,
            size: 24,
          ),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Personal Override',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  DateFormat('EEEE, MMM d, yyyy').format(widget.date),
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.8),
                    fontSize: 14,
                  ),
                ),
              ],
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

  Widget _buildCurrentStatusInfo() {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.info_outline, color: Colors.grey.shade600),
              SizedBox(width: 8),
              Text(
                'Current Status',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.grey.shade700,
                ),
              ),
            ],
          ),
          SizedBox(height: 8),
          Row(
            children: [
              Text(
                widget.existingStatus.iconText,
                style: TextStyle(fontSize: 20),
              ),
              SizedBox(width: 8),
              Text(
                widget.existingStatus.statusText,
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                ),
              ),
            ],
          ),
          SizedBox(height: 4),
          Text(
            widget.existingStatus.reason,
            style: TextStyle(
              color: Colors.grey.shade600,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRestrictionSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Override with:',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
            color: Colors.grey.shade700,
          ),
        ),
        SizedBox(height: 12),
        ...RestrictionType.values.map((restriction) {
          return Container(
            margin: EdgeInsets.only(bottom: 8),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: _selectedRestriction == restriction 
                    ? Theme.of(context).primaryColor 
                    : Colors.grey.shade300,
                width: 2,
              ),
              color: _selectedRestriction == restriction 
                  ? Theme.of(context).primaryColor.withOpacity(0.1)
                  : Colors.white,
            ),
            child: RadioListTile<RestrictionType>(
              value: restriction,
              groupValue: _selectedRestriction,
              onChanged: (value) {
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
                  Text(
                    _getRestrictionDisplayName(restriction),
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                ],
              ),
              subtitle: Text(_getRestrictionDescription(restriction)),
              activeColor: Theme.of(context).primaryColor,
            ),
          );
        }).toList(),
      ],
    );
  }

  Widget _buildReasonField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Reason *',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 14,
            color: Colors.grey.shade700,
          ),
        ),
        SizedBox(height: 8),
        TextFormField(
          controller: _reasonController,
          maxLines: 2,
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'Please provide a reason for this override';
            }
            return null;
          },
          decoration: InputDecoration(
            hintText: 'e.g., Birthday celebration, Special occasion, Exam day',
            prefixIcon: Icon(Icons.edit, color: Theme.of(context).primaryColor),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Theme.of(context).primaryColor),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildNotesField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Additional Notes (Optional)',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 14,
            color: Colors.grey.shade700,
          ),
        ),
        SizedBox(height: 8),
        TextFormField(
          controller: _notesController,
          maxLines: 3,
          decoration: InputDecoration(
            hintText: 'Any additional notes or details...',
            prefixIcon: Icon(Icons.note, color: Theme.of(context).primaryColor),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Theme.of(context).primaryColor),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildQuickReasons() {
    final quickReasons = _getQuickReasons();
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Quick Reasons',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 14,
            color: Colors.grey.shade700,
          ),
        ),
        SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: quickReasons.map((reason) {
            return InkWell(
              onTap: () {
                setState(() {
                  _reasonController.text = reason;
                });
              },
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.blue.shade200),
                ),
                child: Text(
                  reason,
                  style: TextStyle(
                    color: Colors.blue.shade700,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildOverrideActionButtons(BuildContext context) {
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
              onPressed: _saveOverride,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue.shade600,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text('Save Override'),
            ),
          ),
        ],
      ),
    );
  }

  List<String> _getQuickReasons() {
    switch (_selectedRestriction) {
      case RestrictionType.nonVegAllowed:
        return [
          'Birthday celebration',
          'Special occasion',
          'Family gathering',
          'Personal choice',
          'Recovery day',
        ];
      case RestrictionType.vegOnly:
        return [
          'Exam day focus',
          'Health recovery',
          'Personal vow',
          'Spiritual practice',
          'Extra devotion',
        ];
      case RestrictionType.conditional:
        return [
          'Limited options',
          'Specific restrictions',
          'Partial observance',
          'Medical reasons',
          'Travel adjustments',
        ];
    }
  }

  void _saveOverride() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final override = ManualOverride(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      date: widget.date,
      restriction: _selectedRestriction,
      reason: _reasonController.text.trim(),
      notes: _notesController.text.trim().isEmpty 
          ? null 
          : _notesController.text.trim(),
      createdAt: DateTime.now(),
    );

    context.read<DietService>().addManualOverride(override);
    
    Navigator.of(context).pop(); // Close override dialog
    Navigator.of(context).pop(); // Close day detail dialog

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Personal override saved successfully'),
        backgroundColor: Colors.green,
        action: SnackBarAction(
          label: 'Undo',
          textColor: Colors.white,
          onPressed: () {
            context.read<DietService>().removeManualOverride(override.id);
          },
        ),
      ),
    );
  }

  // Helper methods
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
        return 'Override to vegetarian-only for this day';
      case RestrictionType.nonVegAllowed:
        return 'Allow non-vegetarian food for this day';
      case RestrictionType.conditional:
        return 'Some restrictions may apply';
    }
  }
}