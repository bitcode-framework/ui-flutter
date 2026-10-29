library bc_favorites;

import 'package:flutter/material.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import '../core/types.dart';
import '../theme/bc_theme.dart';

/// Favorites toggle button with active/inactive state
/// (ADR-011 Phase 5c — M7 misc).
///
/// Mirrors TS [BcFavoritesContract] ({ items?, emptyText?, ariaLabel?,
/// onSelect?, onRemove? }).
///
/// Renders a star/heart toggle button. Tapping it toggles favorited state
/// and invokes [onValueChange] with the boolean favorited value and
/// [BcChangeMeta]. The active state renders with a distinct color
/// (token-based).
///
/// Controlled mode: parent provides [value]; uncontrolled: [defaultValue].
/// In controlled mode, tapping the toggle invokes [onValueChange] but does
/// not flip the internal visual state until the parent updates [value].
class BcFavorites extends StatefulWidget {
  final String? name;
  final bool? value;
  final bool? defaultValue;
  final IconData activeIcon;
  final IconData inactiveIcon;
  final double iconSize;
  final BcChangeHandler<bool>? onValueChange;

  const BcFavorites({
    super.key,
    this.name,
    this.value,
    this.defaultValue,
    this.activeIcon = Icons.star,
    this.inactiveIcon = Icons.star_border,
    this.iconSize = 24,
    this.onValueChange,
  });

  @override
  State<BcFavorites> createState() => _BcFavoritesState();
}

class _BcFavoritesState extends State<BcFavorites> {
  bool _internal = false;

  @override
  void initState() {
    super.initState();
    _internal = widget.defaultValue ?? false;
  }

  @override
  void didUpdateWidget(BcFavorites oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.defaultValue != oldWidget.defaultValue) {
      _internal = widget.defaultValue ?? false;
    }
  }

  bool get _isActive => widget.value ?? _internal;

  void _toggle() {
    final next = !_isActive;

    if (widget.value == null) {
      setState(() => _internal = next);
    }

    widget.onValueChange?.call(
      next,
      BcChangeMeta(
        reason:
            next ? BcChangeReason.select : BcChangeReason.deselect,
        source: BcEventSource.pointer,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final color =
        _isActive ? BcTheme.warning : BcTheme.mutedForeground;
    final icon = _isActive ? widget.activeIcon : widget.inactiveIcon;

    return PlatformIconButton(
      key: Key('bc_favorites_${_isActive ? 'active' : 'inactive'}'),
      padding: EdgeInsets.zero,
      icon: Icon(icon, size: widget.iconSize, color: color),
      onPressed: _toggle,
    );
  }
}
