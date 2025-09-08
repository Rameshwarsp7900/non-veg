import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/diet_service.dart';
import '../models/user_preferences.dart';
import '../models/diet_event.dart';

class WeeklyRulesScreen extends StatefulWidget {
  @override
  _WeeklyRulesScreenState createState() => _WeeklyRulesScreenState();
}

class _WeeklyRulesScreenState extends State<WeeklyRulesScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Consumer<DietService>(
        builder: (context, dietService, child) {
          final userPreferences = dietService.userPreferences;
          
          if (userPreferences == null) {
            return _buildLoadingState();
          }
          
          return SingleChildScrollView(
            padding: EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(context),
                SizedBox(height: 20),
                _buildWeeklyRulesCard(context, userPreferences),
                SizedBox(height: 20),
                _buildQuickPresetsCard(context),
                SizedBox(height: 20),
                _buildTraditionInfoCard(context),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(),
          SizedBox(height: 16),
          Text('Loading preferences...'),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              Icons.schedule,
              color: Theme.of(context).primaryColor,
              size: 28,
            ),
            SizedBox(width: 12),
            Text(
              'Weekly Rules',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: Theme.of(context).primaryColor,
              ),
            ),
          ],
        ),
        SizedBox(height: 8),
        Text(
          'Set recurring dietary restrictions for specific days of the week',
          style: TextStyle(
            color: Colors.grey.shade600,
            fontSize: 16,
          ),
        ),
      ],
    );
  }

  Widget _buildWeeklyRulesCard(BuildContext context, UserPreferences preferences) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.edit_calendar,
                  color: Theme.of(context).primaryColor,
                ),
                SizedBox(width: 8),
                Text(
                  'Weekly Dietary Rules',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            SizedBox(height: 16),
            
            // Weekday Rules List
            ...List.generate(7, (index) {
              final weekday = index + 1; // 1 = Monday
              final existingRule = preferences.weeklyRules
                  .where((rule) => rule.weekday == weekday)
                  .firstOrNull;
              
              return _buildWeekdayRow(
                context,
                weekday,
                existingRule,
                preferences,
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildWeekdayRow(
    BuildContext context,
    int weekday,
    WeeklyRule? existingRule,
    UserPreferences preferences,
  ) {
    final weekdayName = _getWeekdayName(weekday);
    final hasRule = existingRule != null && existingRule.isActive;
    final traditionalRestriction = _getTraditionalRestriction(weekday);
    
    return Container(
      margin: EdgeInsets.only(bottom: 12),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: hasRule ? Colors.red.shade50 : Colors.green.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: hasRule ? Colors.red.shade200 : Colors.green.shade200,
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              // Weekday Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      weekdayName,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: hasRule ? Colors.red.shade800 : Colors.green.shade800,
                      ),
                    ),
                    if (traditionalRestriction != null) ..[
                      SizedBox(height: 4),
                      Text(
                        traditionalRestriction,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ],
                    if (hasRule && existingRule!.reason.isNotEmpty) ..[
                      SizedBox(height: 4),
                      Text(
                        existingRule.reason,
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.red.shade700,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              
              // Status Icon
              Container(
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: hasRule ? Colors.red.shade100 : Colors.green.shade100,
                  shape: BoxShape.circle,
                ),
                child: Text(
                  hasRule ? '❌' : '✅',
                  style: TextStyle(fontSize: 16),
                ),
              ),
              
              SizedBox(width: 12),
              
              // Toggle Switch
              Switch(
                value: hasRule,
                onChanged: (value) => _toggleWeekdayRule(
                  context,
                  weekday,
                  value,
                  preferences,
                ),
                activeColor: Colors.red.shade600,
                inactiveTrackColor: Colors.green.shade200,
              ),
            ],
          ),
          
          // Edit Button for Active Rules
          if (hasRule) ..[
            SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _editWeekdayRule(
                      context,
                      weekday,
                      existingRule!,
                      preferences,
                    ),
                    icon: Icon(Icons.edit, size: 16),
                    label: Text('Edit Rule'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.red.shade700,
                      side: BorderSide(color: Colors.red.shade300),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildQuickPresetsCard(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.speed,
                  color: Theme.of(context).primaryColor,
                ),
                SizedBox(width: 8),
                Text(
                  'Quick Presets',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            SizedBox(height: 16),
            
            GridView.count(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              childAspectRatio: 3,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              children: [
                _buildPresetButton(
                  context,
                  'Traditional',
                  'Tue & Sat',
                  Icons.temple_hindu,
                  () => _applyTraditionalPreset(context),
                ),
                _buildPresetButton(
                  context,
                  'Strict',
                  'Mon, Tue, Thu, Sat',
                  Icons.block,
                  () => _applyStrictPreset(context),
                ),
                _buildPresetButton(
                  context,
                  'Minimal',
                  'Sat only',
                  Icons.minimize,
                  () => _applyMinimalPreset(context),
                ),
                _buildPresetButton(
                  context,
                  'Clear All',
                  'No restrictions',
                  Icons.clear_all,
                  () => _clearAllRules(context),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPresetButton(
    BuildContext context,
    String title,
    String subtitle,
    IconData icon,
    VoidCallback onPressed,
  ) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.grey.shade100,
        foregroundColor: Colors.grey.shade800,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 20),
          SizedBox(height: 4),
          Text(
            title,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
          Text(
            subtitle,
            style: TextStyle(
              fontSize: 10,
              color: Colors.grey.shade600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTraditionInfoCard(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Colors.orange.shade50, Colors.orange.shade100],
          ),
          borderRadius: BorderRadius.circular(16),
        ),
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.info_outline,
                  color: Colors.orange.shade700,
                ),
                SizedBox(width: 8),
                Text(
                  'Traditional Hindu Dietary Practices',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: Colors.orange.shade800,
                  ),
                ),
              ],
            ),
            SizedBox(height: 12),
            
            _buildTraditionItem(
              'Tuesday & Saturday',
              'Sacred to Lord Hanuman - traditional fasting days',
              Colors.orange.shade700,
            ),
            SizedBox(height: 8),
            _buildTraditionItem(
              'Monday',
              'Sacred to Lord Shiva in many regions',
              Colors.orange.shade700,
            ),
            SizedBox(height: 8),
            _buildTraditionItem(
              'Thursday',
              'Guru\'s day (Brihaspati) - some observe fasting',
              Colors.orange.shade700,
            ),
            
            SizedBox(height: 12),
            Text(
              'These are traditional practices. Choose what works for your family.',
              style: TextStyle(
                fontSize: 12,
                color: Colors.orange.shade600,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTraditionItem(String day, String description, Color color) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 6,
          height: 6,
          margin: EdgeInsets.only(top: 6),
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        SizedBox(width: 8),
        Expanded(
          child: RichText(
            text: TextSpan(
              children: [
                TextSpan(
                  text: '$day: ',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: color,
                    fontSize: 14,
                  ),
                ),
                TextSpan(
                  text: description,
                  style: TextStyle(
                    color: color,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  String _getWeekdayName(int weekday) {
    const weekdays = [
      'Monday', 'Tuesday', 'Wednesday', 'Thursday',
      'Friday', 'Saturday', 'Sunday'
    ];
    return weekdays[weekday - 1];
  }

  String? _getTraditionalRestriction(int weekday) {
    switch (weekday) {
      case 1: // Monday
        return 'Lord Shiva\'s day';
      case 2: // Tuesday
        return 'Hanuman\'s day (traditional)';
      case 4: // Thursday
        return 'Guru\'s day (Brihaspati)';
      case 6: // Saturday
        return 'Hanuman\'s day (traditional)';
      default:
        return null;
    }
  }

  void _toggleWeekdayRule(
    BuildContext context,
    int weekday,
    bool isActive,
    UserPreferences preferences,
  ) {
    if (isActive) {
      _addWeekdayRule(context, weekday, preferences);
    } else {
      _removeWeekdayRule(context, weekday, preferences);
    }
  }

  void _addWeekdayRule(
    BuildContext context,
    int weekday,
    UserPreferences preferences,
  ) {
    final weekdayName = _getWeekdayName(weekday);
    final defaultReason = _getDefaultReason(weekday);
    
    final newRule = WeeklyRule(
      weekday: weekday,
      restriction: RestrictionType.vegOnly,
      reason: defaultReason,
      isActive: true,
    );
    
    final updatedRules = List<WeeklyRule>.from(preferences.weeklyRules)
      ..removeWhere((rule) => rule.weekday == weekday)
      ..add(newRule);
    
    final updatedPreferences = preferences.copyWith(weeklyRules: updatedRules);
    
    context.read<DietService>().updateUserPreferences(updatedPreferences);
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$weekdayName rule added'),
        backgroundColor: Colors.red.shade600,
      ),
    );
  }

  void _removeWeekdayRule(
    BuildContext context,
    int weekday,
    UserPreferences preferences,
  ) {
    final weekdayName = _getWeekdayName(weekday);
    
    final updatedRules = preferences.weeklyRules
        .where((rule) => rule.weekday != weekday)
        .toList();
    
    final updatedPreferences = preferences.copyWith(weeklyRules: updatedRules);
    
    context.read<DietService>().updateUserPreferences(updatedPreferences);
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$weekdayName rule removed'),
        backgroundColor: Colors.green.shade600,
      ),
    );
  }

  void _editWeekdayRule(
    BuildContext context,
    int weekday,
    WeeklyRule existingRule,
    UserPreferences preferences,
  ) {
    showDialog(
      context: context,
      builder: (context) => _WeeklyRuleEditDialog(
        weekday: weekday,
        existingRule: existingRule,
        onSave: (updatedRule) {
          final updatedRules = List<WeeklyRule>.from(preferences.weeklyRules)
            ..removeWhere((rule) => rule.weekday == weekday)
            ..add(updatedRule);
          
          final updatedPreferences = preferences.copyWith(weeklyRules: updatedRules);
          context.read<DietService>().updateUserPreferences(updatedPreferences);
        },
      ),
    );
  }

  String _getDefaultReason(int weekday) {
    switch (weekday) {
      case 1: // Monday
        return 'Monday - Lord Shiva\'s day';
      case 2: // Tuesday
        return 'Tuesday - Hanuman\'s day (traditional restriction)';
      case 4: // Thursday
        return 'Thursday - Guru\'s day (Brihaspati)';
      case 6: // Saturday
        return 'Saturday - Hanuman\'s day (traditional restriction)';
      default:
        return '${_getWeekdayName(weekday)} - Personal dietary restriction';
    }
  }

  void _applyTraditionalPreset(BuildContext context) {
    _showPresetConfirmation(
      context,
      'Traditional Preset',
      'This will set vegetarian-only rules for Tuesday and Saturday (Hanuman\'s days).',
      () {
        final preferences = context.read<DietService>().userPreferences!;
        final traditionalRules = [
          WeeklyRule(
            weekday: 2,
            restriction: RestrictionType.vegOnly,
            reason: 'Tuesday - Hanuman\'s day (traditional restriction)',
          ),
          WeeklyRule(
            weekday: 6,
            restriction: RestrictionType.vegOnly,
            reason: 'Saturday - Hanuman\'s day (traditional restriction)',
          ),
        ];
        
        final updatedPreferences = preferences.copyWith(weeklyRules: traditionalRules);
        context.read<DietService>().updateUserPreferences(updatedPreferences);
      },
    );
  }

  void _applyStrictPreset(BuildContext context) {
    _showPresetConfirmation(
      context,
      'Strict Preset',
      'This will set vegetarian-only rules for Monday, Tuesday, Thursday, and Saturday.',
      () {
        final preferences = context.read<DietService>().userPreferences!;
        final strictRules = [
          WeeklyRule(
            weekday: 1,
            restriction: RestrictionType.vegOnly,
            reason: 'Monday - Lord Shiva\'s day',
          ),
          WeeklyRule(
            weekday: 2,
            restriction: RestrictionType.vegOnly,
            reason: 'Tuesday - Hanuman\'s day',
          ),
          WeeklyRule(
            weekday: 4,
            restriction: RestrictionType.vegOnly,
            reason: 'Thursday - Guru\'s day (Brihaspati)',
          ),
          WeeklyRule(
            weekday: 6,
            restriction: RestrictionType.vegOnly,
            reason: 'Saturday - Hanuman\'s day',
          ),
        ];
        
        final updatedPreferences = preferences.copyWith(weeklyRules: strictRules);
        context.read<DietService>().updateUserPreferences(updatedPreferences);
      },
    );
  }

  void _applyMinimalPreset(BuildContext context) {
    _showPresetConfirmation(
      context,
      'Minimal Preset',
      'This will set vegetarian-only rule for Saturday only.',
      () {
        final preferences = context.read<DietService>().userPreferences!;
        final minimalRules = [
          WeeklyRule(
            weekday: 6,
            restriction: RestrictionType.vegOnly,
            reason: 'Saturday - Hanuman\'s day',
          ),
        ];
        
        final updatedPreferences = preferences.copyWith(weeklyRules: minimalRules);
        context.read<DietService>().updateUserPreferences(updatedPreferences);
      },
    );
  }

  void _clearAllRules(BuildContext context) {
    _showPresetConfirmation(
      context,
      'Clear All Rules',
      'This will remove all weekly dietary restrictions.',
      () {
        final preferences = context.read<DietService>().userPreferences!;
        final updatedPreferences = preferences.copyWith(weeklyRules: []);
        context.read<DietService>().updateUserPreferences(updatedPreferences);
      },
    );
  }

  void _showPresetConfirmation(
    BuildContext context,
    String title,
    String message,
    VoidCallback onConfirm,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              onConfirm();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Weekly rules updated'),
                  backgroundColor: Colors.green,
                ),
              );
            },
            child: Text('Apply'),
          ),
        ],
      ),
    );
  }
}

class _WeeklyRuleEditDialog extends StatefulWidget {
  final int weekday;
  final WeeklyRule existingRule;
  final Function(WeeklyRule) onSave;

  const _WeeklyRuleEditDialog({
    Key? key,
    required this.weekday,
    required this.existingRule,
    required this.onSave,
  }) : super(key: key);

  @override
  _WeeklyRuleEditDialogState createState() => _WeeklyRuleEditDialogState();
}

class _WeeklyRuleEditDialogState extends State<_WeeklyRuleEditDialog> {
  late TextEditingController _reasonController;
  late RestrictionType _selectedRestriction;

  @override
  void initState() {
    super.initState();
    _reasonController = TextEditingController(text: widget.existingRule.reason);
    _selectedRestriction = widget.existingRule.restriction;
  }

  @override
  void dispose() {
    _reasonController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final weekdayName = _getWeekdayName(widget.weekday);
    
    return AlertDialog(
      title: Text('Edit $weekdayName Rule'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Restriction Type
          Text(
            'Restriction Type',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 8),
          ...RestrictionType.values.map((restriction) {
            return RadioListTile<RestrictionType>(
              value: restriction,
              groupValue: _selectedRestriction,
              onChanged: (value) {
                setState(() {
                  _selectedRestriction = value!;
                });
              },
              title: Text(_getRestrictionName(restriction)),
              dense: true,
            );
          }).toList(),
          
          SizedBox(height: 16),
          
          // Reason
          TextField(
            controller: _reasonController,
            decoration: InputDecoration(
              labelText: 'Reason',
              hintText: 'Why this restriction applies',
              border: OutlineInputBorder(),
            ),
            maxLines: 2,
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            final updatedRule = WeeklyRule(
              weekday: widget.weekday,
              restriction: _selectedRestriction,
              reason: _reasonController.text.trim(),
              isActive: true,
            );
            
            widget.onSave(updatedRule);
            Navigator.of(context).pop();
            
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('$weekdayName rule updated'),
                backgroundColor: Colors.green,
              ),
            );
          },
          child: Text('Save'),
        ),
      ],
    );
  }

  String _getWeekdayName(int weekday) {
    const weekdays = [
      'Monday', 'Tuesday', 'Wednesday', 'Thursday',
      'Friday', 'Saturday', 'Sunday'
    ];
    return weekdays[weekday - 1];
  }

  String _getRestrictionName(RestrictionType restriction) {
    switch (restriction) {
      case RestrictionType.vegOnly:
        return 'Vegetarian Only';
      case RestrictionType.nonVegAllowed:
        return 'Non-Veg Allowed';
      case RestrictionType.conditional:
        return 'Conditional';
    }
  }
}

// Extension for nullable firstOrNull
extension IterableExtension<T> on Iterable<T> {
  T? get firstOrNull => isEmpty ? null : first;
}