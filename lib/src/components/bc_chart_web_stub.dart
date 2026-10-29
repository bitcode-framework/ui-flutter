// Non-web stub for BcChart web renderer.
//
// This file is imported ONLY on non-web platforms (mobile/desktop) via the
// conditional import in bc_chart.dart. It provides a no-op placeholder that
// is never actually rendered (the kIsWeb guard in bc_chart.dart ensures the
// web path is only entered on web, where the real implementation
// bc_chart_web_impl.dart is imported instead).
//
// The purpose is to prevent dart:ui_web and package:web (web-only SDKs) from
// being compiled on mobile/desktop targets.

import 'package:flutter/widgets.dart';

/// Placeholder web chart renderer for non-web platforms.
///
/// On non-web, BcChart uses flutter_echarts (WebView) directly. This stub
/// exists solely so the conditional import resolves on all platforms.
class BcChartWeb extends StatelessWidget {
  final String optionJson;
  final String? theme;
  final double width;
  final double height;

  const BcChartWeb({
    super.key,
    required this.optionJson,
    this.theme,
    required this.width,
    required this.height,
  });

  @override
  Widget build(BuildContext context) => const SizedBox.shrink();
}
