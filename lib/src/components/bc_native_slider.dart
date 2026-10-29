library bc_native_slider;

import 'bc_slider.dart';

/// BcNativeSlider — platform-idiomatic range slider (ADR-006 Adapt POC).
///
/// BcSlider is already platform-aware (ADR-011): Flutter's `Slider` widget
/// automatically renders Cupertino-style on iOS and Material on Android.
/// BcNativeSlider is a transparent alias so consumers can write one
/// component name across web/RN/Flutter; on Flutter it resolves to the
/// adaptive BcSlider.
typedef BcNativeSlider = BcSlider;
