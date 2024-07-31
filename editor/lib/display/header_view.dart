import 'dart:typed_data';

import 'package:editor/data/particular_editor_controller.dart';
import 'package:editor/display/context_menu.dart';
import 'package:editor/services/io.dart';
import 'package:editor/theme/theme.dart';
import 'package:flutter/material.dart';
import 'package:particular/particular.dart';

class HeaderView extends StatefulWidget {
  /// The configurations for the application.
  final Map appConfigs;

  /// The controller for the particle system.
  final ParticularController controller;

  /// Creates a footer view.
  const HeaderView(
      {super.key, required this.appConfigs, required this.controller});

  @override
  State<HeaderView> createState() => _HeaderViewState();
}

class _HeaderViewState extends State<HeaderView> {
  final Map<String, GlobalKey> _overlayKeys = {
    "Export": GlobalKey(),
    "Menu": GlobalKey()
  };
  final Map<String, OverlayEntry> _overlayEntries = {};

  /// Creates a footer view.
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      height: widget.appConfigs["appBarHeight"],
      color: Colors.white10,
      child: Row(
        children: [
          Image.asset("assets/favicon.png"),
          _menuButton(
            title: "Menu",
            width: 250,
            child: const Icon(Icons.menu),
            style: IconButton.styleFrom(backgroundColor: Colors.white10),
            items: {
              "Import configs": _importConfigs,
              "Export configs": _exportConfigs,
              "Export with textures (zipped)": _exportConfigsWithTextures,
              "Add background image": _importConfigs,
            },
          ),
          const Expanded(child: SizedBox()),
          _menuButton(title: "Export", items: {
            "Export configs": _exportConfigs,
            "Export with textures (zipped)": _exportConfigsWithTextures
          }),
        ],
      ),
    );
  }

  Widget _menuButton({
    required String title,
    required Map<String, Function()> items,
    ButtonStyle? style,
    Widget? child,
    double width = 220.0,
  }) {
    return TapRegion(
      child: ElevatedButton(
        key: _overlayKeys[title],
        style: style ?? Themes.buttonStyle(),
        child: child ?? Text(title),
        onPressed: () {
          _overlayEntries[title] = createOverlayEntry(
            context,
            key: _overlayKeys[title]!,
            items: items,
            width: width,
          );
          Overlay.of(context).insert(_overlayEntries[title]!);
        },
      ),
      onTapOutside: (event) async {
        if (_overlayEntries.containsKey(title)) {
          await Future.delayed(const Duration(milliseconds: 200));
          _overlayEntries[title]?.remove();
          _overlayEntries.remove(title);
        }
      },
    );
  }

  void _importConfigs() {}

  /// Save configs without textures
  void _exportConfigs() {
    var layersConfigs = [];
    for (var i = 0; i < widget.controller.layers.length; i++) {
      layersConfigs.add(widget.controller.layers[i].configs.toMap());
    }
    saveConfigs(configs: layersConfigs);
  }

  /// Save configs with textures (zipped)
  void _exportConfigsWithTextures() {
    final layersConfigs = [];
    final texures = <String, Uint8List>{};
    for (var i = 0; i < widget.controller.layers.length; i++) {
      layersConfigs.add(widget.controller.layers[i].configs.toMap());
      var textureName = widget.controller.layers[i].configs.textureFileName;

      if (!texures.containsKey(textureName)) {
        texures[textureName] = widget.controller.layers[i].textureBytes!;
      }
    }
    saveConfigsWithTextures(configs: layersConfigs, textures: texures);
  }
}
