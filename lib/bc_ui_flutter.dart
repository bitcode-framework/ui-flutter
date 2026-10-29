/// BitCode UI Flutter adapter.
///
/// Contract-driven Dart widgets ported from @bitcode/ui (ADR-011).
/// Consumer API is identical across React/Vue/RN/Flutter — only the
/// implementation language differs.
///
/// Simple usage (platform-aware, zero config):
/// ```dart
/// void main() => runApp(BcApp(home: MyScreen()));
/// ```
///
/// Raw token access:
/// ```dart
/// Container(color: BcTheme.primary.withValues(alpha: 0.5));
/// ```

library bc_ui_flutter;

// Core types
export 'src/core/types.dart';

// Chart option contract (ADR-015 — Dart port of the TS chart-option factory).
// Pure functions/enums, no widget deps — testable in isolation.
export 'src/core/chart/chart_contract.dart';

// Reactive engine
export 'src/core/reactive_store.dart';
export 'src/core/reactive_store_notifier.dart';

// AppProvider consumption surface (ADR-013 Phase 1) — cross-tier parity with
// @bitcode/ui core/providers + core/hooks/use-app-context.
export 'src/core/app_config_snapshot.dart';
export 'src/core/app_config_store.dart';
export 'src/core/bc_app_config.dart';
export 'src/core/bc_i18n.dart';

// Hooks P1 parity (ADR-013 Phase 5b) — Dart ports of the TS P1 headless hooks
// (packages/ui/src/core/hooks/*). Headless utility classes / factories.
export 'src/core/hooks/hooks.dart';

// Animation runtime parity (ADR-013 Phase 5b) — Dart port of the TS
// `core/animation` runtime (resolveAnimation, BcAnimationKind, reduced-motion).
export 'src/core/animation/animation.dart';

// Adapt runtime parity (ADR-013 Phase 5b) — Dart port of the TS `core/adapt`
// runtime (resolveAdapt, BcAdaptResolver, BcAdaptContext). Shared breakpoint
// queries (BC_BREAKPOINTS parity) live in bc_breakpoints.dart.
export 'src/core/adapt/adapt.dart';
export 'src/core/bc_breakpoints.dart';

// UiSchema types (ADR-011 Phase 5b.1)
// BcKey and DataSource are defined in core/types.dart and core/reactive_store.dart;
// hide them here to avoid ambiguous_export conflicts.
export 'src/schema/ui_schema_types.dart' hide BcKey, DataSource;
export 'src/schema/ui_schema_events.dart';
export 'src/schema/ui_schema.dart';
export 'src/schema/field_resolver.dart';

// Theme
export 'src/theme/bc_theme.dart';

// App
export 'src/bc_app.dart';

// M1 layout primitives
export 'src/components/bc_slot.dart';
export 'src/components/bc_stack.dart';
export 'src/components/bc_xstack.dart';
export 'src/components/bc_ystack.dart';
export 'src/components/bc_box.dart';
export 'src/components/bc_visually_hidden.dart';
export 'src/components/bc_backdrop.dart';
export 'src/components/bc_loading_overlay.dart';

// M1 display widgets
export 'src/components/bc_descriptions.dart';
export 'src/components/bc_steps.dart';
export 'src/components/bc_statistic.dart';
export 'src/components/bc_empty.dart';
export 'src/components/bc_result.dart';

// M1 advanced input widgets
export 'src/components/bc_otp.dart';
export 'src/components/bc_transfer.dart';
export 'src/components/bc_cascader.dart';
export 'src/components/bc_tree_select.dart';

// M1 overlays
export 'src/components/bc_toast_queue.dart';

// M2 forms — text inputs
export 'src/components/bc_richtext.dart';
export 'src/components/bc_code.dart';
export 'src/components/bc_json.dart';
export 'src/components/bc_markdown.dart';

// M2 forms — pickers and specialized inputs
export 'src/components/bc_color_picker.dart';
export 'src/components/bc_rate.dart';
export 'src/components/bc_slider.dart';
export 'src/components/bc_range_slider.dart';
export 'src/components/bc_tags_input.dart';
export 'src/components/bc_toggle_group.dart';
export 'src/components/bc_mentions.dart';
export 'src/components/bc_knob.dart';

