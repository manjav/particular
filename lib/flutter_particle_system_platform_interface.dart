import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'flutter_particle_system_method_channel.dart';

abstract class FlutterParticleSystemPlatform extends PlatformInterface {
  /// Constructs a FlutterParticleSystemPlatform.
  FlutterParticleSystemPlatform() : super(token: _token);

  static final Object _token = Object();

  static FlutterParticleSystemPlatform _instance = MethodChannelFlutterParticleSystem();

  /// The default instance of [FlutterParticleSystemPlatform] to use.
  ///
  /// Defaults to [MethodChannelFlutterParticleSystem].
  static FlutterParticleSystemPlatform get instance => _instance;

  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [FlutterParticleSystemPlatform] when
  /// they register themselves.
  static set instance(FlutterParticleSystemPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  Future<String?> getPlatformVersion() {
    throw UnimplementedError('platformVersion() has not been implemented.');
  }
}
