# Finoro 💰

**A modern personal finance app that helps you organize, track, and understand your money through Workspaces.**

Finoro transforms personal finance into organized, visual stories. Each Workspace is a flexible financial space that groups budgets, expenses, and incomes under a single goal — whether it's a vacation fund, monthly budget, side hustle, or home renovation.

## ✨ Core Concept

**Workspaces** are financial containers that bring together:

- 📊 **Budgets** — set your financial plan or spending limits
- 💸 **Expenses** — track real spending with categories
- 💰 **Incomes** — log earnings, payments, or transfers
- 📈 **Insights** — visualize balance and spending trends
- 🎯 **Progress** — see how close you are to your goals

## 🎯 Platform Support

**iOS Only** - Focused on delivering an exceptional iOS experience for the next 6 months.

## 🚀 Getting Started

### Prerequisites

- Flutter SDK ^3.7.2
- Xcode (for iOS development)
- CocoaPods
- Firebase account
- Apple Developer account (to configure Sign in with Apple)

### Installation

1. **Clone the repository**

   ```bash
   git clone <repository-url>
   cd money_tracker
   ```

2. **Install dependencies**

   ```bash
   flutter pub get
   cd ios && pod install && cd ..
   ```

3. **Generate localization files**

   ```bash
   flutter gen-l10n
   ```

4. **Run on iOS**
   ```bash
   flutter run -d ios
   ```

### Firebase Setup

1. Add your `GoogleService-Info.plist` to `ios/Runner/`.
2. (Optional) If you target Android later, add the matching `google-services.json` to `android/app/`.
3. In the Firebase Console, enable **Firestore** and **Authentication**.
4. Under Authentication → Sign-in providers, enable **Google** and **Apple**.

### Authentication Configuration

1. **Google Sign-In**
   - Create an iOS OAuth client in Google Cloud with the bundle identifier `com.korotindenys.moneyTracker`.
   - Add the reversed client ID from `GoogleService-Info.plist` to `ios/Runner/Info.plist` → `CFBundleURLTypes`.
   - If you support Android later, register the SHA-1 / SHA-256 fingerprints and download the updated `google-services.json`.
2. **Sign in with Apple**
   - Enable the `Sign in with Apple` capability in Xcode for the Runner target.
   - Ensure your Apple Developer team has the service configured for the bundle ID.
   - For simulator testing, make sure you are signed into an Apple ID that supports the feature.
3. Rebuild the app after configuration changes so the native plugins pick up the new entitlements.

## 📱 Running the App

```bash
# Run on iOS Simulator
flutter run

# Run on connected iOS device
flutter run -d <device-id>

# Build for iOS
flutter build ios
```

## 🏗️ Project Structure

```
lib/
├── core/               # Core utilities and constants
│   ├── constants/      # App colors, sizes, strings
│   ├── errors/         # Error handling
│   ├── interfaces/     # Repository interfaces
│   ├── providers/      # Riverpod providers
│   ├── routing/        # Navigation setup
│   ├── utils/          # Haptic feedback, helpers
│   └── validators/     # Form validation
├── features/          # Feature modules (clean architecture)
│   ├── auth/          # Authentication domain/usecases/providers
│   ├── dashboard/     # Dashboard tab + project creation flow
│   ├── expenses/      # Expenses tab + CRUD
│   ├── history/       # Insights & analytics
│   ├── money/         # Shared money domain models/usecases
│   ├── onboarding/    # Launch experience
│   ├── projects/      # Legacy project management (domain/data)
│   ├── workspaces/    # Workspace onboarding & setup
│   └── settings/      # Settings & account pages
└── ui/               # Reusable UI components
    ├── auth_widgets.dart
    └── widgets/       # Glassmorphic cards, buttons
```

## 📚 Documentation

- [REFACTORING.md](REFACTORING.md) - Complete refactoring details
- [IMPROVEMENT_ROADMAP.md](IMPROVEMENT_ROADMAP.md) - 6-phase development plan
- [QUICK_START_GUIDE.md](QUICK_START_GUIDE.md) - Top 3 improvements to implement today
- [VISUAL_GUIDE.md](VISUAL_GUIDE.md) - Architecture diagrams
- [MIGRATION_CHECKLIST.md](MIGRATION_CHECKLIST.md) - Migration guide

## 🔧 Development

### Code Generation

```bash
# Run code generation for Freezed models
flutter pub run build_runner build --delete-conflicting-outputs
```

### Testing

```bash
# Run all tests
flutter test

# Run with coverage
flutter test --coverage
```

## 📋 Next Steps

See [QUICK_START_GUIDE.md](QUICK_START_GUIDE.md) for the top 3 improvements to implement:

1. Lock down Google/Apple social sign-in (≈2 hours)
2. Connect the dashboard to live Firestore data (≈2.5 hours)
3. Expand automated coverage for the money flows (≈2 hours)

## 🛠️ Tech Stack

- **Framework**: Flutter 3.7.2+
- **State Management**: Riverpod 3.0.3
- **Backend**: Firebase (Auth + Firestore)
- **Routing**: go_router 16.2.5
- **Code Generation**: Freezed, json_serializable
- **UI**: Glassmorphism, Custom gradients, Cupertino widgets
- **Security**: Firebase Auth, Biometric (Face ID/Touch ID)
- **Localization**: English + Ukrainian

## 🎯 Design System

- **Primary Gradient**: Purple to Pink (`#9D50F0` → `#F050C9`)
- **Glass Effect**: Semi-transparent cards with blur
- **Typography**: SF Pro (iOS system font)
- **Haptic Feedback**: Light, Medium, Heavy impacts
- **Dark Mode**: Primary theme with accent colors

## 📄 License

Personal project - Not for distribution

---

**Built with ❤️ for iOS** 🍎
