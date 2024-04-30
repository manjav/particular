import 'package:flutter/material.dart';
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
                ReorderableListView.builder(
                  buildDefaultDragHandles: false,
                  itemBuilder: (c, i) => _layerItemBuilder(i),
                  itemCount: c.layers.length,
                  onReorder: (int oldIndex, int newIndex) {
                    c.reOrder(oldIndex, newIndex);
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
                  Text(layer.configName),
                ],
              ),
            ),
            _activeLineBuilder(layer),
          ],
        ),
        onTap: () => widget.controller.selectAt(index),
      ),
    );
  }

  Widget _activeLineBuilder(ParticularConfigs layer) {
    return ListenableBuilder(
      listenable: widget.controller.getNotifier(NotifierType.time),
      builder: (context, child) {
        var emptyArea = widget.controller.timelineDuration - layer.duration;
        var positionRate = layer.startTime / emptyArea;
        return Expanded(
          child: SizedBox(
            child: FractionallySizedBox(
              alignment: Alignment(positionRate * 2 - 1, 0),
              widthFactor: layer.duration < 0
                  ? 1
                  : layer.duration / widget.controller.timelineDuration,
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
    return ListenableBuilder(
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
    );
  }
}
