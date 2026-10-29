/// Core types ported from @bitcode/ui-schema (ADR-011 Section 6).
///
/// Enum-based event types (non-generic) for Dart type safety.
/// Mirrors the TS BcChangeMeta/BcEventSource/BcChangeHandler contract
/// without generic overhead.

library core_types;

import 'package:flutter/painting.dart' show Color, BoxFit;

// ADR-015: The chart contract (BcChartType, BcChartItem, BcChartSeries,
// BC_CHART_TYPES) now lives in core/chart/chart_types.dart to mirror the
// TypeScript chart-option contract (packages/ui/src/contracts/chart-option/).
// Re-exported here so existing importers of core/types.dart keep resolving
// unchanged (backward compatibility).
export 'chart/chart_types.dart';

/// Source of a user-initiated change.
///
/// Mirrors TS `BcEventSource` but trimmed to Dart-relevant values.
/// `touch` is folded into `pointer` (Flutter gesture system unifies them).
enum BcEventSource { pointer, keyboard, programmatic, external }

/// Reason metadata for change events.
///
/// Mirrors TS string literal reasons as a Dart enum for exhaustiveness
/// checking in switch statements (ADR-011 Section 6).
///
/// P0 reasons (indices 0-5) are preserved for backward compatibility.
/// P1 reasons (indices 6-17) extend the enum for the 8 P1 widgets.
/// TS kebab-case names map to Dart camelCase:
///   type-change -> typeChange
///   value-change -> valueChange
///   model-change -> modelChange
///   overlay-click -> overlayClick
enum BcChangeReason {
  input,
  reaction,
  programmatic,
  select,
  toggle,
  submit,
  escape,
  back,
  deselect,
  clear,
  typeChange,
  valueChange,
  modelChange,
  confirm,
  cancel,
  overlayClick,
  increment,
  decrement,
}

/// Metadata attached to every change event.
///
/// Non-generic (ADR-011 Section 6): consumer does not annotate
/// `BcChangeMeta<'input'>`. The enum already provides type safety.
class BcChangeMeta {
  final BcChangeReason reason;
  final BcEventSource source;
  final Object? nativeEvent;

  const BcChangeMeta({
    required this.reason,
    this.source = BcEventSource.programmatic,
    this.nativeEvent,
  });

  @override
  String toString() =>
      'BcChangeMeta(reason: $reason, source: $source, nativeEvent: $nativeEvent)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BcChangeMeta && reason == other.reason && source == other.source;

  @override
  int get hashCode => Object.hash(reason, source);
}

/// Callback signature for value changes.
///
/// Mirrors TS `BcChangeHandler<TValue, TReason>`.
/// Dart uses generics only for the value type; reason is enum-typed.
typedef BcChangeHandler<TValue> =
    void Function(TValue value, BcChangeMeta meta);

/// Key type for selection and collection identifiers.
typedef BcKey = Object; // String or int

/// Component size variants.
enum BcComponentSize { sm, md, lg }

/// Component visual variants.
enum BcComponentVariant {
  defaultVariant,
  primary,
  secondary,
  destructive,
  outline,
  ghost,
  link,
}

// ---------------------------------------------------------------------------
// P1 typed wrapper classes (ADR-011 Phase 5b.2)
//
// These mirror the TS contract interfaces for composite value types used by
// the 8 P1 widgets. They are plain immutable classes with const constructors
// and value-based equality so widget tests can compare instances directly.
// ---------------------------------------------------------------------------

/// Column descriptor for [BcFieldTableSelect].
///
/// Mirrors TS `BcFieldTableSelectColumn` ({ key, label }).
class BcFieldTableSelectColumn {
  final String key;
  final String label;

  const BcFieldTableSelectColumn({required this.key, required this.label});

  @override
  String toString() => 'BcFieldTableSelectColumn(key: $key, label: $label)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BcFieldTableSelectColumn &&
          key == other.key &&
          label == other.label;

  @override
  int get hashCode => Object.hash(key, label);
}

/// Single selectable option for a morph `select` widget kind.
///
/// Mirrors TS `BcFieldMorphOption` ({ label, value }).
class BcFieldMorphOption {
  final String label;
  final String value;

  const BcFieldMorphOption({required this.label, required this.value});

