# Language Switching Feature

## Overview

The app now supports dynamic language switching between English and Ukrainian.

## Implementation Details

### 1. Localization Strings Added

**English (`lib/l10n/app_en.arb`):**

- `language`: "Language"
- `languageEnglish`: "English"
- `languageUkrainian`: "Українська"
- `selectLanguage`: "Select Language"
- `languageChanged`: "Language changed to {language}"

**Ukrainian (`lib/l10n/app_uk.arb`):**

- `language`: "Мова"
- `languageEnglish`: "English"
- `languageUkrainian`: "Українська"
- `selectLanguage`: "Виберіть мову"
- `languageChanged`: "Мову змінено на {language}"

### 2. Locale Stack

**Files:** `lib/features/settings/data/**/*`, `lib/features/settings/domain/**/*`, `lib/features/settings/presentation/providers/locale_controller.dart`

- Data source reads and writes the locale preference via SharedPreferences.
- Repository converts stored data to the `AppLocale` domain entity.
- Use cases expose `load`, `save`, and `clear` operations.
- `LocaleController` (Riverpod `Notifier`) drives locale state for the UI.

### 3. Main App Integration

**File:** `lib/main.dart`

Changes:

- App wrapped with `ProviderScope`
- `MoneyApp` implemented as `ConsumerWidget`
- Watches `localeControllerProvider` for preference changes
- Falls back to system locale when no preference is stored

### 4. Settings UI

**File:** `lib/features/settings/presentation/settings_tab.dart`

Features:

- New "Language" option in GENERAL settings group
- Shows language selection dialog when tapped
- Dialog displays both English and Ukrainian options
- Visual feedback shows currently selected language
- Success notification after changing language

## How It Works

1. **Initial Load:**

   - App starts and loads saved locale from SharedPreferences
   - If no saved preference, uses system locale
   - Falls back to English if system locale not supported

2. **Changing Language:**

   - User taps "Language" in Settings
   - Dialog shows with English and Ukrainian options
   - User selects desired language
   - Selection is persisted via `LocaleController`
   - `localeControllerProvider` updates, triggering app rebuild
   - All UI text updates immediately to new language
   - Success notification shows in selected language

3. **Persistence:**
   - User's language choice is saved across app restarts
   - Stored in SharedPreferences with key `app_locale`

## UI Components

### Language Dialog

- Clean, modern design matching app theme
- Shows current selection with checkmark
- Purple accent color for selected option
- Haptic feedback on selection

### Settings Option

- Located in GENERAL section
- Globe icon (🌐) for visual recognition
- Consistent with other settings items

## Testing

To test the feature:

1. Run the app
2. Go to Settings tab
3. Tap "Language" option
4. Select a language (English or Ukrainian)
5. Observe immediate UI update
6. Restart app to verify persistence

## Future Enhancements

Possible improvements:

- Add more languages (Spanish, French, etc.)
- System language option in dialog
- Language preview before applying
- RTL language support
