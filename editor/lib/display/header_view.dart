import 'dart:typed_data';

import 'package:editor/data/particular_editor_controller.dart';
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
  OverlayEntry? _overlayEntry;
  final GlobalKey _globalkey = GlobalKey();

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
          const Expanded(child: SizedBox()),
          TapRegion(
            child: // your sub-tree that triggered the keyboard
                ElevatedButton(
              key: _globalkey,
              style: Themes.buttonStyle(),
              child: const Text("Export"),
              onPressed: () {
                _overlayEntry = _createOverlayEntry(context);
                Overlay.of(context).insert(_overlayEntry!);
              },
            ),
            onTapOutside: (event) async {
              if (_overlayEntry != null) {
                await Future.delayed(const Duration(milliseconds: 200));
                _overlayEntry?.remove();
                _overlayEntry = null;
              }
            },
          )
        ],
      ),
    );
  }

  /// Creates an overlay entry for the export button.
  OverlayEntry _createOverlayEntry(BuildContext context) {
    RenderBox renderBox =
        _globalkey.currentContext?.findRenderObject() as RenderBox;
    Offset offset = renderBox.localToGlobal(Offset.zero);
    Size size = renderBox.size;

    return OverlayEntry(
      builder: (context) => Positioned(
        left: offset.dx,
        top: offset.dy + size.height + 5.0,
        width: size.width * 2,
        child: Material(
          elevation: 4.0,
          child: ListView(
            padding: EdgeInsets.zero,
            shrinkWrap: true,
            children: <Widget>[
              ListTile(
                title: const Text("Export configs"),
                onTap: _exportConfigs,
              ),
              ListTile(
                title: const Text("Export with textures (zipped)"),
                onTap: _exportConfigsWithTextures,
              )
            ],
          ),
        ),
      ),
    );
  }

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
