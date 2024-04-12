import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_particle_system/flutter_particle_system.dart';
import 'package:flutter_particle_system/flutter_particle_system_platform_interface.dart';
import 'package:flutter_particle_system/flutter_particle_system_method_channel.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class MockFlutterParticleSystemPlatform
    with MockPlatformInterfaceMixin
    implements FlutterParticleSystemPlatform {
  @override
  Future<String?> getPlatformVersion() => Future.value('42');
}

void main() {
  final FlutterParticleSystemPlatform initialPlatform =
      FlutterParticleSystemPlatform.instance;

  test('$MethodChannelFlutterParticleSystem is the default instance', () {
    expect(initialPlatform, isInstanceOf<MethodChannelFlutterParticleSystem>());
  });

  test('getPlatformVersion', () async {
    FlutterParticleSystem flutterParticleSystemPlugin =
        const FlutterParticleSystem();
    MockFlutterParticleSystemPlatform fakePlatform =
        MockFlutterParticleSystemPlatform();
    FlutterParticleSystemPlatform.instance = fakePlatform;

    expect(await flutterParticleSystemPlugin.getPlatformVersion(), '42');
  });
}