  @override
  String toString() => 'BcFieldMorphOption(label: $label, value: $value)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BcFieldMorphOption &&
          label == other.label &&
          value == other.value;

  @override
  int get hashCode => Object.hash(label, value);
}

/// Type descriptor for [BcFieldMorph].
///
/// Mirrors TS `BcFieldMorphType` ({ value, label, widget, options? }).
/// The [widget] field is a string tag ('text', 'number', 'date', 'select',
/// 'boolean') that the morph widget maps to a concrete Flutter input.
class BcFieldMorphType {
  final String value;
  final String label;
  final String widget;
  final List<BcFieldMorphOption>? options;

  const BcFieldMorphType({
    required this.value,
    required this.label,
    required this.widget,
    this.options,
  });

  @override
  String toString() =>
      'BcFieldMorphType(value: $value, label: $label, widget: $widget, options: $options)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BcFieldMorphType &&
          value == other.value &&
          label == other.label &&
          widget == other.widget &&
          _listEquals(options, other.options);

  @override
  int get hashCode => Object.hash(value, label, widget, options);

  static bool _listEquals(
    List<BcFieldMorphOption>? a,
    List<BcFieldMorphOption>? b,
  ) {
    if (identical(a, b)) return true;
    if (a == null || b == null) return a == b;
    if (a.length != b.length) return false;
    for (var i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }
}

/// Composite value for [BcFieldMorph].
///
/// Mirrors TS `BcFieldMorphValue` ({ type, value }).
/// The [value] is `Object?` because the concrete type varies by widget
/// kind (String for text, num for number, bool for boolean, etc.).
class BcFieldMorphValue {
  final String type;
  final Object? value;

  const BcFieldMorphValue({required this.type, this.value});

  @override
  String toString() => 'BcFieldMorphValue(type: $type, value: $value)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BcFieldMorphValue && type == other.type && value == other.value;

  @override
  int get hashCode => Object.hash(type, value);
}

/// Model descriptor for [BcFieldDynLink].
///
/// Mirrors TS `BcDynLinkModel` ({ model, label }).
class BcDynLinkModel {
  final String model;
  final String label;

  const BcDynLinkModel({required this.model, required this.label});

  @override
  String toString() => 'BcDynLinkModel(model: $model, label: $label)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BcDynLinkModel && model == other.model && label == other.label;

  @override
  int get hashCode => Object.hash(model, label);
}

/// Composite value for [BcFieldDynLink].
///
/// Mirrors TS `BcDynLinkValue` ({ model, id, display }).
class BcDynLinkValue {
  final String model;
  final String id;
  final String display;

  const BcDynLinkValue({
    required this.model,
    required this.id,
    required this.display,
  });

  @override
  String toString() =>
      'BcDynLinkValue(model: $model, id: $id, display: $display)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BcDynLinkValue &&
          model == other.model &&
          id == other.id &&
          display == other.display;

  @override
  int get hashCode => Object.hash(model, id, display);
}

/// Record returned by a [BcFieldDynLink] data fetcher.
///
/// Mirrors TS `BcDynLinkRecord` ({ id, label }).
class BcDynLinkRecord {
  final String id;
  final String label;

  const BcDynLinkRecord({required this.id, required this.label});

  @override
  String toString() => 'BcDynLinkRecord(id: $id, label: $label)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BcDynLinkRecord && id == other.id && label == other.label;

  @override
  int get hashCode => Object.hash(id, label);
}

/// Column descriptor for [BcLookupModal].
///
/// Mirrors TS `BcLookupModalColumn` ({ key, label }).
/// Intentionally parallels [BcFieldTableSelectColumn] shape.
class BcLookupModalColumn {
  final String key;
  final String label;

  const BcLookupModalColumn({required this.key, required this.label});

  @override
  String toString() => 'BcLookupModalColumn(key: $key, label: $label)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BcLookupModalColumn && key == other.key && label == other.label;

