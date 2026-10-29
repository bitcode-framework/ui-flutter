library bc_native_switch;

import 'bc_toggle.dart';

/// BcNativeSwitch — platform-idiomatic toggle switch (ADR-006 Adapt POC).
///
/// BcToggle is already platform-aware via flutter_platform_widgets
/// (ADR-011): Material `Switch` on Android, `CupertinoSwitch` on iOS (FPW
/// `PlatformSwitch` maps automatically). BcNativeSwitch is a transparent
/// alias so consumers can write one component name across web/RN/Flutter;
/// on Flutter it resolves to the adaptive BcToggle.
typedef BcNativeSwitch = BcToggle;
