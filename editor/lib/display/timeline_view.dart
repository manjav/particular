import 'package:editor/data/particular_editor_controller.dart';
import 'package:editor/services/io.dart';
import 'package:flutter/material.dart';

class TimelineView extends StatefulWidget {
  final Map<String, dynamic> configs;
  final ParticularControllers controllers;
  const TimelineView({
    super.key,
    required this.configs,
    required this.controllers,
  });

  @override
  State<TimelineView> createState() => _TimelineViewState();
}

class _TimelineViewState extends State<TimelineView> {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
        height: 200,
        child: ValueListenableBuilder<List<ParticularEditorController>>(
          valueListenable: widget.controllers,
          builder: (context, value, child) {
            return ReorderableListView.builder(
              buildDefaultDragHandles: false,
              itemBuilder: _layerItemBuilder,
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
    final name = "Layer ${controller.index + 1}";
    return Container(
      key: key,
      height: widget.configs["timeline"]["layerHeight"],
      color: Colors.black12,
      child: GestureDetector(
        child: Row(
          children: [
            Container(
              color: widget.controllers.selectedIndex == index
                  ? Colors.white30
                  : Colors.white12,
              width: widget.configs["timeline"]["sideWidth"],
              child: Row(
                children: [
                  const SizedBox(width: 8),
                  ReorderableDragStartListener(
                    key: key,
                    index: index,
                    child: const Icon(Icons.drag_handle, size: 12),
                  ),
                  const SizedBox(width: 8),
                  Text(name),
                  const Expanded(child: SizedBox()),
                  IconButton(
                    onPressed: () => widget.controllers.toggleVisible(index),
                    icon: Icon(
                      controller.isVisible
                          ? Icons.visibility
                          : Icons.visibility_off,
                      size: 12,
                    ),
                  ),
                  IconButton(
                    onPressed: () => widget.controllers.removeAt(index),
                    icon: const Icon(
                      Icons.close,
                      size: 12,
                    ),
                  ),
                  IconButton(
                    onPressed: () => saveConfigs(
                        configs: controller.getConfigs(), filename: name),
                    icon: const Icon(
                      Icons.save,
                      size: 12,
                    ),
                  ),
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
