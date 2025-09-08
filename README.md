# Veg/Non-Veg Decision Calendar App

A comprehensive Flutter application that helps users navigate vegetarian/non-vegetarian dietary decisions based on Hindu traditions, cultural practices, family rules, weekly patterns, and personal preferences. The app features an intelligent AI assistant for food-related questions and provides a complete calendar view with color-coded dietary restrictions.

![App Preview](assets/app_preview.png)

## Features

### 📅 **Smart Calendar View**
- **Color-coded dates**: Green (✅) for Non-Veg OK, Red (❌) for Veg-only, Yellow (⚠️) for Conditional
- **Interactive calendar**: Tap any date to see detailed dietary status and restrictions
- **Monthly navigation**: Easy browsing through months with festival and event highlights
- **Today's status**: Prominent display of current day's dietary guidelines

### 🎊 **Festival & Event Management**
- **Pre-loaded Hindu festivals**: Ganesh Chaturthi, Navratri, Diwali, Janmashtami, and more
- **Eclipse tracking**: Solar and lunar eclipses with traditional dietary restrictions
- **Custom events**: Add personal occasions, birthdays, exam days, etc.
- **Event categories**: Festival, Eclipse, Holiday, Personal, Weekly, Family
- **Recurring events**: Yearly festivals and monthly observances (Ekadashi, Purnima)

