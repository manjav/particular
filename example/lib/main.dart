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
            GestureDetector(
              onPanUpdate: (details) {
                _particleController.update(
                    emitterX: details.localPosition.dx,
                    emitterY: details.localPosition.dy);
              },
              onTapDown: (details) {
                _particleController.update(
                    emitterX: details.localPosition.dx,
                    emitterY: details.localPosition.dy);
              },
              child: SizedBox(
                width: 600,
                height: 600,
                child: Particular(
                  controller: _particleController,
                ),
              ),
            ),
            TextButton(
              onPressed: () {
                _particleController.update(
                    maxParticles:
                        _particleController.maxParticles > 500 ? 300 : 13000);
              },
              child: ListenableBuilder(
                listenable: _particleController,
                builder: (c, w) =>
                    Text("${_particleController.maxParticles} particles."),
              ),
            )
          ],
        ),
      ),
    );
  }
}
