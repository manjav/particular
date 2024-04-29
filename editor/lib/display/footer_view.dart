import 'package:editor/data/controllers.dart';
import 'package:editor/data/particular_editor_controller.dart';
import 'package:editor/services/io.dart';
import 'package:flutter/material.dart';

class FooterView extends StatelessWidget {
  final Map appConfigs;
  final ParticularControllers controllers;

  const FooterView(
      {super.key, required this.appConfigs, required this.controllers});

  @override
  Widget build(BuildContext context) {
        var items = <Widget>[
          _footerItem(Icons.add, () => controllers.addParticleSystem()),
          _footerItem(Icons.file_open, () async {
            final configs = await browseConfigs(["json"]);
            controllers.addParticleSystem(configs: configs);
          }),
          const SizedBox(width: 32),
        ];

        return Container(
          color: Colors.white10,
          height: appConfigs["footerHeight"],
          child: Row(children: items),
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
