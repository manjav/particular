import 'package:flutter/material.dart';
import 'package:particular/particular.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  // Add controller to change particle
  final _particleController = ParticularController();

  @override
  void initState() {
    _loadParticleAssets();
    super.initState();
  }

  // Load configs and texture of particle
  Future<void> _loadParticleAssets() async {
    await _particleController.addParticleSystem();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        backgroundColor: Colors.black,
        body: Column(
          children: [
            Container(
              color: Colors.black,
              child: ValueListenableBuilder(
                valueListenable: _particleController,
                builder: (context, value, child) {
                  return Stack(
                    children: [
                      for (var configs in _particleController.value)
                        Particular(
                          configs: configs,
                          controller: _particleController,
                        ),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
