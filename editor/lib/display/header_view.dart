import 'dart:typed_data';

import 'package:editor/data/particular_editor_config.dart';
import 'package:editor/services/io.dart';
import 'package:editor/theme/theme.dart';
import 'package:flutter/material.dart';
import 'package:particular/particular.dart';

/// The header line for the application that contains the buttons for layers.
class HeaderView extends StatefulWidget {
  /// The configurations for the application.
  final Map appConfigs;

  /// The controller for the particle system.
  final ParticularController controller;

  /// The callback function for when the background image is changed.
  final Function(Uint8List) onBackroundImageChanged;

  /// Creates a footer view.
  const HeaderView(
      {super.key,
      required this.appConfigs,
      required this.controller,
      required this.onBackroundImageChanged});

  @override
  State<HeaderView> createState() => _HeaderViewState();
}

/// Creates a header view.
class _HeaderViewState extends State<HeaderView> {
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
            child: Icon(
              Icons.menu,
              color: Themes.foregroundColor,
            ),
            style: IconButton.styleFrom(backgroundColor: Colors.white10),
            items: {
              "Import configs": _importConfigs,
              "Export configs": _exportConfigs,
              "Export with textures (zipped)": _exportConfigsWithTextures,
              "Add background image": _browseBackgroundImage,
            },
          ),
          const Expanded(child: SizedBox()),
          _menuButton(
            child: const Text("Export"),
            items: {
              "Export configs": _exportConfigs,
              "Export with textures (zipped)": _exportConfigsWithTextures
            },
          ),
        ],
      ),
    );
  }

  /// Creates a menu button widget.
  ///
  /// The [child] parameter represents the child widget of the button.
  /// The [style] parameter represents the style of the button.
  /// The [items] parameter represents the map of items that will be displayed
  /// in the menu when the button is pressed.
  ///
  /// Returns a [MenuAnchor] widget that contains the button and the menu.
  Widget _menuButton({
    required Widget child,
    ButtonStyle? style,
    required Map<String, Function()> items,
  }) {
    final entries = items.entries.toList();
    // Create a menu anchor widget that contains the button and the menu.
    return MenuAnchor(
      builder: (BuildContext context, MenuController controller,
          Widget? innerChild) {
        return ElevatedButton(
          style: style ?? Themes.buttonStyle(),
          child: child,
          onPressed: () {
            if (controller.isOpen) {
              controller.close();
            } else {
              controller.open();
            }
          },
        );
      },
      // Create a list of menu item buttons that represent the items in the menu.
      menuChildren: List<MenuItemButton>.generate(
        entries.length,
        (int index) => MenuItemButton(
          onPressed: entries[index].value,
          child: Text(entries[index].key),
        ),
      ),
    );
  }

  /// Browse and import configs
  Future<void> _importConfigs() async {
    final configs = await browseConfigs(["json"]);
    if (configs != null) {
      widget.controller.addConfigLayer(configsData: configs);
    }
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

  /// Browse background image
  void _browseBackgroundImage() async {
    final files = await browseFiles();
    if (files.isNotEmpty) {
      setState(() {
        widget.onBackroundImageChanged(files.first.bytes!);
      });
    }
  }
}
