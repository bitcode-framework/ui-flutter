// ===========================================================================
// main.dart — BitCode UI Flutter Demo App
//
// A runnable showcase of the bc_ui_flutter package. Mirrors the structure
// of the React demo-app (packages/ui/demo-app) — a sidebar with grouped
// component categories, each opening a scrollable demo page.
//
// Run (web):   flutter run -t example/lib/main.dart -d chrome
// Build web:   flutter build web -t example/lib/main.dart
// Run (debug): flutter run -t example/lib/main.dart
// ===========================================================================

import 'dart:ui' show PlatformDispatcher;

import 'package:flutter/material.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:bc_ui_flutter/bc_ui_flutter.dart';

import 'sections/forms_section.dart';
import 'sections/overlays_section.dart';
import 'sections/data_section.dart';
import 'sections/layout_section.dart';
import 'sections/display_section.dart';
import 'sections/navigation_section.dart';
import 'sections/primitives_section.dart';
import 'sections/feedback_section.dart';
import 'sections/media_section.dart';
import 'sections/charts_section.dart';
import 'sections/social_section.dart';
import 'sections/misc_section.dart';
import 'sections/input_extended_section.dart';
import 'sections/print_section.dart';
import 'sections/views_section.dart';
import 'sections/native_section.dart';
import 'sections/block_catalog_section.dart';
import 'sections/builders_section.dart';

void main() {
  // Redirect Flutter errors to console for debugging
  FlutterError.onError = (FlutterErrorDetails details) {
    FlutterError.presentError(details);
    debugPrint('FLUTTER_ERROR: ${details.exceptionAsString()}');
    debugPrint('FLUTTER_ERROR_STACK: ${details.stack}');
  };
  PlatformDispatcher.instance.onError = (error, stack) {
    debugPrint('PLATFORM_ERROR: $error');
    debugPrint('PLATFORM_ERROR_STACK: $stack');
    return true;
  };
  runApp(const BcUiDemoApp());
}

