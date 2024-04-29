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

  Widget _layerItemBuilder(BuildContext context, int index) {
    final key = Key('$index');
    final controller = widget.controllers.value[index];
    return Container(
      key: key,
      height: widget.appConfigs["timeline"]["layerHeight"],
      color: Colors.black26,
      child: GestureDetector(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              color: widget.controllers.selectedIndex == index
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
                  Text(controller.configName),
                  const Expanded(child: SizedBox()),
                ],
              ),
            ),
          ],
        ),
        onTap: () => widget.controllers.selectAt(index),
      ),
    );
  }
}
