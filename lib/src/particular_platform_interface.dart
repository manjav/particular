import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'particular_method_channel.dart';

abstract class ParticularPlatform extends PlatformInterface {
  /// Constructs a ParticularPlatform.
  ParticularPlatform() : super(token: _token);

  static final Object _token = Object();

  static ParticularPlatform _instance = MethodChannelParticular();

  /// The default instance of [ParticularPlatform] to use.
  ///
  /// Defaults to [MethodChannelParticular].
  static ParticularPlatform get instance => _instance;

  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [ParticularPlatform] when
  /// they register themselves.
  static set instance(ParticularPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  Future<String?> getPlatformVersion() {
    throw UnimplementedError('platformVersion() has not been implemented.');
  }
}
