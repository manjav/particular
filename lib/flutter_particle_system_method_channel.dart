import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'flutter_particle_system_platform_interface.dart';

/// An implementation of [FlutterParticleSystemPlatform] that uses method channels.
class MethodChannelFlutterParticleSystem extends FlutterParticleSystemPlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('flutter_particle_system');

  @override
  Future<String?> getPlatformVersion() async {
    final version = await methodChannel.invokeMethod<String>('getPlatformVersion');
    return version;
  }
}
