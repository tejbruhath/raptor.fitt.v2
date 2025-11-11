# 🦅 Raptor.fitt v2 Setup Instructions

## Prerequisites
- Flutter SDK 3.0+
- Dart SDK 3.0+
- Android Studio / Xcode (for mobile development)
- Git

## Installation Steps

### 1. Install Dependencies
```bash
flutter pub get
```

### 2. Generate Code (Hive Adapters)
```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

### 3. Configure Environment Variables
Create a `.env` file in the root directory:
```env
SUPABASE_URL=your_supabase_url_here
SUPABASE_ANON_KEY=your_supabase_anon_key_here
OPENAI_API_KEY=your_openai_api_key_here
```

### 4. Setup Supabase (Optional - for cloud sync)
1. Create a Supabase project at https://supabase.com
2. Copy your project URL and anon key
3. Update `.env` file with your credentials
4. Uncomment Supabase initialization in `lib/main.dart`

### 5. Setup OpenAI (Optional - for AI features)
1. Get API key from https://platform.openai.com
2. Add to `.env` file
3. Uncomment AI service initialization in `lib/main.dart`

## Running the App

### For Android
```bash
flutter run
```

### For iOS
```bash
flutter run -d ios
```

### For Web
```bash
flutter run -d chrome
```

## Project Structure

```
lib/
├── core/
│   ├── router/          # Navigation (go_router)
│   ├── services/        # Hive, AI, Analytics services
│   ├── theme/           # App theme & colors
│   ├── utils/           # Utilities (haptics, etc.)
│   └── widgets/         # Reusable widgets
├── features/
│   ├── dashboard/       # Home screen
│   ├── insights/        # Analytics & charts
│   ├── models/          # Data models (Hive)
│   ├── nutrition/       # Nutrition tracking
│   ├── onboarding/      # User setup flow
│   ├── profile/         # User profile & settings
│   ├── sleep/           # Sleep tracking
│   ├── social/          # Training crews & challenges
│   ├── voice/           # Voice input
│   └── workout/         # Workout logging & session
└── main.dart            # App entry point
```

## Features Implemented

### ✅ Core Features
- [x] Onboarding with metrics collection
- [x] Quick Log (AI-powered workout parsing)
- [x] Workout Session Mode
- [x] Exercise Library (20+ preloaded exercises)
- [x] Nutrition Tracking (macros & calories)
- [x] Sleep & Recovery Tracking
- [x] Voice Input for logging
- [x] Offline-first (Hive local database)

### ✅ Analytics & Intelligence
- [x] Strength Index calculation
- [x] 2-Week Growth Potential
- [x] PR Estimation (1RM calculator)
- [x] Recovery Pattern Analysis
- [x] Consistency Index
- [x] Weekly Volume Tracking
- [x] Muscle Strength Tiers
- [x] Deload Recommendations

### ✅ UI/UX
- [x] Dark theme with purple/blue accents
- [x] Material 3 design
- [x] Smooth animations (flutter_animate)
- [x] Haptic feedback
- [x] Custom gradient buttons
- [x] Chart visualizations (fl_chart)

### 🚧 Advanced Features (Ready to Implement)
- [ ] Supabase cloud sync
- [ ] OpenAI integration (full AI parsing & summaries)
- [ ] Social Crews (multiplayer accountability)
- [ ] Weekly Challenges
- [ ] Body measurement photos
- [ ] Export data (CSV/JSON)
- [ ] Push notifications
- [ ] Custom workout programs

## Troubleshooting

### Build Runner Issues
If you encounter issues with code generation:
```bash
flutter clean
flutter pub get
flutter pub run build_runner clean
flutter pub run build_runner build --delete-conflicting-outputs
```

### Hive Database Issues
Clear app data:
```dart
await HiveService.clearAllData();
```

### Android Build Issues
Ensure `minSdkVersion` is at least 24 in `android/app/build.gradle`

### iOS Build Issues
Run pod install:
```bash
cd ios
pod install
cd ..
```

## Testing

### Run Tests
```bash
flutter test
```

### Run in Debug Mode
```bash
flutter run --debug
```

### Build Release APK
```bash
flutter build apk --release
```

### Build iOS IPA
```bash
flutter build ios --release
```

## API Keys Setup (Optional)

### OpenAI API
1. Get key from: https://platform.openai.com/api-keys
2. Add to `.env`: `OPENAI_API_KEY=sk-...`
3. Uncomment in `lib/main.dart`:
```dart
AIParsingService.init(Platform.environment['OPENAI_API_KEY'] ?? '');
```

### Supabase Setup
1. Create project: https://supabase.com
2. Add credentials to `.env`
3. Uncomment in `lib/main.dart`:
```dart
await Supabase.initialize(
  url: Platform.environment['SUPABASE_URL']!,
  anonKey: Platform.environment['SUPABASE_ANON_KEY']!,
);
```

## Performance Optimization

- Hive provides instant local database access
- Images are cached with `cached_network_image`
- Lazy loading for large lists
- Offline-first architecture

## Contributing

1. Fork the repository
2. Create feature branch
3. Commit changes
4. Push to branch
5. Create Pull Request

## License

MIT License - See LICENSE file for details

## Support

For issues or questions:
- GitHub Issues: [Create an issue]
- Email: support@raptorfitt.com

---

Built with 🔥 by the Raptor.fitt team
