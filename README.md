<p align="center">
  <img src="https://github.com/manjav/particular/raw/main/repo_files/logo.png" alt="Particular Logo"/>
</p>

# Particular: Flutter Particle System

 Enhance your app or game visuals with this high-performance Flutter `particle system` widget. Utilize JSON or programmatic configuration, seamlessly integrating with popular particle editors for effortless customization.

### - Samples:
|   Meteor   |   Galaxy   |   Snow   |  Firework  |
|:-----------:|:-----------:|:-----------:|:-----------:|
[![](https://github.com/manjav/particular/raw/main/repo_files/example_meteor.gif)](https://github.com/manjav/particular/raw/main/example/assets/meteor.json)|[![](https://github.com/manjav/particular/raw/main/repo_files/example_galaxy.gif)](https://github.com/manjav/particular/raw/main/example/assets/galaxy.json)|[![](https://github.com/manjav/particular/raw/main/repo_files/example_snow.gif)](https://github.com/manjav/particular/raw/main/example/assets/snow.json)|[![](https://github.com/manjav/particular/raw/main/repo_files/example_firework.gif)](https://github.com/manjav/particular/raw/main/example/assets/firework.json)


### - Installation
To integrate the particular package into your project, follow these steps:

Add particular to your pubspec.yaml file:
``` yaml
dependencies:
  particular: ^latest_version
```
<br/>

Install the package by running:
```bash
flutter pub get
```
For detailed installation instructions, refer to the [installation guide](https://pub.dev/packages/particular/install) on pub.dev.
<br/><br/>

---

### - Configurate your particle!
You have two options for configuring your particles:
1. <b>Using Particle Editors:</b>  
Generate particle configurations using popular particle editors such as [Particle 2dx Editor](http://www.effecthub.com/particle2dx) or [Particle Designer](https://www.71squared.com/particledesigner). (We're working on dedicated editor as soon as possible!)
2. <b>Programmatic Configuration:</b>  
Manually configure your particle controller in code. Refer to the following steps for more details.

---

### - Getting Started with Coding
Follow these steps to integrate the particle system into your Flutter app:

#### I. Initialize the Particle Controller in `initState`:
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
#### II. Add the `Particular` Widget in Your Widget Three:
``` dart
Particular(
    width: 600,
    height: 600,
    color: Colors.black,
    controller: controller,
)
```

#### III. Live Update Particle System:
``` dart
controller.update(
    maxParticles: 100,
    duration:1.5,
    lifespan:1.2,
    angle:30,
    speed:100,
);
```

---

This revised README provides clear installation instructions, options for configuring particles, and steps for integrating and customizing the particle system in your Flutter app. If you have any questions or need further assistance, don't hesitate to ask!