import 'package:flutter/material.dart';
import 'package:particular/particular.dart';

class TimelineView extends StatefulWidget {
  final Map<String, dynamic> appConfigs;
  final ParticularController controllers;
  const TimelineView({
    super.key,
    required this.appConfigs,
    required this.controllers,
  });

  @override
  State<TimelineView> createState() => _TimelineViewState();
}

class _TimelineViewState extends State<TimelineView> {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
        height: widget.appConfigs["timeline"]["height"],
        child: ValueListenableBuilder<List<ParticularConfigs>>(
          valueListenable: widget.controllers,
          builder: (context, value, child) {
            return Stack(
              children: [
                ReorderableListView.builder(
              buildDefaultDragHandles: false,
                  itemBuilder: (c, i) => _layerItemBuilder(i),
              itemCount: widget.controllers.value.length,
              onReorder: (int oldIndex, int newIndex) {
                widget.controllers.reOrder(oldIndex, newIndex);
              },
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
