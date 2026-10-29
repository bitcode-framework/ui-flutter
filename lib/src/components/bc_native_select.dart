library bc_native_select;

import 'bc_select.dart';

/// BcNativeSelect — platform-idiomatic picker (ADR-006 Adapt POC).
///
/// BcSelect is already platform-aware via flutter_platform_widgets
/// (ADR-011): Material `DropdownButtonFormField` on Android,
/// `CupertinoButton` + `showCupertinoModalPopup` on iOS. BcNativeSelect is
/// a transparent alias so consumers can write one component name across
/// web/RN/Flutter; on Flutter it resolves to the adaptive BcSelect.
typedef BcNativeSelect = BcSelect;
