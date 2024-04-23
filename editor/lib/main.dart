import 'dart:convert';
import 'dart:ui' as ui;

import 'package:editor/data/inspector.dart';
import 'package:editor/data/particular_editor_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image/image.dart' as image;
import 'package:particular/particular.dart';
import 'package:intry/intry.dart';

void main() {
  runApp(const EdittorApp());
}

class EdittorApp extends StatefulWidget {
  const EdittorApp({super.key});

  @override
  State<EdittorApp> createState() => _EdittorAppState();
}

class _EdittorAppState extends State<EdittorApp> {
  // Add controller to change particle
  final _particleController = ParticularEditorController();
  final _selectedInspactorColumn = ValueNotifier([]);

  @override
  void initState() {
    _loadInspectorsData();
    _loadParticleAssets();
    super.initState();
  }

  // Load configs from json
  void _loadInspectorsData() async {
    var json = await rootBundle.loadString("assets/inspector.json");
    _inspactorData = List.castFrom(jsonDecode(json));
    setState(() => _selectTab(0));
  }

  void _selectTab(int index) {
    _selectedColumsIndex = index;
    var list = <Inspector>[];
    for (var line in _inspactorData[index]) {
      list.add(Inspector(
        line["ui"] ?? "input",
        line["type"],
        line["title"] ?? "",
        line["inputs"],
      ));
    }
    _selectedInspactorColumn.value = list;
  }

  Future<void> _loadParticleAssets() async {
    // Load json config
    var json = await rootBundle.loadString("assets/meteor.json");
    var configsMap = jsonDecode(json);

    // Load particle textu
    final ByteData assetImageByteData =
        await rootBundle.load("assets/${configsMap["textureFileName"]}");
    image.Image? baseSizeImage =
        image.decodeImage(assetImageByteData.buffer.asUint8List());
    image.Image resizeImage = image.copyResize(baseSizeImage!,
        height: baseSizeImage.width, width: baseSizeImage.height);
    ui.Codec codec =
        await ui.instantiateImageCodec(image.encodePng(resizeImage));
    ui.FrameInfo frameInfo = await codec.getNextFrame();

    _particleController.initialize(
      texture: frameInfo.image,
      configs: configsMap,
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_inspactorData.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }
    return MaterialApp(
      title: "Particular Editor",
      theme: ThemeData.dark(useMaterial3: true),
      home: Scaffold(
        appBar: _appBarBuilder(),
        body: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _canvasBuilder(),
  AppBar _appBarBuilder() {
    return AppBar(
      toolbarHeight: 48,
      title: Text(
        "Particular Editor",
        style: Theme.of(context).primaryTextTheme.headlineSmall,
      ),
      backgroundColor: Theme.of(context).tabBarTheme.indicatorColor,
    );
  }

  Widget _canvasBuilder() {
    return Expanded(
      child: GestureDetector(
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
        child: Container(
          color: Colors.black,
          // alignment: Alignment.center,
          // width: 600,
          // height: 310,
                    child: Particular(
                      controller: _particleController,
                    ),
                  ),
                ),
    );
  }

            ),
            _inspactorBuilder()
          ],
        ),
      ),
    );
  }

  Widget _inspactorBuilder() {
    return ListenableBuilder(
      listenable: _particleController,
      builder: (c, w) => Column(
        children: [
          NumericIntry(
            value: _particleController.maxParticles,
            onChanged: (int value) {
              _particleController.update(maxParticles: value);
            },
          ),
        ],
      ),
    );
  }
}
