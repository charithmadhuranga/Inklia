# Inklia - Your Personal Journal App

<p align="center">
  <img src="https://img.shields.io/badge/Platform-iOS%20%7C%20Android-blue?style=for-the-badge" alt="Platform">
  <img src="https://img.shields.io/badge/Framework-Flutter-purple?style=for-the-badge" alt="Framework">
  <img src="https://img.shields.io/badge/License-MIT-green?style=for-the-badge" alt="License">
</p>

Inklia is a beautiful, feature-rich personal journal application built with Flutter. It allows you to track your daily thoughts, memories, and emotions with a stunning calendar-based interface.

---

## Features

### 📅 Calendar System
- Beautiful monthly/weekly calendar view
- Visual indicators for days with entries
- Easy navigation between months
- Quick access to any date's entries

### 📝 Rich Journal Entries
- **Text Support**: Write unlimited content with title and body
- **Mood Tracking**: 7 emoji-based moods (Happy, Excited, Calm, Neutral, Sad, Anxious, Angry)
- **Tags**: Organize entries with custom tags for easy filtering
- **Templates**: 8 pre-built journal templates:
  - Gratitude Journal
  - Morning Reflection
  - Evening Reflection
  - Goals & Dreams
  - Emotions Check-in
  - Travel Memories
  - Creative Writing
  - Self Care

### 📷 Media Support
- **Image Gallery**: Pick images from your photo library
- **Camera**: Take photos directly within the app
- **Voice Memos**: Record and attach voice recordings to entries
- Full media management (add/remove/view)

### ⭐ Favorites
- Star important entries for quick access
- Dedicated favorites screen with grid view
- Visual indicators for favorited items

### 🔍 Search
- Full-text search across titles, content, and tags
- Recent entries displayed when not searching
- Instant search results

### 📊 Insights & Statistics
- Total entries count
- Current journaling streak
- Mood distribution chart
- Tag cloud visualization

---

## Screenshots

The app features a modern, gradient-based UI with:
- Purple to pink gradient accents
- Clean card-based layouts
- Smooth animations
- Material Design 3 components

---

## Project Structure

```
lib/
├── main.dart                    # App entry point
├── config/
│   └── templates.dart           # Journal entry templates
├── models/
│   └── journal_entry.dart       # Data model with Mood enum
├── services/
│   └── database_service.dart    # SQLite database operations
├── screens/
│   ├── main_navigation.dart    # Bottom navigation container
│   ├── home_screen.dart        # Calendar view with entries
│   ├── search_screen.dart      # Search functionality
│   ├── favorites_screen.dart   # Favorited entries grid
│   ├── statistics_screen.dart  # Insights & statistics
│   └── journal_entry_screen.dart # Create/edit entries
└── theme/
    └── app_theme.dart          # Custom theme configuration
```

---

## Technology Stack

| Category | Technology |
|----------|------------|
| Framework | Flutter 3.x |
| Language | Dart |
| Local Database | SQLite (sqflite) |
| Calendar | table_calendar |
| Image Picker | image_picker |
| Audio Recording | record |
| Audio Playback | audioplayers |
| Utilities | path_provider, uuid, intl |

---

## Prerequisites

Before setting up the project, ensure you have:

1. **Flutter SDK** (3.x or later)
   - Install from: https://flutter.dev/docs/get-started/install

2. **Dart SDK** (included with Flutter)

3. **iOS Development** (for iOS builds):
   - macOS with Xcode
   - Xcode Command Line Tools

4. **Android Development** (for Android builds):
   - Android Studio
   - Android SDK

---

## Setup Instructions

### 1. Clone the Repository

```bash
git clone <repository-url>
cd testapp
```

### 2. Install Dependencies

```bash
flutter pub get
```

### 3. Configure iOS (Optional - for microphone/camera permissions)

The app already includes the required permissions in `ios/Runner/Info.plist`:
- `NSMicrophoneUsageDescription` - For voice recording
- `NSCameraUsageDescription` - For taking photos
- `NSPhotoLibraryUsageDescription` - For accessing photos

### 4. Run the App

**For iOS Simulator:**
```bash
flutter run -d "iPhone 15"
```

**For Android Emulator:**
```bash
flutter run -d <emulator-id>
```

**For all available devices:**
```bash
flutter devices    # List available devices
flutter run        # Run on connected device
```

### 5. Build for Release

**iOS (App Store):**
```bash
flutter build ios --release
```

**Android (APK):**
```bash
flutter build apk --release
```

---

## Database Schema

The app uses SQLite with the following schema:

```sql
CREATE TABLE journal_entries (
    id TEXT PRIMARY KEY,
    date TEXT NOT NULL,
    title TEXT NOT NULL,
    content TEXT NOT NULL,
    imagePaths TEXT NOT NULL,
    voiceMemoPaths TEXT NOT NULL,
    mood INTEGER,
    tags TEXT NOT NULL,
    isFavorite INTEGER NOT NULL DEFAULT 0,
    templateType TEXT,
    createdAt TEXT NOT NULL,
    updatedAt TEXT NOT NULL
)
```

---

## Key Implementation Details

### Mood Enum
The app supports 7 moods stored as integers (0-6):
- 0: Happy 😊
- 1: Excited 🤩
- 2: Calm 😌
- 3: Neutral 😐
- 4: Sad 😢
- 5: Anxious 😰
- 6: Angry 😠

### Templates
Templates provide pre-filled content structures. Users can:
- Select a template when creating new entries
- Clear template selection anytime
- Templates are stored as `templateType` string in the database

### Media Storage
- Images and voice memos are stored in the app's documents directory
- File paths are stored in the database as JSON arrays
- Files are automatically cleaned up when entries are deleted

---

## Customization

### Changing the Theme Colors

Edit `lib/theme/app_theme.dart`:

```dart
static const Color primaryColor = Color(0xFF6B4EFF);    // Purple
static const Color secondaryColor = Color(0xFFFF6B9D);  // Pink
static const Color accentColor = Color(0xFF00D9FF);     // Cyan
```

### Adding More Templates

Edit `lib/config/templates.dart` and add new `JournalTemplate` entries to the `templates` list.

---

## License

This project is licensed under the MIT License.

---

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

---

## Acknowledgments

- [Flutter](https://flutter.dev) - The UI framework
- [table_calendar](https://pub.dev/packages/table_calendar) - Calendar widget
- [sqflite](https://pub.dev/packages/sqflite) - SQLite database
- [image_picker](https://pub.dev/packages/image_picker) - Image selection
- [record](https://pub.dev/packages/record) - Audio recording
- [audioplayers](https://pub.dev/packages/audioplayers) - Audio playback

---

<p align="center">Made with ❤️ using Flutter</p>
