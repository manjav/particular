import 'dart:convert';
import 'dart:ui' as ui;

import 'package:editor/data/inspector.dart';
import 'package:editor/data/particular_editor_controller.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
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
  final _selectedColor = ValueNotifier<String?>(null);
  int _selectedTabIndex = 0;
  Map _appConfigs = {};

  @override
  void initState() {
    _loadAppConfigs();
    _loadDefaultTexture();
    super.initState();
  }

  // Load configs data for app from json
  _loadAppConfigs() async {
    var json = await rootBundle.loadString("assets/app_configs.json");
    _appConfigs = Map.castFrom(jsonDecode(json));
  }

  void _selectTab(int index) {
    _selectedTabIndex = index;
    var list = <Inspector>[];
    for (var line in _appConfigs["inspector"]["components"][index]) {
      list.add(Inspector(
        line["ui"] ?? "input",
        line["type"],
        line["title"] ?? "",
        line["inputs"] ?? {},
      ));
    }
    _selectedInspactorColumn.value = list;
  }

  /// Load default particle texture
  Future<void> _loadDefaultTexture() async {
    final ByteData assetImageByteData =
        await rootBundle.load("assets/texture.png");
    final image = await _loadUIImage(assetImageByteData.buffer.asUint8List());
    _particleController.initialize(texture: image);
  }

  @override
  Widget build(BuildContext context) {
    if (_appConfigs.isEmpty) {
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
      toolbarHeight: _appConfigs["appBarHeight"],
      leadingWidth: 240,
      title: Text("Particular Editor",
          style: Theme.of(context).primaryTextTheme.bodyMedium),
      backgroundColor: Theme.of(context).tabBarTheme.indicatorColor,
    );
  }

  Widget _canvasBuilder() {
    return Expanded(
      child: GestureDetector(
        onPanUpdate: (details) {
          _particleController.update(
            emitterX: details.localPosition.dx,
            emitterY: details.localPosition.dy,
          );
        },
        onTapDown: (details) {
          _particleController.update(
            emitterX: details.localPosition.dx,
            emitterY: details.localPosition.dy,
            startTime: -1,
          );
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
      width: 330,
      color: themeData.colorScheme.inverseSurface,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _tabBarBuilder(),
          _inspactorListBuilder(themeData),
          const Expanded(child: SizedBox()),
          _colorPickerBuilder(),
        ],
      ),
    );
  }

  Widget _tabBarBuilder() {
    return ValueListenableBuilder(
      valueListenable: _selectedInspactorColumn,
      builder: (context, value, child) {
        return Container(
          color: Colors.black12,
          child: Row(
            children: [
              _tabItemBuilder(0, Icons.snowing),
              _tabItemBuilder(1, Icons.color_lens),
            ],
          ),
        );
      },
    );
  }

  Widget _tabItemBuilder(int index, IconData icon) {
    return Expanded(
      child: IconButton(
        color:
            _selectedTabIndex != index ? Theme.of(context).splashColor : null,
        icon: Icon(icon),
        onPressed: () => _selectTab(index),
      ),
    );
  }

  Widget _inspactorListBuilder(ThemeData themeData) {
    return ValueListenableBuilder(
      valueListenable: _selectedInspactorColumn,
      builder: (context, value, child) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Column(
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
        );
      },
    );
  }

  Widget _inspectorItemBuilder(ThemeData themeData, Inspector inspector) {
    if (inspector.type == null ||
        inspector.type ==
            [
              "gravity",
              "radial"
            ][_particleController.getParam("emitterType").index]) {
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

  void _inputLineBuilder(
    Inspector inspector,
    List<Widget> children,
    ThemeData themeData,
    Widget Function(ThemeData themeData, Inspector inspector,
            MapEntry<String, dynamic> entry)
        inspectorBuilder,
  ) {
    for (var entry in inspector.inputs.entries) {
      children.add(_getText(entry.key.toTitleCase(), themeData));
      children.add(const SizedBox(width: 8));
      children.add(
        Expanded(
          child: ListenableBuilder(
            listenable: _particleController,
            builder: (c, w) => inspectorBuilder(themeData, inspector, entry),
          ),
        ),
      );
      children.add(const SizedBox(width: 12));
    }
  }

  Widget _addInputs(ThemeData themeData, Inspector inspector,
      MapEntry<String, dynamic> entry) {
    if (inspector.ui == "input") {
          return NumericIntry(
            changeSpeed: 1,
            decoration: NumericIntryDecoration.outline(context),
            value: _particleController.getParam(entry.value).toDouble(),
        onChanged: (double value) => _updateParticleParam(entry.value, value),
      );
    } else if (inspector.ui == "dropdown") {
          List values = switch (entry.value) {
            "blendFunctionSource" ||
            "blendFunctionDestination" =>
              BlendFunction.values,
        "renderBlendMode" || "textureBlendMode" => BlendMode.values,
            _ => EmitterType.values,
          };
          var items = values
              .map((item) => DropdownMenuItem(
                  value: item,
                  child: _getText(item.toString().toTitleCase(), themeData)))
              .toList();
          return InputDecorator(
        decoration: const InputDecoration(
            border: OutlineInputBorder(),
            contentPadding: EdgeInsets.symmetric(horizontal: 8)),
            child: DropdownButtonHideUnderline(
              child: DropdownButton(
            itemHeight: 56,
                items: items,
                value: _particleController.getParam(entry.value),
                onChanged: (dynamic selected) =>
                    _particleController.updateFromMap({entry.value: selected}),
              ),
            ),
          );
    } else if (inspector.ui == "color") {
          return IconButton(
            icon: Icon(
              Icons.circle,
              color: _particleController.getParam(entry.value).getColor(),
            ),
            onPressed: () => _selectedColor.value = entry.value,
          );
    } else {
      // Button
      return OutlinedButton(
        onPressed: _browseTexture,
        child: _getText("${entry.value}".toTitleCase(), themeData),
      );
    }
  }

  Future<void> _browseTexture() async {
    FilePickerResult? result =
        await FilePicker.platform.pickFiles(type: FileType.image);

    if (result != null) {
      PlatformFile file = result.files.first;
      final image = await _loadUIImage(file.bytes!);
      _particleController.update(texture: image);
    }
  }

    }
  }

  Text _getText(String text, ThemeData themeData) =>
      Text(text, style: themeData.primaryTextTheme.labelSmall);

  void _updateParticleParam(String key, num value) {
    var param = _particleController.getParam(key);
    _particleController
        .updateFromMap({key: param is int ? value.toInt() : value});
  }

  Widget _colorPickerBuilder() {
    return ValueListenableBuilder<String?>(
      valueListenable: _selectedColor,
      builder: (context, value, child) {
        if (value == null) {
          return const SizedBox();
        }
        return TapRegion(
          onTapOutside: (event) => _selectedColor.value = null,
          child: Container(
            color: Colors.black12,
            padding: const EdgeInsets.all(16),
            child: SlidePicker(
              showIndicator: false,
              showSliderText: false,
              pickerColor: _particleController.getParam(value).getColor(),
              onColorChanged: (color) {
                _particleController.updateFromMap({
                  value: ARGB(color.alpha / 255, color.red / 255,
                      color.green / 255, color.blue / 255)
                });
              },
            ),
          ),
        );
      },
    );
  }

  Future<ui.Image> _loadUIImage(Uint8List bytes) async {
    image.Image? baseSizeImage = image.decodeImage(bytes);
    image.Image resizeImage = image.copyResize(baseSizeImage!,
        height: baseSizeImage.width, width: baseSizeImage.height);
    ui.Codec codec =
        await ui.instantiateImageCodec(image.encodePng(resizeImage));
    ui.FrameInfo frameInfo = await codec.getNextFrame();
    return frameInfo.image;
  }
}

extension StringExtension on String {
  String toTitleCase() => "${this[0].toUpperCase()}${substring(1)}";
}
