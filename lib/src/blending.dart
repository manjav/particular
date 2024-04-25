import 'dart:ui';

/// kClear_Mode,    //!< [0, 0]
/// kSrc_Mode,      //!< [Sa, Sc]
/// kDst_Mode,      //!< [Da, Dc]
/// kSrcOver_Mode,  //!< [Sa + Da - Sa*Da, Rc = Sc + (1 - Sa)*Dc]
/// kDstOver_Mode,  //!< [Sa + Da - Sa*Da, Rc = Dc + (1 - Da)*Sc]
/// kSrcIn_Mode,    //!< [Sa * Da, Sc * Da]
/// kDstIn_Mode,    //!< [Sa * Da, Sa * Dc]
/// kSrcOut_Mode,   //!< [Sa * (1 - Da), Sc * (1 - Da)]
/// kDstOut_Mode,   //!< [Da * (1 - Sa), Dc * (1 - Sa)]
/// kSrcATop_Mode,  //!< [Da, Sc * Da + (1 - Sa) * Dc]
/// kDstATop_Mode,  //!< [Sa, Sa * Dc + Sc * (1 - Da)]
/// kXor_Mode,      //!< [Sa + Da - 2 * Sa * Da, Sc * (1 - Da) + (1 - Sa) * Dc]
/// kPlus_Mode,     //!< [Sa + Da, Sc + Dc]
/// kModulate_Mode, // multiplies all components (= alpha and color)
List<BlendModeItem> blendModeList = [
  BlendModeItem(
    BlendMode.clear,
    BlendFunction.zero,
    BlendFunction.zero,
  ),
  BlendModeItem(
    BlendMode.color,
    BlendFunction.zero,
    BlendFunction.sourceColor,
  ),
  BlendModeItem(
    BlendMode.colorBurn,
    BlendFunction.zero,
    BlendFunction.oneMinusSourceColor,
  ),
  // BlendModeItem(
  //   BlendMode.colorDodge,
  //   BlendFunction.zero,
  //   BlendFunction.one,
  // ),
  BlendModeItem(
    BlendMode.darken,
    BlendFunction.oneMinusDestinationColor,
    BlendFunction.oneMinusSourceColor,
  ),
  BlendModeItem(
    BlendMode.difference,
    BlendFunction.zero,
    BlendFunction.oneMinusSourceColor,
  ),
  BlendModeItem(
    BlendMode.dst,
    BlendFunction.zero,
    BlendFunction.one,
  ),
  BlendModeItem(
    BlendMode.dstATop,
    BlendFunction.destinationAlpha,
    BlendFunction.oneMinusSourceAlpha,
  ),
  BlendModeItem(
    BlendMode.dstIn,
    BlendFunction.zero,
    BlendFunction.sourceAlpha,
  ),
  // Erase
  BlendModeItem(
    BlendMode.dstOut,
    BlendFunction.zero,
    BlendFunction.oneMinusSourceAlpha,
  ),
  BlendModeItem(
    BlendMode.dstOver,
    BlendFunction.oneMinusDestinationAlpha,
    BlendFunction.one,
  ),
  BlendModeItem(
    BlendMode.exclusion,
    BlendFunction.oneMinusDestinationColor,
    BlendFunction.oneMinusSourceColor,
  ),
  BlendModeItem(
    BlendMode.hardLight,
    BlendFunction.zero,
    BlendFunction.oneMinusSourceColor,
  ),
  BlendModeItem(
    BlendMode.hue,
    BlendFunction.oneMinusDestinationColor,
    BlendFunction.zero,
  ),
  // BlendModeItem(
  //   BlendMode.lighten,
  //   BlendFunction.oneMinusDestinationColor,
  //   BlendFunction.one,
  // ),
  BlendModeItem(
    BlendMode.luminosity,
    BlendFunction.zero,
    BlendFunction.oneMinusSourceColor,
  ),
  // BlendModeItem(
  //   BlendMode.modulate,
  //   BlendFunction.one,
  //   BlendFunction.oneMinusSourceColor,
  // ),
  // Multiply
  BlendModeItem(
    BlendMode.multiply,
    BlendFunction.destinationColor,
    BlendFunction.oneMinusSourceAlpha,
  ),
  BlendModeItem(
    BlendMode.overlay,
    BlendFunction.oneMinusDestinationColor,
    BlendFunction.oneMinusSourceColor,
  ),
  // Add
  BlendModeItem(
    BlendMode.plus,
    BlendFunction.one,
    BlendFunction.one,
  ),
  // Screen
  BlendModeItem(
    BlendMode.screen,
    BlendFunction.one,
    BlendFunction.oneMinusSourceColor,
  ),
  BlendModeItem(
    BlendMode.softLight,
    BlendFunction.zero,
    BlendFunction.oneMinusSourceColor,
  ),
  BlendModeItem(
    BlendMode.src,
    BlendFunction.one,
    BlendFunction.zero,
  ),
  BlendModeItem(
    BlendMode.srcATop,
    BlendFunction.destinationAlpha,
    BlendFunction.oneMinusSourceAlpha,
  ),
  BlendModeItem(
    BlendMode.srcIn,
    BlendFunction.destinationAlpha,
    BlendFunction.zero,
  ),
  BlendModeItem(
    BlendMode.srcOut,
    BlendFunction.oneMinusDestinationAlpha,
    BlendFunction.zero,
  ),
  // Normal
  BlendModeItem(
    BlendMode.srcOver,
    BlendFunction.one,
    BlendFunction.oneMinusSourceAlpha,
  ),
  BlendModeItem(
    BlendMode.xor,
    BlendFunction.oneMinusDestinationColor,
    BlendFunction.oneMinusSourceColor,
  ),
];