  @override
  int get hashCode => Object.hash(key, label);
}

// ---------------------------------------------------------------------------
// Gantt domain types (ADR-011 Phase 5b.2 — BcViewGantt)
// ---------------------------------------------------------------------------

/// Rendering shape for a Gantt task bar.
///
/// Mirrors TS `BcGanttTaskType` ('task' | 'milestone' | 'summary').
enum BcGanttTaskType { task, milestone, summary }

/// Zoom level for the Gantt timeline.
///
/// Mirrors TS `BcGanttZoomLevel` ('day' | 'week' | 'month' | 'quarter').
enum BcGanttZoomLevel { day, week, month, quarter }

/// Single Gantt task.
///
/// Mirrors TS `BcGanttTask`. [start] and [duration] are in time units
/// relative to the timeline start. [progress] is 0-100.
class BcGanttTask {
  final String id;
  final String label;
  final double start;
  final double duration;
  final double? progress;
  final String? color;
  final String? parentId;
  final bool? collapsed;
  final BcGanttTaskType? type;
  final List<String>? assignees;

  const BcGanttTask({
    required this.id,
    required this.label,
    required this.start,
    required this.duration,
    this.progress,
    this.color,
    this.parentId,
    this.collapsed,
    this.type,
    this.assignees,
  });

  @override
  String toString() =>
      'BcGanttTask(id: $id, label: $label, start: $start, '
      'duration: $duration, progress: $progress, color: $color, '
      'parentId: $parentId, collapsed: $collapsed, type: $type, '
      'assignees: $assignees)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BcGanttTask &&
          id == other.id &&
          label == other.label &&
          start == other.start &&
          duration == other.duration &&
          progress == other.progress &&
          color == other.color &&
          parentId == other.parentId &&
          collapsed == other.collapsed &&
          type == other.type &&
          _listEquals(assignees, other.assignees);

  @override
  int get hashCode => Object.hash(
    id,
    label,
    start,
    duration,
    progress,
    color,
    parentId,
    collapsed,
    type,
    Object.hashAll(assignees ?? const []),
  );

  static bool _listEquals(List<String>? a, List<String>? b) {
    if (identical(a, b)) return true;
    if (a == null || b == null) return a == b;
    if (a.length != b.length) return false;
    for (var i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }
}

/// Dependency link between two Gantt tasks.
///
/// Mirrors TS `BcGanttLink`. The [type] field accepts 'FS', 'FF', 'SS',
/// 'SF' (validated at usage layer, not constructor).
class BcGanttLink {
  final String id;
  final String from;
  final String to;
  final String? type;

  const BcGanttLink({
    required this.id,
    required this.from,
    required this.to,
    this.type,
  });

  @override
  String toString() =>
      'BcGanttLink(id: $id, from: $from, to: $to, type: $type)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BcGanttLink &&
          id == other.id &&
          from == other.from &&
          to == other.to &&
          type == other.type;

  @override
  int get hashCode => Object.hash(id, from, to, type);
}

// ---------------------------------------------------------------------------
// M2 upload/capture typed wrappers (ADR-011 Phase 5c — M2 forms-upload)
// ---------------------------------------------------------------------------

/// File reference for [BcFile] and [BcDropZone].
///
/// Mirrors a browser `File` object's salient fields used by the filtering
/// and display logic. [path] is set on native (desktop/mobile) platforms.
class BcFileRef {
  final String name;
  final int size;
  final String? type;
  final String? path;

  const BcFileRef({
    required this.name,
    required this.size,
    this.type,
    this.path,
  });

  @override
  String toString() =>
      'BcFileRef(name: $name, size: $size, type: $type, path: $path)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BcFileRef &&
          name == other.name &&
          size == other.size &&
          type == other.type &&
          path == other.path;

  @override
  int get hashCode => Object.hash(name, size, type, path);
}

/// Geographic coordinate pair for [BcGeo].
///
/// Mirrors TS `{ lat: number; lng: number }`.
class BcGeoCoord {
  final double lat;
  final double lng;

  const BcGeoCoord({required this.lat, required this.lng});

  @override
  String toString() => 'BcGeoCoord(lat: $lat, lng: $lng)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BcGeoCoord && lat == other.lat && lng == other.lng;

  @override
  int get hashCode => Object.hash(lat, lng);
}

/// Saturation/value (brightness) pair for [BcColorArea].
///
/// Maps the 2D drag area's horizontal axis (saturation, 0–100) and
/// vertical axis (value, 0–100).
class BcSvValue {
  final double saturation;
  final double value;

