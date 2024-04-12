import 'package:flutter/material.dart';
import 'package:flutter_particle_system/flutter_particle_system.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  var emitter = const Offset(300, 300);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: Align(
          alignment: Alignment.topCenter,
          child: GestureDetector(
            onPanUpdate: (details) {
              emitter = details.localPosition;
              setState(() {});
            },
            child: FlutterParticleSystem(
              color: Colors.black,
              configs: "assets/fire.json",
              width: 600,
              height: 600,
              emitterX: emitter.dx,
              emitterY: emitter.dy,
            ),
          ),
        ),
      ),
    );
  }
}
