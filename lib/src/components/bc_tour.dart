library bc_tour;

import 'package:flutter/material.dart';

import '../core/types.dart';
import '../theme/bc_theme.dart';

/// A single step in the guided tour.
///
/// Mirrors TS `BcTourStep` ({ title, description?, target? }).
/// [target] is a string key that can be used to locate the target widget
/// (via GlobalKey or find.byKey). When omitted, the cut-out overlays the
/// center of the screen as a default highlight region.
class BcTourStep {
  final String title;
  final String? description;
  final String? target;

  const BcTourStep({
    required this.title,
    this.description,
    this.target,
  });
}

/// Guided tour overlay with sequential step highlights.
///
/// Mirrors the TS `BcTourContract`: when [open] is true, renders a full-screen
/// overlay that darkens everything except a rectangular cut-out region
/// framing the current step's target element. Navigation controls (Next/Back)
/// advance and reverse through [steps] in order, with Next disabled on the
/// last step (becomes Finish) and Back disabled on the first step.
///
/// Controlled mode: the parent provides [step]; internal state is not
/// self-mutated on Next/Back until the parent updates the prop. Next/Back
/// still emit [onStepChange] carrying the candidate new index and a
/// [BcChangeMeta] whose source reflects the origin.
///
/// Finishing on the last step invokes [onFinish] and disposes the overlay
/// (the parent should set [open] to false). Skipping/cancelling at any step
/// invokes [onSkip] and likewise disposes.
///
/// The cut-out highlight is a [Rect] defined by [BcTourStep.target] resolved
/// to a [GlobalKey] in [targetKeys]. If no key is provided for a step, the
/// cut-out defaults to a centered rect. Advancing moves the cut-out to the
/// next target's bounds.
class BcTour extends StatefulWidget {
  /// Whether the tour overlay is visible.
  final bool open;

  /// The ordered list of tour steps.
  final List<BcTourStep> steps;

  /// Controlled current step index. When non-null, the widget is controlled.
  final int? step;

  /// Initial step index for uncontrolled mode.
  final int defaultStep;

  /// Label for the next navigation button.
  final String nextLabel;

  /// Label for the previous navigation button.
  final String prevLabel;

  /// Label for the finish button (shown on the last step).
  final String finishLabel;

  /// Map of target string IDs to [GlobalKey]s used to locate the widget
  /// for the cut-out highlight.
  final Map<String, GlobalKey> targetKeys;

  /// Called on each step transition with the new step index and meta.
  final BcChangeHandler<int>? onStepChange;

  /// Called when the tour finishes (Finish button on last step).
  final void Function(BcChangeMeta meta)? onFinish;

  /// Called when the tour is skipped/cancelled.
  final void Function(BcChangeMeta meta)? onSkip;

  const BcTour({
    super.key,
    this.open = false,
    this.steps = const [],
    this.step,
    this.defaultStep = 0,
    this.nextLabel = 'Next',
    this.prevLabel = 'Back',
    this.finishLabel = 'Finish',
    this.targetKeys = const {},
    this.onStepChange,
    this.onFinish,
    this.onSkip,
  });

  @override
  State<BcTour> createState() => _BcTourState();
}

class _BcTourState extends State<BcTour> {
  late int _internalStep;
  bool _internallyClosed = false;

  bool get _isControlled => widget.step != null;

  int get _currentStep {
    if (widget.steps.isEmpty) return 0;
    final base = _isControlled ? widget.step! : _internalStep;
    return base.clamp(0, widget.steps.length - 1);
  }

  int get _total => widget.steps.length;

  bool get _isLast => _currentStep >= _total - 1;
  bool get _isFirst => _currentStep == 0;

  BcTourStep? get _currentStepData {
    if (widget.steps.isEmpty) return null;
    return widget.steps[_currentStep];
  }

  @override
  void initState() {
    super.initState();
    _internalStep = widget.steps.isEmpty
        ? 0
        : widget.defaultStep.clamp(0, widget.steps.length - 1);
  }

  @override
  void didUpdateWidget(covariant BcTour oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Reset internal close when parent re-opens.
    if (widget.open && !oldWidget.open) {
      _internallyClosed = false;
    }
    if (!_isControlled && widget.defaultStep != oldWidget.defaultStep) {
      _internalStep = widget.steps.isEmpty
          ? 0
          : widget.defaultStep.clamp(0, widget.steps.length - 1);
    }
  }

  void _transitionTo(int target, BcChangeMeta meta) {
    if (widget.steps.isEmpty) return;
    final clamped = target.clamp(0, widget.steps.length - 1);
    if (clamped == _currentStep && !_isControlled) return;
    if (!_isControlled) {
      setState(() => _internalStep = clamped);
    }
    widget.onStepChange?.call(clamped, meta);
  }

  void _handleNext() {
    if (_isLast) {
      setState(() => _internallyClosed = true);
      widget.onFinish?.call(
        const BcChangeMeta(
          reason: BcChangeReason.submit,
          source: BcEventSource.pointer,
        ),
      );
      return;
    }
    _transitionTo(
      _currentStep + 1,
      const BcChangeMeta(
        reason: BcChangeReason.increment,
        source: BcEventSource.pointer,
      ),
    );
  }

  void _handlePrev() {
    _transitionTo(
      _currentStep - 1,
      const BcChangeMeta(
        reason: BcChangeReason.decrement,
        source: BcEventSource.pointer,
      ),
    );
  }

  void _handleSkip() {
    setState(() => _internallyClosed = true);
    widget.onSkip?.call(
      const BcChangeMeta(
        reason: BcChangeReason.cancel,
        source: BcEventSource.pointer,
      ),
    );
  }