class BcUiDemoApp extends StatelessWidget {
  const BcUiDemoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return PlatformProvider(
      settings: PlatformSettingsData(
        iosUsesMaterialWidgets: true,
      ),
      builder: (context) => BcApp(
        title: 'BitCode UI — Flutter Demo',
        home: const DemoShell(),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Navigation model
// ---------------------------------------------------------------------------

class _NavItem {
  final IconData icon;
  final IconData selectedIcon;
  final String label;
  final WidgetBuilder builder;

  const _NavItem({
    required this.icon,
    required this.selectedIcon,
    required this.label,
    required this.builder,
  });
}

// ---------------------------------------------------------------------------
// Demo shell — responsive sidebar + content area
// ---------------------------------------------------------------------------

class DemoShell extends StatefulWidget {
  const DemoShell({super.key});

  @override
  State<DemoShell> createState() => _DemoShellState();
}

class _DemoShellState extends State<DemoShell> {
  int _selectedIndex = 0;

  late final List<_NavItem> _sections = [
    _NavItem(
      icon: Icons.view_quilt_outlined,
      selectedIcon: Icons.view_quilt,
      label: 'Forms',
      builder: (_) => const FormsSection(),
    ),
    _NavItem(
      icon: Icons.layers_outlined,
      selectedIcon: Icons.layers,
      label: 'Overlays',
      builder: (_) => const OverlaysSection(),
    ),
    _NavItem(
      icon: Icons.table_chart_outlined,
      selectedIcon: Icons.table_chart,
      label: 'Data',
      builder: (_) => const DataSection(),
    ),
    _NavItem(
      icon: Icons.display_settings_outlined,
      selectedIcon: Icons.display_settings,
      label: 'Display',
      builder: (_) => const DisplaySection(),
    ),
    _NavItem(
      icon: Icons.navigation_outlined,
      selectedIcon: Icons.navigation,
      label: 'Navigation',
      builder: (_) => const NavigationSection(),
    ),
    _NavItem(
      icon: Icons.dashboard_outlined,
      selectedIcon: Icons.dashboard,
      label: 'Layout',
      builder: (_) => const LayoutSection(),
    ),
    _NavItem(
      icon: Icons.bubble_chart_outlined,
      selectedIcon: Icons.bubble_chart,
      label: 'Primitives',
      builder: (_) => const PrimitivesSection(),
    ),
    _NavItem(
      icon: Icons.feedback_outlined,
      selectedIcon: Icons.feedback,
      label: 'Feedback',
      builder: (_) => const FeedbackSection(),
    ),
    _NavItem(
      icon: Icons.perm_media_outlined,
      selectedIcon: Icons.perm_media,
      label: 'Media',
      builder: (_) => const MediaSection(),
    ),
    _NavItem(
      icon: Icons.show_chart_outlined,
      selectedIcon: Icons.show_chart,
      label: 'Charts',
      builder: (_) => const ChartsSection(),
    ),
    _NavItem(
      icon: Icons.people_outline,
      selectedIcon: Icons.people,
      label: 'Social',
      builder: (_) => const SocialSection(),
    ),
    _NavItem(
      icon: Icons.extension_outlined,
      selectedIcon: Icons.extension,
      label: 'Misc',
      builder: (_) => const MiscSection(),
    ),
    _NavItem(
      icon: Icons.edit_attributes_outlined,
      selectedIcon: Icons.edit_attributes,
      label: 'Input Extended',
      builder: (_) => const InputExtendedSection(),
    ),
    _NavItem(
      icon: Icons.print_outlined,
      selectedIcon: Icons.print,
      label: 'Print',
      builder: (_) => const PrintSection(),
    ),
    _NavItem(
      icon: Icons.view_module_outlined,
      selectedIcon: Icons.view_module,
      label: 'Views',
      builder: (_) => const ViewsSection(),
    ),
    _NavItem(
      icon: Icons.phone_iphone_outlined,
      selectedIcon: Icons.phone_iphone,
      label: 'Native',
      builder: (_) => const NativeSection(),
    ),
    _NavItem(
      icon: Icons.dashboard_outlined,
      selectedIcon: Icons.dashboard,
      label: 'Block Catalog',
      builder: (_) => const BlockCatalogSection(),
    ),
    _NavItem(
      icon: Icons.build_outlined,
      selectedIcon: Icons.build,
      label: 'Builders',
      builder: (_) => const BuildersSection(),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.of(context).size.width >= 768;

    if (!isWide) {
      // Narrow: bottom navigation bar
      return Scaffold(
        body: SafeArea(
          child: SingleChildScrollView(
            child: _sections[_selectedIndex].builder(context),
          ),
        ),
        bottomNavigationBar: NavigationBar(
          selectedIndex: _selectedIndex,
          onDestinationSelected: (i) => setState(() => _selectedIndex = i),
          destinations: _sections
              .map((s) => NavigationDestination(
                    icon: Icon(s.icon),
                    selectedIcon: Icon(s.selectedIcon),
                    label: s.label,
                  ))
              .toList(),
        ),
      );
    }

    // Wide: sidebar + content
    return Scaffold(
      body: Row(
        children: [
          _buildSidebar(),
          const VerticalDivider(width: 1),
          Expanded(
            child: SingleChildScrollView(
              child: _sections[_selectedIndex].builder(context),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSidebar() {
    return Container(
      width: 240,
      color: BcTheme.background,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(color: BcTheme.border),
              ),
            ),
            child: BcYStack(
              gap: 4,
              children: [
                Text(
                  'BitCode UI',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: BcTheme.primary,
                      ),
                ),
                Text(
                  'Flutter Demo',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: BcTheme.mutedForeground,
                      ),
                ),
              ],
            ),
          ),
          // Nav items
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(vertical: 8),
              children: [
                for (int i = 0; i < _sections.length; i++)
                  _SidebarItem(
                    icon: _sections[i].icon,
                    selectedIcon: _sections[i].selectedIcon,
                    label: _sections[i].label,
                    selected: i == _selectedIndex,
                    onTap: () => setState(() => _selectedIndex = i),
                  ),
              ],
            ),
          ),
          // Footer
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border(
                top: BorderSide(color: BcTheme.border),
              ),
            ),
            child: Text(
              'bc_ui_flutter v0.1.0',
              style: TextStyle(
                fontSize: 11,
                color: BcTheme.mutedForeground,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SidebarItem extends StatelessWidget {
  final IconData icon;
  final IconData selectedIcon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _SidebarItem({
    required this.icon,
    required this.selectedIcon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected ? BcTheme.muted : Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          child: Row(
            children: [
              Icon(
                selected ? selectedIcon : icon,
                size: 20,
                color: selected ? BcTheme.primary : BcTheme.mutedForeground,
              ),
              const SizedBox(width: 12),
              Text(
                label,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
                  color: selected ? BcTheme.primary : BcTheme.foreground,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
