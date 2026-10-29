import 'package:flutter_test/flutter_test.dart';
import 'package:bc_ui_flutter/bc_ui_flutter.dart';

void main() {
  group('BcChangeMeta', () {
    test('default source is programmatic', () {
      const meta = BcChangeMeta(reason: BcChangeReason.input);
      expect(meta.source, BcEventSource.programmatic);
    });

    test('equality based on reason and source', () {
      const a = BcChangeMeta(reason: BcChangeReason.select, source: BcEventSource.pointer);
      const b = BcChangeMeta(reason: BcChangeReason.select, source: BcEventSource.pointer);
      const c = BcChangeMeta(reason: BcChangeReason.toggle, source: BcEventSource.pointer);
      expect(a == b, isTrue);
      expect(a == c, isFalse);
      expect(a.hashCode, b.hashCode);
    });

    test('nativeEvent does not affect equality', () {
      const a = BcChangeMeta(reason: BcChangeReason.input, nativeEvent: 'event1');
      const b = BcChangeMeta(reason: BcChangeReason.input, nativeEvent: 'event2');
      expect(a == b, isTrue);
    });
  });

  group('BcEventSource', () {
    test('has all expected values', () {
      expect(BcEventSource.values.length, 4);
      expect(BcEventSource.values, contains(BcEventSource.pointer));
      expect(BcEventSource.values, contains(BcEventSource.keyboard));
      expect(BcEventSource.values, contains(BcEventSource.programmatic));
      expect(BcEventSource.values, contains(BcEventSource.external));
    });
  });

  group('BcChangeReason', () {
    test('BcChangeReason has all 18 values', () {
      expect(BcChangeReason.values.length, 18);
      expect(BcChangeReason.values, contains(BcChangeReason.input));
      expect(BcChangeReason.values, contains(BcChangeReason.reaction));
      expect(BcChangeReason.values, contains(BcChangeReason.programmatic));
      expect(BcChangeReason.values, contains(BcChangeReason.select));
      expect(BcChangeReason.values, contains(BcChangeReason.toggle));
      expect(BcChangeReason.values, contains(BcChangeReason.submit));
      expect(BcChangeReason.values, contains(BcChangeReason.escape));
      expect(BcChangeReason.values, contains(BcChangeReason.back));
      expect(BcChangeReason.values, contains(BcChangeReason.deselect));
      expect(BcChangeReason.values, contains(BcChangeReason.clear));
      expect(BcChangeReason.values, contains(BcChangeReason.typeChange));
      expect(BcChangeReason.values, contains(BcChangeReason.valueChange));
      expect(BcChangeReason.values, contains(BcChangeReason.modelChange));
      expect(BcChangeReason.values, contains(BcChangeReason.confirm));
      expect(BcChangeReason.values, contains(BcChangeReason.cancel));
      expect(BcChangeReason.values, contains(BcChangeReason.overlayClick));
      expect(BcChangeReason.values, contains(BcChangeReason.increment));
      expect(BcChangeReason.values, contains(BcChangeReason.decrement));
    });

    test('BcChangeReason preserves existing values', () {
      expect(BcChangeReason.values[0], BcChangeReason.input);
      expect(BcChangeReason.values[1], BcChangeReason.reaction);
      expect(BcChangeReason.values[2], BcChangeReason.programmatic);
      expect(BcChangeReason.values[3], BcChangeReason.select);
      expect(BcChangeReason.values[4], BcChangeReason.toggle);
      expect(BcChangeReason.values[5], BcChangeReason.submit);
    });

    test('BcChangeReason has new P1 reason members', () {
      expect(BcChangeReason.values[6], BcChangeReason.escape);
      expect(BcChangeReason.values[7], BcChangeReason.back);
      expect(BcChangeReason.values[8], BcChangeReason.deselect);
      expect(BcChangeReason.values[9], BcChangeReason.clear);
      expect(BcChangeReason.values[10], BcChangeReason.typeChange);
      expect(BcChangeReason.values[11], BcChangeReason.valueChange);
      expect(BcChangeReason.values[12], BcChangeReason.modelChange);
      expect(BcChangeReason.values[13], BcChangeReason.confirm);
      expect(BcChangeReason.values[14], BcChangeReason.cancel);
      expect(BcChangeReason.values[15], BcChangeReason.overlayClick);
      expect(BcChangeReason.values[16], BcChangeReason.increment);
      expect(BcChangeReason.values[17], BcChangeReason.decrement);
    });
  });

  group('BcChangeMeta with new reasons', () {
    test('BcChangeMeta accepts new reasons', () {
      const escapeMeta = BcChangeMeta(
          reason: BcChangeReason.escape, source: BcEventSource.keyboard);
      const clearMeta = BcChangeMeta(
          reason: BcChangeReason.clear, source: BcEventSource.pointer);
      const incrementMeta = BcChangeMeta(
          reason: BcChangeReason.increment, source: BcEventSource.pointer);
      const decrementMeta = BcChangeMeta(
          reason: BcChangeReason.decrement, source: BcEventSource.pointer);
      const typeChangeMeta = BcChangeMeta(
          reason: BcChangeReason.typeChange, source: BcEventSource.pointer);
      const modelChangeMeta = BcChangeMeta(
          reason: BcChangeReason.modelChange, source: BcEventSource.pointer);
      const confirmMeta = BcChangeMeta(
          reason: BcChangeReason.confirm, source: BcEventSource.pointer);
      const cancelMeta = BcChangeMeta(
          reason: BcChangeReason.cancel, source: BcEventSource.pointer);
      const overlayClickMeta = BcChangeMeta(
          reason: BcChangeReason.overlayClick, source: BcEventSource.pointer);
      const backMeta = BcChangeMeta(
          reason: BcChangeReason.back, source: BcEventSource.external);
      const deselectMeta = BcChangeMeta(
          reason: BcChangeReason.deselect, source: BcEventSource.pointer);
      const valueChangeMeta = BcChangeMeta(
          reason: BcChangeReason.valueChange, source: BcEventSource.pointer);

      expect(escapeMeta.reason, BcChangeReason.escape);
      expect(clearMeta.reason, BcChangeReason.clear);
      expect(incrementMeta.reason, BcChangeReason.increment);
      expect(decrementMeta.reason, BcChangeReason.decrement);
      expect(typeChangeMeta.reason, BcChangeReason.typeChange);
      expect(modelChangeMeta.reason, BcChangeReason.modelChange);
      expect(confirmMeta.reason, BcChangeReason.confirm);
      expect(cancelMeta.reason, BcChangeReason.cancel);
      expect(overlayClickMeta.reason, BcChangeReason.overlayClick);
      expect(backMeta.reason, BcChangeReason.back);
      expect(deselectMeta.reason, BcChangeReason.deselect);
      expect(valueChangeMeta.reason, BcChangeReason.valueChange);

      const escapeMeta2 = BcChangeMeta(
          reason: BcChangeReason.escape, source: BcEventSource.keyboard);
      expect(escapeMeta == escapeMeta2, isTrue);
      expect(escapeMeta == clearMeta, isFalse);
    });
  });

  group('BcComponentSize', () {
    test('has sm, md, lg', () {
      expect(BcComponentSize.values.length, 3);
    });
  });

  group('BcComponentVariant', () {
    test('has all expected variants', () {
      expect(BcComponentVariant.values.length, 7);
    });
  });

  group('BcFieldTableSelectColumn', () {
    test('BcFieldTableSelectColumn has key and label fields', () {
      const col = BcFieldTableSelectColumn(key: 'code', label: 'Code');
      expect(col.key, 'code');
      expect(col.label, 'Code');
    });

    test('equality and hashCode', () {
      const a = BcFieldTableSelectColumn(key: 'code', label: 'Code');
      const b = BcFieldTableSelectColumn(key: 'code', label: 'Code');
      const c = BcFieldTableSelectColumn(key: 'name', label: 'Name');
      expect(a == b, isTrue);
      expect(a.hashCode, b.hashCode);
      expect(a == c, isFalse);
    });
  });

  group('BcFieldMorphOption', () {
    test('BcFieldMorphOption has label and value', () {
      const opt = BcFieldMorphOption(label: 'Yes', value: 'Y');
      expect(opt.label, 'Yes');
      expect(opt.value, 'Y');
    });

    test('equality and hashCode', () {
      const a = BcFieldMorphOption(label: 'Yes', value: 'Y');
      const b = BcFieldMorphOption(label: 'Yes', value: 'Y');
      const c = BcFieldMorphOption(label: 'No', value: 'N');
      expect(a == b, isTrue);
      expect(a.hashCode, b.hashCode);
      expect(a == c, isFalse);
    });
  });

  group('BcFieldMorphType', () {
    test('BcFieldMorphType has value/label/widget/options', () {
      const t = BcFieldMorphType(
        value: 'text',
        label: 'Text',
        widget: 'text',
      );
      expect(t.value, 'text');
      expect(t.label, 'Text');
      expect(t.widget, 'text');
      expect(t.options, isNull);
    });

    test('BcFieldMorphType with options', () {
      const t = BcFieldMorphType(
        value: 'select',
        label: 'Select',
        widget: 'select',
        options: [
          BcFieldMorphOption(label: 'Red', value: 'red'),
          BcFieldMorphOption(label: 'Blue', value: 'blue'),
        ],
      );
      expect(t.options, isNotNull);
      expect(t.options!.length, 2);
      expect(t.options![0].label, 'Red');
      expect(t.options![1].value, 'blue');
    });

    test('equality and hashCode', () {
      const a = BcFieldMorphType(
        value: 'text',
        label: 'Text',
        widget: 'text',
        options: [BcFieldMorphOption(label: 'A', value: 'a')],
      );
      const b = BcFieldMorphType(
        value: 'text',
        label: 'Text',
        widget: 'text',
        options: [BcFieldMorphOption(label: 'A', value: 'a')],
      );
      expect(a == b, isTrue);
      expect(a.hashCode, b.hashCode);
    });
  });

  group('BcFieldMorphValue', () {
    test('BcFieldMorphValue has type and nullable value', () {
      const str = BcFieldMorphValue(type: 'text', value: 'hello');
      const num = BcFieldMorphValue(type: 'number', value: 42);
      const nullVal = BcFieldMorphValue(type: 'text');
      expect(str.type, 'text');
      expect(str.value, 'hello');
      expect(num.type, 'number');
      expect(num.value, 42);
      expect(nullVal.value, isNull);
    });

    test('equality and hashCode', () {
      const a = BcFieldMorphValue(type: 'text', value: 'hello');
      const b = BcFieldMorphValue(type: 'text', value: 'hello');
      const c = BcFieldMorphValue(type: 'number', value: 42);
      expect(a == b, isTrue);
      expect(a.hashCode, b.hashCode);
      expect(a == c, isFalse);
    });
  });

  group('BcDynLinkModel', () {
    test('BcDynLinkModel has model and label', () {
      const m = BcDynLinkModel(model: 'res.partner', label: 'Partner');
      expect(m.model, 'res.partner');
      expect(m.label, 'Partner');
    });

    test('equality and hashCode', () {
      const a = BcDynLinkModel(model: 'res.partner', label: 'Partner');
      const b = BcDynLinkModel(model: 'res.partner', label: 'Partner');
      const c = BcDynLinkModel(model: 'res.users', label: 'User');
      expect(a == b, isTrue);
      expect(a.hashCode, b.hashCode);
      expect(a == c, isFalse);
    });
  });

  group('BcDynLinkValue', () {
    test('BcDynLinkValue has model/id/display', () {
      const v = BcDynLinkValue(
        model: 'res.partner',
        id: '1',
        display: 'Acme',
      );
      expect(v.model, 'res.partner');
      expect(v.id, '1');
      expect(v.display, 'Acme');
    });

    test('equality and hashCode', () {
      const a = BcDynLinkValue(model: 'res.partner', id: '1', display: 'Acme');
      const b = BcDynLinkValue(model: 'res.partner', id: '1', display: 'Acme');
      const c = BcDynLinkValue(model: 'res.partner', id: '2', display: 'Beta');
      expect(a == b, isTrue);
      expect(a.hashCode, b.hashCode);
      expect(a == c, isFalse);
    });
  });

  group('BcDynLinkRecord', () {
    test('BcDynLinkRecord has id and label', () {
      const r = BcDynLinkRecord(id: '1', label: 'Acme');
      expect(r.id, '1');
      expect(r.label, 'Acme');
    });

    test('equality and hashCode', () {
      const a = BcDynLinkRecord(id: '1', label: 'Acme');
      const b = BcDynLinkRecord(id: '1', label: 'Acme');
      const c = BcDynLinkRecord(id: '2', label: 'Beta');
      expect(a == b, isTrue);
      expect(a.hashCode, b.hashCode);
      expect(a == c, isFalse);
    });
  });

  group('BcLookupModalColumn', () {
    test('BcLookupModalColumn has key and label', () {
      const col = BcLookupModalColumn(key: 'name', label: 'Name');
      expect(col.key, 'name');
      expect(col.label, 'Name');
    });

    test('equality and hashCode', () {
      const a = BcLookupModalColumn(key: 'name', label: 'Name');
      const b = BcLookupModalColumn(key: 'name', label: 'Name');
      const c = BcLookupModalColumn(key: 'email', label: 'Email');
      expect(a == b, isTrue);
      expect(a.hashCode, b.hashCode);
      expect(a == c, isFalse);
    });
  });

  group('BcGanttTaskType', () {
    test('BcGanttTaskType has task/milestone/summary', () {
      expect(BcGanttTaskType.values.length, 3);
      expect(BcGanttTaskType.values, contains(BcGanttTaskType.task));
      expect(BcGanttTaskType.values, contains(BcGanttTaskType.milestone));
      expect(BcGanttTaskType.values, contains(BcGanttTaskType.summary));
    });
  });

  group('BcGanttZoomLevel', () {
    test('BcGanttZoomLevel has day/week/month/quarter', () {
      expect(BcGanttZoomLevel.values.length, 4);
      expect(BcGanttZoomLevel.values, contains(BcGanttZoomLevel.day));
      expect(BcGanttZoomLevel.values, contains(BcGanttZoomLevel.week));
      expect(BcGanttZoomLevel.values, contains(BcGanttZoomLevel.month));
      expect(BcGanttZoomLevel.values, contains(BcGanttZoomLevel.quarter));
    });
  });

  group('BcGanttTask', () {
    test('BcGanttTask has required and optional fields', () {
      const minimal = BcGanttTask(
        id: 't1',
        label: 'Task 1',
        start: 0,
        duration: 5,
      );
      expect(minimal.id, 't1');
      expect(minimal.label, 'Task 1');
      expect(minimal.start, 0);
      expect(minimal.duration, 5);
      expect(minimal.progress, isNull);
      expect(minimal.color, isNull);
      expect(minimal.parentId, isNull);
      expect(minimal.collapsed, isNull);
      expect(minimal.type, isNull);
      expect(minimal.assignees, isNull);
    });

    test('BcGanttTask with full fields', () {
      const full = BcGanttTask(
        id: 't2',
        label: 'Design',
        start: 3,
        duration: 10,
        progress: 50,
        color: '#FF0000',
        parentId: 't1',
        collapsed: true,
        type: BcGanttTaskType.summary,
        assignees: ['alice', 'bob'],
      );
      expect(full.progress, 50);
      expect(full.color, '#FF0000');
      expect(full.parentId, 't1');
      expect(full.collapsed, true);
      expect(full.type, BcGanttTaskType.summary);
      expect(full.assignees, ['alice', 'bob']);
    });

    test('equality and hashCode', () {
      const a = BcGanttTask(id: 't1', label: 'Task', start: 0, duration: 5);
      const b = BcGanttTask(id: 't1', label: 'Task', start: 0, duration: 5);
      const c = BcGanttTask(id: 't2', label: 'Task', start: 0, duration: 5);
      expect(a == b, isTrue);
      expect(a.hashCode, b.hashCode);
      expect(a == c, isFalse);
    });
  });

  group('BcGanttLink', () {
    test('BcGanttLink has id/from/to/type', () {
      const withType = BcGanttLink(
        id: 'l1',
        from: 't1',
        to: 't2',
        type: 'FS',
      );
      expect(withType.id, 'l1');
      expect(withType.from, 't1');
      expect(withType.to, 't2');
      expect(withType.type, 'FS');

      const withoutType = BcGanttLink(id: 'l2', from: 't1', to: 't3');
      expect(withoutType.type, isNull);
    });

    test('equality and hashCode', () {
      const a = BcGanttLink(id: 'l1', from: 't1', to: 't2', type: 'FS');
      const b = BcGanttLink(id: 'l1', from: 't1', to: 't2', type: 'FS');
      const c = BcGanttLink(id: 'l1', from: 't1', to: 't2', type: 'FF');
      expect(a == b, isTrue);
      expect(a.hashCode, b.hashCode);
      expect(a == c, isFalse);
    });
  });

  group('Barrel exports', () {
    test('barrel exports all infrastructure types', () {
      expect(BcFieldTableSelectColumn, isNotNull);
      expect(BcFieldMorphOption, isNotNull);
      expect(BcFieldMorphType, isNotNull);
      expect(BcFieldMorphValue, isNotNull);
      expect(BcDynLinkModel, isNotNull);
      expect(BcDynLinkValue, isNotNull);
      expect(BcDynLinkRecord, isNotNull);
      expect(BcLookupModalColumn, isNotNull);
      expect(BcGanttTaskType, isNotNull);
      expect(BcGanttZoomLevel, isNotNull);
      expect(BcGanttTask, isNotNull);
      expect(BcGanttLink, isNotNull);

      const col = BcFieldTableSelectColumn(key: 'k', label: 'l');
      const opt = BcFieldMorphOption(label: 'l', value: 'v');
      const morphType = BcFieldMorphType(value: 'v', label: 'l', widget: 'text');
      const morphVal = BcFieldMorphValue(type: 'text', value: 'x');
      const dynModel = BcDynLinkModel(model: 'm', label: 'l');
      const dynVal = BcDynLinkValue(model: 'm', id: '1', display: 'd');
      const dynRec = BcDynLinkRecord(id: '1', label: 'l');
      const lookupCol = BcLookupModalColumn(key: 'k', label: 'l');
      const ganttTask = BcGanttTask(id: 't', label: 'l', start: 0, duration: 1);
      const ganttLink = BcGanttLink(id: 'l', from: 'a', to: 'b');

      expect(col, isA<BcFieldTableSelectColumn>());
      expect(opt, isA<BcFieldMorphOption>());
      expect(morphType, isA<BcFieldMorphType>());
      expect(morphVal, isA<BcFieldMorphValue>());
      expect(dynModel, isA<BcDynLinkModel>());
      expect(dynVal, isA<BcDynLinkValue>());
      expect(dynRec, isA<BcDynLinkRecord>());
      expect(lookupCol, isA<BcLookupModalColumn>());
      expect(ganttTask, isA<BcGanttTask>());
      expect(ganttLink, isA<BcGanttLink>());
      expect(BcGanttTaskType.task, isA<BcGanttTaskType>());
      expect(BcGanttZoomLevel.day, isA<BcGanttZoomLevel>());
    });
  });
}
