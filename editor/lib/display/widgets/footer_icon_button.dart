import 'package:flutter/material.dart';

/// This class creates an [IconButton] widget for the footer of the
/// screen. The icon button represents an action and when pressed, it
/// executes the provided function [onPressed].
class FooterIconButton extends StatelessWidget {
  const FooterIconButton({
    super.key,
    required this.icon,
    this.onPressed,
    this.tooltip,
    this.color,
  });

  final IconData icon;
  final VoidCallback? onPressed;
  final String? tooltip;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip ?? "",
      child: IconButton(
        padding: const EdgeInsets.all(2),
        icon: Icon(
          icon,
          size: 16,
          color: color,
        ),
        onPressed: onPressed,
      ),
    );
  }
}
