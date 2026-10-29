/// Field event types ported from @bitcode/ui-schema/src/types.ts (ADR-011).
///
/// Mirrors the TS `Field*Event` interfaces. All events share the [BcEventBase]
/// shape (`name` + `timestamp`) so consumers can route them through a single
/// handler and switch on runtime type.

library ui_schema_events;

import 'package:freezed_annotation/freezed_annotation.dart';

part 'ui_schema_events.freezed.dart';
part 'ui_schema_events.g.dart';

/// Base shape for every field event. Mirrors TS `BcEventBase`.
@freezed
class BcEventBase with _$BcEventBase {
  const factory BcEventBase({
    required String name,
    required int timestamp,
  }) = _BcEventBase;

  factory BcEventBase.fromJson(Map<String, dynamic> json) =>
      _$BcEventBaseFromJson(json);
}

/// Fired when a field value changes. Carries old + new value.
@freezed
class FieldChangeEvent with _$FieldChangeEvent {
  const factory FieldChangeEvent({
    required String name,
    required int timestamp,
    required Object? value,
    required Object? oldValue,
  }) = _FieldChangeEvent;

  factory FieldChangeEvent.fromJson(Map<String, dynamic> json) =>
      _$FieldChangeEventFromJson(json);
}

/// Fired when a field gains focus.
@freezed
class FieldFocusEvent with _$FieldFocusEvent {
  const factory FieldFocusEvent({
    required String name,
    required int timestamp,
    required Object? value,
  }) = _FieldFocusEvent;

  factory FieldFocusEvent.fromJson(Map<String, dynamic> json) =>
      _$FieldFocusEventFromJson(json);
}

/// Fired when a field loses focus. Includes `dirty` / `touched` flags.
@freezed
class FieldBlurEvent with _$FieldBlurEvent {
  const factory FieldBlurEvent({
    required String name,
    required int timestamp,
    required Object? value,
    @Default(false) bool dirty,
    @Default(false) bool touched,
  }) = _FieldBlurEvent;

  factory FieldBlurEvent.fromJson(Map<String, dynamic> json) =>
      _$FieldBlurEventFromJson(json);
}

/// Fired when a field is cleared. Carries the previous value.
@freezed
class FieldClearEvent with _$FieldClearEvent {
  const factory FieldClearEvent({
    required String name,
    required int timestamp,
    required Object? oldValue,
  }) = _FieldClearEvent;

  factory FieldClearEvent.fromJson(Map<String, dynamic> json) =>
      _$FieldClearEventFromJson(json);
}

/// Fired on every keystroke / input mutation (before commit).
@freezed
class FieldInputEvent with _$FieldInputEvent {
  const factory FieldInputEvent({
    required String name,
    required int timestamp,
    required Object? value,
  }) = _FieldInputEvent;

  factory FieldInputEvent.fromJson(Map<String, dynamic> json) =>
      _$FieldInputEventFromJson(json);
}

/// Fired on key down. `key` mirrors the browser `KeyboardEvent.key` string.
@freezed
class FieldKeyEvent with _$FieldKeyEvent {
  const factory FieldKeyEvent({
    required String name,
    required int timestamp,
    required Object? value,
    required String key,
  }) = _FieldKeyEvent;

  factory FieldKeyEvent.fromJson(Map<String, dynamic> json) =>
      _$FieldKeyEventFromJson(json);
}

/// Fired after validation runs. `valid` + optional `message`.
@freezed
class FieldValidateEvent with _$FieldValidateEvent {
  const factory FieldValidateEvent({
    required String name,
    required int timestamp,
    required Object? value,
    @Default(false) bool valid,
    @Default('') String message,
  }) = _FieldValidateEvent;

  factory FieldValidateEvent.fromJson(Map<String, dynamic> json) =>
      _$FieldValidateEventFromJson(json);
}
