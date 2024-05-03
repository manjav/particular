<p align="center">
<img src="https://github.com/manjav/particular/raw/main/repo_files/logo.png" alt="Particular Logo" width="140" />
</p>
Enhance your app or game visuals with this high-performance Flutter Particles System widget. Utilize JSON or programmatic configuration, seamlessly integrating with popular particles editors for effortless customization.  
<br>
<br>
<li>Customizable (live) Particle Effects.
<li>Ready Presets (JSON Configs).
<li>Seamless Integration with Editors.
<li>Optimized Performance with 1~10k particle at frame

Whether you're a designer or developer, Particular empowers you to bring your creative visions with ease.

---

### - Some Presets:

<a href="https://github.com/manjav/particular/raw/main/example/assets">
<p float="left" align="center">
   <img width="180" src="https://github.com/manjav/particular/raw/main/repo_files/example_meteor.gif" alt="Meteor">
   <img width="180" src="https://github.com/manjav/particular/raw/main/repo_files/example_galaxy.gif" alt="Galaxy">
   <img width="180" src="https://github.com/manjav/particular/raw/main/repo_files/example_snow.gif" alt="Snow">
   <img width="180" src="https://github.com/manjav/particular/raw/main/repo_files/example_firework.gif" alt="Meteor">
  </table>
</a>

---

### - Installation
Add `particular` to your pubspec.yaml file:  
For detailed installation instructions, refer to the [installation guide](https://pub.dev/packages/particular/install) on pub.dev.
<br>

---

### - Configurate your particles
You have two options for configuring your particles:
1. <b>Using Editors:</b>

Generate your particles system configurations by [Particular Editor](https://manjav.github.io/particular/editor/web).

<a href="https://manjav.github.io/particular/editor/web">
 <p align="center">
  <td ><img src="https://github.com/manjav/particular/raw/main/repo_files/editor_left.gif"/></td>
  <td ><img src="https://github.com/manjav/particular/raw/main/repo_files/editor_right.png"/></td>
 </p>
</a>
<br>

2. <b>Programmatic Configuration:</b>  
Manually configure your particle controller in code. Refer to the following steps for more details.

---

### - Getting Started with Coding
To use this library, import `package:particular/particular.dart`.<br>
Follow these steps to integrate the particles system into your Flutter app:<br>
<b>I. Initialize the Particles Controller in `initState`:</b>
``` dart
final _particleController = ParticularController();
...
@override
void initState() {
  // Load particle configs file
  String json = await rootBundle.loadString("assets/particle.json");
  final configsData = jsonDecode(json);

  // Load particle texture file
  ByteData  bytes = await rootBundle.load("assets/${configsData["textureFileName"]}");
  ui.Image texture = await loadUIImage(bytes.buffer.asUint8List());

  // Add particles layer
  _particleController.addLayer(
    texture: frameInfo.image, // Remove in default-texture case
    configsData: configsData, // Remove in programmatic configuration case
  );
  super.initState();
}
```
<b>II. Add the `Particular` widget in your widget three:</b>
``` dart
@override
Widget build(BuildContext context) {
  return MaterialApp(
    home: Scaffold(
      backgroundColor: Colors.black,
      body: Particular(
        controller: _particleController,
      ),
    ),
  );
}
```

<b>III. Live Update Particle Layer:</b>
``` dart
_particleController.layers.first.update(
    maxParticles: 100,
    lifespan:1.2,
    speed:100,
    angle:30,
);
```

---

This revised README provides clear installation instructions, options for configuring particles, and steps for integrating and customizing the particle system in your Flutter app. If you have any questions or need further assistance, don't hesitate to ask!