// P0 widgets — adaptive (FPW)
export 'src/components/bc_input.dart';
export 'src/components/bc_select.dart';
export 'src/components/bc_checkbox.dart';
export 'src/components/bc_toggle.dart';
export 'src/components/bc_segmented.dart';
export 'src/components/bc_number_field.dart';
export 'src/components/bc_date_field.dart';
export 'src/components/bc_time_field.dart';
export 'src/components/bc_dialog.dart';
export 'src/components/bc_alert_dialog.dart';
export 'src/components/bc_portal.dart';
export 'src/components/bc_tooltip.dart';
export 'src/components/bc_dropdown.dart';

// P0 widgets — Material-only
export 'src/components/bc_combobox.dart';
export 'src/components/bc_multi_select.dart';
export 'src/components/bc_form.dart';
export 'src/components/bc_drawer.dart';
export 'src/components/bc_popover.dart';
export 'src/components/bc_context_menu.dart';
export 'src/components/bc_command.dart';
export 'src/components/bc_tabs.dart';
export 'src/components/bc_accordion.dart';
export 'src/components/bc_disclosure.dart';
export 'src/components/bc_splitter.dart';
export 'src/components/bc_data_table.dart';
export 'src/components/bc_list.dart';
export 'src/components/bc_field_duration.dart';
export 'src/components/bc_field_table_select.dart';
export 'src/components/bc_field_morph.dart';
export 'src/components/bc_field_dyn_link.dart';
export 'src/components/bc_lookup_modal.dart';
export 'src/components/bc_view_gantt.dart';

// M3 navigation
export 'src/components/bc_breadcrumb.dart';
export 'src/components/bc_pagination.dart';
export 'src/components/bc_menubar.dart';
export 'src/components/bc_megamenu.dart';
export 'src/components/bc_navigation_menu.dart';
export 'src/components/bc_affix.dart';
export 'src/components/bc_anchor.dart';
export 'src/components/bc_backtop.dart';
export 'src/components/bc_dock.dart';
export 'src/components/bc_panel_menu.dart';
export 'src/components/bc_slide_menu.dart';

// M4 overlays — modal
export 'src/components/bc_prompt.dart';
export 'src/components/bc_wizard.dart';

// M4 overlays — reveal
export 'src/components/bc_hover_card.dart';
export 'src/components/bc_actionsheet.dart';
export 'src/components/bc_speed_dial.dart';

// M4 feedback
export 'src/components/bc_notification.dart';
export 'src/components/bc_tour.dart';
export 'src/components/bc_inplace.dart';

// M4 layout utility
export 'src/components/bc_meter_group.dart';
export 'src/components/bc_aspect_ratio.dart';
export 'src/components/bc_flex.dart';

// M2 forms — upload and capture
export 'src/components/bc_file.dart';
export 'src/components/bc_signature.dart';
export 'src/components/bc_barcode.dart';
export 'src/components/bc_geo.dart';
export 'src/components/bc_drop_zone.dart';
export 'src/components/bc_color_area.dart';
export 'src/components/bc_color_slider.dart';

// M5 data display
export 'src/components/bc_carousel.dart';
export 'src/components/bc_orgchart.dart';
export 'src/components/bc_taggroup.dart';
export 'src/components/bc_sparkline.dart';
export 'src/components/bc_chart.dart';
export 'src/components/bc_kanban_board.dart';
export 'src/components/bc_view_map.dart';
export 'src/components/bc_view_report.dart';
export 'src/components/bc_view_editor.dart';
export 'src/components/bc_view_activity.dart';
export 'src/components/bc_virtual_scroller.dart';
export 'src/components/bc_tiered_menu.dart';

// M6 media viewers and players
export 'src/components/bc_viewer_pdf.dart';
export 'src/components/bc_viewer_image.dart';
export 'src/components/bc_viewer_document.dart';
export 'src/components/bc_viewer_video.dart';
export 'src/components/bc_viewer_audio.dart';
export 'src/components/bc_viewer_youtube.dart';
export 'src/components/bc_viewer_instagram.dart';
export 'src/components/bc_viewer_tiktok.dart';

// M6 social widgets
export 'src/components/bc_chatter.dart';
export 'src/components/bc_activity.dart';
export 'src/components/bc_notification_center.dart';
export 'src/components/bc_form_builder.dart';
export 'src/components/bc_schema_builder.dart';
export 'src/components/bc_workflow_builder.dart';
export 'src/components/bc_timeline_social.dart';
export 'src/components/bc_galleria.dart';
export 'src/components/bc_image.dart';

