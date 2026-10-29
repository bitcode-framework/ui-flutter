# BitCode UI — Flutter

[![Flutter](https://img.shields.io/badge/Flutter-3.27%2B-02569B?logo=flutter)](https://flutter.dev)
[![Dart](https://img.shields.io/badge/Dart-3.12%2B-0175C2?logo=dart)](https://dart.dev)
[![Tests](https://img.shields.io/badge/tests-2144%20passing-brightgreen)](https://github.com/bitcode-framework/ui-flutter)
[![License](https://img.shields.io/badge/license-MIT-blue)](LICENSE)

**Live demo → https://bitcode-framework.github.io/ui-flutter/**

The Tier C Flutter adapter for [BitCode UI](https://github.com/bitcode-framework/ui).
It provides contract-driven Dart widgets plus a schema renderer that consumes the
same `UiSchema` documents as the React, Vue, and React Native adapters — so one
JSON definition drives every platform.

---

## What this is

BitCode is a modular low-code ERP platform where **JSON is the source code**.
A UI document describes forms, lists, grids, and sections; each adapter renders
it natively. This package is the Flutter side of that contract (ADR-011).

```
UiSchema (JSON)
   ├── @bitcode/ui          → React / Vue / React Native  (Mitosis)
   └── bc_ui_flutter        → Flutter (this package)
```

Same schema, same props, same behaviour — only the implementation language
differs. A `BcDateField` takes a JSON date string on web and a `DateTime` in
Dart; this adapter reconciles the two automatically (see *JSON value coercion*).

## Live demo

https://bitcode-framework.github.io/ui-flutter/

17 sections, 100+ widgets, running as a real Flutter web build. Each section is
also covered by a widget test that fails on a render crash or a layout overflow.

## Quick start

```yaml
# pubspec.yaml
dependencies:
  bc_ui_flutter:
    git:
      url: https://github.com/bitcode-framework/ui-flutter.git
```

```dart
import 'package:flutter/material.dart';
import 'package:bc_ui_flutter/bc_ui_flutter.dart';

void main() => runApp(BcApp(home: MyScreen()));

class MyScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BcRenderer(
        props: BcRendererProps(
          schema: const UiSchema(
            type: UiSchemaKind.form,
            fields: [
              FieldNode(name: 'email', label: 'Email', type: FieldType.email),
              FieldNode(name: 'active', label: 'Active', type: FieldType.toggle),
            ],
          ),
          values: const {'active': true},
          onSubmit: (values) => debugPrint('submit: $values'),
        ),
      ),
    );
  }
}
```

`BcApp` applies the platform theme (Material on Android/Windows/Linux/Web,
Cupertino on iOS/macOS). Use `MaterialApp` directly if you manage your own theme.

## Schema kinds

`BcRenderer` walks a `UiSchema` tree and dispatches on `type`:

| Kind | Behaviour |
|---|---|
| `form` | `BcForm` with fields, actions, and reactions |
| `detail` | Same as `form`, rendered disabled with submit hidden |
| `list` | Async load via `loadDataSource`, rendered as `BcDataTable` |
| `section` | Title/description + children in a `Column` |
| `grid` | Title/description + children in content-sized columns |
| `custom` | Delegates to the `customBuilder` callback |

Nested `section`/`grid` nodes propagate `values`, `disabled`, and every callback
to child renderers. Each nested form owns an independent `ReactiveStore`.

## Core APIs

| Area | Entry points |
|---|---|
| Rendering | `BcRenderer`, `BcRendererProps`, `buildField` |
| Schema | `UiSchema`, `UiSchemaKind`, `FieldNode`, `FieldType`, `ColumnDef`, `UiAction` |
| Reactivity | `ReactiveStore`, `ReactiveStoreOptions`, `Reaction`, `FieldMeta` |
| Data sources | `loadDataSource` (null / local / fetcher / url / model) |
| Theming | `BcTheme`, `BcApp`, `BcSetup` |
| Expressions | `src/expressions` — portable AST mirror of the TS package |
| Actions | `src/actions` — action runtime mirror of the TS package |
| Block renderer | `src/block_renderer` — contract mirror + ready catalog (ADR-017) |

## Design notes

### JSON value coercion

`ReactiveStore.get()` returns `dynamic`, and renderer values normally originate
from JSON documents rather than Dart natives. `buildField` therefore **coerces,
never hard-casts**. `coerceString`, `coerceNum`, `coerceDateTime`, and
`coerceBool` accept the native type as well as the JSON shape — ISO 8601 date
strings, numeric strings, epoch millis, `1`/`0`, `'true'`/`'false'`. Anything
unconvertible degrades to `null` instead of throwing, and the store value is
never mutated.

### Grid layout

`grid` sizes each cell from its content (`Row` + `Expanded`, top-aligned), so a
`detail` block with many fields grows its row instead of overflowing a fixed
cell height.

### Height-adaptive widgets

`BcPivot`, `BcViewerDocument`, `BcViewerInstagram`, and `BcViewerTiktok` branch
on incoming constraints via `LayoutBuilder`. They fill the box when the host
provides a bounded height, and fall back to the web adapter's `600px` default
viewport when it does not — for example inside a `SingleChildScrollView`. This
mirrors the web contracts (`BcPivot` is `overflow-auto` with natural height; the
viewers default to `height: '600px'`) and keeps them safe in any parent.

### Responsive by construction

Every composite widget tolerates narrow hosts. Toolbars scroll horizontally
below their natural width, calendar headers reflow to two rows, builder panes
keep a minimum canvas width, and field cards ellipsize rather than clip. The
demo is audited at 1400 / 1024 / 800 / 600 px with zero overflows.

## Component inventory

~120 widgets across layout, display, forms, views, media, and admin builders.
Highlights:

- **Layout** — `BcBox`, `BcXStack`, `BcYStack`, `BcStack`, `BcFlex`, `BcCenter`, `BcSplitter`
- **Forms** — `BcInput`, `BcNumberField`, `BcDateField`, `BcTimeField`, `BcSelect`, `BcMultiSelect`, `BcCheckbox`, `BcToggle`, `BcSlider`, `BcRangeSlider`, `BcCombobox`, `BcTagsInput`, `BcForm`, `BcFieldMorph`, `BcFieldDuration`
- **Data** — `BcDataTable`, `BcList`, `BcTreeView`, `BcTreeSelect`, `BcPivot`, `BcDashboard`, `BcStatistic`, `BcDescriptions`, `BcSteps`
- **Views** — `BcKanbanBoard`, `BcKanbanView`, `BcCalendarView`, `BcViewGantt`, `BcViewMap`, `BcViewReport`, `BcViewActivity`, `BcOrgChart`, `BcVirtualScroller`
- **Media** — `BcImage`, `BcViewerImage`, `BcViewerVideo`, `BcViewerAudio`, `BcViewerPdf`, `BcViewerDocument`, `BcViewerYoutube`, `BcViewerInstagram`, `BcViewerTiktok`, `BcGalleria`, `BcLightbox`
- **Builders** — `BcFormBuilder`, `BcSchemaBuilder`, `BcWorkflowBuilder` (drag-drop canvas + property panel + JSON preview)
- **Feedback / overlays** — `BcAlert`, `BcNotification`, `BcDialog`, `BcDrawer`, `BcPopover`, `BcContextMenu`, `BcTour`, `BcLoadingOverlay`

See [`CONTRACT_INVENTORY.md`](CONTRACT_INVENTORY.md) for the mapping between
`@bitcode/ui` contracts and their Dart implementations.

## Development

```bash
cd packages/ui-flutter

flutter pub get
flutter test                      # 2144 tests
flutter analyze                   # 0 errors
dart run build_runner build --delete-conflicting-outputs   # regenerate freezed/json
```

Scoped runs:

```bash
flutter test test/renderer        # renderer + field builder
flutter test test/unbounded_height_test.dart
cd example && flutter test        # demo section tests
```

### Running the demo

```bash
cd packages/ui-flutter/example
flutter run -d chrome --web-port=5050
```

## Validation status

- **2144 tests passing**, 0 failing.
- `flutter analyze`: **0 errors**.
- Demo: 24 section tests green; overflow audit clean at 1400 / 1024 / 800 / 600 px.
- Chart parity (ADR-015): 111 tests — 48 golden fixtures, 34 helpers, 29 widget contracts.
- Renderer scope: 294 tests, including `bc_field_coercion_test.dart` (18),
  `bc_grid_layout_test.dart` (7), and `unbounded_height_test.dart` (13).

## Repository layout

```
ui-flutter/
├── lib/
│   ├── bc_ui_flutter.dart        barrel export
│   └── src/
│       ├── components/           ~120 widgets
│       ├── renderer/             BcRenderer, field builder, data source loader
│       ├── schema/               UiSchema types (freezed) + field resolver
│       ├── core/                 reactive store, hooks, animation, adapt, chart
│       ├── expressions/          portable expression AST
│       ├── actions/              action runtime
│       ├── block_renderer/       ADR-017 contract + ready catalog
│       └── theme/                BcTheme tokens
├── example/                      demo app (published to GitHub Pages)
├── test/                         library tests
└── doc/
```

## Related

- [`bitcode-framework/ui`](https://github.com/bitcode-framework/ui) — Mitosis component source + React demo
- [`bitcode-framework/ui-schema`](https://github.com/bitcode-framework/ui-schema) — shared schema contracts

## License

MIT — see [LICENSE](LICENSE).
