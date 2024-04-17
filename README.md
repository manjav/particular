<p align="center">
  <img src="https://github.com/manjav/particular/raw/main/repo_files/logo.png" alt="Particular Logo"/>
</p>

### Overview
The <b>Particular</b> is a high performance particle effects flutter widget that can configure  bot with `config.json` and programmatically. 

### Samples:
|Meteor|Galaxy|Snow|Firework|
|:-:|:-:|:-:|:-:|
[![](https://github.com/manjav/particular/raw/main/repo_files/example_meteor.gif)](https://github.com/imaNNeo/fl_chart/blob/main/repo_files/documentations/line_chart.md#sample-1-source-code)|[![](https://github.com/manjav/particular/raw/main/repo_files/example_galaxy.gif)](https://github.com/imaNNeo/fl_chart/blob/main/repo_files/documentations/line_chart.md#sample-1-source-code)|[![](https://github.com/manjav/particular/raw/main/repo_files/example_snow.gif)](https://github.com/imaNNeo/fl_chart/blob/main/repo_files/documentations/line_chart.md#sample-1-source-code)|[![](https://github.com/manjav/particular/raw/main/repo_files/example_firework.gif)](https://github.com/imaNNeo/fl_chart/blob/main/repo_files/documentations/line_chart.md#sample-1-source-code)


## Let's get started
First of all, you need to add the `particular` in your project. In order to do that, follow [this guide](https://pub.dev/packages/particular/install).


Easy to use: just write a simple `onTick` handler to manage a list of particles.
Architected to be highly extensible. Utilizes `CustomPainter` and `drawAtlas` to
offer exceptional performance.

``` dart
// Add controller to change particle 
final _particleController = ParticularController();
...

_particleController.initialize(
    texture: frameInfo.image,
    configs: configsMap,
);

// Add Particular widget in your widget three
Particular(
    width: 600,
    height: 600,
    color: Colors.black,
    controller: _particleController,
)
```

Also you can update your particle with update controller.
``` dart
_particleController.update(
    maxParticles: 100,
    duration:1.5,
    lifespan:1.2,
    angle:30,
    speed:100,
);
```

Then you need to read the docs. Start from [here](https://github.com/manjav/particular/blob/main/repo_files/documentations/index.md).