  const BcSvValue({required this.saturation, required this.value});

  @override
  String toString() => 'BcSvValue(saturation: $saturation, value: $value)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BcSvValue &&
          saturation == other.saturation &&
          value == other.value;

  @override
  int get hashCode => Object.hash(saturation, value);
}

// ---------------------------------------------------------------------------
// M5 data-display typed wrappers (ADR-011 Phase 5c — M5)
// ---------------------------------------------------------------------------

/// Rendering style for [BcSparkline].
enum BcSparklineType { line, bar, area }

/// Visual variant for a tag in [BcTagGroup].
enum BcTagVariant { defaultVariant, success, warning, destructive, info }

// ---------------------------------------------------------------------------
// M5 BcChart typed wrappers — moved to core/chart/chart_types.dart
// (ADR-015 Flutter ECharts chart strategy).
//
// The chart contract (BcChartType, BcChartItem, BcChartSeries,
// BC_CHART_TYPES) now lives in core/chart/chart_types.dart to mirror the
// TypeScript chart-option contract (packages/ui/src/contracts/chart-option/).
// It is re-exported from the top of this file so existing importers of
// core/types.dart keep resolving unchanged (backward compatibility).
// ---------------------------------------------------------------------------

// ---------------------------------------------------------------------------
// M5 BcKanbanBoard typed wrappers (ADR-011 Phase 5c — M5 data display)
// ---------------------------------------------------------------------------

/// Priority level for a [BcKanbanCard].
enum BcKanbanPriority { low, medium, high, critical }

/// Column descriptor for [BcKanbanBoard].
///
/// Mirrors TS `KanbanColumnConfig` ({ id, name, color?, wip_limit? }).
class BcKanbanColumnConfig {
  final String id;
  final String name;
  final Color? color;
  final int? wipLimit;

  const BcKanbanColumnConfig({
    required this.id,
    required this.name,
    this.color,
    this.wipLimit,
  });

  @override
  String toString() =>
      'BcKanbanColumnConfig(id: $id, name: $name, color: $color, wipLimit: $wipLimit)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BcKanbanColumnConfig &&
          id == other.id &&
          name == other.name &&
          color == other.color &&
          wipLimit == other.wipLimit;

  @override
  int get hashCode => Object.hash(id, name, color, wipLimit);
}

/// Card in a [BcKanbanBoard].
///
/// Mirrors TS `KanbanCard` with the fields relevant to the Flutter widget.
class BcKanbanCard {
  final String id;
  final String title;
  final String? description;
  final String column;
  final int? position;
  final BcKanbanPriority? priority;
  final String? dueDate;
  final List<String>? labels;

  const BcKanbanCard({
    required this.id,
    required this.title,
    required this.column,
    this.description,
    this.position,
    this.priority,
    this.dueDate,
    this.labels,
  });

  @override
  String toString() =>
      'BcKanbanCard(id: $id, title: $title, column: $column, '
      'description: $description, position: $position, priority: $priority, '
      'dueDate: $dueDate, labels: $labels)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BcKanbanCard &&
          id == other.id &&
          title == other.title &&
          column == other.column &&
          description == other.description &&
          position == other.position &&
          priority == other.priority &&
          dueDate == other.dueDate &&
          _listEquals(labels, other.labels);

  @override
  int get hashCode => Object.hash(
    id,
    title,
    column,
    description,
    position,
    priority,
    dueDate,
    Object.hashAll(labels ?? const []),
  );

  static bool _listEquals(List<String>? a, List<String>? b) {
    if (identical(a, b)) return true;
    if (a == null || b == null) return a == b;
    if (a.length != b.length) return false;
    for (var i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }
}

/// Event payload emitted when a card is moved or reordered.
///
/// Mirrors TS `KanbanCardMoveEvent`
/// ({ cardId, fromColumn, toColumn, toPosition? }).
class BcKanbanCardMoveEvent {
  final String cardId;
  final String fromColumn;
  final String toColumn;
  final int? toPosition;

  const BcKanbanCardMoveEvent({
    required this.cardId,
    required this.fromColumn,
    required this.toColumn,
    this.toPosition,
  });

