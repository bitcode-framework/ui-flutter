// Minimal fake `WebViewPlatform` for widget tests that instantiate
// `flutter_echarts`'s `Echarts` widget (ADR-015 Phase F3).
//
// The `Echarts` widget creates a `WebViewController` in `initState()` which
// requires `WebViewPlatform.instance` to be non-null. In the Flutter widget
// test environment there is no real WebView, so we register a no-op fake
// platform that lets the widget tree build without rendering any web content.
//
// Per XS-001 (cross-surface): widget tests do NOT assert on rendered pixels —
// they verify the widget *contract* surface (container structure, option JSON,
// loading/empty states, semantics, backward-compat). The chart-option factory
// itself is exhaustively parity-tested against golden JSON fixtures in
// `chart_factory_test.dart`.
//
// Usage: call `FakeWebViewPlatform.install()` in `setUpAll()` of any test file
// that pumps a `BcChart` with data (which triggers `Echarts` creation).
library fake_webview_platform;

import 'package:flutter/widgets.dart';
import 'package:webview_flutter_platform_interface/webview_flutter_platform_interface.dart';

/// Registers a no-op [WebViewPlatform] so `flutter_echarts` can build in tests.
///
/// Call this in `setUpAll`. The fake swallows all controller/navigation calls
/// as completed futures and renders an empty [SizedBox] for the WebView widget.
void installFakeWebViewPlatform() {
  if (WebViewPlatform.instance is! FakeWebViewPlatform) {
    WebViewPlatform.instance = FakeWebViewPlatform();
  }
}

class FakeWebViewPlatform extends WebViewPlatform {
  @override
  PlatformWebViewController createPlatformWebViewController(
    PlatformWebViewControllerCreationParams params,
  ) => FakePlatformWebViewController(params);

  @override
  PlatformWebViewWidget createPlatformWebViewWidget(
    PlatformWebViewWidgetCreationParams params,
  ) => FakePlatformWebViewWidget(params);

  @override
  PlatformNavigationDelegate createPlatformNavigationDelegate(
    PlatformNavigationDelegateCreationParams params,
  ) => FakePlatformNavigationDelegate(params);

  @override
  PlatformWebViewCookieManager createPlatformCookieManager(
    PlatformWebViewCookieManagerCreationParams params,
  ) => FakePlatformWebViewCookieManager(params);
}

/// No-op controller. `flutter_echarts` calls these methods in `initState` /
/// `didUpdateWidget` / `dispose`; none are awaited synchronously, so returning
/// completed futures is sufficient for the widget tree to build.
class FakePlatformWebViewController extends PlatformWebViewController {
  FakePlatformWebViewController(super.params) : super.implementation();

  @override
  Future<void> loadHtmlString(String html, {String? baseUrl}) async {}

  @override
  Future<void> setJavaScriptMode(JavaScriptMode javaScriptMode) async {}

  @override
  Future<void> setBackgroundColor(Color color) async {}

  @override
  Future<void> setPlatformNavigationDelegate(
    PlatformNavigationDelegate handler,
  ) async {}

  @override
  Future<void> addJavaScriptChannel(JavaScriptChannelParams params) async {}

  @override
  Future<void> runJavaScript(String javaScript) async {}

  @override
  Future<void> clearCache() async {}

  @override
  Future<void> reload() async {}
}

/// Renders an empty widget instead of a real WebView.
class FakePlatformWebViewWidget extends PlatformWebViewWidget {
  FakePlatformWebViewWidget(super.params) : super.implementation();

  @override
  Widget build(BuildContext context) => const SizedBox.shrink();
}

/// No-op navigation delegate — all event setters are swallowed.
class FakePlatformNavigationDelegate extends PlatformNavigationDelegate {
  FakePlatformNavigationDelegate(super.params) : super.implementation();

  @override
  Future<void> setOnPageStarted(PageEventCallback onPageStarted) async {}

  @override
  Future<void> setOnPageFinished(PageEventCallback onPageFinished) async {}

  @override
  Future<void> setOnProgress(ProgressCallback onProgress) async {}

  @override
  Future<void> setOnNavigationRequest(
    NavigationRequestCallback onNavigationRequest,
  ) async {}

  @override
  Future<void> setOnHttpError(HttpResponseErrorCallback onHttpError) async {}

  @override
  Future<void> setOnWebResourceError(
    WebResourceErrorCallback onWebResourceError,
  ) async {}

  @override
  Future<void> setOnUrlChange(UrlChangeCallback onUrlChange) async {}

  @override
  Future<void> setOnHttpAuthRequest(
    HttpAuthRequestCallback onHttpAuthRequest,
  ) async {}

  @override
  Future<void> setOnSSlAuthError(SslAuthErrorCallback onSslAuthError) async {}
}

/// No-op cookie manager.
class FakePlatformWebViewCookieManager extends PlatformWebViewCookieManager {
  FakePlatformWebViewCookieManager(super.params) : super.implementation();

  @override
  Future<bool> clearCookies() async => false;

  @override
  Future<void> setCookie(WebViewCookie cookie) async {}

  @override
  Future<List<WebViewCookie>> getCookies(Uri url) async => const [];
}
