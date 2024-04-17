import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'particular_platform_interface.dart';

/// An implementation of [ParticularPlatform] that uses method channels.
class MethodChannelParticular extends ParticularPlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('particular');

  @override
  Future<String?> getPlatformVersion() async {
    final version =
        await methodChannel.invokeMethod<String>('getPlatformVersion');
    return version;
  }
}
