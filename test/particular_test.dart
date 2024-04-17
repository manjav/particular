import 'package:flutter_test/flutter_test.dart';
import 'package:particular/particular.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class MockParticularPlatform
    with MockPlatformInterfaceMixin
    implements ParticularPlatform {
  @override
  Future<String?> getPlatformVersion() => Future.value('42');
}

void main() {
  final ParticularPlatform initialPlatform = ParticularPlatform.instance;

  test('$MethodChannelParticular is the default instance', () {
    expect(initialPlatform, isInstanceOf<MethodChannelParticular>());
  });

  test('getPlatformVersion', () async {
    Particular plugin = const Particular();
    MockParticularPlatform fakePlatform = MockParticularPlatform();
    ParticularPlatform.instance = fakePlatform;

    expect(await plugin.getPlatformVersion(), '42');
  });
}
