// Platform-selecting re-export for the iframe embed renderer.
//
// On web, `bc_web_embed_web_impl.dart` provides a real `<iframe>` hosted via
// HtmlElementView. Everywhere else `bc_web_embed_stub.dart` provides
// `bcWebEmbedSupported = false` so callers render their native fallback and
// `dart:ui_web` / `package:web` are never compiled off-web.

export 'bc_web_embed_stub.dart'
    if (dart.library.html) 'bc_web_embed_web_impl.dart';
