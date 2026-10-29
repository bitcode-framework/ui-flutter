library bc_command;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Material-only command palette (ADR-011 Section 5).
/// Pure Material 3 — Ctrl+K / Cmd+K triggered searchable command menu.
class BcCommand extends StatefulWidget {
  final List<BcCommandItem> commands;
  final Widget child;
  final String? placeholder;

  const BcCommand({
    super.key,
    required this.commands,
    required this.child,
    this.placeholder,
  });

  @override
  State<BcCommand> createState() => _BcCommandState();
}

class _BcCommandState extends State<BcCommand> {
  late FocusNode _focusNode;
  OverlayEntry? _overlayEntry;
  late TextEditingController _searchController;

  @override
  void initState() {
    super.initState();
    _focusNode = FocusNode();
    _searchController = TextEditingController();
  }

  @override
  void dispose() {
    _focusNode.dispose();
    _searchController.dispose();
    _overlayEntry?.remove();
    super.dispose();
  }

  void _toggle() {
    if (_overlayEntry != null) {
      _hide();
    } else {
      _show();
    }
  }

  void _show() {
    _overlayEntry = OverlayEntry(
      builder: (context) => _CommandOverlay(
        searchController: _searchController,
        commands: widget.commands,
        placeholder: widget.placeholder,
        onClose: _hide,
      ),
    );
    Overlay.of(context).insert(_overlayEntry!);
    _searchController.clear();
  }

  void _hide() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  @override
  Widget build(BuildContext context) {
    return KeyboardListener(
      focusNode: _focusNode,
      autofocus: true,
      onKeyEvent: (event) {
        final isCtrl = HardwareKeyboard.instance.isControlPressed;
        final isMeta = HardwareKeyboard.instance.isMetaPressed;
        if ((isCtrl || isMeta) && event.logicalKey == LogicalKeyboardKey.keyK) {
          _toggle();
        }
      },
      child: widget.child,
    );
  }
}

class _CommandOverlay extends StatefulWidget {
  final TextEditingController searchController;
  final List<BcCommandItem> commands;
  final String? placeholder;
  final VoidCallback onClose;

  const _CommandOverlay({
    required this.searchController,
    required this.commands,
    required this.placeholder,
    required this.onClose,
  });

  @override
  State<_CommandOverlay> createState() => _CommandOverlayState();
}

class _CommandOverlayState extends State<_CommandOverlay> {
  String _query = '';

  @override
  Widget build(BuildContext context) {
    final filtered = widget.commands
        .where((c) => c.label.toLowerCase().contains(_query.toLowerCase()))
        .toList();

    return Stack(
      children: [
        GestureDetector(
          onTap: widget.onClose,
          child: Container(color: Colors.black54),
        ),
        Center(
          child: Material(
            elevation: 8,
            borderRadius: BorderRadius.circular(12),
            child: Container(
              width: 400,
              constraints: const BoxConstraints(maxHeight: 400),
              padding: const EdgeInsets.all(12),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: widget.searchController,
                    autofocus: true,
                    decoration: InputDecoration(
                      hintText: widget.placeholder ?? 'Type a command...',
                      border: const OutlineInputBorder(),
                      prefixIcon: const Icon(Icons.search),
                    ),
                    onChanged: (v) => setState(() => _query = v),
                  ),
                  const SizedBox(height: 8),
                  Flexible(
                    child: ListView.builder(
                      shrinkWrap: true,
                      itemCount: filtered.length,
                      itemBuilder: (context, index) {
                        final cmd = filtered[index];
                        return Material(
                          color: Colors.transparent,
                          child: ListTile(
                            leading: cmd.icon != null ? Icon(cmd.icon) : null,
                            title: Text(cmd.label),
                            onTap: () {
                              widget.onClose();
                              cmd.onExecute?.call();
                            },
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class BcCommandItem {
  final String key;
  final String label;
  final IconData? icon;
  final VoidCallback? onExecute;

  const BcCommandItem({
    required this.key,
    required this.label,
    this.icon,
    this.onExecute,
  });
}
