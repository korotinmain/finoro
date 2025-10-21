# 🍎 iOS Development Guide

## Overview

This Money Tracker project is **iOS-focused** for the next 6 months. All development, testing, and optimization efforts are centered on delivering an exceptional iOS experience.

---

## 🛠️ Development Setup

### Requirements

- **macOS** (Ventura 13.0+)
- **Xcode** (15.0+)
- **CocoaPods** (1.11.0+)
- **Flutter SDK** (3.7.2+)

### Initial Setup

```bash
# Install CocoaPods if not already installed
sudo gem install cocoapods

# Clone and setup project
git clone <repo-url>
cd money_tracker
flutter pub get

# Setup iOS dependencies
cd ios
pod install
cd ..

# Generate localization files
flutter gen-l10n

# Open iOS project in Xcode (optional)
open ios/Runner.xcworkspace
```

---

## 🚀 Running the App

### Using Flutter CLI

```bash
# List available iOS simulators
flutter devices

# Run on default simulator
flutter run

# Run on specific simulator
flutter run -d "iPhone 15 Pro"

# Run on connected physical device
flutter run -d <device-id>

# Run in release mode
flutter run --release
```

### Using Xcode

1. Open `ios/Runner.xcworkspace` in Xcode
2. Select your target device/simulator
3. Click Run (⌘R)

---

## 📱 iOS-Specific Features to Implement

### Phase 1: Core iOS Experience (Next 2 Weeks)

- [ ] Haptic feedback for button interactions
- [ ] Native iOS sharing sheet for data export
- [ ] iOS-style pull-to-refresh
- [ ] Native iOS date/time pickers
- [ ] Cupertino-style alerts and action sheets

### Phase 2: iOS Polish (Weeks 3-4)

- [ ] SF Symbols integration (where appropriate)
- [ ] Context menus (long-press actions)
- [ ] Swipe actions on transaction items
- [ ] iOS keyboard shortcuts
- [ ] Adaptive layout for iPad

### Phase 3: iOS Advanced Features (Months 2-3)

- [ ] Widget support (Home Screen & Lock Screen)
- [ ] Siri Shortcuts integration
- [ ] Face ID / Touch ID for app lock
- [ ] iCloud sync (optional)
- [ ] Handoff support between devices

### Phase 4: App Store Preparation (Months 4-5)

- [ ] App Store screenshots & preview videos
- [ ] App Store description & keywords
- [ ] Privacy policy & terms of service
- [ ] TestFlight beta testing
- [ ] App Store submission

---

## 🎨 iOS Design Guidelines

### Navigation

- Use bottom tab bar (currently implemented)
- Add swipe-back gestures
- Implement modal presentations with proper iOS styles

### Typography

- Use SF Pro (system font) - already default in Flutter
- Follow iOS text size categories for accessibility

### Colors

- Support both Light and Dark mode
- Use iOS semantic colors where appropriate
- Current custom gradient is fine for brand identity

### Interactions

- Add haptic feedback (light, medium, heavy)
- Use iOS-native gestures
- Implement context menus for actions

### Layout

- Support safe areas (already implemented)
- Handle keyboard properly
- Support landscape orientation
- Responsive design for iPad

---

## 🔧 iOS-Specific Code Examples

### Add Haptic Feedback

```dart
import 'package:flutter/services.dart';

// Light impact (for selections)
HapticFeedback.lightImpact();

// Medium impact (for success actions)
HapticFeedback.mediumImpact();

// Heavy impact (for important actions)
HapticFeedback.heavyImpact();

// Selection changed
HapticFeedback.selectionClick();
```

### Use Cupertino Widgets

```dart
import 'package:flutter/cupertino.dart';

// Cupertino Alert Dialog
showCupertinoDialog(
  context: context,
  builder: (context) => CupertinoAlertDialog(
    title: Text('Delete Transaction'),
    content: Text('Are you sure?'),
    actions: [
      CupertinoDialogAction(
        child: Text('Cancel'),
        onPressed: () => Navigator.pop(context),
      ),
      CupertinoDialogAction(
        isDestructiveAction: true,
        child: Text('Delete'),
        onPressed: () {
          // Delete action
          Navigator.pop(context);
        },
      ),
    ],
  ),
);

// Cupertino Action Sheet
showCupertinoModalPopup(
  context: context,
  builder: (context) => CupertinoActionSheet(
    title: Text('Choose Category'),
    actions: [
      CupertinoActionSheetAction(
        child: Text('Food'),
        onPressed: () => Navigator.pop(context, 'Food'),
      ),
      CupertinoActionSheetAction(
        child: Text('Transport'),
        onPressed: () => Navigator.pop(context, 'Transport'),
      ),
    ],
    cancelButton: CupertinoActionSheetAction(
      child: Text('Cancel'),
      onPressed: () => Navigator.pop(context),
    ),
  ),
);
```

