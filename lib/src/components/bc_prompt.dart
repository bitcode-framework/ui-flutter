library bc_prompt;

import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import '../core/types.dart';
import '../theme/bc_theme.dart';

/// Modal prompt dialog with input field, OK/cancel actions.
///
/// Mirrors the TS `BcPromptContract`: a modal overlay that renders a title,
/// optional description, a text input field seeded with [defaultValue] (or
/// the controlled [value]), and OK/cancel action controls.
///
/// Confirming with OK invokes [onConfirm] (and [onValueChange]) carrying the
/// exact string currently in the input field and a [BcChangeMeta] whose
/// reason is [BcChangeReason.confirm]. Cancelling invokes [onCancel]
/// carrying a [BcChangeMeta] whose reason is [BcChangeReason.cancel] without
/// propagating the entered text as a value.
///
/// When a [validator] is supplied and the current input fails it, the OK
/// action is disabled and the validation error text is rendered. Entering a
/// valid value re-enables OK.
///
/// [barrierDismissible] controls whether tapping the scrim (or pressing
/// Escape) dismisses the dialog with a cancel outcome. Default is `true`.
///
/// Platform-aware: renders `CupertinoAlertDialog` on iOS/macOS,
/// `AlertDialog` elsewhere.
class BcPrompt {
  BcPrompt._();

  /// Shows the prompt dialog and returns when it is dismissed.
  static void show({
    required BuildContext context,
    String? title,
    String? description,
    String? defaultValue,
    String? value,
    String? placeholder,
    String confirmLabel = 'OK',
    String cancelLabel = 'Cancel',
    bool barrierDismissible = true,
    String? Function(String?)? validator,
    BcChangeHandler<String>? onValueChange,
    BcChangeHandler<String>? onConfirm,
    BcChangeHandler<void>? onCancel,
  }) {
    Navigator.of(context, rootNavigator: true).push<dynamic>(
      _BcPromptRoute(
        context: context,
        title: title,
        description: description,
        defaultValue: defaultValue,
        value: value,
        placeholder: placeholder,
        confirmLabel: confirmLabel,
        cancelLabel: cancelLabel,
        barrierDismissible: barrierDismissible,
        validator: validator,
        onValueChange: onValueChange,
        onConfirm: onConfirm,
        onCancel: onCancel,
      ),
    );
  }
}

class _BcPromptRoute extends PopupRoute<dynamic> {
  final BuildContext context;
  final String? title;
  final String? description;
  final String? defaultValue;
  final String? value;
  final String? placeholder;
  final String confirmLabel;
  final String cancelLabel;
  final bool _dismissible;
  final String? Function(String?)? validator;
  final BcChangeHandler<String>? onValueChange;
  final BcChangeHandler<String>? onConfirm;
  final BcChangeHandler<void>? onCancel;

  _BcPromptRoute({
    required this.context,
    required this.title,
    required this.description,
    required this.defaultValue,
    required this.value,
    required this.placeholder,
    required this.confirmLabel,
    required this.cancelLabel,
    required bool barrierDismissible,
    required this.validator,
    required this.onValueChange,
    required this.onConfirm,
    required this.onCancel,
  }) : _dismissible = barrierDismissible;

  @override
  Color? get barrierColor => Colors.black54;

  @override
  bool get barrierDismissible => false;

  @override
  String? get barrierLabel => _dismissible ? 'bc-prompt-barrier' : null;

  @override
  Widget buildPage(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
  ) {
    return _BcPromptPage(
      route: this,
    );
  }

  @override
  Widget buildTransitions(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    return FadeTransition(opacity: animation, child: child);
  }

  @override
  Duration get transitionDuration => const Duration(milliseconds: 200);

  void dismiss([dynamic result]) {
    if (isCurrent) {
      Navigator.of(context).pop(result);
    }
  }
}

class _BcPromptPage extends StatefulWidget {
  final _BcPromptRoute route;

  const _BcPromptPage({required this.route});

  @override
  State<_BcPromptPage> createState() => _BcPromptPageState();
}

class _BcPromptPageState extends State<_BcPromptPage> {
  late TextEditingController _controller;
  late FocusNode _focusNode;
  String? _errorText;
  bool _isControlled = false;

  bool get _hasValidator => widget.route.validator != null;

  String? _validate(String input) {
    if (!_hasValidator) return null;
    return widget.route.validator!(input);
  }

