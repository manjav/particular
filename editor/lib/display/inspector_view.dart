import 'package:editor/data/inspector.dart';
import 'package:editor/data/particular_editor_controller.dart';
import 'package:editor/services/io.dart';
import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:intry/intry.dart';
import 'package:particular/particular.dart';

class InspactorView extends StatefulWidget {
  final Map configs;
  final ParticularEditorController controller;
  const InspactorView({
    super.key,
    required this.configs,
    required this.controller,
  });

  @override
  State<InspactorView> createState() => _InspactorViewState();
}

class _InspactorViewState extends State<InspactorView> {
  final _selectedColor = ValueNotifier<String?>(null);
  int _selectedTabIndex = 0;

  @override
  void initState() {
    _selectTab(_selectedTabIndex);
    super.initState();
  }

  void _selectTab(int index) {
    _selectedTabIndex = index;
    final node = widget.configs["inspector"]["components"][index];
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
      width: widget.configs["inspector"]["width"],
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
      valueListenable: Inspector.list,
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
      valueListenable: Inspector.list,
      builder: (context, value, child) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Column(
            children: [
              const SizedBox(height: 12),
              Text(value.title),
              const SizedBox(height: 12),
              for (var inspector in value.children)
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
            ][widget.controller.getParam("emitterType").index]) {
      var items = <Widget>[];
      _inputLineBuilder(
        inspector,
        items,
        themeData,
        (themeData, inspector, entry) =>
            _addInputs(themeData, inspector, entry),
      );

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          inspector.title.isEmpty
              ? const SizedBox()
              : Text(inspector.title,
                  style: themeData.primaryTextTheme.labelSmall!
                      .copyWith(fontSize: 8)),
          const SizedBox(height: 2),
          Row(children: items),
          const SizedBox(height: 6),
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
            listenable: widget.controller.getNotifier(entry.value),
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
        slidingSpeed: 1,
        min: inspector.min,
        max: inspector.max,
        decoration: NumericIntryDecoration.outline(context),
        value: widget.controller.getParam(entry.value).toDouble(),
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
              child: _getText(
                  item.toString().split('.').last.toTitleCase(), themeData)))
          .toList();
      return InputDecorator(
        decoration: const InputDecoration(
            border: OutlineInputBorder(),
            contentPadding: EdgeInsets.symmetric(horizontal: 8)),
        child: DropdownButtonHideUnderline(
          child: DropdownButton(
            itemHeight: 48,
            items: items,
            value: widget.controller.getParam(entry.value),
            onChanged: (dynamic selected) {
              widget.controller.updateFromMap({entry.value: selected});
              if (entry.value == "emitterType") {
                setState(() {});
              }
            },
          ),
        ),
      );
    } else if (inspector.ui == "color") {
      return _buttonBuilder(
        themeData,
        color: widget.controller.getParam(entry.value).getColor(),
        onTap: () => _selectedColor.value = entry.value,
      );
    } else {
      // Button
      return _buttonBuilder(
        themeData,
        child: _getText("${entry.value}".toTitleCase(), themeData),
        onTap: () async {
          final image = await browseImage();
          if (image != null) {
            widget.controller.update(texture: image);
          }
        },
      );
    }
  }

  Widget _buttonBuilder(
    ThemeData themeData, {
    Color? color,
    Widget? child,
    required Function() onTap,
  }) {
    return InkWell(
      onTap: () => onTap(),
      child: Container(
        height: 28,
        margin: const EdgeInsets.symmetric(vertical: 2),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: color ?? themeData.splashColor,
          shape: BoxShape.rectangle,
          borderRadius: const BorderRadius.all(Radius.circular(4)),
          border: Border.all(width: 1, color: themeData.splashColor),
        ),
        child: child,
      ),
    );
  }

  Text _getText(String text, ThemeData themeData) =>
      Text(text, style: themeData.primaryTextTheme.labelSmall);

  void _updateParticleParam(String key, num value) {
    var param = widget.controller.getParam(key);
    widget.controller
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
              pickerColor: widget.controller.getParam(value).getColor(),
              onColorChanged: (color) {
                widget.controller.updateFromMap({
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
