import 'package:editor/data/particular_editor_controller.dart';
import 'package:editor/services/io.dart';
import 'package:flutter/material.dart';
import 'package:intry/intry.dart';
import 'package:particular/particular.dart';

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
    var c = widget.controller;
    return SizedBox(
        height: widget.appConfigs["timeline"]["height"],
        child: ListenableBuilder(
          listenable: c.getNotifier(NotifierType.layer),
          builder: (context, child) {
            return Stack(
              children: [
                Container(
                  color: Colors.black12,
                  width: widget.appConfigs["timeline"]["sideWidth"],
                ),
                ReorderableListView.builder(
                  reverse: true,
                  buildDefaultDragHandles: false,
                  itemBuilder: (c, i) => _layerItemBuilder(i),
                  itemCount: c.layers.length,
                  onReorder: (int oldIndex, int newIndex) {
                    c.reOrderLayer(oldIndex, newIndex);
                  },
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
                  ReorderableDragStartListener(
                    key: key,
                    index: index,
                    child: const Icon(Icons.drag_handle, size: 12),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: ListenableBuilder(
                      listenable: layer.configs.getNotifier("configName"),
                      builder: (context, child) {
                        return NumericIntry(
                          value: layer.configs.configName,
                          inputType: IntryInputType.text,
                          onTextChanged: (value) => layer.configs
                              .updateFromMap({"configName": value}),
                        );
                      },
                    ),
                  ),
                  _buttonBuilder(
                    Icons.save,
                    () => saveConfigs(
                        configs: layer.configs.getData(),
                        filename: layer.configs.configName),
                  ),
                  _buttonBuilder(
                    Icons.delete,
                    () => widget.controller.removeLayerAt(index),
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

  Widget _buttonBuilder(IconData icon, Function() onPressed) =>
      IconButton(icon: Icon(icon, size: 12), onPressed: () => onPressed());
}
