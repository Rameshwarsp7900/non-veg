# Quick Setup Guide

## Prerequisites
- Flutter SDK 3.0.0 or later
- Android Studio or VS Code
- Android device or emulator

## Setup Steps

1. **Install Flutter dependencies:**
   ```bash
   flutter pub get
   ```

2. **Run the app:**
   ```bash
   flutter run
   ```

## First Use

1. **Explore Today's Status** - See current dietary restrictions on home screen
2. **Browse Calendar** - Tap dates to view detailed information
3. **Check Pre-loaded Festivals** - Hindu festivals are already configured
4. **Set Weekly Rules** - Go to Weekly Rules tab to customize patterns
5. **Try the Assistant** - Ask \"Can I eat meat today?\" in the Assistant tab

## Key Features to Test

- **Calendar Navigation**: Swipe between months, tap dates for details
- **Event Management**: Add custom events like birthdays or exam days
- **Weekly Patterns**: Enable Tuesday/Saturday restrictions (traditional)
- **Personal Overrides**: Override any day's restriction for special occasions
- **AI Assistant**: Ask natural language questions about food restrictions

## Default Configuration

- **Weekly Rules**: Tuesday and Saturday set as vegetarian-only (traditional Hanuman days)
- **Festivals**: Major Hindu festivals pre-loaded for 2025-2026
- **Restrictions**: Color-coded system (Green=OK, Red=Veg-only, Yellow=Conditional)

## Troubleshooting

- **App won't start**: Run `flutter clean` then `flutter pub get`
- **No calendar data**: Data loads automatically on first run
- **Missing festivals**: Default events are created on initial startup

Enjoy exploring your personalized dietary calendar! 🎉