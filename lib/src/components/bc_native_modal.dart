library bc_native_modal;

import 'package:flutter/material.dart';

import '../core/types.dart';
import '../theme/bc_theme.dart';

/// How the modal is presented (mirrors iOS presentation styles).
enum BcNativeModalPresentationStyle {
  /// Fullscreen — covers the entire viewport.
  fullscreen,
  /// Form sheet — centered card with rounded corners (iOS formSheet).
  formSheet,
  /// Page sheet — covers most of the viewport, rounded top corners.
  pageSheet,
}

/// Platform-idiomatic modal container (ADR-006 Adapt POC, ADR-011).
///
/// iOS: Cupertino fullscreen / formSheet / pageSheet transition. Android:
/// Material Dialog. Uses `showGeneralDialog` with a fade/slide transition
/// so the same entry point works on both platforms.
///
/// Controlled mode: parent manages [open]; internal transitions fire
/// callbacks but visibility is driven by the prop. Renders slotted [child]
/// content with an optional title bar and close button.
class BcNativeModal extends StatefulWidget {
  /// Controlled open state. When non-null, the widget is controlled.
  final bool? open;

  /// Initial open state for uncontrolled mode.
  final bool defaultOpen;

  /// Modal title.
  final String? title;

  /// Show the close button. Default true.
  final bool closable;

  /// Clicking the overlay closes the modal. Default true.
  final bool closeOnOverlay;

  /// Escape key closes the modal. Default true.
  final bool closeOnEscape;

  /// Presentation style. Default [BcNativeModalPresentationStyle.fullscreen].
  final BcNativeModalPresentationStyle presentationStyle;

  /// Modal body content.
  final Widget? child;

  /// Called when the modal is dismissed (close button, overlay, escape).
  /// Carries a reason describing the dismissal source.
  final void Function(BcChangeMeta meta)? onClose;

  const BcNativeModal({
    super.key,
    this.open,
    this.defaultOpen = false,
    this.title,
    this.closable = true,
    this.closeOnOverlay = true,
    this.closeOnEscape = true,
    this.presentationStyle =
        BcNativeModalPresentationStyle.fullscreen,
    this.child,
    this.onClose,
  });

  @override
  State<BcNativeModal> createState() => _BcNativeModalState();
}

class _BcNativeModalState extends State<BcNativeModal> {
  bool _internalOpen = false;
  bool _dialogShown = false;

  bool get _isControlled => widget.open != null;

  bool get _isOpen => _isControlled ? widget.open! : _internalOpen;

  @override
  void initState() {
    super.initState();
    _internalOpen = widget.defaultOpen;
  }

  @override
  void didUpdateWidget(covariant BcNativeModal oldWidget) {
    super.didUpdateWidget(oldWidget);
    final open = _isOpen;
    if (open && !_dialogShown) {
      _dialogShown = true;
      WidgetsBinding.instance.addPostFrameCallback((_) => _present());
    } else if (!open && _dialogShown) {
      _dialogShown = false;
    }
  }

  void _present() {
    if (!mounted) return;
    showGeneralDialog<void>(
      context: context,
      barrierDismissible: widget.closeOnOverlay,
      barrierLabel: 'Dismiss',
      barrierColor: Colors.black.withValues(alpha: 0.5),
      transitionDuration: const Duration(milliseconds: 250),
      pageBuilder: (context, animation, secondaryAnimation) =>
          _buildPanel(context),
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        return FadeTransition(
          opacity: animation,
          child: SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0, 0.05),
              end: Offset.zero,
            ).animate(CurvedAnimation(
              parent: animation,
              curve: Curves.easeOutCubic,
            )),
            child: child,
          ),
        );
      },
    ).then((_) {
      if (!_isControlled) {
        setState(() => _internalOpen = false);
      }
      _dialogShown = false;
      widget.onClose?.call(const BcChangeMeta(
        reason: BcChangeReason.overlayClick,
        source: BcEventSource.pointer,
      ));
    });
  }

  void _close(BcChangeReason reason, BcEventSource source) {
    widget.onClose?.call(BcChangeMeta(reason: reason, source: source));
    if (!_isControlled) {
      setState(() => _internalOpen = false);
    }
    if (mounted && _dialogShown) {
      Navigator.of(context, rootNavigator: true).pop();
    }
  }

  Widget _buildPanel(BuildContext context) {
    final style = widget.presentationStyle;
    final isFullscreen =
        style == BcNativeModalPresentationStyle.fullscreen;

    final screen = MediaQuery.of(context).size;

    BoxConstraints? constraints;
    if (style == BcNativeModalPresentationStyle.formSheet) {
      constraints = BoxConstraints(
        maxWidth: 480,
        maxHeight: screen.height * 0.7,
      );
    } else if (style == BcNativeModalPresentationStyle.pageSheet) {
      constraints = BoxConstraints(
        maxWidth: 640,
        maxHeight: screen.height * 0.85,
      );
    }

    return SafeArea(
      child: Material(
        color: Colors.transparent,
        child: Container(
          key: const Key('bc-native-modal-panel'),
          width: isFullscreen ? screen.width : null,
          height: isFullscreen ? screen.height : null,
          constraints: constraints,
          margin: isFullscreen
              ? EdgeInsets.zero
              : const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
          decoration: BoxDecoration(
            color: BcTheme.background,
            borderRadius: isFullscreen
                ? BorderRadius.zero
                : BorderRadius.circular(BcTheme.radius),
            boxShadow: const [
              BoxShadow(
                color: Color(0x33000000),
                blurRadius: 24,
                offset: Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            children: [
              if (widget.title != null || widget.closable)
                Container(
                  key: const Key('bc-native-modal-header'),
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 12),
                  decoration: const BoxDecoration(
                    border: Border(
                      bottom: BorderSide(color: BcTheme.border),
                    ),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: widget.title != null
                            ? Text(
                                widget.title!,
                                key: const Key('bc-native-modal-title'),
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: BcTheme.foreground,
                                ),
                              )
                            : const SizedBox.shrink(),
                      ),
                      if (widget.closable)
                        SizedBox(
                          width: 44,
                          height: 44,
                          child: IconButton(
                            key: const Key('bc-native-modal-close'),
                            icon: const Icon(Icons.close, size: 22),
                            color: BcTheme.mutedForeground,
                            onPressed: () => _close(
                              BcChangeReason.escape,
                              BcEventSource.pointer,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              Expanded(
                child: widget.child ?? const SizedBox.shrink(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final open = _isOpen;
    if (open && !_dialogShown) {
      _dialogShown = true;
      WidgetsBinding.instance.addPostFrameCallback((_) => _present());
    }
    return const SizedBox.shrink();
  }
}
