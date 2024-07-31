import 'package:flutter/material.dart';

/// Creates an overlay entry for the export button.
OverlayEntry createOverlayEntry(
  BuildContext context, {
  required GlobalKey key,
  required Map<String, Function()> items,
  double width = 250.0,
}) {
  RenderBox renderBox = key.currentContext?.findRenderObject() as RenderBox;
  Offset offset = renderBox.localToGlobal(Offset.zero);
  Size size = renderBox.size;
  final children = <Widget>[];
  for (var entry in items.entries) {
    children.add(
      ListTile(
        title: Text(entry.key),
        onTap: entry.value,
      ),
    );
  }

  final windowSize = MediaQuery.sizeOf(context);
  var x = offset.dx;
  if (x > windowSize.width * 0.5) {
    x = offset.dx - width + size.width;
  }

  return OverlayEntry(
    builder: (context) => Positioned(
      left: x,
      top: offset.dy + size.height + 5.0,
      width: width,
      child: Material(
        elevation: 4.0,
        child: ListView(
          padding: EdgeInsets.zero,
          shrinkWrap: true,
          children: children,
        ),
      ),
    ),
  );
}
