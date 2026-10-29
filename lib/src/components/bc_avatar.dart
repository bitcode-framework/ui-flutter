library bc_avatar;

import 'package:flutter/material.dart';
import '../core/types.dart';
import '../theme/bc_theme.dart';

/// Avatar with image fallback to initials (ADR-011 Phase 5c - block parity).
///
/// Mirrors TS `BcAvatar` contract. Renders a circular avatar with the
/// following resolution order:
///  1. When [src] is provided and non-empty, load it as a network image
///     clipped to a circle. If loading fails, fall back to step 2.
///  2. Otherwise render a muted-background circle containing initials
///     derived from [fallback] (preferred) or the first character of
///     [alt] uppercased. When neither is available, a `?` placeholder
///     is shown.
///
/// Sizes map [BcComponentSize] to diameter: sm = 32, md = 40, lg = 48.
class BcAvatar extends StatelessWidget {
  final String? src;
  final String? alt;
  final String? fallback;
  final BcComponentSize size;

  const BcAvatar({
    super.key,
    this.src,
    this.alt,
    this.fallback,
    this.size = BcComponentSize.md,
  });

  double get _diameter {
    switch (size) {
      case BcComponentSize.sm:
        return 32;
      case BcComponentSize.md:
        return 40;
      case BcComponentSize.lg:
        return 48;
    }
  }

  double get _fontSize {
    switch (size) {
      case BcComponentSize.sm:
        return 12;
      case BcComponentSize.md:
        return 14;
      case BcComponentSize.lg:
        return 16;
    }
  }

  String get _fallbackText {
    final fb = fallback;
    if (fb != null && fb.isNotEmpty) return fb;
    final a = alt;
    if (a != null && a.isNotEmpty) {
      return a.substring(0, 1).toUpperCase();
    }
    return '?';
  }

  Widget _buildFallback() {
    return Container(
      key: const Key('bc-avatar-fallback'),
      width: _diameter,
      height: _diameter,
      alignment: Alignment.center,
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        color: BcTheme.muted,
      ),
      child: Text(
        _fallbackText,
        style: TextStyle(
          fontSize: _fontSize,
          fontWeight: FontWeight.w500,
          color: BcTheme.mutedForeground,
        ),
      ),
    );
  }

  Widget _buildImage() {
    final s = src;
    if (s == null || s.isEmpty) return _buildFallback();
    return ClipOval(
      key: const Key('bc-avatar-image'),
      child: Image.network(
        s,
        width: _diameter,
        height: _diameter,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => _buildFallback(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final hasImage = src != null && src!.isNotEmpty;
    final semanticsLabel =
        (alt != null && alt!.isNotEmpty) ? alt! : _fallbackText;

    return Semantics(
      label: semanticsLabel,
      image: hasImage,
      child: ExcludeSemantics(
        child: SizedBox(
          width: _diameter,
          height: _diameter,
          child: hasImage ? _buildImage() : _buildFallback(),
        ),
      ),
    );
  }
}