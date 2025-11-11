# 🦅 Raptor.fitt v2

<div align="center">

**A smart, adaptive fitness companion that logs workouts, tracks recovery, and predicts performance — all from minimal user input.**

[![Flutter](https://img.shields.io/badge/Flutter-3.0+-02569B?logo=flutter)](https://flutter.dev)
[![Dart](https://img.shields.io/badge/Dart-3.0+-0175C2?logo=dart)](https://dart.dev)
[![License](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)

[Features](#-features) • [Tech Stack](#-tech-stack) • [Quick Start](#-quick-start) • [Screenshots](#-screenshots) • [Documentation](#-documentation)

</div>

---

## 🎯 Vision

**Raptor.fitt v2** is designed to evolve with the user through data and AI feedback. The app provides intelligent insights, adaptive recommendations, and a seamless logging experience that makes fitness tracking **faster than opening Instagram**.

### What Makes This Different?
- 🎤 **Voice-First Logging**: "bench 80 3 10" → Instantly logged
- 🧠 **AI-Powered Intelligence**: Predicts PRs, recommends deloads, tracks recovery patterns
- 📊 **Advanced Analytics**: 8 intelligence indexes including strength, growth potential, consistency
- 🏃 **Offline-First**: Full functionality without internet
- 🎨 **Beautiful UI**: Dark theme with neon accents, Material 3 design
- 👥 **Social Features**: Training crews and weekly challenges

---

## ✨ Features

### 🏋️ Core Modules

<table>
<tr>
<td width="50%">

#### Workout Tracking
- ✅ Quick Log with AI parsing
- ✅ Voice input (speech-to-text)
- ✅ 20+ preloaded exercises
- ✅ Session mode with rest timers
- ✅ PR tracking & 1RM estimation
- ✅ Volume tracking per session
- ✅ Offline logging (Hive)

</td>
<td width="50%">

#### Nutrition Tracking
- ✅ Quick food logging
- ✅ Macro breakdown (P/C/F)
- ✅ Calorie progress rings
- ✅ Daily macro targets
- ✅ Custom foods & meals
- ✅ Auto-adjusted by goal
- ✅ Meal categorization

</td>
</tr>
<tr>
<td width="50%">

#### Sleep & Recovery
- ✅ Sleep hours logging
- ✅ Quality rating (1-10)
- ✅ Soreness tracking
- ✅ Energy level tracking
- ✅ Recovery score (0-100)
- ✅ Fatigue detection
- ✅ Rest recommendations

</td>
<td width="50%">

#### Onboarding
- ✅ Profile creation
- ✅ Metrics collection
- ✅ Goal selection
- ✅ Body fat estimation
- ✅ Experience level
- ✅ Auto TDEE calculation
- ✅ Macro auto-calculation

</td>
</tr>
</table>

### 🧠 Intelligence & Analytics

**8 Advanced Indexes:**
1. **Strength Index** (0-100) - Volume + consistency scoring
2. **2-Week Growth Potential** - Projected progress rate
3. **Estimated PRs** - 1RM calculations for all exercises
4. **Recovery-Output Pattern** - Correlation analysis
5. **Muscle Strength Tiers** - Strong/Developing/Weak categorization
6. **Weekly Volume** - 8-week trend tracking
7. **Consistency Index** - Adherence percentage
8. **Deload Recommendations** - Fatigue-based suggestions

### 💡 Smart Features

- 🎤 **Voice Input**: Hands-free workout logging
- 🤖 **AI Parsing**: "bench 80 3 10" → auto-parsed (works offline too)
- 🔥 **Streak Tracking**: Daily consistency monitoring
- 📈 **Progress Charts**: Interactive visualizations (fl_chart)
- 🔔 **Smart Notifications**: Recovery alerts, PR celebrations, deload suggestions
- 👥 **Social Crews**: Compete with friends (2-5 people groups)
- 🏆 **Challenges**: Weekly volume/consistency/PR competitions
- 🎯 **Adaptive Goals**: Auto-recalibrates macros & training load

---

## 🛠️ Tech Stack

| Category | Technology | Purpose |
|----------|-----------|---------|
| **Framework** | Flutter 3.0+ | Cross-platform UI |
| **Language** | Dart 3.0+ | Type-safe programming |
| **State** | Riverpod | Reactive state management |
| **Navigation** | go_router | Declarative routing |
| **Database** | Hive | Offline-first local storage |
| **Backend** | Supabase | Auth, cloud DB (optional) |
| **AI** | OpenAI API | Parsing, summaries, insights |
| **Charts** | fl_chart + Syncfusion | Data visualization |
| **Animations** | flutter_animate | Smooth transitions |
| **Voice** | speech_to_text | Voice input |
| **Notifications** | flutter_local_notifications | Smart alerts |

---

## 🚀 Quick Start

### Prerequisites
- Flutter SDK 3.0+
- Dart SDK 3.0+
- Android Studio / Xcode (for mobile)

### Installation

#### Option 1: Automated (Windows)
```bash
build_and_run.bat
```

#### Option 2: Manual
```bash
# 1. Install dependencies
flutter pub get

# 2. Generate Hive adapters
flutter pub run build_runner build --delete-conflicting-outputs

# 3. Run the app
flutter run
```

### Optional: Cloud Features Setup

1. **Create `.env` file:**
```env
SUPABASE_URL=your_supabase_url
SUPABASE_ANON_KEY=your_supabase_key
OPENAI_API_KEY=your_openai_key
```

2. **Uncomment in `lib/main.dart`:**
```dart
// Supabase sync
await Supabase.initialize(url: '...', anonKey: '...');

// AI features
AIParsingService.init('your_openai_key');
```

---

## 📱 Screenshots

<table>
<tr>
<td><b>Onboarding</b><br/>Clean profile setup</td>
<td><b>Dashboard</b><br/>Quick log center</td>
<td><b>Workout</b><br/>Session tracking</td>
<td><b>Insights</b><br/>Analytics & charts</td>
</tr>
<tr>
<td><img src="docs/screenshots/onboarding.png" width="200"/></td>
<td><img src="docs/screenshots/dashboard.png" width="200"/></td>
<td><img src="docs/screenshots/workout.png" width="200"/></td>
<td><img src="docs/screenshots/insights.png" width="200"/></td>
</tr>
</table>

---

## 📂 Project Structure

```
lib/
├── core/
│   ├── router/          # Navigation (go_router)
│   ├── services/        # Hive, AI, Analytics, Notifications
│   ├── theme/           # Colors & theme
│   ├── utils/           # Haptics, helpers
│   └── widgets/         # Reusable components
├── features/
│   ├── dashboard/       # Home screen
│   ├── insights/        # Analytics & charts
│   ├── models/          # Data models (Hive)
│   ├── nutrition/       # Food tracking
│   ├── onboarding/      # User setup
│   ├── profile/         # Settings
│   ├── sleep/           # Recovery tracking
│   ├── social/          # Crews & challenges
│   ├── voice/           # Voice input
│   └── workout/         # Exercise logging
└── main.dart            # Entry point
```

---

## 📖 Documentation

- **[Setup Instructions](SETUP_INSTRUCTIONS.md)** - Detailed installation guide
- **[Project Summary](PROJECT_SUMMARY.md)** - Complete feature list & implementation details
- **[API Documentation](docs/API.md)** - Service & model reference

---

## 🎨 Design Philosophy

### Dark Theme with Neon Accents
- **Background**: Pure black (#0A0A0A) - Easy on eyes in gym
- **Cards**: Dark grey (#1A1A1A) - Clear hierarchy
- **Primary**: Electric purple (#6B5FED) - Energy & focus
- **Accent**: Electric blue (#3B82F6) - Intelligence
- **Success**: Neon green (#10F4B4) - Achievement

### Typography
- **Poppins** (Headers) - Bold, energetic
- **Inter** (Body) - Clean, readable
- **Monospace** (Numbers) - Clear stats

### Interactions
- ✅ Big tap targets (40x40 min)
- ✅ Haptic feedback on all actions
- ✅ Smooth animations (60 FPS)
- ✅ Gesture-based navigation
- ✅ Progressive disclosure

---

## 🏗️ Architecture

```
┌─────────────────┐
│   Presentation  │  Flutter Widgets + Riverpod
├─────────────────┤
│   Domain        │  Models + Business Logic
├─────────────────┤
│   Data          │  Hive (Local) + Supabase (Cloud)
├─────────────────┤
│   External      │  OpenAI API + Device Services
└─────────────────┘
```

**Key Principles:**
- ✅ Offline-first architecture
- ✅ Clean separation of concerns
- ✅ Type-safe models with Hive
- ✅ Reactive state with Riverpod
- ✅ Modular feature structure

---

## 🚢 Deployment

### Android APK
```bash
flutter build apk --release
```

### iOS IPA
```bash
flutter build ios --release
```

### Web
```bash
flutter build web
```

---

## 🧪 Testing

```bash
# Run all tests
flutter test

# Run with coverage
flutter test --coverage

# Integration tests
flutter test integration_test
```

---

## 📊 Performance

- ⚡ **Local DB**: Instant read/write with Hive
- ⚡ **Lazy Loading**: Efficient list rendering
- ⚡ **Image Caching**: Cached network images
- ⚡ **Minimal Rebuilds**: Optimized Riverpod state
- ⚡ **60 FPS Animations**: Hardware-accelerated

---

## 🤝 Contributing

We welcome contributions! Please follow these steps:

1. Fork the repository
2. Create feature branch (`git checkout -b feature/amazing-feature`)
3. Commit changes (`git commit -m 'Add amazing feature'`)
4. Push to branch (`git push origin feature/amazing-feature`)
5. Open Pull Request

---

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

---

## 🙏 Acknowledgments

- **Flutter Team** - Amazing framework
- **OpenAI** - AI capabilities
- **Supabase** - Backend infrastructure
- **Community** - Feedback and support

---

## 📞 Support

- **Issues**: [GitHub Issues](https://github.com/yourusername/raptor-fitt/issues)
- **Discussions**: [GitHub Discussions](https://github.com/yourusername/raptor-fitt/discussions)
- **Email**: support@raptorfitt.com

---

<div align="center">

**Built with 🔥 for people who lift heavy things**

[⬆ Back to Top](#-raptorfitt-v2)

</div>
#   r a p t o r . f i t t . v 2  
 