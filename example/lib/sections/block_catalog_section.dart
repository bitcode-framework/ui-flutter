// ===========================================================================
// block_catalog_section.dart — Block Catalog Preview Demo (Flutter)
//
// Renders a Sales Order detail page using the production Flutter BcRenderer
// (ADR-005) with nested section + grid + detail + list UiSchema kinds.
// This is the lower-level renderer that the P4 BcBlockRenderer will delegate
// to (ADR-017 S3).
//
// HONEST LABEL: Uses production Flutter BcRenderer directly. Not the final
// Block Catalog runtime (BcBlockRenderer is P4, not yet implemented).
// Full parity pending P4.
//
// Platform-aware (ADR-011): Uses flutter_platform_widgets (Platform.*) for
// iOS Cupertino / Android Material adaptation on interactive surfaces.
// ===========================================================================
library block_catalog_section;

import 'package:flutter/material.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:bc_ui_flutter/bc_ui_flutter.dart';

import '../demo_widgets.dart';

class BlockCatalogSection extends StatelessWidget {
  const BlockCatalogSection({super.key});

  @override
  Widget build(BuildContext context) {
    return BcYStack(
      gap: 24,
      children: [
        const SectionHeader(
          title: 'Block Catalog (Preview)',
          subtitle: 'Nested layout via production Flutter BcRenderer. '
              'Full parity pending P4 BcBlockRenderer.',
        ),

        // Preview banner
        _PreviewBanner(
          text: 'Uses production Flutter BcRenderer (ADR-005). '
              'This is the lower-level renderer P4 BcBlockRenderer will delegate to.',
        ),

        DemoCard(
          title: 'Sales Order Detail (BcRenderer nested)',
          description: 'section → grid(2) → detail, detail / section → list',
          child: BcRenderer(
            props: BcRendererProps(
              schema: _salesOrderSchema(),
              values: _salesOrderValues(),
              onChange: (_) {},
              onSubmit: (_) {},
              onAction: (_, __) {},
            ),
          ),
        ),

        DemoCard(
          title: 'Customer Summary Block',
          description: 'Simple detail block via BcRenderer',
          child: BcRenderer(
            props: BcRendererProps(
              schema: _customerSummarySchema(),
              values: _customerValues(),
              onChange: (_) {},
              onSubmit: (_) {},
              onAction: (_, __) {},
            ),
          ),
        ),

        // Platform-aware action button demonstrating ADR-011 adapt
        DemoCard(
          title: 'Platform-Aware Action Button',
          description: 'iOS → Cupertino, Android → Material (ADR-011)',
          child: Center(
            child: PlatformElevatedButton(
              onPressed: () => _showPlatformToast(context),
              child: PlatformText('Create Contact (Platform-Aware)'),
            ),
          ),
        ),
      ],
    );
  }

  void _showPlatformToast(BuildContext context) {
    showPlatformDialog(
      context: context,
      builder: (context) => PlatformAlertDialog(
        title: PlatformText('Action Triggered'),
        content: PlatformText('Demo action executed via platform-aware button.'),
        actions: [
          PlatformDialogAction(
            onPressed: () => Navigator.pop(context),
            child: PlatformText('OK'),
          ),
        ],
      ),
    );
  }

  // -------------------------------------------------------------------------
  // Sales Order nested schema: section → grid(2) → [detail, detail], list
  // -------------------------------------------------------------------------

