/// Ready Block Catalog - Flutter runtime registration (ADR-017 §5).
///
/// Dart mirror of @bitcode/ui ready-catalog.ts. Wires the Ready catalog
/// entries' required components into the Flutter [BlockComponentRegistry]
/// so the renderer engine can resolve them at render time.
///
/// Usage:
///   ```dart
///   import 'package:bc_ui_flutter/bc_ui_flutter.dart';
///
///   registerReadyCatalog(registry);
///   ```
library bitcode.ui_schema.block_renderer.ready_catalog;

import 'block_node.dart' show ComponentMetadata;
import 'registry.dart' show BlockComponentRegistry;

/// A Ready catalog entry definition (minimal metadata for registration).
class ReadyCatalogEntry {
  const ReadyCatalogEntry({
    required this.id,
    required this.category,
    required this.capabilities,
    required this.requiredComponents,
  });

  final String id;
  final String category;
  final List<String> capabilities;
  final List<String> requiredComponents;
}

/// The production-Ready Block Catalog entries (ADR-017/018).
///
/// Mirrors the TS READY_CATALOG_ENTRIES in ready-promotions.ts.
/// content.plain-text: static, i18n, a11y. Components: BcLabel, BcBox.
/// content.faq: static, data-source, a11y, i18n. Components: BcAccordion, BcDisclosure.
const readyCatalogEntries = <ReadyCatalogEntry>[
  ReadyCatalogEntry(
    id: 'content.plain-text',
    category: 'content',
    capabilities: ['static', 'i18n', 'a11y'],
    requiredComponents: ['BcLabel', 'BcBox'],
  ),
  ReadyCatalogEntry(
    id: 'content.faq',
    category: 'content',
    capabilities: ['static', 'data-source', 'a11y', 'i18n'],
    requiredComponents: ['BcAccordion', 'BcDisclosure'],
  ),
];

/// Number of Ready entries.
int get readyCount => readyCatalogEntries.length;

/// Register all Ready catalog entries' required components into [registry].
/// Each component key is registered with metadata. Skips already-registered
/// keys (idempotent).
///
/// Returns the list of entry ids that were processed.
List<String> registerReadyCatalog(BlockComponentRegistry registry) {
  final registered = <String>[];
  for (final entry in readyCatalogEntries) {
    for (final key in entry.requiredComponents) {
      if (registry.has(key)) continue;
      registry.register(ComponentMetadata(
        componentKey: key,
        category: entry.category,
        capabilities: entry.capabilities,
        supportedPlatforms: const ['web', 'flutter'],
      ));
    }
    registered.add(entry.id);
  }
  return registered;
}

/// Check whether all required components for a Ready entry are registered.
bool isReadyEntryReady(String entryId, BlockComponentRegistry registry) {
  final entry = readyCatalogEntries.where((e) => e.id == entryId).firstOrNull;
  if (entry == null) return false;
  return entry.requiredComponents.every((key) => registry.has(key));
}

/// Get all Ready catalog entry ids.
List<String> getReadyEntryIds() =>
    readyCatalogEntries.map((e) => e.id).toList(growable: false);
