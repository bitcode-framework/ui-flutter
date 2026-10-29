// Non-web stub for the iframe embed renderer.
//
// Imported ONLY on non-web platforms via the conditional import in
// bc_web_embed.dart. It exists so `dart:ui_web` and `package:web` are never
// compiled for mobile/desktop, where they do not exist.
//
// On non-web there is no `<iframe>` to host, so callers fall back to their own
// native placeholder/WebView path. [bcWebEmbedSupported] is what they check.

import 'package:flutter/widgets.dart';

/// Whether the current platform can host a real browser `<iframe>`.
const bool bcWebEmbedSupported = false;

/// Placeholder used when the platform cannot host an iframe.
///
/// Callers guard on [bcWebEmbedSupported] and render their native fallback
/// instead, so this widget is normally never built.
class BcWebEmbed extends StatelessWidget {
  /// Absolute URL to embed.
  final String url;

  /// Accessible title / iframe `title` attribute.
  final String? title;

  /// Stable prefix used to derive the platform-view type.
  final String keyPrefix;

  /// Optional `sandbox` attribute value. Omitted on non-web.
  final String? sandbox;

  /// Optional `allow` attribute value. Omitted on non-web.
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
  Widget build(BuildContext context) => const SizedBox.shrink();
}

/// Which HTML media element to host (web only).
enum BcWebMediaKind { video, audio }

/// Placeholder for the web-only native `<video>` / `<audio>` host.
///
/// Callers guard on [bcWebEmbedSupported] and render their own player widget
/// instead, so this is normally never built.
class BcWebMediaElement extends StatelessWidget {
  final String src;
  final BcWebMediaKind kind;
  final String keyPrefix;
  final String? poster;
  final bool controls;
  final bool autoplay;
  final bool loop;
  final bool muted;
  final String? mimeType;

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
  Widget build(BuildContext context) => const SizedBox.shrink();
}
