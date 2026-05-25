import 'dart:io' show Platform;
class PlatformUtils {
  PlatformUtils._();
  static bool get isMobile=>Platform.isAndroid||Platform.isIOS;
}
