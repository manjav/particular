import 'package:editor/data/particular_editor_controller.dart';
import 'package:editor/services/io.dart';
import 'package:flutter/material.dart';
import 'package:particular/particular.dart';

class FooterView extends StatelessWidget {
  final Map appConfigs;
  final ParticularController controllers;

  const FooterView(
      {super.key, required this.appConfigs, required this.controllers});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<List<ParticularConfigs>>(
      valueListenable: controllers,
      builder: (context, value, child) {
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

  Widget _footerItem(IconData icon, Function() onPressed) {
    return IconButton(
      padding: const EdgeInsets.all(2),
      icon: Icon(icon, size: 12),
      onPressed: () => onPressed(),
    );
  }
}
