import 'package:flutter/material.dart';
import 'package:particular/particular.dart';

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
  @override
  Widget build(BuildContext context) {
    var c = widget.controller;
    return SizedBox(
        height: widget.appConfigs["timeline"]["height"],
        child: ValueListenableBuilder<List<ParticularConfigs>>(
          valueListenable: c,
          builder: (context, value, child) {
            var timeRatio =
                c.elapsedTime.clamp(0, c.timelineDuration) / c.timelineDuration;
            return Stack(
              children: [
                ReorderableListView.builder(
              buildDefaultDragHandles: false,
                  itemBuilder: (c, i) => _layerItemBuilder(i),
                  itemCount: c.value.length,
              onReorder: (int oldIndex, int newIndex) {
                    c.reOrder(oldIndex, newIndex);
              },
                ),
                Align(
                    alignment: Alignment(timeRatio * 2 - 1, 0),
                    child: Container(
                      width: 1,
                      color: Colors.white,
                      height: widget.appConfigs["timeline"]["height"],
                    ))
              ],
            );
          },
        ));
  }

  Widget _layerItemBuilder(int index) {
    final key = Key('$index');
    final layer = widget.controller.value[index];
    var emptyArea = widget.controller.timelineDuration - layer.duration;
    var positionRate = layer.startTime / emptyArea;
    return Container(
      key: key,
      height: widget.appConfigs["timeline"]["layerHeight"],
      color: Colors.black26,
      child: GestureDetector(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              color: widget.controller.selectedIndex == index
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
            Expanded(
              child: SizedBox(
                child: FractionallySizedBox(
                  alignment: Alignment(positionRate * 2 - 1, 0),
                  widthFactor: layer.duration < 0
                      ? 1
                      : layer.duration /
                          widget.controller.timelineDuration,
                  heightFactor: 0.3,
                  child: Container(color: Colors.green),
                ),
              ),
            )
          ],
        ),
        onTap: () => widget.controller.selectAt(index),
      ),
    );
  }
}
