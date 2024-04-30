import 'package:editor/data/particular_editor_controller.dart';
import 'package:editor/services/io.dart';
import 'package:flutter/material.dart';
import 'package:particular/particular.dart';

/// The footer line for the application that contains the buttons for layers.
class FooterView extends StatelessWidget {
  /// The configurations for the application.
  final Map appConfigs;

  /// The controller for the particle system.
  final ParticularController controllers;

  /// Creates a footer view.
  const FooterView(
      {super.key, required this.appConfigs, required this.controllers});

  /// Creates a footer view.
  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: controllers.getNotifier(NotifierType.layer),
      builder: (context, child) {
        var items = <Widget>[
          _footerItem(Icons.add, () => controllers.addParticleSystem()),
          _footerItem(Icons.file_open, () async {
            final configs = await browseConfigs(["json"]);
            controllers.addParticleSystem(configs: configs);
          }),
          const SizedBox(width: 32),
        ];

        if (!controllers.isEmpty) {
          items.addAll(
            [
              _footerItem(
                Icons.save,
                () => saveConfigs(
                    configs: controllers.selected!.getConfigs(),
                    filename: controllers.selected!.configName),
              ),
              /* _footerItem(
                controllers.selected!.isVisible
                    ? Icons.visibility
                    : Icons.visibility_off,
                () => controllers.toggleVisible(controllers.selectedIndex),
              ), */
              _footerItem(
                Icons.close,
                () => controllers.removeAt(controllers.selectedIndex),
              ),
            ],
          );
        }
        return Container(
          color: Colors.white10,
          height: appConfigs["footerHeight"],
          child: Row(children: items),
        );
      },
    );
  }

  /// This function creates an [IconButton] widget for the footer of the
  /// screen. The icon button represents an action and when pressed, it
  /// executes the provided function [onPressed].
  Widget _footerItem(IconData icon, Function() onPressed) {
    // IconButton configuration
    return IconButton(
      padding: const EdgeInsets.all(2),
      icon: Icon(icon, size: 12),
      onPressed: () => onPressed(),
    );
  }
}
