import 'package:flutter/material.dart';
import 'package:flutter_particle_system/flutter_particle_system.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: Scaffold(
        body: Align(
          alignment: Alignment.topCenter,
          child: FlutterParticleSystem(
            color: Colors.black,
            configs: "assets/fire.json",
          ),
        ),
      ),
    );
  }
}