### Native iOS Date Picker

```dart
import 'package:flutter/cupertino.dart';

void _showDatePicker(BuildContext context) {
  showCupertinoModalPopup(
    context: context,
    builder: (context) => Container(
      height: 250,
      color: CupertinoColors.systemBackground.resolveFrom(context),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              CupertinoButton(
                child: Text('Cancel'),
                onPressed: () => Navigator.pop(context),
              ),
              CupertinoButton(
                child: Text('Done'),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
          Expanded(
            child: CupertinoDatePicker(
              mode: CupertinoDatePickerMode.date,
              initialDateTime: DateTime.now(),
              onDateTimeChanged: (DateTime newDate) {
                // Handle date change
              },
            ),
          ),
        ],
      ),
    ),
  );
}
```

### Swipe Actions (Slidable Package)

Add to `pubspec.yaml`:

```yaml
dependencies:
  flutter_slidable: ^3.0.0
```

Usage:

```dart
import 'package:flutter_slidable/flutter_slidable.dart';

Slidable(
  key: ValueKey(transaction.id),
  endActionPane: ActionPane(
    motion: const ScrollMotion(),
    children: [
      SlidableAction(
        onPressed: (context) {
          // Edit action
        },
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        icon: Icons.edit,
        label: 'Edit',
      ),
      SlidableAction(
        onPressed: (context) {
          // Delete action
          HapticFeedback.mediumImpact();
        },
        backgroundColor: Colors.red,
        foregroundColor: Colors.white,
        icon: Icons.delete,
        label: 'Delete',
      ),
    ],
  ),
  child: TransactionListItem(transaction: transaction),
);
```

---

## 🧪 Testing on iOS

### Simulators

```bash
# Launch specific simulator
xcrun simctl boot "iPhone 15 Pro"
open -a Simulator

# Hot reload works great
flutter run --hot
```

### Physical Devices

1. Connect iPhone/iPad via USB
2. Trust computer on device
3. In Xcode: Sign the app with your Apple ID
   - Open `ios/Runner.xcworkspace`
   - Select Runner target
   - Go to "Signing & Capabilities"
   - Select your team
4. Run: `flutter run`

### TestFlight (Later)

```bash
# Build for TestFlight
flutter build ios --release

# Archive in Xcode
# Upload to App Store Connect
# Invite beta testers
```

---

## 📦 iOS Build & Deployment

### Debug Build

```bash
flutter build ios --debug
```

### Release Build

```bash
# Create release build
flutter build ios --release

# Build IPA for distribution
flutter build ipa --release
```

### Build Configuration

File: `ios/Runner/Info.plist`

- App name
- Bundle identifier
- Permissions (Camera, Photos, Notifications, etc.)
- Supported orientations
- Minimum iOS version (currently 12.0)

### App Icons

Icons are managed via `flutter_launcher_icons` (iOS-only now):

```bash
# Generate iOS app icons
flutter pub run flutter_launcher_icons
```

---

## 🔐 iOS Permissions

### Configure in `ios/Runner/Info.plist`

```xml
<!-- Camera (for receipt scanning) -->
<key>NSCameraUsageDescription</key>
<string>We need camera access to scan receipts</string>

<!-- Photo Library (for saving/loading) -->
<key>NSPhotoLibraryUsageDescription</key>
<string>We need photo access to save receipts</string>

<!-- Face ID (for app security) -->
<key>NSFaceIDUsageDescription</key>
<string>Authenticate to access your financial data</string>

<!-- Notifications -->
<key>UIBackgroundModes</key>
<array>
  <string>remote-notification</string>
</array>
```

---

## 🎯 iOS Performance Optimization

