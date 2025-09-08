import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../services/diet_service.dart';
import '../models/day_status.dart';

class ChatAssistantScreen extends StatefulWidget {
  @override
  _ChatAssistantScreenState createState() => _ChatAssistantScreenState();
}

class _ChatAssistantScreenState extends State<ChatAssistantScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final List<ChatMessage> _messages = [];
  bool _isTyping = false;

  @override
  void initState() {
    super.initState();
    _addWelcomeMessage();
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _addWelcomeMessage() {
    final dietService = context.read<DietService>();
    final todayStatus = dietService.getDayStatus(DateTime.now());
    
    final welcomeText = '''
Hello! I'm your food assistant 🍽️

I can help you understand your dietary restrictions and answer food-related questions.

Today is ${todayStatus.statusText}. ${todayStatus.reason}

Try asking me:
• "Can I eat chicken today?"
• "Why can't I eat meat today?"
• "What foods are allowed today?"
• "When is my next non-veg day?"
''';

    _messages.add(ChatMessage(
      text: welcomeText,
      isUser: false,
      timestamp: DateTime.now(),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          // Header
          _buildHeader(),
          
          // Chat Messages
          Expanded(
            child: _buildMessagesList(),
          ),
          
          // Message Input
          _buildMessageInput(),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: EdgeInsets.fromLTRB(16, 16, 16, 8),
      decoration: BoxDecoration(
        color: Theme.of(context).primaryColor.withOpacity(0.1),
        border: Border(
          bottom: BorderSide(color: Colors.grey.shade200),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.restaurant,
              color: Colors.white,
              size: 20,
            ),
          ),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Food Assistant',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                Text(
                  'Ask me about your dietary restrictions',
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: _clearChat,
            icon: Icon(Icons.refresh),
            tooltip: 'Clear Chat',
          ),
        ],
      ),
    );
  }

  Widget _buildMessagesList() {
    return ListView.builder(
      controller: _scrollController,
      padding: EdgeInsets.all(16),
      itemCount: _messages.length + (_isTyping ? 1 : 0),
      itemBuilder: (context, index) {
        if (_isTyping && index == _messages.length) {
          return _buildTypingIndicator();
        }
        
        final message = _messages[index];
        return _buildMessageBubble(message);
      },
    );
  }

  Widget _buildMessageBubble(ChatMessage message) {
    return Container(
      margin: EdgeInsets.only(bottom: 16),
      child: Row(
        mainAxisAlignment: message.isUser 
            ? MainAxisAlignment.end 
            : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!message.isUser) ..[
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.restaurant,
                color: Colors.white,
                size: 16,
              ),
            ),
            SizedBox(width: 8),
          ],
          
          Flexible(
            child: Container(
              constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width * 0.7,
              ),
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: message.isUser 
                    ? Theme.of(context).primaryColor
                    : Colors.grey.shade100,
                borderRadius: BorderRadius.circular(20).copyWith(
                  bottomLeft: message.isUser ? Radius.circular(20) : Radius.circular(4),
                  bottomRight: message.isUser ? Radius.circular(4) : Radius.circular(20),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    message.text,
                    style: TextStyle(
                      color: message.isUser ? Colors.white : Colors.black87,
                      fontSize: 15,
                      height: 1.4,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    DateFormat('HH:mm').format(message.timestamp),
                    style: TextStyle(
                      color: message.isUser 
                          ? Colors.white.withOpacity(0.7)
                          : Colors.grey.shade500,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          if (message.isUser) ..[
            SizedBox(width: 8),
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.person,
                color: Colors.grey.shade600,
                size: 16,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildTypingIndicator() {
    return Container(
      margin: EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.restaurant,
              color: Colors.white,
              size: 16,
            ),
          ),
          SizedBox(width: 8),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(20).copyWith(
                bottomLeft: Radius.circular(4),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildTypingDot(0),
                SizedBox(width: 4),
                _buildTypingDot(200),
                SizedBox(width: 4),
                _buildTypingDot(400),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTypingDot(int delay) {
    return AnimatedContainer(
      duration: Duration(milliseconds: 600),
      curve: Curves.easeInOut,
      width: 8,
      height: 8,
      decoration: BoxDecoration(
        color: Colors.grey.shade500,
        shape: BoxShape.circle,
      ),
      child: TweenAnimationBuilder<double>(
        tween: Tween(begin: 0.4, end: 1.0),
        duration: Duration(milliseconds: 600),
        builder: (context, value, child) {
          Future.delayed(Duration(milliseconds: delay), () {
            if (mounted) {
              setState(() {});
            }
          });
          return Opacity(
            opacity: value,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.grey.shade500,
                shape: BoxShape.circle,
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildMessageInput() {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          top: BorderSide(color: Colors.grey.shade200),
        ),
      ),
      child: Column(
        children: [
          // Quick Question Buttons
          _buildQuickQuestions(),
          
          SizedBox(height: 12),
          
          // Input Field
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _messageController,
                  decoration: InputDecoration(
                    hintText: 'Ask about your dietary restrictions...',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(24),
                      borderSide: BorderSide(color: Colors.grey.shade300),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(24),
                      borderSide: BorderSide(color: Colors.grey.shade300),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(24),
                      borderSide: BorderSide(color: Theme.of(context).primaryColor),
                    ),
                    contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    filled: true,
                    fillColor: Colors.grey.shade50,
                  ),
                  onSubmitted: _sendMessage,
                  textInputAction: TextInputAction.send,
                ),
              ),
              SizedBox(width: 8),
              Container(
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor,
                  shape: BoxShape.circle,
                ),
                child: IconButton(
                  onPressed: () => _sendMessage(_messageController.text),
                  icon: Icon(Icons.send, color: Colors.white),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuickQuestions() {
    final quickQuestions = [
      "Can I eat meat today?",
      "What's allowed today?",
      "Why this restriction?",
      "Next non-veg day?",
    ];
    
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: quickQuestions.map((question) {
          return Container(
            margin: EdgeInsets.only(right: 8),
            child: OutlinedButton(
              onPressed: () => _sendMessage(question),
              style: OutlinedButton.styleFrom(
                foregroundColor: Theme.of(context).primaryColor,
                side: BorderSide(color: Theme.of(context).primaryColor.withOpacity(0.5)),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              ),
              child: Text(
                question,
                style: TextStyle(fontSize: 12),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  void _sendMessage(String text) {
    if (text.trim().isEmpty) return;
    
    setState(() {
      _messages.add(ChatMessage(
        text: text.trim(),
        isUser: true,
        timestamp: DateTime.now(),
      ));
      _isTyping = true;
    });
    
    _messageController.clear();
    _scrollToBottom();
    
    // Simulate AI response with actual diet logic
    Future.delayed(Duration(milliseconds: 1500), () {
      if (mounted) {
        final response = _generateResponse(text.trim());
        setState(() {
          _isTyping = false;
          _messages.add(ChatMessage(
            text: response,
            isUser: false,
            timestamp: DateTime.now(),
          ));
        });
        _scrollToBottom();
      }
    });
  }

  String _generateResponse(String userMessage) {
    final dietService = context.read<DietService>();
    final today = DateTime.now();
    final todayStatus = dietService.getDayStatus(today);
    final lowercaseMessage = userMessage.toLowerCase();
    
    // Food-specific questions
    if (lowercaseMessage.contains('chicken') || 
        lowercaseMessage.contains('meat') ||
        lowercaseMessage.contains('fish') ||
        lowercaseMessage.contains('egg')) {
      
      String foodType = 'non-vegetarian food';
      if (lowercaseMessage.contains('chicken')) foodType = 'chicken';
      else if (lowercaseMessage.contains('fish')) foodType = 'fish';
      else if (lowercaseMessage.contains('egg')) foodType = 'eggs';
      
      if (todayStatus.restriction == RestrictionType.nonVegAllowed) {
        return '''Yes, you can eat $foodType today! ✅

Today is ${todayStatus.statusText}. ${todayStatus.reason}

Enjoy your meal! 🍽️''';
      } else {
        return '''No, you should avoid $foodType today. ❌

${todayStatus.reason}

Consider vegetarian alternatives instead! 🌱''';
      }
    }
    
    // General restriction questions
    if (lowercaseMessage.contains('why') || lowercaseMessage.contains('reason')) {
      String explanation = todayStatus.reason;
      
      if (todayStatus.events.isNotEmpty) {
        final eventNames = todayStatus.events.map((e) => e.name).join(', ');
        explanation += '\n\nSpecial events today: $eventNames';
      }
      
      if (todayStatus.hasUserOverride) {
        explanation += '\n\nNote: You have a personal override for today.';
      }
      
      return '''Here's why today is ${todayStatus.statusText}:

$explanation

This helps maintain spiritual and cultural practices! 🙏''';
    }
    
    // What's allowed questions
    if (lowercaseMessage.contains('allowed') || lowercaseMessage.contains('eat today')) {
      if (todayStatus.restriction == RestrictionType.nonVegAllowed) {
        return '''Today you can eat: ✅

• All vegetarian foods (fruits, vegetables, grains, dairy)
• Non-vegetarian foods (meat, fish, eggs)
• All beverages and snacks

No restrictions apply today! Enjoy! 🎉''';
      } else {
        return '''Today you can eat: 🌱

• Fruits and vegetables
• Grains and cereals
• Dairy products (milk, paneer, yogurt)
• Nuts and legumes
• Vegetarian snacks and sweets

Avoid: All meat, fish, and egg products today.''';
      }
    }
    
    // Next non-veg day questions
    if (lowercaseMessage.contains('next') && 
        (lowercaseMessage.contains('non-veg') || lowercaseMessage.contains('meat'))) {
      
      // Find next non-veg allowed day
      DateTime checkDate = today.add(Duration(days: 1));
      int daysChecked = 0;
      
      while (daysChecked < 14) { // Check next 2 weeks
        final dayStatus = dietService.getDayStatus(checkDate);
        if (dayStatus.restriction == RestrictionType.nonVegAllowed) {
          final dayName = DateFormat('EEEE').format(checkDate);
          final dateFormatted = DateFormat('MMM d').format(checkDate);
          
          if (daysChecked == 0) {
            return '''Your next non-veg day is tomorrow! 🎉

$dayName, $dateFormatted - Non-vegetarian food will be allowed.

Plan your meals accordingly! 🍗''';
          } else {
            return '''Your next non-veg day is: 📅

$dayName, $dateFormatted (in ${daysChecked + 1} days)

Non-vegetarian food will be allowed then! 🍗''';
          }
        }
        checkDate = checkDate.add(Duration(days: 1));
        daysChecked++;
      }
      
      return '''I couldn't find a non-veg day in the next 2 weeks. 🤔

This might be due to:
• Festival season with many restrictions
• Your weekly rules are quite strict
• Many family/personal overrides

Check your weekly rules or add a personal override! ⚙️''';
    }
    
    // Default helpful response
    return '''I can help you with questions about:

🍗 Specific foods ("Can I eat chicken?")
📅 Today's restrictions ("What's allowed today?")
❓ Reasons ("Why can't I eat meat?")
📆 Future dates ("When's my next non-veg day?")

Today is ${todayStatus.statusText}. ${todayStatus.reason}

Feel free to ask me anything about your dietary rules! 😊''';
  }

  void _clearChat() {
    setState(() {
      _messages.clear();
    });
    _addWelcomeMessage();
    setState(() {});
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }
}

class ChatMessage {
  final String text;
  final bool isUser;
  final DateTime timestamp;
  
  ChatMessage({
    required this.text,
    required this.isUser,
    required this.timestamp,
  });
}