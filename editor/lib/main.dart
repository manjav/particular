import 'dart:convert';
import 'dart:ui' as ui;

import 'package:editor/data/inspector.dart';
import 'package:editor/data/particular_editor_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image/image.dart' as image;
import 'package:intry/intry.dart';
import 'package:particular/particular.dart';

void main() {
  runApp(const EditorApp());
}

class EditorApp extends StatefulWidget {
  const EditorApp({super.key});

  @override
  State<EditorApp> createState() => _EditorAppState();
}

class _EditorAppState extends State<EditorApp> {
  // Add controller to change particle
  final _particleController = ParticularEditorController();
  final _selectedInspactorColumn = ValueNotifier([]);
  int _selectedTypeIndex = 0;
  int _selectedTabIndex = 1;
  List _inspactorData = [];

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
    setState(() => _selectTab(_selectedTabIndex));
  }

  void _selectTab(int index) {
    _selectedTabIndex = index;
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
            _inspactorBuilder(),
          ],
        ),
      ),
    );
  }

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
                    child: Particular(
                      controller: _particleController,
                    ),
                  ),
                ),
    );
  }

  Widget _inspactorBuilder() {
    var themeData = Theme.of(context);
    return Container(
      width: 320,
      color: themeData.colorScheme.inverseSurface,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _tabBarBuilder(),
          _inspactorListBuilder(themeData),
          const Expanded(child: SizedBox()),
        ],
      ),
    );
  }

  Widget _tabBarBuilder() {
    return Container(
      color: Colors.black12,
      child: Row(
        children: [
          _tabItemBuilder(0, Icons.animation),
          _tabItemBuilder(1, Icons.circle),
        ],
      ),
    );
  }

  Widget _tabItemBuilder(int index, IconData icon) {
    return Expanded(
      child: IconButton(
        icon: Icon(icon),
        onPressed: () => _selectTab(index),
      ),
    );
  }

  Widget _inspactorListBuilder(ThemeData themeData) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Expanded(
      child: ValueListenableBuilder(
        valueListenable: _selectedInspactorColumn,
        builder: (context, value, child) => Column(
          children: [
            const SizedBox(height: 16),
            Text(
                ["Emitter Settings", "Particle Settings"][_selectedTabIndex],
            ),
            const SizedBox(height: 16),
            for (Inspector inspector in value)
              _inspectorItemBuilder(themeData, inspector),
          ],
          ),
        ),
      ),
    );
  }

  Widget _inspectorItemBuilder(ThemeData themeData, Inspector inspector) {
    if (inspector.type == null ||
        inspector.type == ["gravity", "radial"][_selectedTypeIndex]) {
      var items = <Widget>[];
      _addInputs(inspector, items, themeData);
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          inspector.title.isEmpty
              ? const SizedBox()
              : _getText(inspector.title, themeData),
          const SizedBox(height: 4),
          Row(children: items),
          const SizedBox(height: 12),
        ],
      );
    }
    return const SizedBox();
  }

  void _addInputs(
      Inspector inspector, List<Widget> children, ThemeData themeData) {
    if (inspector.ui == "input") {
      for (var entry in inspector.inputs.entries) {
        children.add(_getText(entry.key, themeData));
        children.add(const SizedBox(width: 4));
        children.add(
          Expanded(
            child: ListenableBuilder(
              listenable: _particleController,
              builder: (c, w) {
                return NumericIntry(
                  fractionDigits: 1,
                  changeSpeed: 1,
                  value: _particleController.getParam(entry.value).toDouble(),
                  decoration: NumericIntryDecoration.outline(context),
                  onChanged: (double value) =>
                      _updateParticleParam(entry.value, value),
                );
              },
            ),
          ),
        );
        children.add(const SizedBox(width: 12));
      }
    } else if (inspector.ui == "dropdown") {
      List<String> values = inspector.inputs.values.first.split(',');
      children.add(_getText(inspector.inputs.keys.first, themeData));
      children.add(const Expanded(child: SizedBox()));
      var items = values
          .map(
            (name) => DropdownMenuItem<String>(
                value: name,
                child: _getText(
                    "${name[0].toUpperCase()}${name.substring(1)}", themeData)),
          )
          .toList();
      children.add(
        SizedBox(
          width: 200,
          height: 46,
          child: InputDecorator(
            decoration: const InputDecoration(border: OutlineInputBorder()),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                items: items,
                value: values[_selectedTypeIndex],
                onChanged: (String? selected) {
                  _selectedTypeIndex = values.indexOf(selected!);
                  _updateParticleParam("emitterType", _selectedTypeIndex);
                  setState(() {});
                },
              ),
            ),
          ),
        ),
      );
    } else {
      
    }
  }

  Text _getText(String text, ThemeData themeData) =>
      Text(text, style: themeData.primaryTextTheme.labelSmall);

  void _updateParticleParam(String key, num value) {
    var param = _particleController.getParam(key);
    _particleController
        .updateFromMap({key: param is int ? value.toInt() : value});
  }
}