  @override
  String toString() =>
      'BcKanbanCardMoveEvent(cardId: $cardId, fromColumn: $fromColumn, '
      'toColumn: $toColumn, toPosition: $toPosition)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BcKanbanCardMoveEvent &&
          cardId == other.cardId &&
          fromColumn == other.fromColumn &&
          toColumn == other.toColumn &&
          toPosition == other.toPosition;

  @override
  int get hashCode => Object.hash(cardId, fromColumn, toColumn, toPosition);
}

// ---------------------------------------------------------------------------
// M5 BcViewMap typed wrappers (ADR-011 Phase 5c — M5 data display)
// ---------------------------------------------------------------------------

/// Marker for [BcViewMap].
///
/// Carries the geo coordinate and optional label.
class BcMapMarker {
  final String id;
  final double lat;
  final double lng;
  final String? label;

  const BcMapMarker({
    required this.id,
    required this.lat,
    required this.lng,
    this.label,
  });

  @override
  String toString() =>
      'BcMapMarker(id: $id, lat: $lat, lng: $lng, label: $label)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BcMapMarker &&
          id == other.id &&
          lat == other.lat &&
          lng == other.lng &&
          label == other.label;

  @override
  int get hashCode => Object.hash(id, lat, lng, label);
}

/// Shape type for a geo region/polyline.
enum BcGeoShapeType { polygon, polyline }

/// Geo region (polygon) or polyline for [BcViewMap].
class BcMapRegion {
  final String id;
  final BcGeoShapeType type;
  final List<BcGeoCoord> points;
  final String? label;
  final Color? color;

  const BcMapRegion({
    required this.id,
    required this.type,
    required this.points,
    this.label,
    this.color,
  });

  @override
  String toString() =>
      'BcMapRegion(id: $id, type: $type, points: $points, label: $label)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BcMapRegion &&
          id == other.id &&
          type == other.type &&
          _coordListEquals(points, other.points) &&
          label == other.label &&
          color == other.color;

  @override
  int get hashCode =>
      Object.hash(id, type, Object.hashAll(points), label, color);

  static bool _coordListEquals(List<BcGeoCoord> a, List<BcGeoCoord> b) {
    if (identical(a, b)) return true;
    if (a.length != b.length) return false;
    for (var i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }
}

// ---------------------------------------------------------------------------
// M6 BcImage (media — lazy loading image) typed wrappers
// ---------------------------------------------------------------------------

/// Fit mode for [BcImage].
enum BcImageFit {
  cover,
  contain,
  fill;

  BoxFit get boxFit {
    switch (this) {
      case BcImageFit.cover:
        return BoxFit.cover;
      case BcImageFit.contain:
        return BoxFit.contain;
      case BcImageFit.fill:
        return BoxFit.fill;
    }
  }
}

// ---------------------------------------------------------------------------
// M6 BcGalleria typed wrappers (ADR-011 Phase 5c — M6 media/social)
// ---------------------------------------------------------------------------

/// Image item in a [BcGalleria] gallery.
///
/// Mirrors TS `BcGalleriaItem` ({ id, src, alt?, thumbnail?, caption? }).
class BcGalleriaItem {
  final String id;
  final String src;
  final String? alt;
  final String? thumbnail;
  final String? caption;

  const BcGalleriaItem({
    required this.id,
    required this.src,
    this.alt,
    this.thumbnail,
    this.caption,
  });

  @override
  String toString() =>
      'BcGalleriaItem(id: $id, src: $src, alt: $alt, thumbnail: $thumbnail, caption: $caption)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BcGalleriaItem &&
          id == other.id &&
          src == other.src &&
          alt == other.alt &&
          thumbnail == other.thumbnail &&
          caption == other.caption;

  @override
  int get hashCode => Object.hash(id, src, alt, thumbnail, caption);
}

// ---------------------------------------------------------------------------
// M6 BcActivity typed wrappers (ADR-011 Phase 5c — M6 social)
// ---------------------------------------------------------------------------

/// Visual variant for an activity timeline entry.
enum BcActivityVariant { defaultVariant, success, warning, destructive, info }

/// Single activity timeline entry.
///
/// Mirrors TS `BcActivityEntry` ({ id, actor, action, target?, timestamp, variant? }).
class BcActivityEntry {
  final String id;
  final String actor;
  final String action;
  final String? target;
  final String timestamp;
  final BcActivityVariant variant;

