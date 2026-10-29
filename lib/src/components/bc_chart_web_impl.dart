// Web-only ECharts renderer for BcChart (ADR-015 — Flutter Web chart strategy).
//
// flutter_echarts uses webview_flutter which has no web platform impl. This
// renderer loads Apache ECharts from CDN and renders into a real DOM div via
// HtmlElementView, achieving full chart parity on Flutter Web.
//
// Pattern adapted from echarts_flutter_plus (github.com/noeljolly09/echarts_flutter_plus)
// — lazy CDN load, platformViewRegistry, dart:js_interop bindings.
//
// This file is ONLY compiled on web (conditional import in bc_chart.dart).

import 'dart:async';
import 'dart:js_interop';
import 'dart:ui_web' as ui_web;

import 'package:flutter/material.dart';
import 'package:web/web.dart' as web;

import '../theme/bc_theme.dart';

// ---------------------------------------------------------------------------
// ECharts JS interop bindings
// ---------------------------------------------------------------------------

@JS('echarts')
external JSObject? get _echarts;

@JS('echarts.init')
external JSObject _echartsInit(web.Element el, [String? theme]);

@JS('JSON.parse')
external JSAny? _jsParseJson(String json);

extension EChartsInterop on JSObject {
  external void setOption(JSAny? option, [bool? notMerge]);
  external void dispose();
  external void resize();
}

// ---------------------------------------------------------------------------
// ECharts CDN loader (singleton — loaded once per page)
// ---------------------------------------------------------------------------

Future<void>? _echartsLoader;

Future<void> _ensureEchartsLoaded({int timeoutSeconds = 12}) async {
  if (_echartsLoader != null) return _echartsLoader!;

  final completer = Completer<void>();
  final script = web.document.createElement('script');
  script.setAttribute('src', 'https://cdn.jsdelivr.net/npm/echarts@5.5.0/dist/echarts.min.js');
  script.setAttribute('type', 'text/javascript');
  script.setAttribute('async', 'true');
  web.document.body!.append(script);

  int attempts = 0;
  void poll() {
    attempts++;
    if (_echarts != null) {
      completer.complete();
      return;
    }
    if (attempts < timeoutSeconds * 10) {
      Timer(const Duration(milliseconds: 100), poll);
    } else {
      completer.completeError(TimeoutException('ECharts CDN load timeout'));
    }
  }

  poll();
  _echartsLoader = completer.future;
  return _echartsLoader!;
}

// ---------------------------------------------------------------------------
// BcChartWeb — real ECharts rendering on Flutter Web
// ---------------------------------------------------------------------------

/// Renders an ECharts chart on Flutter Web via HtmlElementView + CDN.
///
/// Receives the ECharts option JSON string (built by BcChart's chart-option
/// contract) and renders it into a DOM div registered as a platform view.
class BcChartWeb extends StatefulWidget {
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
  State<BcChartWeb> createState() => _BcChartWebState();
}

class _BcChartWebState extends State<BcChartWeb> {
  late final String _viewType;
  web.Element? _container;
  JSObject? _chart;
  Object? _error;
  static int _instanceCounter = 0;

  @override
  void initState() {
    super.initState();
    _viewType = 'bc_chart_web_${_instanceCounter++}';
    _prepareContainer();
    _registerViewFactory();
    _initChart();
  }

  void _prepareContainer() {
    _container = web.document.createElement('div');
    _applyContainerStyle();
  }

  void _applyContainerStyle() {
    final w = widget.width.isInfinite || widget.width.isNaN ? '100%' : '${widget.width.toInt()}px';
    final h = widget.height.isInfinite || widget.height.isNaN ? '100%' : '${widget.height.toInt()}px';
    _container?.setAttribute(
      'style',
      'width:$w;height:$h;position:relative;overflow:hidden;',
    );
  }

  void _registerViewFactory() {
    ui_web.platformViewRegistry.registerViewFactory(
      _viewType,
      (int viewId) => _container!,
    );
  }

  Future<void> _initChart() async {
    try {
      await _ensureEchartsLoaded();
      if (!mounted) return;
      // Wait for the container to be mounted in the DOM by HtmlElementView
      // and have real dimensions. On re-visit (CDN cached), this is the
      // critical delay that prevents ECharts from measuring 0px width.
      await _waitForContainerReady();
      if (mounted) _renderChart();
    } catch (e) {
      if (mounted) setState(() => _error = e);
    }
  }

  /// Polls until the container element is in the DOM with non-zero width.
  /// HtmlElementView inserts elements asynchronously after build; without
  /// this wait, ECharts inits against a 0-width container on re-visit.
  Future<void> _waitForContainerReady() async {
    for (int i = 0; i < 50; i++) {
      final el = _container as web.HTMLElement;
      if (el.offsetWidth > 0 && el.offsetHeight > 0) return;
      await Future.delayed(const Duration(milliseconds: 20));
    }
  }

  void _renderChart() {
    _chart?.dispose();

    if (_echarts == null) return;

    try {
      final option = _jsParseJson(widget.optionJson);
      if (option == null) throw Exception('Failed to parse chart option JSON');

      // Ensure container style is current before ECharts measures it.
      _applyContainerStyle();

      _chart = _echartsInit(_container!, widget.theme);
      _chart!.setOption(option, true);

      // Force ECharts to use the actual container dimensions after mount.
      _chart!.resize();

      if (mounted) setState(() => _error = null);
    } catch (e) {
      if (mounted) setState(() => _error = e);
    }
  }

  @override
  void didUpdateWidget(BcChartWeb oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.optionJson != widget.optionJson || oldWidget.theme != widget.theme) {
      _renderChart();
    }
    if (oldWidget.width != widget.width || oldWidget.height != widget.height) {
      _applyContainerStyle();
      _chart?.resize();
    }
  }

  @override
  void dispose() {
    _chart?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final w = widget.width.isInfinite || widget.width.isNaN ? null : widget.width;
    final h = widget.height.isInfinite || widget.height.isNaN ? null : widget.height;
    if (_error != null) {
      return SizedBox(
        width: w,
        height: h,
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Text(
              'Chart error: $_error',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 11, color: BcTheme.mutedForeground),
            ),
          ),
        ),
      );
    }
    return SizedBox(
      width: w,
      height: h,
      child: HtmlElementView(viewType: _viewType),
    );
  }
}
