import 'package:plugin_platform_interface/plugin_platform_interface.dart';
import 'bcore_method_channel.dart';

abstract class BcoreDesktopPlatform extends PlatformInterface {
  /// Constructs a BcoreDesktopPlatform.
  BcoreDesktopPlatform() : super(token: _token);

  static final Object _token = Object();

  static BcoreDesktopPlatform _instance =
      MethodChannelBcoreDesktop();

  /// The default instance of [BcoreDesktopPlatform] to use.
  ///
  /// Defaults to [MethodChannelBcoreDesktop].
  static BcoreDesktopPlatform get instance => _instance;

  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [BcoreDesktopPlatform] when
  /// they register themselves.
  static set instance(BcoreDesktopPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  Future<String?> getSingPath() {
    throw UnimplementedError('platformVersion() has not been implemented.');
  }
}
