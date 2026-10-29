# BcUiDemoApp — Flutter Demo

A single-page Flutter showcase app that renders **127+ `bc_ui_flutter` widget demos across 15 sections** in one navigable page. Useful for manual QA, screenshot verification, and contract validation across Material and Cupertino platforms. Mirrors the React demo-app (`packages/ui/demo-app`) group structure and covers every exported library component.

## What it demonstrates

- **15 demo sections** — Forms, Overlays, Data, Display, Navigation, Layout, Primitives, Feedback, Media, Charts, Social, Misc, Input Extended, Print, Views.
- **Material ↔ Cupertino adaptation** via [`flutter_platform_widgets`](https://pub.dev/packages/flutter_platform_widgets) (FPW), matching the adaptive behavior of the Stencil/React targets.
- **Theme tokens** consumed from `bc_theme.dart` (light + dark palettes generated from `theme.css` at build time).
- **Sidebar + section list navigation** (wide) / **bottom nav** (narrow) — every widget is reachable without scrolling through one giant list.

## Section inventory

| # | Section | Components |
|---|---------|-----------|
| 1 | Forms | BcInput, BcSelect, BcCheckbox, BcToggle, BcSegmented, BcSlider, BcNumberField, BcDateField, BcCombobox, BcMultiSelect, BcTagsInput, BcToggleGroup, BcFieldDuration, BcRangeSlider |
| 2 | Overlays | BcDialog, BcAlertDialog, BcTooltip, BcAccordion, BcDisclosure, BcTabs, BcSplitter, BcDropdown, BcPopover, BcCommand, BcHoverCard, BcActionsheet, BcWizard, BcPrompt, BcSpeedDial |
| 3 | Data | BcDataTable, BcDescriptions, BcStatistic |
| 4 | Display | BcStatistic, BcDescriptions, BcSteps, BcResult, BcEmpty |
| 5 | Navigation | BcBreadcrumb, BcPagination, BcMenubar, BcSearch, BcAffix, BcBackTop, BcMegaMenu, BcNavigationMenu, BcPanelMenu, BcAnchor, BcDock, BcSlideMenu, BcSidebar |
| 6 | Layout | BcYStack, BcXStack, BcBox, BcAspectRatio, BcCenter, BcVisuallyHidden, BcFlex, BcMeterGroup |
| 7 | Primitives | BcBox, BcCenter, BcCircle, BcSquare, BcKbd, BcSlot, BcVisuallyHidden, BcAspectRatio, BcBackdrop, BcLoadingOverlay |
| 8 | Feedback | BcToastQueue, BcNotification, BcResult, BcEmpty, BcTour, BcInplace |
| 9 | Media | BcImage, BcViewerImage, BcViewerVideo, BcViewerAudio, BcViewerPdf, BcViewerYoutube, BcGalleria |
| 10 | Charts | BcChart (bar/line/pie via ECharts ADR-015), BcSparkline |
| 11 | Social | BcChatter, BcActivity, BcTimelineSocial, BcRate, BcQRCode |
| 12 | Misc | BcWatermark, BcColorSwatch, BcColorWheel, BcFile, BcDropZone, BcSignature, BcBarcode, BcGeo, BcColorArea, BcColorSlider, BcFavorites |
| 13 | Input Extended | BcRichText, BcCode, BcJson, BcMarkdown, BcColorPicker, BcKnob, BcMentions, BcOtp, BcTransfer, BcCascader, BcTreeSelect, BcFieldMorph, BcFieldTableSelect, BcLookupModal |
| 14 | Print | BcExport, BcPrint, BcReportLink |
| 15 | Views | BcKanbanBoard, BcViewGantt, BcViewMap, BcViewReport, BcViewActivity, BcViewEditor, BcOrgChart, BcTieredMenu, BcVirtualScroller, BcCarousel |

## Run it

```bash
cd packages/ui-flutter/example

# Web (fastest for quick QA)
flutter run -d chrome

# Mobile/desktop (requires an attached device or emulator)
flutter run

# Production web build
flutter build web
```

> On machines with a bloated PATH, invoke Flutter through `../tool/run-flutter.ps1` instead of the bare `flutter` command.

## Verify

```bash
flutter analyze    # expect 0 issues
flutter test       # 12 tests: app smoke + per-section regression (renders without ErrorWidget)
flutter build web  # expect success
```

> **Charts note:** `BcChart` uses `flutter_echarts` (WebView-based). The test suite installs a fake `WebViewPlatform` (in `test/helpers/fake_webview_platform.dart`) via `setUpAll` so `BcChart` builds its tree in headless widget tests without a real WebView platform impl.

## Structure

```
example/
├── lib/
│   ├── main.dart                      # App entry, sidebar/bottom-nav shell
│   ├── demo_widgets.dart              # Shared DemoCard + SectionHeader
│   ├── demo_data.dart                 # Sample data (Person, etc.)
│   └── sections/                      # 15 demo section files
│       ├── forms_section.dart
│       ├── overlays_section.dart
│       ├── data_section.dart
│       ├── display_section.dart
│       ├── navigation_section.dart
│       ├── layout_section.dart
│       ├── primitives_section.dart
│       ├── feedback_section.dart
│       ├── media_section.dart
│       ├── charts_section.dart
│       ├── social_section.dart
│       ├── misc_section.dart
│       ├── input_extended_section.dart
│       ├── print_section.dart
│       └── views_section.dart
├── test/
│   ├── helpers/
│   │   └── fake_webview_platform.dart  # Fake WebView for BcChart in tests
│   └── widget_test.dart                # App smoke + per-section regression tests
└── web/                                # Flutter web bootstrap
```

The app is a path-dependency consumer of `bc_ui_flutter` — there is no published package to install. Edit widgets in `packages/ui-flutter/lib/` and the demo picks them up on the next hot reload.
