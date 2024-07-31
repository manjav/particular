import 'package:editor/data/inspector.dart';
import 'package:editor/data/particular_editor_controller.dart';
import 'package:editor/theme/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:intry/intry.dart';
import 'package:particular/particular.dart';

import '../services/io.dart';

/// The inspector view for the application
class InspactorView extends StatefulWidget {
  final Map appConfigs;
  final ParticularController controller;
  const InspactorView({
    super.key,
    required this.appConfigs,
    required this.controller,
  });

  @override
  State<InspactorView> createState() => _InspactorViewState();
}

class _InspactorViewState extends State<InspactorView> {
  final _selectedColor = ValueNotifier<String?>(null);
  int _selectedTabIndex = 0;
  ParticularLayer? _selectedLayer;

  @override
  void initState() {
    _selectTab(_selectedTabIndex);
    super.initState();
  }

  void _selectTab(int index) {
    _selectedTabIndex = index;
    final node = widget.appConfigs["inspector"]["components"][index];
    final children = <Inspector>[];
    for (var line in node["children"]) {
      children.add(Inspector(
        line["ui"] ?? "input",
        line["min"],
        line["max"],
        line["type"],
        line["title"] ?? "",
        line["inputs"] ?? {},
      ));
    }
    Inspector.list.value = InspectorList(node["title"], children);
  }

  @override
  Widget build(BuildContext context) {
    var themeData = Theme.of(context);
    return SizedBox(
      width: widget.appConfigs["inspector"]["width"],
      child: ListenableBuilder(
        listenable: widget.controller.getNotifier(NotifierType.layer),
        builder: (context, child) {
          _selectedLayer = widget.controller.selectedLayer;
          if (widget.controller.selectedLayer == null) {
            return const SizedBox();
          }
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _tabBarBuilder(),
              _inspactorListBuilder(themeData),
              _colorPickerBuilder(),
            ],
          );
        },
      ),
    );
  }

  Widget _tabBarBuilder() {
    return ValueListenableBuilder(
      valueListenable: Inspector.list,
      builder: (context, value, child) {
        return Container(
          margin: const EdgeInsets.only(bottom: 10),
          color: Colors.black12,
          child: Row(
            children: [
              _tabItemBuilder(0, Icons.stream),
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
      valueListenable: Inspector.list,
      builder: (context, value, child) {
        return Expanded(
          child: ListView.builder(
            itemCount: value.children.length,
            itemBuilder: (context, index) =>
                _inspectorItemBuilder(themeData, value.children[index]),
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
            ][_selectedLayer!.configs.getParam("emitterType").index]) {
      var items = <Widget>[];
      _inputLineBuilder(
        inspector,
        items,
        themeData,
        (themeData, inspector, entry) =>
            _addInputs(themeData, inspector, entry),
      );

      return Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                inspector.title.isEmpty
                    ? const SizedBox()
                    : Text(inspector.title,
                        style: themeData.textTheme.titleMedium),
                const SizedBox(height: 2),
                Row(children: items),
              ],
            ),
          ),
          items.isEmpty ? const SizedBox(height: 12) : const Divider(height: 14)
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
    final entries = inspector.inputs.entries.toList();
    for (var i = 0; i < entries.length; i++) {
      var entry = entries[i];
      children.add(_getText(entry.key.toTitleCase(), themeData));
      children.add(const SizedBox(width: 8));
      children.add(
        Expanded(
          child: ListenableBuilder(
            listenable: _selectedLayer!.configs.getNotifier(entry.value),
            builder: (c, w) => inspectorBuilder(themeData, inspector, entry),
          ),
        ),
      );
      if (i < entries.length - 1) {
        children.add(const SizedBox(width: 20));
      }
    }
  }

  Widget _addInputs(ThemeData themeData, Inspector inspector,
      MapEntry<String, dynamic> entry) {
    if (inspector.ui == "input") {
      return IntryNumericField(
        slidingSpeed: 1,
        min: inspector.min,
        max: inspector.max,
        decoration: IntryFieldDecoration.outline(context),
        value: _selectedLayer!.configs.getParam(entry.value).toDouble(),
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
              alignment: Alignment.center,
              value: item,
              child: _getText(
                  item.toString().split('.').last.toTitleCase(), themeData)))
          .toList();
      return DropdownButtonFormField(
        decoration: const InputDecoration(
          contentPadding: EdgeInsets.symmetric(horizontal: 12),
          border: OutlineInputBorder(),
        ),
        itemHeight: 48,
        items: items,
        value: _selectedLayer!.configs.getParam(entry.value),
        onChanged: (dynamic selected) {
          _selectedLayer!.configs.updateFromMap({entry.value: selected});
          if (entry.value == "emitterType") {
            setState(() {});
          }
        },
      );
    } else if (inspector.ui == "color") {
      return ElevatedButton(
        style: Themes.buttonStyle(
            color: _selectedLayer!.configs.getParam(entry.value).getColor()),
        onPressed: () => _selectedColor.value = entry.value,
        child: const SizedBox(),
      );
    } else {
      return ElevatedButton(
        style: Themes.buttonStyle(),
        child: _getText("${entry.value}".toTitleCase(), themeData),
        onPressed: () async {
          final result = await browseImage();
          if (result.$2 != null) {
            _selectedLayer!.configs.update(textureFileName: result.$1);
            _selectedLayer!.texture = result.$2!;
          }
        },
      );
    }
  }

  Text _getText(String text, ThemeData themeData) =>
      Text(text, style: themeData.textTheme.labelMedium);

  void _updateParticleParam(String key, num value) {
    var param = _selectedLayer!.configs.getParam(key);
    _selectedLayer!.configs
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
              pickerColor: _selectedLayer!.configs.getParam(value).getColor(),
              onColorChanged: (color) {
                _selectedLayer!.configs.updateFromMap({
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
}

extension StringExtension on String {
  String toTitleCase() => "${this[0].toUpperCase()}${substring(1)}";
}