### 📆 **Weekly Rules Editor**
- **Traditional presets**: 
  - Tuesday & Saturday (Hanuman's days)
  - Monday (Shiva's day)
  - Thursday (Guru's day)
- **Custom weekly patterns**: Set any day as vegetarian-only
- **Quick presets**: Traditional, Strict, Minimal, or Clear All options
- **Cultural information**: Learn about Hindu dietary traditions

### ⚙️ **Manual Overrides**
- **Personal exceptions**: Override any day's restriction for special occasions
- **Detailed reasons**: Add context for why you're making an exception
- **Quick reasons**: Pre-filled suggestions for common scenarios
- **Override history**: View and manage all your personal overrides

### 👨‍👩‍👧‍👦 **Family Rules (Mom's Rules)**
- **Shared restrictions**: Family members can set rules that apply to everyone
- **Parental controls**: Parents can manage family-wide dietary guidelines
- **Synchronized rules**: Changes reflect across all linked family accounts

### 🤖 **AI Food Assistant**
- **Natural conversation**: Ask questions in plain English
- **Smart responses**: "Can I eat chicken today?", "Why can't I eat meat today?"
- **Contextual answers**: Responses based on your actual calendar data
- **Quick questions**: Pre-made buttons for common queries
- **Detailed explanations**: Learn why certain restrictions apply

### 🔔 **Notifications & Reminders**
- **Daily alerts**: Morning reminders about the day's dietary status
- **Event notifications**: Alerts for upcoming festivals and special days
- **Customizable timing**: Set preferred reminder times
- **Smart content**: Contextual messages based on your rules

## Technical Architecture

### **Tech Stack**
- **Framework**: Flutter (Cross-platform mobile development)
- **State Management**: Provider pattern for reactive UI updates
- **Local Storage**: SharedPreferences for user data persistence
- **Calendar UI**: TableCalendar widget for interactive calendar view
- **Notifications**: flutter_local_notifications for system alerts
- **Date Handling**: intl package for localization and formatting

### **Data Models**
```dart\n// Core restriction types\nenum RestrictionType {\n  nonVegAllowed,  // ✅ All food types allowed\n  vegOnly,        // ❌ Vegetarian food only\n  conditional,    // ⚠️ Some restrictions apply\n}\n\n// Event categories\nenum EventCategory {\n  festival,   // Religious festivals\n  eclipse,    // Solar/lunar eclipses\n  holiday,    // National holidays\n  personal,   // Personal occasions\n  weekly,     // Recurring weekly\n  family,     // Family-wide rules\n}\n```\n\n### **Rule Priority System**\n1. **Manual Overrides** (Highest priority)\n2. **Special Events** (Festivals, Eclipses)\n3. **Weekly Rules** (Recurring patterns)\n4. **Default** (Non-veg allowed)\n\n## Setup Instructions\n\n### **Prerequisites**\n- Flutter SDK (3.0.0 or later)\n- Dart SDK\n- Android Studio / VS Code\n- Android device or emulator\n\n### **Installation**\n\n1. **Clone the repository**\n   ```bash\n   git clone https://github.com/your-repo/veg-nonveg-calendar.git\n   cd veg-nonveg-calendar\n   ```\n\n2. **Install dependencies**\n   ```bash\n   flutter pub get\n   ```\n\n3. **Run the app**\n   ```bash\n   flutter run\n   ```\n\n### **Project Structure**\n```\nlib/\n├── main.dart                 # App entry point\n├── models/                   # Data models\n│   ├── diet_event.dart      # Event and restriction models\n│   ├── user_preferences.dart # User settings and weekly rules\n│   └── day_status.dart      # Daily dietary status\n├── services/                # Business logic\n│   ├── diet_service.dart    # Core diet management\n│   └── notification_service.dart # Push notifications\n├── screens/                 # UI screens\n│   ├── home_screen.dart     # Main calendar view\n│   ├── event_manager_screen.dart # Event management\n│   ├── weekly_rules_screen.dart  # Weekly patterns\n│   ├── chat_assistant_screen.dart # AI assistant\n│   └── settings_screen.dart # App configuration\n├── widgets/                 # Reusable components\n│   ├── calendar_widget.dart # Interactive calendar\n│   ├── today_status_card.dart # Daily status display\n│   └── event_form_dialog.dart # Event creation form\n└── utils/                   # Utilities\n    └── default_events.dart  # Pre-loaded festivals\n```\n\n## Usage Guide\n\n### **Getting Started**\n1. **Launch the app** - View today's dietary status on the home screen\n2. **Explore the calendar** - Tap dates to see detailed restrictions\n3. **Set weekly rules** - Configure recurring patterns (Tue/Sat traditional)\n4. **Add personal events** - Birthdays, exam days, special occasions\n5. **Ask the assistant** - Get answers to food-related questions\n\n### **Common Tasks**\n\n#### **Adding a Festival**\n1. Go to **Events** tab\n2. Tap **+** button\n3. Fill in festival details:\n   - Name: \"Ganesh Chaturthi\"\n   - Date: Select from calendar\n   - Category: Festival\n   - Restriction: Veg Only\n   - Description: Cultural/religious context\n\n#### **Setting Weekly Rules**\n1. Go to **Weekly Rules** tab\n2. Toggle switches for desired days\n3. Use **Quick Presets** for common patterns:\n   - **Traditional**: Tue & Sat (Hanuman's days)\n   - **Strict**: Mon, Tue, Thu, Sat\n   - **Minimal**: Sat only\n\n#### **Creating Personal Override**\n1. Tap any date in calendar\n2. Select **Add Override**\n3. Choose new restriction level\n4. Add reason (birthday, exam, etc.)\n5. Save with optional notes\n\n#### **Using Food Assistant**\n1. Go to **Assistant** tab\n2. Type questions like:\n   - \"Can I eat fish today?\"\n   - \"Why can't I eat meat?\"\n   - \"When is my next non-veg day?\"\n3. Get instant, contextual answers\n\n## Cultural Context\n\n### **Hindu Dietary Traditions**\nThe app incorporates authentic Hindu dietary practices:\n\n- **Ahimsa (Non-violence)**: Many Hindus avoid meat on sacred days\n- **Hanuman Days**: Tuesday and Saturday traditional fasting\n- **Shiva Days**: Monday restrictions in many regions\n- **Festival Observances**: Strict vegetarianism during major festivals\n- **Eclipse Periods**: Traditional avoidance of food during eclipses\n- **Lunar Calendar**: Ekadashi, Purnima, and other monthly observances\n\n### **Regional Variations**\nThe app allows customization for different regional practices:\n- North Indian traditions (Monday Shiva fasting)\n- South Indian customs (Saturday Hanuman worship)\n- Bengali practices (Tuesday Mangal observances)\n- Gujarati festivals (Extended Navratri periods)\n\n## Upcoming Features\n\n### **Phase 2 Enhancements**\n- [ ] **Database Integration**: Supabase for cloud storage and family sync\n- [ ] **OpenAI Integration**: Real ChatGPT API for enhanced AI responses\n- [ ] **Push Notifications**: Cloud-based reminders and family updates\n- [ ] **Multi-language Support**: Hindi, Tamil, Bengali, Gujarati\n- [ ] **Recipe Suggestions**: Vegetarian recipes for restricted days\n- [ ] **Community Features**: Share traditions with other families\n\n### **Advanced Features**\n- [ ] **Lunar Calendar Sync**: Accurate festival date calculations\n- [ ] **Regional Festivals**: State-specific celebrations and observances\n- [ ] **Dietary Tracking**: Log actual food consumption vs. restrictions\n- [ ] **Health Integration**: Connect with nutrition and wellness apps\n- [ ] **Social Sharing**: Share dietary status with family and friends\n\n## Contributing\n\nWe welcome contributions from the community! Please see our [Contributing Guidelines](CONTRIBUTING.md) for details.\n\n### **Development Setup**\n1. Fork the repository\n2. Create a feature branch: `git checkout -b feature/amazing-feature`\n3. Make your changes\n4. Add tests if applicable\n5. Commit: `git commit -m 'Add amazing feature'`\n6. Push: `git push origin feature/amazing-feature`\n7. Open a Pull Request\n\n## License\n\nThis project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.\n\n## Acknowledgments\n\n- **Hindu Calendar Data**: Traditional festival dates and observances\n- **Cultural Consultants**: Community leaders and religious scholars\n- **Design Inspiration**: Material Design principles and Indian aesthetics\n- **Open Source Libraries**: Flutter, Provider, and community packages\n\n## Support\n\nFor questions, suggestions, or support:\n- 📧 Email: support@vegnonvegcalendar.com\n- 🐛 Issues: [GitHub Issues](https://github.com/your-repo/issues)\n- 💬 Discussions: [GitHub Discussions](https://github.com/your-repo/discussions)\n- 📱 App Store: Leave a review and rating\n\n---\n\n**Built with ❤️ for the Hindu community and anyone following traditional dietary practices**\n\n*\"Ahimsa paramo dharma\"* - Non-violence is the highest virtue