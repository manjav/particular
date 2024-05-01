<p align="center">
<img src="https://github.com/manjav/particular/raw/main/repo_files/logo.png" alt="Particular Logo" width="140" />
</p>
Enhance your app or game visuals with this high-performance Flutter particle system widget. Utilize JSON or programmatic configuration, seamlessly integrating with popular particle editors for effortless customization.  
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

### - Configurate your particle
You have two options for configuring your particles:
1. <b>Using Editor:</b>  
Generate your particle system configurations by [Particular Editor](https://manjav.github.io/particular/editor/web).

<a href="https://manjav.github.io/particular/editor/web">
<p align="center"><img src="https://github.com/manjav/particular/raw/main/repo_files/editor.gif" alt="Particular Editor" /></p>
</a>
<br>

2. <b>Programmatic Configuration:</b>  
Manually configure your particle controller in code. Refer to the following steps for more details.

---

### - Getting Started with Coding
To use this library, import `package:intry_numeric/intry_numeric.dart`.<br>
Follow these steps to integrate the particle system into your Flutter app:<br>
<b>I. Initialize the Particle Controller in `initState`:</b>
``` dart
final controller = ParticularController();
...
@override
void initState() {

  controller.initialize(
    texture: frameInfo.image,
    configs: configsMap, // Remove in programmatic configuration case
  );
  super.initState();
}
```
<b>II. Add the `Particular` Widget in Your Widget Three:</b>
``` dart
Particular(controller: controller)
```

<b>III. Live Update Particle System:</b>
``` dart
controller.update(
    maxParticles: 100,
    lifespan:1.2,
    angle:30,
    speed:100,
);
```

---

This revised README provides clear installation instructions, options for configuring particles, and steps for integrating and customizing the particle system in your Flutter app. If you have any questions or need further assistance, don't hesitate to ask!