  const BcActivityEntry({
    required this.id,
    required this.actor,
    required this.action,
    required this.timestamp,
    this.target,
    this.variant = BcActivityVariant.defaultVariant,
  });

  @override
  String toString() =>
      'BcActivityEntry(id: $id, actor: $actor, action: $action, target: $target, timestamp: $timestamp, variant: $variant)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BcActivityEntry &&
          id == other.id &&
          actor == other.actor &&
          action == other.action &&
          target == other.target &&
          timestamp == other.timestamp &&
          variant == other.variant;

  @override
  int get hashCode =>
      Object.hash(id, actor, action, target, timestamp, variant);
}

/// Layout variant for the activity feed (mirrors TS `BcActivityLayout`).
enum BcActivityLayout { timeline, feed, compact }

/// Declarative data-source binding for the activity feed (ADR-005 §3).
///
/// Mirrors TS `BcActivityDataSource` ({ endpoint?, model?, recordId?, params? }).
/// When provided, [BcActivity] fetches entries from the engine activity API.
class BcActivityDataSource {
  final String? endpoint;
  final String? model;
  final String? recordId;
  final Map<String, String>? params;

  const BcActivityDataSource({
    this.endpoint,
    this.model,
    this.recordId,
    this.params,
  });

  @override
  String toString() =>
      'BcActivityDataSource(endpoint: $endpoint, model: $model, recordId: $recordId, params: $params)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BcActivityDataSource &&
          endpoint == other.endpoint &&
          model == other.model &&
          recordId == other.recordId &&
          _mapEq(params, other.params);

  @override
  int get hashCode => Object.hash(endpoint, model, recordId, params);

  static bool _mapEq(Map<String, String>? a, Map<String, String>? b) {
    if (a == null) return b == null;
    if (b == null) return false;
    if (a.length != b.length) return false;
    for (final key in a.keys) {
      if (a[key] != b[key]) return false;
    }
    return true;
  }
}

// ---------------------------------------------------------------------------
// M6 BcTimelineSocial typed wrappers (ADR-011 Phase 5c — M6 social)
// ---------------------------------------------------------------------------

/// Comment under a [BcSocialPost].
///
/// Mirrors TS `BcSocialComment` ({ id, author, content, timestamp? }).
class BcSocialComment {
  final String id;
  final String author;
  final String content;
  final String? timestamp;

  const BcSocialComment({
    required this.id,
    required this.author,
    required this.content,
    this.timestamp,
  });

  @override
  String toString() =>
      'BcSocialComment(id: $id, author: $author, content: $content, timestamp: $timestamp)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BcSocialComment &&
          id == other.id &&
          author == other.author &&
          content == other.content &&
          timestamp == other.timestamp;

  @override
  int get hashCode => Object.hash(id, author, content, timestamp);
}

/// Social post with optional nested comments for [BcTimelineSocial].
///
/// Mirrors TS `BcSocialPost` ({ id, author, handle?, avatar?, content,
/// timestamp?, likes?, comments?, shares?, commentList? }).
class BcSocialPost {
  final String id;
  final String author;
  final String? handle;
  final String? avatar;
  final String content;
  final String? timestamp;
  final int likes;
  final int comments;
  final int shares;
  final List<BcSocialComment> commentList;

  const BcSocialPost({
    required this.id,
    required this.author,
    required this.content,
    this.handle,
    this.avatar,
    this.timestamp,
    this.likes = 0,
    this.comments = 0,
    this.shares = 0,
    this.commentList = const [],
  });

  @override
  String toString() =>
      'BcSocialPost(id: $id, author: $author, handle: $handle, content: $content, '
      'timestamp: $timestamp, likes: $likes, comments: $comments, shares: $shares, '
      'commentList: $commentList)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BcSocialPost &&
          id == other.id &&
          author == other.author &&
          handle == other.handle &&
          avatar == other.avatar &&
          content == other.content &&
          timestamp == other.timestamp &&
          likes == other.likes &&
          comments == other.comments &&
          shares == other.shares &&
          _listEquals(commentList, other.commentList);

