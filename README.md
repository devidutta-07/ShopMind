# ShopMind

A smart, AI-powered shopping list application with budget tracking and expense reports.

## Features
- **Smart Shopping List:** Add, edit, and organize items by category.
- **Budget Tracking:** Set monthly budgets and track spending.
- **Expense Reports:** Visualize expenses with charts and export to PDF.
- **ShopAI:** Intelligent categorization and suggestions.
- **Cloud Sync:** Google Sign-In for profile management.

## Release Instructions (Amazon Appstore)

To build the release APK for the Amazon Appstore, follow these steps:

### 1. Prerequisites
- Ensure `android/app/upload-keystore.jks` exists.
- Ensure `android/key.properties` is configured with `keyAlias=upload`.
- Ensure Firebase SHA-1 fingerprints (Release & Debug) are added in the Firebase Console.

### 2. Build Command
Run the following command in your terminal. We use `--no-tree-shake-icons` to support dynamic category icons.

```bash
flutter clean
flutter build apk --release --no-tree-shake-icons
```

### 3. Locate APK
The optimized release APK will be generated at:
`build/app/outputs/flutter-apk/app-release.apk`

Upload this file to the Amazon Appstore.

## Development
- **Icons:** App icon is located at `web/icons/icon-123.jpeg`. Run `flutter pub run flutter_launcher_icons:main` to update.
- **AdMob:** Configure Real/Test IDs in `lib/services/ad_helper.dart`.