  bool get _isValid {
    final err = _validate(_controller.text);
    return err == null;
  }

  @override
  void initState() {
    super.initState();
    _isControlled = widget.route.value != null;
    final initial = widget.route.value ?? widget.route.defaultValue ?? '';
    _controller = TextEditingController(text: initial);
    _focusNode = FocusNode();
    _errorText = _validate(initial);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _focusNode.requestFocus();
    });
  }

  @override
  void didUpdateWidget(covariant _BcPromptPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (_isControlled) {
      final controlled = widget.route.value ?? '';
      if (_controller.text != controlled) {
        _controller.text = controlled;
        _errorText = _validate(controlled);
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _onInputChanged(String text) {
    if (_hasValidator) {
      final err = _validate(text);
      if (err != _errorText) {
        setState(() => _errorText = err);
      }
    }
    widget.route.onValueChange?.call(
      text,
      const BcChangeMeta(
        reason: BcChangeReason.input,
        source: BcEventSource.keyboard,
      ),
    );
  }

  void _handleConfirm() {
    final text = _controller.text;
    const meta = BcChangeMeta(
      reason: BcChangeReason.confirm,
      source: BcEventSource.pointer,
    );
    widget.route.onValueChange?.call(text, meta);
    widget.route.onConfirm?.call(text, meta);
    widget.route.dismiss(true);
  }

  void _handleCancel() {
    const meta = BcChangeMeta(
      reason: BcChangeReason.cancel,
      source: BcEventSource.pointer,
    );
    widget.route.onCancel?.call(null, meta);
    widget.route.dismiss(false);
  }

  @override
  Widget build(BuildContext context) {
    final platform = Theme.of(context).platform;
    final isIOS = platform == TargetPlatform.iOS ||
        platform == TargetPlatform.macOS;
    final dialog = isIOS ? _buildCupertino() : _buildMaterial();
    if (!widget.route._dismissible) {
      return dialog;
    }
    return GestureDetector(
      onTap: _handleBarrierTap,
      behavior: HitTestBehavior.opaque,
      child: dialog,
    );
  }

  void _handleBarrierTap() {
    const meta = BcChangeMeta(
      reason: BcChangeReason.cancel,
      source: BcEventSource.pointer,
    );
    widget.route.onCancel?.call(null, meta);
    widget.route.dismiss(false);
  }

  Widget _buildMaterial() {
    return Center(
      child: GestureDetector(
        onTap: () {},
        child: AlertDialog(
          key: const Key('bc-prompt-dialog'),
          title: widget.route.title != null ? Text(widget.route.title!) : null,
          content: _buildContent(),
          actions: [
            TextButton(
              key: const Key('bc-prompt-cancel'),
              onPressed: _handleCancel,
              child: Text(widget.route.cancelLabel),
            ),
            FilledButton(
              key: const Key('bc-prompt-confirm'),
              onPressed: _isValid ? _handleConfirm : null,
              child: Text(widget.route.confirmLabel),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCupertino() {
    return Center(
      child: GestureDetector(
        onTap: () {},
        child: CupertinoAlertDialog(
          key: const Key('bc-prompt-dialog'),
          title: widget.route.title != null ? Text(widget.route.title!) : null,
          content: Padding(
            padding: const EdgeInsets.only(top: 8),
            child: _buildContent(),
          ),
          actions: [
            CupertinoDialogAction(
              key: const Key('bc-prompt-cancel'),
              onPressed: _handleCancel,
              child: Text(widget.route.cancelLabel),
            ),
            CupertinoDialogAction(
              key: const Key('bc-prompt-confirm'),
              onPressed: _isValid ? _handleConfirm : null,
              child: Text(widget.route.confirmLabel),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.route.description != null)
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Text(
              widget.route.description!,
              style: const TextStyle(fontSize: 14, color: BcTheme.mutedForeground),
            ),
          ),
        TextField(
          key: const Key('bc-prompt-input'),
          controller: _controller,
          focusNode: _focusNode,
          decoration: InputDecoration(
            hintText: widget.route.placeholder,
            errorText: _errorText,
            border: const OutlineInputBorder(),
          ),
          autofocus: true,
          onChanged: _onInputChanged,
          onSubmitted: (_) {
            if (_isValid) _handleConfirm();
          },
        ),
      ],
    );
  }
}
