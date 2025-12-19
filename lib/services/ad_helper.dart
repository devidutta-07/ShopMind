import 'dart:io';

class AdHelper {
  // ============================================================
  // INSTRUCTIONS FOR REAL ADS:
  // 1. Get your REAL Ad Unit ID from AdMob Console (Ad units -> Banner).
  // 2. Replace the 'return' string below with your real ID.
  // 3. Make sure you also updated AndroidManifest.xml with your App ID.
  // ============================================================

  static String get bannerAdUnitId {
    // To verify your code is working, use Google's Test IDs.
    // Once your app is approved on the store and you see impressions 
    // in your AdMob console, switch to your REAL ID.

    // Set to true to use your real ID, false to use the Test ID.
    // NOTE: Switched to FALSE to fix "Error Code 3: No Fill" during testing.
    // Real ads often fail to load on side-loaded APKs or unregistered test devices.
    const bool useRealAdUnit = true;

    if (Platform.isAndroid) {
      if (useRealAdUnit) {
        return 'ca-app-pub-8615053668355084/7884162129';
      } else {
        // Test ID
        return 'ca-app-pub-3940256099942544/6300978111';
      }
    } else if (Platform.isIOS) {
      if (useRealAdUnit) {
        return 'ca-app-pub-8615053668355084/7884162129';
      } else {
        // Test ID
        return 'ca-app-pub-3940256099942544/2934735716';
      }
    } else {
      throw UnsupportedError('Unsupported platform');
    }
  }
}
