library bc_portal;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../core/types.dart';

/// Animation style for [BcPortal].
///
/// Mirrors the TS `animation` union `'none' | 'slide' | 'fade'`. Flutter
/// portals live in an [Overlay] (no native route transitions), so the value
/// is accepted for API parity and applied as a best-effort transition on the
/// portal content.
enum BcPortalAnimation { none, slide, fade }

/// Portal that renders its [child] into a root-level [Overlay], outside the
/// parent's stacking context (ADR-011 Phase 5b.2).
///
/// Mirrors the TS `BcPortal` contract: a controlled `open` prop mounts and
/// unmounts an [OverlayEntry]. When open, the child floats above the rest of
/// the application. [onRequestClose] fires with [BcChangeReason.escape] when
/// the Escape key is pressed (web parity) and with [BcChangeReason.back] on
/// a hardware back gesture (RN parity). The [name] prop is surfaced as a
/// [ValueKey] so tests and styling hooks can locate the portal root.
class BcPortal extends StatefulWidget {
  /// Whether the portal is mounted. When false (or null), children are not
  /// rendered and no overlay entry is held.
  final bool? open;

  /// Mount target. On Flutter the portal always mounts into the nearest
  /// ancestor [Overlay] (provided by [MaterialApp]/[Scaffold]); this prop is
  /// accepted for API parity and otherwise ignored.
  final Object? container;

  /// Transition style applied when the overlay entry mounts. Accepted for
  /// API parity; defaults to [BcPortalAnimation.fade].
  final BcPortalAnimation? animation;

  /// Stable hook for tests and styling. Surfaced as
  /// `ValueKey<String>('bc-portal-<name>')` on the portal root.
  final String? name;

  /// Top-level className appended to the root part. Accepted for API parity
  /// (Flutter has no DOM class system); stored but otherwise unused.
  final String? className;

  /// Runtime Part Resolution props for named internal parts. Accepted for
  /// API parity; not currently consumed by the Flutter adapter.
  final Map<String, dynamic>? slotProps;

  /// Called when the host requests dismissal — Escape key (web parity) or
  /// hardware back (RN parity). Receives a [BcChangeMeta] whose `reason`
  /// identifies the dismissal origin.
  final void Function(BcChangeMeta? meta)? onRequestClose;

  /// Portal contents.
  final Widget? child;

  const BcPortal({
    super.key,
    this.open,
    this.container,
    this.animation,
    this.name,
    this.className,
    this.slotProps,
    this.onRequestClose,
    this.child,
  });

  @override
  State<BcPortal> createState() => _BcPortalState();
}

class _BcPortalState extends State<BcPortal> {
  OverlayEntry? _entry;
  late final FocusNode _focusNode;
  FocusNode? _previousFocus;
  bool _mounted = false;
  bool _pendingMount = false;

  @override
  void initState() {
    super.initState();
    _focusNode = FocusNode(debugLabel: 'BcPortal');
    if (_isOpen) {
      _scheduleMount();
    }
  }

  bool get _isOpen => widget.open == true;

  BcPortalAnimation get _animation => widget.animation ?? BcPortalAnimation.fade;

  Key get _portalKey =>
      ValueKey<String>('bc-portal-${widget.name ?? ''}');

  @override
  void didUpdateWidget(BcPortal oldWidget) {
    super.didUpdateWidget(oldWidget);
    final wasOpen = oldWidget.open == true;
    final nowOpen = _isOpen;
    if (nowOpen && !wasOpen) {
      _scheduleMount();
    } else if (!nowOpen && wasOpen) {
      _scheduleUnmount();
    } else if (nowOpen && _entry != null) {
      _scheduleRebuild();
    }
  }

  void _scheduleMount() {
    if (_mounted || _pendingMount) return;
    _pendingMount = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _pendingMount = false;
      if (!mounted || !_isOpen) return;
      _doMount();
    });
  }

  void _scheduleUnmount() {
    if (!_mounted) {
      _pendingMount = false;
      return;
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _doUnmount();
    });
  }

  void _scheduleRebuild() {
    if (!_mounted || _entry == null) return;
    final entry = _entry!;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && _entry == entry) {
        entry.markNeedsBuild();
      }
    });
  }

  void _doMount() {
    if (_mounted) return;
    final overlay = Overlay.maybeOf(context, rootOverlay: true) ??
        Overlay.maybeOf(context);
    if (overlay == null) return;
    _previousFocus = FocusManager.instance.primaryFocus;
    _entry = OverlayEntry(
      builder: (BuildContext context) {
        return _PortalContent(
          key: _portalKey,
          animation: _animation,
          focusNode: _focusNode,
          onEscape: () => _requestClose(BcChangeReason.escape),
          child: widget.child ?? const SizedBox.shrink(),
        );
      },
    );
    overlay.insert(_entry!);
    _mounted = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _focusNode.requestFocus();
    });
  }

  void _doUnmount() {
    if (!_mounted) {
      _pendingMount = false;
      return;
    }
    _entry?.remove();
    _entry = null;
    _mounted = false;
    final previous = _previousFocus;
    _previousFocus = null;
    if (previous != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (previous.canRequestFocus) {
          previous.requestFocus();
        }
      });
    }
  }

  void _requestClose(BcChangeReason reason) {
    if (widget.onRequestClose == null) return;
    final source = reason == BcChangeReason.back
        ? BcEventSource.external
        : BcEventSource.keyboard;
    widget.onRequestClose!.call(
      BcChangeMeta(reason: reason, source: source),
    );
  }

  @override
  void dispose() {
    if (_mounted) {
      _entry?.remove();
      _entry = null;
      _mounted = false;
    }
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: !_isOpen,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop && _isOpen) {
          _requestClose(BcChangeReason.back);
        }
      },
      child: const SizedBox.shrink(),
    );
  }
}

class _PortalContent extends StatelessWidget {
  final BcPortalAnimation animation;
  final FocusNode focusNode;
  final VoidCallback onEscape;
  final Widget child;

  const _PortalContent({
    super.key,
    required this.animation,
    required this.focusNode,
    required this.onEscape,
    required this.child,
  });

  KeyEventResult _handleKeyEvent(FocusNode node, KeyEvent event) {
    if (event is! KeyDownEvent) return KeyEventResult.ignored;
    if (event.logicalKey == LogicalKeyboardKey.escape) {
      onEscape();
      return KeyEventResult.handled;
    }
    return KeyEventResult.ignored;
  }

  @override
  Widget build(BuildContext context) {
    final core = Material(
      type: MaterialType.transparency,
      child: Focus(
        focusNode: focusNode,
        onKeyEvent: _handleKeyEvent,
        child: child,
      ),
    );

    Widget animated;
    switch (animation) {
      case BcPortalAnimation.none:
        animated = core;
        break;
      case BcPortalAnimation.fade:
        animated = TweenAnimationBuilder<double>(
          tween: Tween<double>(begin: 0.0, end: 1.0),
          duration: const Duration(milliseconds: 150),
          builder: (context, value, kid) {
            return Opacity(opacity: value, child: kid);
          },
          child: core,
        );
        break;
      case BcPortalAnimation.slide:
        animated = TweenAnimationBuilder<Offset>(
          tween: Tween<Offset>(
            begin: const Offset(0, 0.05),
            end: Offset.zero,
          ),
          duration: const Duration(milliseconds: 150),
          builder: (context, value, kid) {
            return FractionalTranslation(
              translation: value,
              child: kid,
            );
          },
          child: core,
        );
        break;
    }

    return Positioned(
      top: 0,
      left: 0,
      child: animated,
    );
  }
}