  @override
  int get hashCode => Object.hash(
    id,
    author,
    handle,
    avatar,
    content,
    timestamp,
    likes,
    comments,
    shares,
    Object.hashAll(commentList),
  );

  static bool _listEquals(List<BcSocialComment> a, List<BcSocialComment> b) {
    if (identical(a, b)) return true;
    if (a.length != b.length) return false;
    for (var i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }
}

// ---------------------------------------------------------------------------
// M6 BcChatter typed wrappers (ADR-011 Phase 5c — M6 social)
// ---------------------------------------------------------------------------

/// A user mentioned inside a comment body.
///
/// Mirrors TS `BcChatterMention` ({ username, userId?, resolved? }).
class BcChatterMention {
  final String username;
  final String? userId;
  final bool resolved;

  const BcChatterMention({
    required this.username,
    this.userId,
    this.resolved = false,
  });

  @override
  String toString() =>
      'BcChatterMention(username: $username, userId: $userId, resolved: $resolved)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BcChatterMention &&
          username == other.username &&
          userId == other.userId &&
          resolved == other.resolved;

  @override
  int get hashCode => Object.hash(username, userId, resolved);
}

/// Chat message for [BcChatter].
///
/// Mirrors TS `BcChatterMessage`
/// ({ id, author, avatar?, content, timestamp?, mentions?, parentId?,
///   replies?, authorId? }).
class BcChatterMessage {
  final String id;
  final String author;
  final String? avatar;
  final String content;
  final String? timestamp;
  final List<BcChatterMention> mentions;
  final String? parentId;
  final List<BcChatterMessage> replies;
  final String? authorId;

  const BcChatterMessage({
    required this.id,
    required this.author,
    required this.content,
    this.avatar,
    this.timestamp,
    this.mentions = const [],
    this.parentId,
    this.replies = const [],
    this.authorId,
  });

  BcChatterMessage copyWith({
    String? id,
    String? author,
    String? avatar,
    String? content,
    String? timestamp,
    List<BcChatterMention>? mentions,
    String? parentId,
    List<BcChatterMessage>? replies,
    String? authorId,
  }) {
    return BcChatterMessage(
      id: id ?? this.id,
      author: author ?? this.author,
      avatar: avatar ?? this.avatar,
      content: content ?? this.content,
      timestamp: timestamp ?? this.timestamp,
      mentions: mentions ?? this.mentions,
      parentId: parentId ?? this.parentId,
      replies: replies ?? this.replies,
      authorId: authorId ?? this.authorId,
    );
  }

  @override
  String toString() =>
      'BcChatterMessage(id: $id, author: $author, avatar: $avatar, content: $content, timestamp: $timestamp, mentions: $mentions, parentId: $parentId, replies: ${replies.length}, authorId: $authorId)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BcChatterMessage &&
          id == other.id &&
          author == other.author &&
          avatar == other.avatar &&
          content == other.content &&
          timestamp == other.timestamp &&
          _listEquals(mentions, other.mentions) &&
          parentId == other.parentId &&
          _listEquals(replies, other.replies) &&
          authorId == other.authorId;

  @override
  int get hashCode => Object.hash(
        id,
        author,
        avatar,
        content,
        timestamp,
        Object.hashAll(mentions),
        parentId,
        Object.hashAll(replies),
        authorId,
      );

  static bool _listEquals<T>(List<T> a, List<T> b) {
    if (identical(a, b)) return true;
    if (a.length != b.length) return false;
    for (var i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }
}

// ---------------------------------------------------------------------------
// M5 BcViewReport typed wrappers (ADR-011 Phase 5c — M5 data display)
// ---------------------------------------------------------------------------

/// Section in a [BcViewReport].
///
/// Mirrors TS `BcReportSection` ({ id, title?, content?, visible? }).
class BcReportSection {
  final String id;
  final String? title;
  final String? content;
  final bool visible;

  const BcReportSection({
    required this.id,
    this.title,
    this.content,
    this.visible = true,
  });

  @override
  String toString() =>
      'BcReportSection(id: $id, title: $title, content: $content, visible: $visible)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BcReportSection &&
          id == other.id &&
          title == other.title &&
          content == other.content &&
          visible == other.visible;

  @override
  int get hashCode => Object.hash(id, title, content, visible);
}
