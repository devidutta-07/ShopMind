import 'dart:io';

class AdHelper {
  static bool useRealAdUnit = true;

  static String get bannerAdUnitId {
    if (Platform.isAndroid) {
      if (useRealAdUnit) {
        return 'ca-app-pub-8615053668355084/7884162129';
      }
      return 'ca-app-pub-3940256099942544/6300978111';
    } else if (Platform.isIOS) {
      if (useRealAdUnit) {
        return 'ca-app-pub-8615053668355084/7884162129';
      }
      return 'ca-app-pub-3940256099942544/2934735716';
    } else {
      throw UnsupportedError('Unsupported platform');
    }
  }
}
