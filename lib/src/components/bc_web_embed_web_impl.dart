// Web-only iframe renderer for the media viewers.
//
// The web (React) adapters embed remote players as a plain `<iframe>`
// (`BcViewerYoutube`, `BcViewerInstagram`, `BcViewerTiktok`,
// `BcViewerDocument`). Flutter has no widget that hosts a live iframe, so this
// renderer registers a real `<iframe>` element with the platform view registry
// and displays it via `HtmlElementView` — the same technique `BcChart` uses for
// ECharts (see bc_chart_web_impl.dart).
//
// This file is ONLY compiled on web (conditional import in bc_web_embed.dart).

import 'dart:ui_web' as ui_web;

import 'package:flutter/material.dart';
import 'package:web/web.dart' as web;

/// Whether the current platform can host a real browser `<iframe>`.
const bool bcWebEmbedSupported = true;

/// Renders [url] inside a live browser iframe.
///
/// Each instance registers its own platform-view type so that two embeds on the
/// same page never share an element (the registry maps a type to a single
/// element factory).
class BcWebEmbed extends StatefulWidget {
  /// Absolute URL to embed.
  final String url;

  /// Accessible title / iframe `title` attribute.
  final String? title;

  /// Stable prefix used to derive the platform-view type.
  final String keyPrefix;

  /// Optional `sandbox` attribute value. Omit to leave the iframe unsandboxed.
  final String? sandbox;

  /// Optional `allow` attribute value (e.g. `encrypted-media`).
  final String? allow;

  const BcWebEmbed({
    super.key,
    required this.url,
    required this.keyPrefix,
    this.title,
    this.sandbox,
    this.allow,
  });

  @override
  State<BcWebEmbed> createState() => _BcWebEmbedState();
}

class _BcWebEmbedState extends State<BcWebEmbed> {
  static int _instanceCounter = 0;

  late final String _viewType;
  late final web.HTMLIFrameElement _iframe;

  @override
  void initState() {
    super.initState();
    _viewType = '${widget.keyPrefix}_${_instanceCounter++}';
    _iframe = _createIframe();
    ui_web.platformViewRegistry.registerViewFactory(
      _viewType,
      (int viewId) => _iframe,
    );
  }

  web.HTMLIFrameElement _createIframe() {
    final frame =
        web.document.createElement('iframe') as web.HTMLIFrameElement;
    frame.src = widget.url;
    frame.title = widget.title ?? '';
    frame.setAttribute('frameborder', '0');
    frame.setAttribute('loading', 'lazy');
    frame.setAttribute('referrerpolicy', 'strict-origin-when-cross-origin');
    if (widget.sandbox != null) {
      frame.setAttribute('sandbox', widget.sandbox!);
    }
    if (widget.allow != null) {
      frame.setAttribute('allow', widget.allow!);
    }
    frame.setAttribute(
      'style',
      'width:100%;height:100%;border:0;display:block;',
    );
    return frame;
  }

  @override
  void didUpdateWidget(BcWebEmbed oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.url != oldWidget.url) {
      _iframe.src = widget.url;
    }
    if (widget.title != oldWidget.title) {
      _iframe.title = widget.title ?? '';
    }
  }

  @override
  Widget build(BuildContext context) {
    return HtmlElementView(viewType: _viewType);
  }
}

// ---------------------------------------------------------------------------
// Native HTML media element (<video> / <audio>)
// ---------------------------------------------------------------------------

/// Which HTML media element to host.
enum BcWebMediaKind { video, audio }

/// Renders a real `<video>` or `<audio>` element with native controls.
///
/// The web (React) adapters use the HTML elements directly, so this gives
/// genuine playback on Flutter Web with no extra package dependency.
class BcWebMediaElement extends StatefulWidget {
  /// Media source URL.
  final String src;

  /// [BcWebMediaKind.video] or [BcWebMediaKind.audio].
  final BcWebMediaKind kind;

  /// Poster image (video only).
  final String? poster;

  /// Show the browser's native controls.
  final bool controls;

  final bool autoplay;
  final bool loop;
  final bool muted;

  /// MIME type hint, e.g. `video/mp4`.
  final String? mimeType;

  /// Stable prefix used to derive the platform-view type.
  final String keyPrefix;

  const BcWebMediaElement({
    super.key,
    required this.src,
    required this.kind,
    required this.keyPrefix,
    this.poster,
    this.controls = true,
    this.autoplay = false,
    this.loop = false,
    this.muted = false,
    this.mimeType,
  });

  @override
  State<BcWebMediaElement> createState() => _BcWebMediaElementState();
}

class _BcWebMediaElementState extends State<BcWebMediaElement> {
  static int _instanceCounter = 0;

  late final String _viewType;
  late final web.HTMLElement _element;

  @override
  void initState() {
    super.initState();
    _viewType = '${widget.keyPrefix}_${_instanceCounter++}';
    _element = _createElement();
    ui_web.platformViewRegistry.registerViewFactory(
      _viewType,
      (int viewId) => _element,
    );
  }

  web.HTMLElement _createElement() {
    final isVideo = widget.kind == BcWebMediaKind.video;
    final el = web.document.createElement(isVideo ? 'video' : 'audio')
        as web.HTMLElement;

    // A <source> child carries the MIME hint; the element itself also gets a
    // direct src so browsers without <source> support still play it.
    if (widget.mimeType != null) {
      final source = web.document.createElement('source');
      source.setAttribute('src', widget.src);
      source.setAttribute('type', widget.mimeType!);
      el.append(source);
    } else {
      el.setAttribute('src', widget.src);
    }

    if (isVideo) {
      el.setAttribute('playsinline', '');
      if (widget.poster != null) el.setAttribute('poster', widget.poster!);
    }
    el.setAttribute('preload', 'metadata');
    if (widget.controls) el.setAttribute('controls', '');
    if (widget.autoplay) el.setAttribute('autoplay', '');
    if (widget.loop) el.setAttribute('loop', '');
    if (widget.muted) el.setAttribute('muted', '');
    el.setAttribute(
      'style',
      isVideo
          ? 'width:100%;height:100%;display:block;object-fit:contain;'
          : 'width:100%;height:100%;display:block;',
    );
    return el;
  }

  @override
  void didUpdateWidget(BcWebMediaElement oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.src != oldWidget.src) {
      _element.setAttribute('src', widget.src);
    }
    if (widget.poster != oldWidget.poster) {
      if (widget.poster != null) {
        _element.setAttribute('poster', widget.poster!);
      } else {
        _element.removeAttribute('poster');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return HtmlElementView(viewType: _viewType);
  }
}
