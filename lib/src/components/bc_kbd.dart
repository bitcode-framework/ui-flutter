library bc_kbd;

import 'package:flutter/material.dart';
import '../theme/bc_theme.dart';

/// Keyboard key size variants.
enum BcKbdSize { sm, md }

/// Renders its child with keyboard-key styling (ADR-011 Phase 5c — M7 misc).
///
/// Mirrors TS [BcKbdContract] ({ keys?, label?, size? }).
/// Displays keyboard key text with a distinct visual style resembling a
/// physical key: border, background, monospace font, rounded corners.
/// Supports rendering multiple keys with separators (e.g., Ctrl+K).
/// When no keys/label/child is provided, renders nothing.
class BcKbd extends StatelessWidget {
  final List<String>? keys;
  final String? label;
  final BcKbdSize size;
  final Widget? child;

  const BcKbd({
    super.key,
    this.keys,
    this.label,
    this.size = BcKbdSize.md,
    this.child,
  });

  double get _fontSize => size == BcKbdSize.sm ? 11.0 : 13.0;
  double get _paddingH => size == BcKbdSize.sm ? 5.0 : 7.0;
  double get _paddingV => size == BcKbdSize.sm ? 2.0 : 3.0;

  Widget _buildKey(String text) {
    return Container(
      key: Key('bc_kbd_key_$text'),
      padding: EdgeInsets.symmetric(
        horizontal: _paddingH,
        vertical: _paddingV,
      ),
      decoration: BoxDecoration(
        color: BcTheme.muted,
        border: Border.all(color: BcTheme.border),
        borderRadius: BorderRadius.circular(BcTheme.radius),
        boxShadow: const [
          BoxShadow(
            color: Color(0x1A000000),
            blurRadius: 0,
            offset: Offset(0, 1),
          ),
        ],
      ),
      child: Text(
        text,
        style: TextStyle(
          fontFamily: 'monospace',
          fontSize: _fontSize,
          fontWeight: FontWeight.w500,
          color: BcTheme.foreground,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final effectiveKeys = keys ?? (label != null ? [label!] : <String>[]);

    if (child != null) {
      return Container(
        key: const Key('bc_kbd'),
        padding: EdgeInsets.symmetric(
          horizontal: _paddingH,
          vertical: _paddingV,
        ),
        decoration: BoxDecoration(
          color: BcTheme.muted,
          border: Border.all(color: BcTheme.border),
          borderRadius: BorderRadius.circular(BcTheme.radius),
          boxShadow: const [
            BoxShadow(
              color: Color(0x1A000000),
              blurRadius: 0,
              offset: Offset(0, 1),
            ),
          ],
        ),
        child: DefaultTextStyle.merge(
          style: TextStyle(
            fontFamily: 'monospace',
            fontSize: _fontSize,
            fontWeight: FontWeight.w500,
            color: BcTheme.foreground,
          ),
          child: child!,
        ),
      );
    }

    if (effectiveKeys.isEmpty) {
      return const SizedBox.shrink(key: Key('bc_kbd_empty'));
    }

    if (effectiveKeys.length == 1) {
      return _buildKey(effectiveKeys[0]);
    }

    return Row(
      key: const Key('bc_kbd'),
      mainAxisSize: MainAxisSize.min,
      children: [
        for (var i = 0; i < effectiveKeys.length; i++) ...[
          _buildKey(effectiveKeys[i]),
          if (i < effectiveKeys.length - 1)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 3),
              child: Text(
                '+',
                style: TextStyle(
                  fontSize: _fontSize,
                  color: BcTheme.mutedForeground,
                ),
              ),
            ),
        ],
      ],
    );
  }
}
