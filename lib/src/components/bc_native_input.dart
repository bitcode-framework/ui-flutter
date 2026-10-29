library bc_native_input;

import 'bc_input.dart';

/// BcNativeInput — platform-idiomatic text field (ADR-006 Adapt POC).
///
/// BcInput is already platform-aware via flutter_platform_widgets
/// (ADR-011): Material `TextFormField` on Android, `CupertinoTextField` on
/// iOS. BcNativeInput is a transparent alias so consumers can write one
/// component name across web/RN/Flutter; on Flutter it resolves to the
/// adaptive BcInput.
typedef BcNativeInput = BcInput;