  Rect? _resolveCutout(Rect overlayBounds) {
    final stepData = _currentStepData;
    if (stepData == null) return null;
    final targetId = stepData.target;
    if (targetId == null) return null;
    final key = widget.targetKeys[targetId];
    if (key == null) return null;
    final renderBox = key.currentContext?.findRenderObject() as RenderBox?;
    if (renderBox == null || !renderBox.attached) return null;
    final targetBounds = renderBox.localToGlobal(Offset.zero) & renderBox.size;
    if (!overlayBounds.overlaps(targetBounds)) return null;
    return targetBounds;
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.open || widget.steps.isEmpty || _internallyClosed) {
      return const SizedBox.shrink();
    }

    final stepData = _currentStepData!;

    return Stack(
      key: const Key('bc-tour-overlay'),
      children: [
        Positioned.fill(
          child: GestureDetector(
            key: const Key('bc-tour-backdrop'),
            onTap: _handleSkip,
            child: CustomPaint(
              painter: _TourOverlayPainter(
                cutoutResolver: _resolveCutout,
                dimColor: BcTheme.foreground.withValues(alpha: 0.4),
                highlightColor: BcTheme.popover,
              ),
            ),
          ),
        ),
        Positioned(
          key: const Key('bc-tour-cutout'),
          left: 0,
          right: 0,
          bottom: 0,
          child: SafeArea(
            child: Center(
              child: Container(
                key: const Key('bc-tour-panel'),
                width: double.infinity,
                constraints: const BoxConstraints(maxWidth: 400),
                margin: const EdgeInsets.all(16),
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: BcTheme.popover,
                  borderRadius: BorderRadius.circular(BcTheme.radius),
                  border: Border.all(color: BcTheme.border),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x29000000),
                      blurRadius: 16,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: _buildPanel(stepData),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPanel(BcTourStep stepData) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              '${_currentStep + 1} / $_total',
              key: const Key('bc-tour-progress'),
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: BcTheme.mutedForeground,
              ),
            ),
            const Spacer(),
            SizedBox(
              width: 28,
              height: 28,
              child: IconButton(
                key: const Key('bc-tour-skip'),
                icon: const Icon(Icons.close, size: 16),
                color: BcTheme.mutedForeground,
                tooltip: 'Skip tour',
                onPressed: _handleSkip,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(
                  minWidth: 28,
                  minHeight: 28,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          stepData.title,
          key: const Key('bc-tour-title'),
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: BcTheme.popoverForeground,
          ),
        ),
        if (stepData.description != null) ...[
          const SizedBox(height: 8),
          Text(
            stepData.description!,
            style: const TextStyle(
              fontSize: 14,
              color: BcTheme.mutedForeground,
            ),
          ),
        ],
        const SizedBox(height: 20),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            ElevatedButton(
              key: const Key('bc-tour-prev'),
              onPressed: _isFirst ? null : _handlePrev,
              style: ElevatedButton.styleFrom(
                backgroundColor: BcTheme.background,
                foregroundColor: BcTheme.foreground,
                elevation: 0,
                side: const BorderSide(color: BcTheme.border),
              ),
              child: Text(widget.prevLabel),
            ),
            const SizedBox(width: 8),
            ElevatedButton(
              key: const Key('bc-tour-next'),
              onPressed: _isLast ? null : _handleNext,
              style: ElevatedButton.styleFrom(
                backgroundColor: BcTheme.primary,
                foregroundColor: BcTheme.primaryForeground,
                elevation: 0,
              ),
              child: Text(widget.nextLabel),
            ),
            if (_isLast) ...[
              const SizedBox(width: 8),
              ElevatedButton(
                key: const Key('bc-tour-finish'),
                onPressed: _handleNext,
                style: ElevatedButton.styleFrom(
                  backgroundColor: BcTheme.primary,
                  foregroundColor: BcTheme.primaryForeground,
                  elevation: 0,
                ),
                child: Text(widget.finishLabel),
              ),
            ],
          ],
        ),
      ],
    );
  }
}

/// Custom painter that darkens the whole screen except the cut-out rect.
///
/// When no cut-out is available (target not found), paints a uniform dim
/// layer and draws a centered default highlight rect as the cut-out
/// placeholder.
class _TourOverlayPainter extends CustomPainter {
  final Rect? Function(Rect overlayBounds) cutoutResolver;
  final Color dimColor;
  final Color highlightColor;

  _TourOverlayPainter({
    required this.cutoutResolver,
    required this.dimColor,
    required this.highlightColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final overlayBounds = Offset.zero & size;
    final cutout = cutoutResolver(overlayBounds);

    final paint = Paint()..color = dimColor;

    if (cutout != null && overlayBounds.overlaps(cutout)) {
      final path = Path()
        ..addRect(overlayBounds)
        ..addRect(cutout)
        ..fillType = PathFillType.evenOdd;

      canvas.drawPath(path, paint);

      final borderPaint = Paint()
        ..color = highlightColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3;
      canvas.drawRect(
        cutout.inflate(4),
        borderPaint,
      );
    } else {
      canvas.drawRect(overlayBounds, paint);

      final centerX = size.width / 2;
      final centerY = size.height / 3;
      final defaultCutout = Rect.fromCenter(
        center: Offset(centerX, centerY),
        width: 200,
        height: 60,
      );

      final clearPath = Path()
        ..addRect(overlayBounds)
        ..addRect(defaultCutout)
        ..fillType = PathFillType.evenOdd;

      canvas.drawPath(clearPath, Paint()..color = Colors.transparent);

      final borderPaint = Paint()
        ..color = highlightColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3;
      canvas.drawRect(
        defaultCutout.inflate(4),
        borderPaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _TourOverlayPainter oldDelegate) {
    return oldDelegate.cutoutResolver != cutoutResolver ||
        oldDelegate.dimColor != dimColor;
  }
}
