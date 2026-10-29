library bc_webcam;

import 'package:flutter/material.dart';

import '../core/bc_i18n.dart';
import '../core/types.dart';
import '../theme/bc_theme.dart';

/// Camera facing direction.
enum BcWebcamFacingMode { user, environment }

/// Reason a capture was produced.
enum BcWebcamCaptureReason { captureButton, programmatic }

/// Reason the open state changed.
enum BcWebcamOpenChangeReason {
  closeButton,
  overlayClick,
  escape,
  programmatic,
}

/// Camera capture (ADR-006 Adapt POC, ADR-011).
///
/// Dependency-free: renders the contract surface (placeholder with facing mode
/// + capture button). Actual camera capture is delegated to the caller via
/// [cameraBuilder] (e.g. wired to `camera` plugin). This keeps
/// `bc_ui_flutter` free of platform camera permission manifests — the same
/// delegation strategy used by [BcShare].
class BcWebcam extends StatelessWidget {
  final BcWebcamFacingMode facingMode;
  final String? captureLabel;
  final Widget Function(BuildContext context)? cameraBuilder;
  final void Function(Object error)? onError;
  final void Function(String dataURL, BcChangeMeta meta)? onCapture;

  const BcWebcam({
    super.key,
    this.facingMode = BcWebcamFacingMode.user,
    this.captureLabel,
    this.cameraBuilder,
    this.onError,
    this.onCapture,
  });

  void _handleCapture() {
    // Delegate: the real image bytes come from the caller's camera plugin via
    // [cameraBuilder]. Here we emit the capture event surface so consumers
    // can react (e.g. trigger their capture pipeline).
    onCapture?.call(
      '',
      const BcChangeMeta(
        reason: BcChangeReason.submit,
        source: BcEventSource.pointer,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: bcI18n.t('bc.webcam.ariaLabel'),
      container: true,
      child: Container(
        key: const Key('bc-webcam-root'),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: BcTheme.muted,
          borderRadius: BorderRadius.circular(BcTheme.radius),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Camera (provide cameraBuilder)',
              key: Key('bc-webcam-title'),
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: BcTheme.foreground,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              key: const Key('bc-webcam-facing'),
              'facing: ${facingMode == BcWebcamFacingMode.user ? 'user' : 'environment'}',
              style: const TextStyle(fontSize: 12, color: BcTheme.mutedForeground),
            ),
            const SizedBox(height: 12),
            if (cameraBuilder != null)
              cameraBuilder!(context)
            else
              const SizedBox.shrink(),
            const SizedBox(height: 12),
            ElevatedButton(
              key: const Key('bc-webcam-capture'),
              onPressed: _handleCapture,
              style: ElevatedButton.styleFrom(
                backgroundColor: BcTheme.primary,
                foregroundColor: BcTheme.primaryForeground,
                minimumSize: const Size(0, 44),
                padding: const EdgeInsets.symmetric(horizontal: 24),
                textStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                elevation: 0,
              ),
              child: Text(
                  captureLabel ?? bcI18n.t('bc.webcam.defaultCaptureLabel')),
            ),
          ],
        ),
      ),
    );
  }
}