// M6 print widgets
export 'src/components/bc_export.dart';
export 'src/components/bc_print.dart';
export 'src/components/bc_report_link.dart';

// M8 stub-completion (ADR-016 Phase 4) — Klaster E+D+F ports.
// Pure-tier Flutter widgets mirroring the TS contracts.
export 'src/components/bc_alert.dart';
export 'src/components/bc_chip.dart';
export 'src/components/bc_print_area.dart';
export 'src/components/bc_print_preview.dart';
export 'src/components/bc_text_field.dart';
// M8 stub-completion (ADR-016 Phase 4) — Klaster B social ports.
export 'src/components/bc_like.dart';
export 'src/components/bc_follow.dart';
export 'src/components/bc_comment.dart';
export 'src/components/bc_share.dart';

// M8 stub-completion — Klaster G Adapt POC (10 native components).
// ADR-006 platform-idiomatic components. 5 typedefs alias existing adaptive
// widgets; 5 full FPW widgets provide native overlay/dialog idioms.
export 'src/components/bc_native_button.dart';
export 'src/components/bc_native_input.dart';
export 'src/components/bc_native_select.dart';
export 'src/components/bc_native_switch.dart';
export 'src/components/bc_native_slider.dart';
export 'src/components/bc_native_picker.dart';
export 'src/components/bc_native_alert.dart';
export 'src/components/bc_native_actionsheet.dart';
export 'src/components/bc_native_modal.dart';
export 'src/components/bc_native_toast.dart';

// M8 stub-completion — Klaster C media (3 Adapt components).
// ADR-006 platform-idiomatic media components. Web uses native browser APIs
// (getUserMedia, lazy Leaflet); Flutter is dependency-free (caller wires the
// platform plugin via a builder prop).
export 'src/components/bc_lightbox.dart';
export 'src/components/bc_map.dart';
export 'src/components/bc_webcam.dart';

// M8 stub-completion — Klaster A views (6 components).
// 2 Pure (BcDetailView, BcDashboard) + 4 Adapt (BcGridView, BcTreeView,
// BcKanbanView, BcCalendarView). ERP-critical view components.
export 'src/components/bc_detail_view.dart';
export 'src/components/bc_dashboard.dart';
export 'src/components/bc_grid_view.dart';
export 'src/components/bc_tree_view.dart';
export 'src/components/bc_kanban_view.dart';
export 'src/components/bc_calendar_view.dart';
export 'src/components/bc_pivot.dart';

// M7 misc widgets
export 'src/components/bc_watermark.dart';
export 'src/components/bc_qrcode.dart';
export 'src/components/bc_kbd.dart';
export 'src/components/bc_center.dart';
export 'src/components/bc_circle.dart';
export 'src/components/bc_square.dart';
export 'src/components/bc_color_swatch.dart';
export 'src/components/bc_color_wheel.dart';
export 'src/components/bc_search.dart';
export 'src/components/bc_sidebar.dart';
export 'src/components/bc_favorites.dart';

// Block Catalog parity (ADR-017) - canonical Flutter widgets for Ready gates.
export 'src/components/bc_avatar.dart';
export 'src/components/bc_badge.dart';
export 'src/components/bc_progress.dart';
export 'src/components/bc_kpi.dart';

// Renderer
export 'src/renderer/bc_field_builder.dart';
export 'src/renderer/bc_data_source_loader.dart';
export 'src/renderer/bc_renderer.dart';
export 'src/spa_runtime.dart';

// Portable Expression AST (ADR-018 S5-S6) - Dart mirror of the TS package.
// Pure types + validator + scope + manifest. No widgets, no I/O.
export 'src/expressions/expressions.dart';

// Action runtime (ADR-018 S1-S4, S7-S9) - Dart mirror of the TS package.
export 'src/actions/actions.dart';

// Block Renderer (ADR-017 §3, Agent H) - Dart contract mirror.
// Types, registry interface, renderer contract only. The full Flutter
// BcBlockRenderer widget + Dart engine port is a dedicated follow-up.
export 'src/block_renderer/block_renderer.dart';

// Ready Block Catalog runtime registration (ADR-017 §5).
export 'src/block_renderer/ready_catalog.dart';