class BlendModeItem {
  /// The blend mode to apply.
  final BlendMode blendMode;

  /// The source blend function to apply.
  ///
  /// Defaults to [BlendFunction.zero].
  final BlendFunction sourceBlendFunction;

  /// The destination blend function to apply.
  ///
  /// Defaults to [BlendFunction.zero].
  final BlendFunction destinationBlendFunction;

  /// Creates a new blend mode item.
  ///
  /// If [sourceBlendFunction] and [destinationBlendFunction] are not provided,
  /// they default to [BlendFunction.zero] and [BlendFunction.zero] respectively.
  BlendModeItem(
    this.blendMode, [
    this.sourceBlendFunction = BlendFunction.zero,
    this.destinationBlendFunction = BlendFunction.zero,
  ]);

  /// Gets the blend mode for particle rendering.
  static BlendMode computeBlendMode(BlendFunction src, BlendFunction dst) {
    if (dst == BlendFunction.zero) return BlendMode.clear;
    if (src == BlendFunction.zero) {
      return switch (dst) {
        BlendFunction.oneMinusSourceColor => BlendMode.screen, //erase
        BlendFunction.sourceAlpha => BlendMode.srcIn, //mask
        _ => BlendMode.srcOver,
      };
    }
    if (src == BlendFunction.one) {
      return switch (dst) {
        BlendFunction.one => BlendMode.plus,
        BlendFunction.oneMinusSourceColor => BlendMode.screen,
        _ => BlendMode.srcOver,
      };
    }
    if (src == BlendFunction.destinationColor &&
        dst == BlendFunction.oneMinusSourceAlpha) {
      return BlendMode.multiply;
    }
    if (src == BlendFunction.oneMinusDestinationAlpha &&
        dst == BlendFunction.destinationAlpha) {
      return BlendMode.dst;
    }

    // "none":,ONE, ZERO
    // "normal": ONE, ONE_MINUS_SOURCE_ALPHA
    // "add": ONE, ONE
    // "screen": ONE, ONE_MINUS_SOURCE_COLOR
    // "erase": ZERO, ONE_MINUS_SOURCE_ALPHA
    // "mask": ZERO, SOURCE_ALPHA
    // "multiply": DESTINATION_COLOR, ONE_MINUS_SOURCE_ALPHA
    // "below": ONE_MINUS_DESTINATION_ALPHA, DESTINATION_ALPHA
    return BlendMode.srcOver;
  }

  // Computes the blend mode based on the source and destination blend functions.
  static BlendMode computeFlutterBlendMode(
      BlendFunction src, BlendFunction dst) {
    var item = blendModeList.firstWhere(
        (b) =>
            b.sourceBlendFunction == src && b.destinationBlendFunction == dst,
        orElse: () {
      return BlendModeItem(BlendMode.plus);
    });
    return item.blendMode;
  }
}

/// Enum representing different blend functions used for particle rendering.
enum BlendFunction {
  zero(0), // GL_ZERO
  one(1), // GL_ONE
  // color(10), // GL_COLOR
  sourceColor(0x300), // GL_SOURCE_COLOR
  oneMinusSourceColor(0x301), // GL_ONE_MINUS_SOURCE_COLOR
  sourceAlpha(0x302), // GL_SOURCE_ALPHA
  oneMinusSourceAlpha(0x303), // GL_ONE_MINUS_SOURCE_ALPHA
  destinationAlpha(0x304), // GL_DESTINATION_ALPHA
  oneMinusDestinationAlpha(0x305), // GL_ONE_MINUS_DESTINATION_ALPHA
  destinationColor(0x306), // GL_DESTINATION_COLOR
  oneMinusDestinationColor(0x307), // GL_ONE_MINUS_DESTINATION_COLOR
  sourceAlphaSaturate(0x307); // GL_SOURCE_ALPHA_SATURATE

  final int value;
  const BlendFunction(this.value);

  /// Converts the given [value] to a [BlendFunction].
  ///
  /// The [value] parameter is the integer representation of the [BlendFunction].
  ///
  /// Returns the corresponding [BlendFunction] object.
  static BlendFunction fromValue(int value) {
    return values.where((item) => item.value == value).first;
  }

  /// Returns a string representation of the object. In this case, it returns the value of the 'name' property.
  @override
  String toString() => name;
}
