// Overlays demo - BcDialog, BcAlertDialog, BcTooltip, BcAccordion,
// BcDisclosure, BcTabs, BcSplitter, BcDropdown, BcPopover, BcCommand,
// BcHoverCard, BcActionsheet, BcContextMenu, BcPortal, BcNotificationCenter.
library overlays_section;

import 'package:flutter/material.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:bc_ui_flutter/bc_ui_flutter.dart';

import '../demo_widgets.dart';

class OverlaysSection extends StatefulWidget {
  const OverlaysSection({super.key});

  @override
  State<OverlaysSection> createState() => _OverlaysSectionState();
}

class _OverlaysSectionState extends State<OverlaysSection> {
  String _dropdownValue = 'Option A';
  bool _actionsheetOpen = false;
  String _lastAction = 'none';
  bool _portalOpen = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionHeader(
          title: 'Overlays',
          subtitle: 'Dialogs, tooltips, dropdowns, splitters, command palette, hover cards, and action sheets.',
        ),
        const SizedBox(height: 24),
        DemoCard(
          title: 'BcDialog',
          description: 'Adaptive confirm/cancel dialog (Material AlertDialog / CupertinoAlertDialog).',
          child: PlatformElevatedButton(
            onPressed: () async {
              final result = await BcDialog.show(
                context: context,
                title: 'Delete Item',
                content: const Text(
                    'Are you sure you want to delete this item? This action cannot be undone.'),
                confirmText: 'Delete',
                cancelText: 'Cancel',
              );
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(result == true ? 'Confirmed' : 'Cancelled'),
                    duration: const Duration(seconds: 1),
                  ),
                );
              }
            },
            child: const Text('Open Dialog'),
          ),
        ),
        const SizedBox(height: 24),
        DemoCard(
          title: 'BcAlertDialog',
          description: 'Simple alert with a single dismiss button.',
          child: PlatformElevatedButton(
            onPressed: () {
              BcAlertDialog.show(
                context: context,
                title: 'Information',
                content: const Text(
                    'This is an informational alert dialog. Tap OK to dismiss.'),
                dismissText: 'OK',
              );
            },
            child: const Text('Open Alert'),
          ),
        ),
        const SizedBox(height: 24),
        DemoCard(
          title: 'BcTooltip',
          description: 'Adaptive tooltip on long-press/hover.',
          child: BcTooltip(
            message: 'This is a helpful tooltip!',
            child: Icon(
              PlatformIcons(context).info,
              color: BcTheme.primary,
              size: 32,
            ),
          ),
        ),
        const SizedBox(height: 24),
        DemoCard(
          title: 'BcAccordion',
          description: 'Collapsible accordion sections (Material ExpansionTile).',
          child: BcAccordion(
            initialExpandedIndex: 0,
            items: const [
              BcAccordionItem(
                title: 'What is BitCode UI?',
                child: Text(
                    'BitCode UI is a cross-framework component library that generates React, Vue, Stencil, and Flutter widgets from a single Mitosis source.'),
              ),
              BcAccordionItem(
                title: 'How does it work?',
                child: Text(
                    'Mitosis compiles .lite.tsx files into target frameworks. The Flutter adapter ports the contracts to Dart widgets.'),
              ),
              BcAccordionItem(
                title: 'Is it production ready?',
                child: Text(
                    'The Flutter adapter has 1500+ tests passing and clean static analysis. It is ready for integration.'),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        DemoCard(
          title: 'BcDisclosure',
          description: 'Collapsible panel with animated expand/collapse.',
          child: BcDisclosure(
            title: 'Advanced Settings',
            defaultOpen: false,
            child: const Padding(
              padding: EdgeInsets.only(top: 8),
              child: Text(
                'These are advanced settings that were hidden behind a '
                'disclosure panel. Tap the header to toggle.',
                style: TextStyle(fontSize: 14),
              ),
            ),
          ),
        ),
        const SizedBox(height: 24),
        DemoCard(
          title: 'BcTabs',
          description: 'Material 3 tab bar with swipeable content views.',
          child: SizedBox(
            height: 200,
            child: BcTabs(
              tabs: const [
                BcTabItem(
                  label: 'Overview',
                  child: Center(child: Text('Overview tab content')),
                ),
                BcTabItem(
                  label: 'Details',
                  child: Center(child: Text('Details tab content')),
                ),
                BcTabItem(
                  label: 'Reviews',
                  child: Center(child: Text('Reviews tab content')),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 24),
        DemoCard(
          title: 'BcSplitter',
          description: 'Draggable two-pane splitter (horizontal or vertical).',
          child: SizedBox(
            height: 160,
            child: BcSplitter(
              axis: Axis.horizontal,
              initialFraction: 0.5,
              first: Container(
                color: BcTheme.primary.withValues(alpha: 0.15),
                alignment: Alignment.center,
                child: const Text('Pane 1'),
              ),
              second: Container(
                color: BcTheme.secondary.withValues(alpha: 0.15),
                alignment: Alignment.center,
                child: const Text('Pane 2'),
              ),
            ),
          ),
        ),
        const SizedBox(height: 24),
        DemoCard(
          title: 'BcDropdown',
          description: 'Adaptive dropdown menu with a trigger button.',
          child: BcDropdown<String>(
            value: _dropdownValue,
            options: const [
              BcSelectOption(value: 'Option A', label: 'Option A'),
              BcSelectOption(value: 'Option B', label: 'Option B'),
              BcSelectOption(value: 'Option C', label: 'Option C'),
            ],
            placeholder: 'Choose...',
            onValueChange: (v, _) => setState(() => _dropdownValue = v),
          ),
        ),
        const SizedBox(height: 24),
        DemoCard(
          title: 'BcPopover',
          description: 'Overlay popover anchored to a trigger widget (Material-only).',
          child: BcPopover(
            title: 'Popover Title',
            width: 220,
            trigger: ElevatedButton.icon(
              onPressed: null,
              icon: const Icon(Icons.touch_app_outlined),
              label: const Text('Tap to open'),
            ),
            child: const Padding(
              padding: EdgeInsets.all(8),
              child: Text(
                'This popover content appears in an overlay near the trigger. '
                'Tap outside to dismiss.',
                style: TextStyle(fontSize: 13),
              ),
            ),
          ),
        ),
        const SizedBox(height: 24),
        DemoCard(
          title: 'BcCommand',
          description: 'Command palette triggered by Ctrl+K / Cmd+K (Material-only).',
          child: BcCommand(
            placeholder: 'Type a command...',
            commands: const [
              BcCommandItem(key: 'new-file', label: 'New File'),
              BcCommandItem(key: 'open-file', label: 'Open File'),
              BcCommandItem(key: 'save', label: 'Save'),
              BcCommandItem(key: 'print', label: 'Print'),
              BcCommandItem(key: 'exit', label: 'Exit'),
            ],
            child: const Text(
              'Focus this area and press Ctrl+K (or Cmd+K) to open the command palette.',
              style: TextStyle(fontSize: 13),
            ),
          ),
        ),
        const SizedBox(height: 24),
        DemoCard(
          title: 'BcHoverCard',
          description: 'Card that reveals on hover with placement control.',
          child: BcHoverCard(
            placement: BcHoverCardPlacement.bottom,
            content: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: BcTheme.card,
                border: Border.all(color: BcTheme.border),
              ),
              child: const Text(
                'This card appears on hover and stays while the pointer '
                'remains over the trigger or the card.',
                style: TextStyle(fontSize: 13),
              ),
            ),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: BcTheme.primary,
                borderRadius: BorderRadius.circular(6),
              ),
              child: const Text(
                'Hover me',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ),
        ),
        const SizedBox(height: 24),
        DemoCard(
          title: 'BcActionsheet',
          description: 'Bottom sheet action menu that slides up from the bottom.',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ElevatedButton(
                onPressed: () => setState(() => _actionsheetOpen = true),
                child: const Text('Open Action Sheet'),
              ),
              const SizedBox(height: 8),
              Text('Last action: $_lastAction',
                  style: Theme.of(context).textTheme.bodySmall),
              BcActionsheet(
                open: _actionsheetOpen,
                title: 'Share',
                description: 'Choose how to share this item.',
                items: const [
                  BcActionsheetItem(
                      label: 'Copy Link', value: 'copy', icon: Icons.link),
                  BcActionsheetItem(
                      label: 'Email', value: 'email', icon: Icons.email_outlined),
                  BcActionsheetItem(
                      label: 'Delete',
                      value: 'delete',
                      icon: Icons.delete_outline,
                      destructive: true),
                ],
                onSelect: (item, _) =>
                    setState(() {
                  _actionsheetOpen = false;
                  _lastAction = item.label;
                }),
                onCancel: (_, _) => setState(() => _actionsheetOpen = false),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        DemoCard(
          title: 'BcWizard',
          description: 'Multi-step wizard dialog with Next/Back navigation.',
          child: ElevatedButton(
            onPressed: () {
              BcWizard.show(
                context: context,
                steps: const [
                  BcWizardStep(title: 'Account', description: 'Enter your account details.'),
                  BcWizardStep(title: 'Profile', description: 'Set up your profile.'),
                  BcWizardStep(title: 'Confirm', description: 'Review and confirm.'),
                ],
              );
            },
            child: const Text('Open Wizard'),
          ),
        ),
        const SizedBox(height: 24),
        DemoCard(
          title: 'BcPrompt',
          description: 'Modal prompt dialog with text input and validation.',
          child: ElevatedButton(
            onPressed: () {
              BcPrompt.show(
                context: context,
                title: 'Rename Project',
                description: 'Enter a new name for this project.',
                defaultValue: 'My Project',
                placeholder: 'Project name',
                confirmLabel: 'Save',
                onConfirm: (value, _) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Saved: $value'),
                        duration: const Duration(milliseconds: 1000),
                      ),
                    );
                  }
                },
              );
            },
            child: const Text('Open Prompt'),
          ),
        ),
        const SizedBox(height: 24),
        DemoCard(
          title: 'BcSpeedDial',
          description: 'Floating action button that expands into sub-actions.',
          child: SizedBox(
            height: 200,
            child: Stack(
              children: [
                BcSpeedDial(
                  label: 'Actions',
                  icon: Icons.add,
                  actions: const [
                    BcSpeedDialAction(key: 'new', label: 'New Item', icon: Icons.note_add),
                    BcSpeedDialAction(key: 'share', label: 'Share', icon: Icons.share),
                    BcSpeedDialAction(key: 'email', label: 'Email', icon: Icons.email),
                  ],
                  onSelect: (action, _) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Selected: ${action.label}'),
                        duration: const Duration(milliseconds: 800),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 24),

        // -- BcContextMenu --
        DemoCard(
          title: 'BcContextMenu',
          description: 'Long-press or right-click the card to open a context menu.',
          child: BcContextMenu(
            items: [
              BcContextMenuItem(
                key: 'edit',
                label: 'Edit',
                icon: Icons.edit_outlined,
                onTap: () => ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Context: Edit'),
                    duration: Duration(milliseconds: 800),
                  ),
                ),
              ),
              const BcContextMenuItem(
                key: 'copy',
                label: 'Copy',
                icon: Icons.copy_outlined,
              ),
              const BcContextMenuItem(
                key: 'disabled',
                label: 'Disabled',
                enabled: false,
              ),
              BcContextMenuItem(
                key: 'delete',
                label: 'Delete',
                icon: Icons.delete_outline,
                onTap: () => ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Context: Delete'),
                    duration: Duration(milliseconds: 800),
                  ),
                ),
              ),
            ],
            child: BcBox(
              padding: 24,
              border: true,
              borderRadius: BcTheme.radius,
              backgroundColor: BcBoxColorToken.muted,
              child: const Center(
                child: Text('Long-press or right-click me'),
              ),
            ),
          ),
        ),
        const SizedBox(height: 24),

        // -- BcPortal --
        DemoCard(
          title: 'BcPortal',
          description: 'Renders child into a root-level Overlay, outside the parent stacking context.',
          child: BcYStack(
            gap: 8,
            children: [
              ElevatedButton(
                onPressed: () => setState(() => _portalOpen = !_portalOpen),
                child: Text(_portalOpen ? 'Close Portal' : 'Open Portal'),
              ),
              Text(
                'When open, the portal floats above the rest of the app via an OverlayEntry.',
                style: Theme.of(context).textTheme.bodySmall,
              ),
              BcPortal(
                open: _portalOpen,
                name: 'demo',
                animation: BcPortalAnimation.fade,
                onRequestClose: (_) => setState(() => _portalOpen = false),
                child: Material(
                  color: Colors.transparent,
                  child: Container(
                    margin: const EdgeInsets.only(top: 80, left: 40, right: 40),
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: BcTheme.popover,
                      borderRadius: BorderRadius.circular(BcTheme.radius),
                      boxShadow: const [
                        BoxShadow(
                          color: Color(0x33000000),
                          blurRadius: 20,
                          offset: Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Portal Content',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'This widget is mounted in the root Overlay, '
                          'so it paints above the demo card boundaries.',
                        ),
                        const SizedBox(height: 12),
                        ElevatedButton(
                          onPressed: () => setState(() => _portalOpen = false),
                          child: const Text('Close'),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),

        // -- BcNotificationCenter --
        DemoCard(
          title: 'BcNotificationCenter',
          description: 'Bell icon with unread badge and a dropdown notification list.',
          child: Align(
            alignment: Alignment.centerLeft,
            child: BcNotificationCenter(
              unreadCount: 2,
              notifications: const [
                BcNotificationItemData(
                  id: 'n1',
                  type: BcNotificationVariant.message,
                  title: 'New message from Alice',
                  body: 'Can you review my PR when you get a chance?',
                  createdAt: '2m ago',
                ),
                BcNotificationItemData(
                  id: 'n2',
                  type: BcNotificationVariant.warning,
                  title: 'Build warning',
                  body: 'deploy.yml has 2 deprecated actions.',
                  createdAt: '1h ago',
                ),
                BcNotificationItemData(
                  id: 'n3',
                  type: BcNotificationVariant.success,
                  title: 'Deploy succeeded',
                  body: 'Production build v0.2.0 is live.',
                  createdAt: '3h ago',
                  readAt: '3h ago',
                ),
              ],
              emptyText: 'You are all caught up!',
              onMarkRead: (id) => ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Marked read: $id'),
                  duration: const Duration(milliseconds: 800),
                ),
              ),
              onMarkAllRead: () => ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Marked all as read'),
                  duration: Duration(milliseconds: 800),
                ),
              ),
              onItemClick: (item) => ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Clicked: ${item.title}'),
                  duration: const Duration(milliseconds: 800),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
