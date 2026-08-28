import '../core/wind_codec.dart';

abstract final class GaleConfig {
  static const String appTitle = 'Beakstorm Run';
  static const String bundleId = 'com.beakstormrun.beakstormrungame';
  static const String iosStoreId = '6802349579';

  static const int pushSnoozeSeconds = 331847;
  static const int organicRecheckSeconds = 8;
  static const int savedUrlExpiryDays = 9;
  static const int configPostTimeoutMs = 18400;
  static const int attPromptDelayMs = 540;
  static const int installSignalTimeoutMs = 7400;

  static const String privacyUrl =
      'https://beakstormrun.com/privacy-policy.html';
  static const String supportUrl = 'https://beakstormrun.com/support.html';

  static const String _endpoint =
      'rCaKAz6OQLVo2k4L+mikPvQ9k0J60QXjNNVNGfxwqHGUGq4=';
  static const String _gcd =
      'rCaKAz6OQLVt3EsT7XflLek/lUo4yw/8NdVNGrVwoSyQE7I/MvAuzkuweXWHDMQ=';
  static const String _appsFlyerKey = 'nCCtECDWDcBc0VkL3X6gIf0Bp2EN1w==';
  static const String _firebaseProject = '8mvJRX+NWa0yhh5Y';

  static const String _uaProduct = 'iT2EGiHYDrU/kR8=';
  static const String _uaPlatformPrefix = '7DuuGyLaCqEq/H81qXWbJPYhgwwb4Q==';
  static const String _uaPlatformSuffix = 'qDuVFm35Dvkq8HxA0TU=';
  static const String _uaEngine =
      'hSKOHyjjCvhB1ltPvyz+Yqhh1xl0miHGT/tuW7p1pjSBUpk2Dv8gkw==';
  static const String _uaMobileToken = 'iT2cGiHRQKs/+h5UsQ==';
  static const String _safariVersion = '9WrQRA==';
  static const String _safariTail = '8mLKXXw=';
  static const String _uaAppIdTok = 'pSKOGimb';
  static const String _uaAppNameTok = 'pSKOHSzZCrU=';
  static const String _uaAppLabel = 'hjefGD7AAOhnn30V5w==';

  static String get endpoint => unfoldGust(_endpoint);
  static String get gcdBase => unfoldGust(_gcd);
  static String get appsFlyerKey => unfoldGust(_appsFlyerKey);
  static String get firebaseProjectNumber => unfoldGust(_firebaseProject);

  static String get uaProduct => unfoldGust(_uaProduct);
  static String get uaPlatformPrefix => unfoldGust(_uaPlatformPrefix);
  static String get uaPlatformSuffix => unfoldGust(_uaPlatformSuffix);
  static String get uaEngine => unfoldGust(_uaEngine);
  static String get uaMobileToken => unfoldGust(_uaMobileToken);
  static String get safariVersion => unfoldGust(_safariVersion);
  static String get safariTail => unfoldGust(_safariTail);
  static String get uaAppIdTok => unfoldGust(_uaAppIdTok);
  static String get uaAppNameTok => unfoldGust(_uaAppNameTok);
  static String get uaAppLabel => unfoldGust(_uaAppLabel);

  static String get storeToken => 'id$iosStoreId';

  static bool get grayCredentialsReady =>
      endpoint.isNotEmpty &&
      appsFlyerKey.isNotEmpty &&
      firebaseProjectNumber.isNotEmpty;
}
