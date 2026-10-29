import 'package:flutter/material.dart';
import 'package:bc_ui_flutter/bc_ui_flutter.dart';
import '../demo_widgets.dart';

/// Navigation widgets: BcBreadcrumb, BcPagination, BcMenubar, BcAffix,
/// BcSearch, BcBackTop, BcDrawer.
class NavigationSection extends StatefulWidget {
  const NavigationSection({super.key});

  @override
  State<NavigationSection> createState() => _NavigationSectionState();
}

class _NavigationSectionState extends State<NavigationSection> {
  int _currentPage = 3;
  final ScrollController _scrollController = ScrollController();
  List<BcSearchResult> _searchResults = const [];
  String _searchQuery = '';
  int _drawerIndex = 0;

  void _onSearch(String query, _) {
    setState(() {
      _searchQuery = query;
      if (query.isEmpty) {
        _searchResults = const [];
        return;
      }
      final all = const [
        BcSearchResult(id: '1', label: 'Dashboard', category: 'Pages'),
        BcSearchResult(id: '2', label: 'Settings', category: 'Pages'),
        BcSearchResult(id: '3', label: 'Users', category: 'Admin'),
        BcSearchResult(id: '4', label: 'Reports', category: 'Analytics'),
        BcSearchResult(id: '5', label: 'Invoices', category: 'Finance'),
        BcSearchResult(id: '6', label: 'Inventory', category: 'Operations'),
      ];
      _searchResults = all
          .where((r) => r.label.toLowerCase().contains(query.toLowerCase()))
          .toList();
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BcYStack(
      gap: 24,
      children: [
        const SectionHeader(
          title: 'Navigation',
          subtitle: 'Breadcrumbs, pagination, menubar, affix, search, and back-to-top.',
        ),

        // -- BcBreadcrumb --
        DemoCard(
          title: 'BcBreadcrumb',
          description: 'Adaptive breadcrumb navigation trail with separators.',
          child: BcBreadcrumb(
            items: const [
              BcBreadcrumbItem(label: 'Home', path: '/'),
              BcBreadcrumbItem(label: 'Products', path: '/products'),
              BcBreadcrumbItem(
                  label: 'Electronics', path: '/products/electronics'),
              BcBreadcrumbItem(label: 'Laptops', active: true),
            ],
            onSelected: (path, _) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Navigate to: $path'),
                  duration: const Duration(milliseconds: 800),
                ),
              );
            },
          ),
        ),

        // -- BcPagination --
        DemoCard(
          title: 'BcPagination',
          description: 'Page navigation with sibling range and ellipsis.',
          child: BcYStack(
            gap: 12,
            children: [
              BcPagination(
                currentPage: _currentPage,
                totalPages: 10,
                showFirstLast: true,
                showPrevNext: true,
                onPageChange: (page, _) => setState(() => _currentPage = page),
              ),
              Text('Current page: $_currentPage',
                  style: Theme.of(context).textTheme.bodySmall),
            ],
          ),
        ),

        // -- BcMenubar --
        DemoCard(
          title: 'BcMenubar',
          description: 'Top menu bar with dropdown menus (File, Edit, View).',
          child: BcMenubar(
            menus: const [
              BcMenubarMenu(label: 'File', items: [
                BcMenubarItem(label: 'New', value: 'new'),
                BcMenubarItem(label: 'Open', value: 'open'),
                BcMenubarItem(label: '', value: '', separator: true),
                BcMenubarItem(label: 'Exit', value: 'exit'),
              ]),
              BcMenubarMenu(label: 'Edit', items: [
                BcMenubarItem(label: 'Undo', value: 'undo'),
                BcMenubarItem(label: 'Redo', value: 'redo'),
                BcMenubarItem(label: '', value: '', separator: true),
                BcMenubarItem(label: 'Cut', value: 'cut'),
                BcMenubarItem(label: 'Copy', value: 'copy'),
                BcMenubarItem(label: 'Paste', value: 'paste'),
              ]),
              BcMenubarMenu(label: 'View', items: [
                BcMenubarItem(label: 'Zoom In', value: 'zoom-in'),
                BcMenubarItem(label: 'Zoom Out', value: 'zoom-out'),
                BcMenubarItem(label: 'Reset', value: 'reset'),
              ]),
            ],
            onSelected: (value, _) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Menu: $value'),
                  duration: const Duration(milliseconds: 800),
                ),
              );
            },
          ),
        ),

        // -- BcSearch --
        DemoCard(
          title: 'BcSearch',
          description: 'Search input with icon and results dropdown.',
          child: BcYStack(
            gap: 8,
            children: [
              BcSearch(
                value: _searchQuery,
                results: _searchResults,
                placeholder: 'Search pages, settings...',
                emptyText: 'No matches found',
                onSearch: _onSearch,
                onSelect: (result, _) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Selected: ${result.label}'),
                      duration: const Duration(milliseconds: 800),
                    ),
                  );
                },
              ),
              if (_searchResults.isNotEmpty)
                Text('${_searchResults.length} result(s)',
                    style: Theme.of(context).textTheme.bodySmall),
            ],
          ),
        ),

        // -- BcAffix + BcBackTop (scrollable demo) --
        DemoCard(
          title: 'BcAffix & BcBackTop',
          description: 'Affix pins a header past a scroll threshold; BackTop shows a floating button after scrolling.',
          child: SizedBox(
            height: 240,
            child: Stack(
              children: [
                Scrollbar(
                  controller: _scrollController,
                  child: ListView.builder(
                    controller: _scrollController,
                    itemCount: 30,
                    itemBuilder: (context, index) {
                      if (index == 0) {
                        return BcAffix(
                          offsetTop: 0,
                          child: Container(
                            color: BcTheme.primary,
                            padding: const EdgeInsets.all(12),
                            child: const Text(
                              'Pinned Header (affix)',
                              style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
                            ),
                          ),
                        );
                      }
                      return Material(
                        color: Colors.transparent,
                        child: ListTile(
                          title: Text('Scroll item #$index'),
                        ),
                      );
                    },
                  ),
                ),
                BcBackTop(
                  visibilityHeight: 100,
                  scrollController: _scrollController,
                ),
              ],
            ),
          ),
        ),

        // -- BcMegaMenu --
        DemoCard(
          title: 'BcMegaMenu',
          description: 'Mega menu with multi-column link panels.',
          child: BcMegaMenu(
            items: const [
              BcMegaMenuItem(
                label: 'Products',
                columns: [
                  BcMegaMenuColumn(
                    title: 'ERP',
                    links: [
                      BcMegaMenuLink(label: 'Sales', value: 'sales'),
                      BcMegaMenuLink(label: 'Inventory', value: 'inventory'),
                      BcMegaMenuLink(label: 'Accounting', value: 'accounting'),
                    ],
                  ),
                  BcMegaMenuColumn(
                    title: 'CRM',
                    links: [
                      BcMegaMenuLink(label: 'Leads', value: 'leads'),
                      BcMegaMenuLink(label: 'Pipeline', value: 'pipeline'),
                    ],
                  ),
                ],
              ),
              BcMegaMenuItem(
                label: 'Resources',
                columns: [
                  BcMegaMenuColumn(
                    links: [
                      BcMegaMenuLink(label: 'Docs', value: 'docs'),
                      BcMegaMenuLink(label: 'API', value: 'api'),
                      BcMegaMenuLink(label: 'Blog', value: 'blog'),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),

        // -- BcNavigationMenu --
        DemoCard(
          title: 'BcNavigationMenu',
          description: 'Root items with content panels (horizontal tabs).',
          child: BcNavigationMenu(
            defaultValue: 'overview',
            items: [
              const BcNavigationMenuItem(value: 'overview', label: 'Overview'),
              BcNavigationMenuItem(
                value: 'details',
                label: 'Details',
                panel: const Padding(
                  padding: EdgeInsets.all(16),
                  child: Text('Details panel content.'),
                ),
              ),
              BcNavigationMenuItem(
                value: 'settings',
                label: 'Settings',
                panel: const Padding(
                  padding: EdgeInsets.all(16),
                  child: Text('Settings panel content.'),
                ),
              ),
            ],
          ),
        ),

        // -- BcPanelMenu --
        DemoCard(
          title: 'BcPanelMenu',
          description: 'Panel menu with expandable/collapsible groups.',
          child: BcPanelMenu(
            items: const [
              BcPanelMenuItem(key: 'dashboard', label: 'Dashboard', icon: Icons.dashboard_outlined),
              BcPanelMenuItem(
                key: 'projects',
                label: 'Projects',
                icon: Icons.folder_outlined,
                children: [
                  BcPanelMenuItem(key: 'active', label: 'Active'),
                  BcPanelMenuItem(key: 'archived', label: 'Archived'),
                ],
              ),
              BcPanelMenuItem(
                key: 'reports',
                label: 'Reports',
                icon: Icons.assessment_outlined,
                children: [
                  BcPanelMenuItem(key: 'sales', label: 'Sales Report'),
                  BcPanelMenuItem(key: 'inventory', label: 'Inventory Report'),
                ],
              ),
            ],
            defaultExpandedKeys: const ['projects'],
          ),
        ),

        // -- BcAnchor --
        DemoCard(
          title: 'BcAnchor',
          description: 'Anchor navigation that scrolls to target sections.',
          child: SizedBox(
            height: 200,
            child: Row(
              children: [
                SizedBox(
                  width: 140,
                  child: BcAnchor(
                    anchors: const [
                      BcAnchorLink(label: 'Section A', target: 'a'),
                      BcAnchorLink(label: 'Section B', target: 'b'),
                      BcAnchorLink(label: 'Section C', target: 'c'),
                    ],
                  ),
                ),
                const VerticalDivider(width: 1),
                const Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        Material(color: Colors.transparent, child: ListTile(key: ValueKey('a'), title: Text('Section A'))),
                        Material(color: Colors.transparent, child: ListTile(key: ValueKey('b'), title: Text('Section B'))),
                        Material(color: Colors.transparent, child: ListTile(key: ValueKey('c'), title: Text('Section C'))),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),

        // -- BcDock --
        DemoCard(
          title: 'BcDock',
          description: 'Dockable panel with dock/detach toggle.',
          child: BcDock(
            defaultDocked: true,
            child: BcBox(
              padding: 16,
              border: true,
              borderRadius: BcTheme.radius,
              backgroundColor: BcBoxColorToken.card,
              child: const Text('Dockable panel content. Tap the dock icon to toggle.'),
            ),
          ),
        ),

        // -- BcSlideMenu --
        DemoCard(
          title: 'BcSlideMenu',
          description: 'Slide-out drawer menu with scrim overlay.',
          child: BcSlideMenu(
            items: const [
              BcSlideMenuItem(key: 'home', label: 'Home', icon: Icons.home_outlined),
              BcSlideMenuItem(key: 'search', label: 'Search', icon: Icons.search_outlined),
              BcSlideMenuItem(key: 'notifications', label: 'Notifications', icon: Icons.notifications_outlined),
              BcSlideMenuItem(key: 'settings', label: 'Settings', icon: Icons.settings_outlined),
            ],
            child: Container(
              padding: const EdgeInsets.all(16),
              child: const Text('Main content. Tap the menu icon to open the slide-out drawer.'),
            ),
          ),
        ),

        // -- BcSidebar --
        DemoCard(
          title: 'BcSidebar',
          description: 'Collapsible navigation sidebar with menu items.',
          child: SizedBox(
            height: 240,
            child: BcSidebar(
              title: 'Navigation',
              items: const [
                BcSidebarItem(value: 'home', label: 'Home', icon: Icons.home_outlined),
                BcSidebarItem(value: 'projects', label: 'Projects', icon: Icons.folder_outlined),
                BcSidebarItem(value: 'reports', label: 'Reports', icon: Icons.assessment_outlined),
                BcSidebarItem(value: 'settings', label: 'Settings', icon: Icons.settings_outlined),
              ],
              selectedValue: 'home',
            ),
          ),
        ),
        const SizedBox(height: 24),

        // -- BcDrawer --
        DemoCard(
          title: 'BcDrawer',
          description: 'Material navigation drawer. Tap "Open Drawer" to slide it in.',
          child: SizedBox(
            height: 220,
            child: Scaffold(
              drawer: BcDrawer(
                header: Container(
                  height: 100,
                  color: BcTheme.primary,
                  padding: const EdgeInsets.all(16),
                  alignment: Alignment.bottomLeft,
                  child: Text(
                    'Menu',
                    style: TextStyle(
                      color: BcTheme.primaryForeground,
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                selectedIndex: _drawerIndex,
                onSelected: (i) {
                  setState(() => _drawerIndex = i);
                  Navigator.of(context).pop();
                },
                items: const [
                  BcDrawerItem(label: 'Inbox', icon: Icons.inbox_outlined),
                  BcDrawerItem(label: 'Starred', icon: Icons.star_outline),
                  BcDrawerItem(label: 'Sent', icon: Icons.send_outlined),
                  BcDrawerItem(label: 'Drafts', icon: Icons.drafts_outlined),
                  BcDrawerItem(label: 'Trash', icon: Icons.delete_outline),
                ],
              ),
              body: Center(
                child: ElevatedButton.icon(
                  onPressed: () => Scaffold.of(context).openDrawer(),
                  icon: const Icon(Icons.menu),
                  label: const Text('Open Drawer'),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}