# Particular: Flutter Particle System
<table>
<tr>
<td width = 160><img src="https://github.com/manjav/particular/raw/main/repo_files/logo.png" alt="Particular Logo"></td>
<td>
<td> 
Enhance your app or game visuals with this high-performance Flutter particle system widget. Utilize JSON or programmatic configuration, seamlessly integrating with popular particle editors for effortless customization.

<br>
<b>Key Features:</b>
<li>Customizable (live) Particle Effects.
<li>Ready Presets (JSON Configs).
<li>Seamless Integration with Editors.
<li>Optimized Performance with 1~10k particle at frame

<br>
Whether you're a designer or developer, Particular empowers you to bring your creative visions with ease.
</table>

---

### - Some Presets:

<a href="https://github.com/manjav/particular/raw/main/example/assets">
  <table>
    <td><img src="https://github.com/manjav/particular/raw/main/repo_files/example_meteor.gif" alt="Meteor"></td>
    <td><img src="https://github.com/manjav/particular/raw/main/repo_files/example_galaxy.gif" alt="Galaxy"></td>
    <td><img src="https://github.com/manjav/particular/raw/main/repo_files/example_snow.gif" alt="Snow"></td>
    <td><img src="https://github.com/manjav/particular/raw/main/repo_files/example_firework.gif" alt="Meteor"></td>
  </table>
</a>

---

### - Installation
Add `Particular` to your pubspec.yaml file:  
For detailed installation instructions, refer to the [installation guide](https://pub.dev/packages/particular/install) on pub.dev.
<br>

---

### - Configurate your particle!
You have two options for configuring your particles:
1. <b>Using Editors:</b>  
Generate particle configurations using popular particle editors such as [Particle 2dx Editor](http://effecthub.com/editor/particle2dx/index_en.php) or [Particle Designer](https://www.71squared.com/particledesigner). (We're working on dedicated editor as soon as possible!)
2. <b>Programmatic Configuration:</b>  
Manually configure your particle controller in code. Refer to the following steps for more details.

<br>

---

### - Getting Started with Coding
Follow these steps to integrate the particle system into your Flutter app:

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
Particular(
    width: 600,
    height: 600,
    color: Colors.black,
    controller: controller,
)
```

<b>III. Live Update Particle System:</b>
``` dart
controller.update(
    maxParticles: 100,
    duration:1.5,
    lifespan:1.2,
    angle:30,
    speed:100,
);
```
<br>

---

<br>
This revised README provides clear installation instructions, options for configuring particles, and steps for integrating and customizing the particle system in your Flutter app. If you have any questions or need further assistance, don't hesitate to ask!