import 'package:editor/data/particular_editor_config.dart';
import 'package:editor/services/io.dart';
import 'package:flutter/material.dart';
import 'package:intry/intry.dart';
import 'package:particular/particular.dart';

import 'widgets/footer_icon_button.dart';

/// The timeline view for application.
class TimelineView extends StatefulWidget {
  final Map<String, dynamic> appConfigs;
  final ParticularController controller;

  const TimelineView({
    super.key,
    required this.appConfigs,
    required this.controller,
  });

  @override
  State<TimelineView> createState() => _TimelineViewState();
}

class _TimelineViewState extends State<TimelineView> {
  /// Creates a timeline view.
  @override
  Widget build(BuildContext context) {
    var controller = widget.controller;
    return SizedBox(
        height: widget.appConfigs["timeline"]["height"],
        child: ListenableBuilder(
          listenable: controller.getNotifier(NotifierType.layer),
          builder: (context, child) {
            return Stack(
              children: [
                Container(
                  color: Colors.black12,
                  width: widget.appConfigs["timeline"]["sideWidth"],
                ),
                ReorderableListView.builder(
                  buildDefaultDragHandles: false,
                  itemBuilder: (c, i) =>
                      _layerItemBuilder(controller.layers.length - i - 1),
                  itemCount: controller.layers.length,
                  onReorder: (int oldIndex, int newIndex) =>
                      controller.reOrderLayer(oldIndex, newIndex),
                ),
                _timeSeekBarBuilder(),
              ],
            );
          },
        ));
  }

  /// Builds a layer item.
  Widget _layerItemBuilder(int index) {
    final key = Key('$index');
    final layer = widget.controller.layers[index];
    return Container(
      key: key,
      height: widget.appConfigs["timeline"]["layerHeight"],
      margin: const EdgeInsets.symmetric(vertical: 1),
      color: Colors.black26,
      child: GestureDetector(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              color: widget.controller.selectedLayerIndex == index
                  ? Colors.white30
                  : Colors.white12,
              width: widget.appConfigs["timeline"]["sideWidth"],
              child: Row(
                children: [
                  const SizedBox(width: 8),
                  Tooltip(
                    message: 'Drag to reorder',
                    child: ReorderableDragStartListener(
                      key: key,
                      index: index,
                      child: const Icon(Icons.drag_handle, size: 12),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: ListenableBuilder(
                      listenable: layer.configs.getNotifier("configName"),
                      builder: (context, child) {
                        return IntryTextField(
                          value: layer.configs.configName,
                          onChanged: (value) => layer.configs
                              .updateFromMap({"configName": value}),
                        );
                      },
                    ),
                  ),
                  FooterIconButton(
                    icon: Icons.save,
                    onPressed: () => saveConfigs(
                      configs: layer.configs.toMap(),
                      filename: layer.configs.configName,
                    ),
                    tooltip: 'Export layer',
                  ),
                  FooterIconButton(
                    icon: Icons.delete,
                    onPressed: () => widget.controller.removeLayerAt(index),
                    tooltip: 'Delete layer',
                  ),
                  /* _footerItem(
                controllers.selected!.isVisible
                    ? Icons.visibility
                    : Icons.visibility_off,
                () => controllers.toggleVisible(controllers.selectedIndex),
              ), */
                ],
              ),
            ),
            _activeLineBuilder(layer.configs),
          ],
        ),
        onTap: () => widget.controller.selectLayerAt(index),
      ),
    );
  }

  Widget _activeLineBuilder(ParticularConfigs configs) {
    var c = widget.controller;
    return ListenableBuilder(
      listenable: c.getNotifier(NotifierType.time),
      builder: (context, child) {
        var end = configs.endTime < 0 ? c.timelineDuration : configs.endTime;
        var duration = end - configs.startTime;
        var emptyArea = c.timelineDuration - duration;
        var positionRate = emptyArea <= 0 ? 0 : configs.startTime / emptyArea;
        return Expanded(
          child: SizedBox(
            child: FractionallySizedBox(
              alignment: Alignment(positionRate * 2 - 1, 0),
              widthFactor: duration / c.timelineDuration,
              heightFactor: 0.3,
              child: Container(color: Colors.green),
            ),
          ),
        );
      },
    );
  }

  Widget _timeSeekBarBuilder() {
    var c = widget.controller;
    return Positioned(
      right: 1,
      left: widget.appConfigs["timeline"]["sideWidth"],
      child: ListenableBuilder(
        listenable: widget.controller.getNotifier(NotifierType.time),
        builder: (context, child) {
          var timeRatio =
              c.elapsedTime.clamp(0, c.timelineDuration) / c.timelineDuration;
          return Align(
            alignment: Alignment(timeRatio * 2 - 1, 0),
            child: Container(
              width: 1,
              color: Colors.white,
              height: widget.appConfigs["timeline"]["height"],
            ),
          );
        },
      ),
    );
  }
}