  UiSchema _salesOrderSchema() {
    return UiSchema(
      type: UiSchemaKind.section,
      name: 'sales-order-SO-2026-0481',
      title: 'Sales Order SO-2026-0481',
      description: 'Status: confirmed | Date: 2026-06-18 | Terms: Net 30',
      sections: [
        UiSchema(
          type: UiSchemaKind.grid,
          name: 'order-header',
          columns: 2,
          sections: [
            UiSchema(
              type: UiSchemaKind.detail,
              name: 'customer-info',
              title: 'Customer',
              fields: [
                FieldNode(name: 'customerName', label: 'Name', type: FieldType.input, disabled: true),
                FieldNode(name: 'customerEmail', label: 'Email', type: FieldType.email, disabled: true),
                FieldNode(name: 'company', label: 'Company', type: FieldType.input, disabled: true),
              ],
            ),
            UiSchema(
              type: UiSchemaKind.detail,
              name: 'order-summary',
              title: 'Order Summary',
              fields: [
                FieldNode(name: 'orderNo', label: 'Order No.', type: FieldType.input, disabled: true),
                FieldNode(name: 'orderDate', label: 'Date', type: FieldType.date, disabled: true),
                FieldNode(name: 'paymentTerms', label: 'Terms', type: FieldType.input, disabled: true),
                FieldNode(name: 'status', label: 'Status', type: FieldType.input, disabled: true),
              ],
            ),
          ],
        ),
        UiSchema(
          type: UiSchemaKind.list,
          name: 'line-items',
          title: 'Line Items',
          pageSize: 10,
          columnsDef: [
            ColumnDef(key: 'productSku', label: 'SKU', sortable: true),
            ColumnDef(key: 'productName', label: 'Product', sortable: true),
            ColumnDef(key: 'qty', label: 'Qty', align: ColumnAlign.right, sortable: true),
            ColumnDef(key: 'unitPrice', label: 'Price', align: ColumnAlign.right),
          ],
          data: [
            {'productSku': 'WGT-100', 'productName': 'Precision Widget', 'qty': 200, 'unitPrice': '\$24.50'},
            {'productSku': 'CBL-050', 'productName': 'Braided Cable 2m', 'qty': 50, 'unitPrice': '\$8.75'},
          ],
        ),
      ],
    );
  }

  Map<String, dynamic> _salesOrderValues() {
    return {
      'customerName': 'Sarah Chen',
      'customerEmail': 'sarah.chen@northwind.io',
      'company': 'Northwind Traders',
      'orderNo': 'SO-2026-0481',
      'orderDate': '2026-06-18',
      'paymentTerms': 'Net 30',
      'status': 'confirmed',
    };
  }

  // -------------------------------------------------------------------------
  // Customer summary: simple detail block
  // -------------------------------------------------------------------------

  UiSchema _customerSummarySchema() {
    return UiSchema(
      type: UiSchemaKind.detail,
      name: 'customer-summary',
      title: 'Customer Summary',
      description: 'Read-only CRM contact detail',
      fields: [
        FieldNode(name: 'name', label: 'Name', type: FieldType.input, disabled: true),
        FieldNode(name: 'email', label: 'Email', type: FieldType.email, disabled: true),
        FieldNode(name: 'phone', label: 'Phone', type: FieldType.tel, disabled: true),
        FieldNode(name: 'company', label: 'Company', type: FieldType.input, disabled: true),
        FieldNode(name: 'tier', label: 'Tier', type: FieldType.input, disabled: true),
        FieldNode(name: 'status', label: 'Status', type: FieldType.input, disabled: true),
      ],
    );
  }

  Map<String, dynamic> _customerValues() {
    return {
      'name': 'Marcus Okafor',
      'email': 'marcus@globex.com',
      'phone': '+44 20 7946 0331',
      'company': 'Globex Corporation',
      'tier': 'partner',
      'status': 'active',
    };
  }
}

/// A small preview banner widget to label demo content honestly.
class _PreviewBanner extends StatelessWidget {
  final String text;
  const _PreviewBanner({required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: BcTheme.primary.withValues(alpha: 0.08),
        border: Border.all(color: BcTheme.primary.withValues(alpha: 0.3)),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.info_outline,
            size: 16,
            color: BcTheme.primary,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: BcTheme.primary,
                  ),
            ),
          ),
        ],
      ),
    );
  }
}