### Tips for Smooth 60fps

1. **Use const constructors** wherever possible
2. **Avoid rebuilding expensive widgets** - use keys
3. **Profile using Flutter DevTools**
   ```bash
   flutter run --profile
   # Open DevTools
   ```
4. **Use `RepaintBoundary`** for complex animations
5. **Optimize images** - use appropriate sizes
6. **Lazy load lists** - use `ListView.builder`

### Memory Management

```bash
# Monitor memory usage
flutter run --profile
# Open DevTools > Memory tab
```

---

## 🐛 iOS-Specific Debugging

### Common Issues

**Issue**: App crashes on launch

```bash
# Clean build
flutter clean
cd ios && pod deintegrate && pod install && cd ..
flutter run
```

**Issue**: White screen / blank screen

- Check Firebase configuration
- Verify `GoogleService-Info.plist` is in `ios/Runner/`
- Check Info.plist configurations

**Issue**: Keyboard issues

```dart
// Dismiss keyboard on tap outside
GestureDetector(
  onTap: () => FocusScope.of(context).unfocus(),
  child: YourWidget(),
)
```

### Xcode Logs

```bash
# View iOS system logs
xcrun simctl spawn booted log stream --level debug
```

---

## 📊 iOS Analytics & Monitoring

### Firebase Crashlytics (Recommended)

Add to `pubspec.yaml`:

```yaml
dependencies:
  firebase_crashlytics: ^4.1.3
```

Setup:

```dart
// In main.dart
import 'package:firebase_crashlytics/firebase_crashlytics.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  // Enable Crashlytics
  FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterFatalError;

  runApp(const MoneyApp());
}
```

---

## 🎨 iOS Design Resources

### Apple Resources

- [Human Interface Guidelines](https://developer.apple.com/design/human-interface-guidelines/ios)
- [SF Symbols](https://developer.apple.com/sf-symbols/)
- [iOS 17 Design Resources](https://developer.apple.com/design/resources/)

### Flutter iOS Resources

- [Cupertino Widgets](https://docs.flutter.dev/development/ui/widgets/cupertino)
- [Platform-specific code](https://docs.flutter.dev/platform-integration/platform-channels)

---

## ✅ iOS-Focused Checklist

### Must Have (Weeks 1-4)

- [x] iOS app icons configured
- [x] Firebase iOS setup
- [ ] Haptic feedback on key actions
- [ ] Cupertino-style pickers and alerts
- [ ] Swipe actions on transactions
- [ ] Pull-to-refresh
- [ ] Dark mode support
- [ ] Safe area handling
- [ ] Keyboard handling

### Nice to Have (Months 2-3)

- [ ] Widgets (Home Screen)
- [ ] Siri Shortcuts
- [ ] Face ID / Touch ID
- [ ] iPad optimization
- [ ] Landscape support
- [ ] Context menus
- [ ] Share sheet integration
- [ ] iCloud sync

### Pre-Launch (Months 4-6)

- [ ] App Store assets ready
- [ ] Privacy policy
- [ ] TestFlight beta testing
- [ ] Performance optimization
- [ ] Crashlytics integrated
- [ ] Analytics setup
- [ ] App Store submission ready

---

## 🚀 Quick Commands Reference

```bash
# Daily development
flutter run                          # Run on default device
flutter run --hot                    # Enable hot reload
flutter logs                         # View logs

# Building
flutter build ios --debug           # Debug build
flutter build ios --release         # Release build
flutter build ipa                   # IPA for TestFlight

# Maintenance
flutter clean                       # Clean build artifacts
cd ios && pod install && cd ..     # Update iOS dependencies
flutter pub get                     # Get dependencies
flutter pub upgrade                # Upgrade packages

# Code generation
flutter gen-l10n                   # Generate localizations
flutter pub run build_runner build # Generate Freezed models

# Testing
flutter test                       # Run tests
flutter analyze                    # Static analysis
```

---

## 📞 Support

For iOS-specific Flutter issues:

- [Flutter iOS Documentation](https://docs.flutter.dev/platform-integration/ios)
- [Flutter iOS Samples](https://github.com/flutter/samples)
- Stack Overflow: tag `flutter` + `ios`

---

**Focus**: Deliver an exceptional iOS app experience! 🍎✨
