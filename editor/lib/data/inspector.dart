import 'package:flutter/material.dart';

class InspectorList {
  final String title;
  final List<Inspector> children;
  InspectorList(this.title, this.children);
}

class Inspector {
  final String? ui;
  final String? type;
  final String title;
  final Map<String, dynamic> inputs;
  final double? min;
  final double? max;

  Inspector(
    this.ui,
    this.min,
    this.max,
    this.type,
    this.title,
    this.inputs,
  );

  static final ValueNotifier<InspectorList> list =
      ValueNotifier(InspectorList("", []));
}
