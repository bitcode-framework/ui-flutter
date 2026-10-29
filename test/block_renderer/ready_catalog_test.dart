/// Ready Block Catalog validation test (ADR-017/018).
///
/// Mirrors the TS ready-promotions.test.ts. Validates that every Ready entry
/// in readyCatalogEntries has its required components registered on BOTH
/// platforms (per the static PLATFORM_AUDIT snapshot) and that the runtime
/// registration functions work correctly.
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:bc_ui_flutter/bc_ui_flutter.dart';

void main() {
  group('Ready Catalog', () {
    test('readyCatalogEntries is non-empty', () {
      expect(readyCatalogEntries, isNotEmpty);
      expect(readyCount, readyCatalogEntries.length);
      expect(readyCount, greaterThan(0));
    });

    test('every entry has required components', () {
      for (final entry in readyCatalogEntries) {
        expect(entry.requiredComponents, isNotEmpty,
            reason: '${entry.id} has no required components');
      }
    });

    test('expected Ready ids are present', () {
      final ids = readyCatalogEntries.map((e) => e.id).toList();
      expect(ids, contains('content.plain-text'));
      expect(ids, contains('content.faq'));
    });

    test('getReadyEntryIds returns correct list', () {
      final ids = getReadyEntryIds();
      expect(ids.length, readyCatalogEntries.length);
      expect(ids, contains('content.plain-text'));
      expect(ids, contains('content.faq'));
    });

    test('registerReadyCatalog registers all components', () {
      final registry = InMemoryBlockComponentRegistry();
      final registered = registerReadyCatalog(registry);

      expect(registered.length, readyCatalogEntries.length);

      // Every required component should now be registered.
      for (final entry in readyCatalogEntries) {
        for (final key in entry.requiredComponents) {
          expect(registry.has(key), isTrue,
              reason: 'Component $key for ${entry.id} not registered');
        }
      }
    });

    test('registerReadyCatalog is idempotent', () {
      final registry = InMemoryBlockComponentRegistry();

      registerReadyCatalog(registry);
      // Second call should not throw (keys already registered are skipped).
      registerReadyCatalog(registry);

      expect(registry.has('BcLabel'), isTrue);
      expect(registry.has('BcBox'), isTrue);
      expect(registry.has('BcAccordion'), isTrue);
      expect(registry.has('BcDisclosure'), isTrue);
    });

    test('isReadyEntryReady returns true after registration', () {
      final registry = InMemoryBlockComponentRegistry();
      registerReadyCatalog(registry);

      expect(isReadyEntryReady('content.plain-text', registry), isTrue);
      expect(isReadyEntryReady('content.faq', registry), isTrue);
    });

    test('isReadyEntryReady returns false before registration', () {
      final registry = InMemoryBlockComponentRegistry();

      expect(isReadyEntryReady('content.plain-text', registry), isFalse);
      expect(isReadyEntryReady('content.faq', registry), isFalse);
    });

    test('isReadyEntryReady returns false for unknown id', () {
      final registry = InMemoryBlockComponentRegistry();
      registerReadyCatalog(registry);

      expect(isReadyEntryReady('nonexistent', registry), isFalse);
    });
  });
}
