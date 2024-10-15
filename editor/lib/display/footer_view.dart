import 'package:editor/theme/theme.dart';
import 'package:flutter/material.dart';
import 'package:particular/particular.dart';

import 'widgets/footer_icon_button.dart';

/// The footer line for the application that contains the buttons for layers.
class FooterView extends StatelessWidget {
  /// The configurations for the application.
  final Map appConfigs;

  /// The controller for the particle system.
  final ParticularController controller;

  /// Creates a footer view.
  const FooterView({
    super.key,
    required this.appConfigs,
    required this.controller,
  });

  /// Creates a footer view.
  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: controller.getNotifier(NotifierType.layer),
      builder: (context, child) {
        return Container(
          color: Colors.white10,
          height: appConfigs["footerHeight"],
          child: Row(
            children: [
              FooterIconButton(
                icon: Icons.refresh,
                onPressed: () => controller.resetTick(),
                tooltip: 'Reset time',
              ),
              // SizedBox(width: appConfigs["timeline"]["sideWidth"] - 40),
              FooterIconButton(
                icon: Icons.add,
                onPressed: () => controller.addLayer(),
                tooltip: 'Add layer',
              ),
              FooterIconButton(
                icon: Icons.all_inclusive,
                onPressed: () => controller.setIsLooping(!controller.isLooping),
                tooltip:
                    controller.isLooping ? 'Disable looping' : 'Enable looping',
                color: controller.isLooping ? Themes.activeColor : null,
              ),
            ],
          ),
        );
      },
    );
  }
}
