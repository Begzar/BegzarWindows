import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'bcore_platform_interface.dart';

/// An implementation of [BcoreDesktopPlatform] that uses method channels.
class MethodChannelBcoreDesktop extends BcoreDesktopPlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('bcore');

  @override
  Future<String?> getSingPath() async {
    final version = await methodChannel.invokeMethod<String>('getSingPath');
    return version;
  }
}
