/// Expression Scope & Path Grammar - Dart port of expressions/scope.ts
/// (ADR-018 S5, S7).
///
/// Defines the named evaluation scope, permission snapshot, and deterministic
/// path grammar. Pure data + pure path parsing; no evaluation here.
library bitcode.ui_schema.expressions.scope;

/// The fixed set of scope roots an expression path may start from. Mirrors
/// ExpressionScopeRoot in scope.ts.
const Set<String> expressionScopeRoots = {
  'values',
  'meta',
  'data',
  'services',
  'permissions',
  'args',
};

/// Reserved scope-relative sigils (nested-store parity with ReactiveStore).
/// `$index` is a valid INDEX but NOT a root.
const Set<String> scopeSigils = {'\$self', '\$parent', '\$root', '\$index'};

/// Reserved path roots: canonical scope roots + nested-store sigils
/// ($self/$parent/$root). Used by the validator to reject non-reserved roots.
final Set<String> pathReservedRoots = {
  ...expressionScopeRoots,
  '\$self',
  '\$parent',
  '\$root',
};

/// Permission facts exposed to the evaluator. Built by the permission adapter
/// BEFORE evaluation. Field-level authorization is explicit allow-sets per
/// namespace; an ABSENT set means deny-all for that namespace.
class PermissionSnapshot {
  /// Authorized `values.<field>` top-level field names.
  final Set<String>? allowedValueFields;

  /// Authorized `data.<key>` keys.
  final Set<String>? allowedDataKeys;

  /// Authorized `services.<name>` names.
  final Set<String>? allowedServices;

  /// Permission facts exposed to expressions (e.g. {canApprove: true}).
  final Map<String, bool> facts;

  /// Superuser bypass - host adapters only; never from catalog JSON.
  final bool superuser;

  const PermissionSnapshot({
    this.allowedValueFields,
    this.allowedDataKeys,
    this.allowedServices,
    this.facts = const {},
    this.superuser = false,
  });

  factory PermissionSnapshot.fromJson(Map<String, dynamic> json) {
    Object? setFromJson(dynamic v) {
      if (v == null) return null;
      if (v is List) return v.map((e) => e.toString()).toSet();
      if (v is Set) return v.map((e) => e.toString()).toSet();
      return null;
    }

    final factsRaw = json['facts'];
    final facts = <String, bool>{};
    if (factsRaw is Map) {
      factsRaw.forEach((k, val) {
        facts[k.toString()] = val == true;
      });
    }
    return PermissionSnapshot(
      allowedValueFields: setFromJson(json['allowedValueFields']) as Set<String>?,
      allowedDataKeys: setFromJson(json['allowedDataKeys']) as Set<String>?,
      allowedServices: setFromJson(json['allowedServices']) as Set<String>?,
      facts: facts,
      superuser: json['superuser'] == true,
    );
  }

  Map<String, dynamic> toJson() => {
        if (allowedValueFields != null) 'allowedValueFields': allowedValueFields!.toList(),
        if (allowedDataKeys != null) 'allowedDataKeys': allowedDataKeys!.toList(),
        if (allowedServices != null) 'allowedServices': allowedServices!.toList(),
        'facts': facts,
        if (superuser) 'superuser': true,
      };
}

/// The evaluation scope. All maps are plain maps for JSON-friendliness;
/// `permissions` carries the typed snapshot.
class ExpressionScope {
  final Map<String, dynamic> values;
  final Map<String, dynamic> meta;
  final Map<String, dynamic> data;
  final Map<String, dynamic> services;
  final PermissionSnapshot permissions;
  final Map<String, dynamic> args;

  const ExpressionScope({
    required this.values,
    required this.meta,
    required this.data,
    required this.services,
    required this.permissions,
    this.args = const {},
  });

  factory ExpressionScope.fromJson(Map<String, dynamic> json) {
    final permRaw = json['permissions'];
    final perm = permRaw is Map<String, dynamic>
        ? PermissionSnapshot.fromJson(permRaw)
        : const PermissionSnapshot();
    return ExpressionScope(
      values: Map<String, dynamic>.from(json['values'] as Map? ?? const {}),
      meta: Map<String, dynamic>.from(json['meta'] as Map? ?? const {}),
      data: Map<String, dynamic>.from(json['data'] as Map? ?? const {}),
      services: Map<String, dynamic>.from(json['services'] as Map? ?? const {}),
      permissions: perm,
      args: Map<String, dynamic>.from(json['args'] as Map? ?? const {}),
    );
  }

  Map<String, dynamic> toJson() => {
        'values': values,
        'meta': meta,
        'data': data,
        'services': services,
        'permissions': permissions.toJson(),
        if (args.isNotEmpty) 'args': args,
      };
}

/// A parsed path: root + ordered accessors.
class ParsedPath {
  final String root;
  final List<Object> accessors; // String (property) or int/$sigil (index)

  const ParsedPath({required this.root, required this.accessors});
}

/// Result of path parsing.
class PathParseResult {
  final bool ok;
  final ParsedPath? parsed;
  final String? error;

  const PathParseResult._({required this.ok, this.parsed, this.error});

  const PathParseResult.ok(ParsedPath p) : this._(ok: true, parsed: p);
  const PathParseResult.fail(String message)
      : this._(ok: false, error: message);
}

final RegExp _nameRe = RegExp(r'^[A-Za-z_$][A-Za-z0-9_$]*$');
final RegExp _indexRe = RegExp(r'^(?:[0-9]+|\$index|\$self|\$parent|\$root)$');
final Set<String> _forbiddenSegments = {'__proto__', 'constructor', 'prototype'};

/// Parse a portable expression path. Pure function; does not touch a scope.
/// Mirrors parsePath in scope.ts.
PathParseResult parsePath(String path) {
  if (path.isEmpty) {
    return const PathParseResult.fail('empty path');
  }

  // Split root from the rest. Root ends at first '.' or '['.
  var rootEnd = 0;
  while (rootEnd < path.length &&
      path[rootEnd] != '.' &&
      path[rootEnd] != '[') {
    rootEnd++;
  }
  final rootStr = path.substring(0, rootEnd);

  final isCanonical = expressionScopeRoots.contains(rootStr);
  final isSigil = rootStr == '\$self' || rootStr == '\$parent' || rootStr == '\$root';
  if (!isCanonical && !isSigil) {
    return PathParseResult.fail("unknown scope root '$rootStr'");
  }
  if (rootStr == '\$index') {
    return const PathParseResult.fail("'\$index' is not a valid path root");
  }

  final accessors = <Object>[];
  var i = rootEnd;
  while (i < path.length) {
    final ch = path[i];
    if (ch == '.') {
      i++;
      var j = i;
      while (j < path.length && path[j] != '.' && path[j] != '[') {
        j++;
      }
      final name = path.substring(i, j);
      if (!_nameRe.hasMatch(name)) {
        return PathParseResult.fail("invalid property name '$name'");
      }
      if (_forbiddenSegments.contains(name)) {
        return PathParseResult.fail("forbidden segment '$name'");
      }
      accessors.add(name);
      i = j;
    } else if (ch == '[') {
      i++;
      var j = i;
      while (j < path.length && path[j] != ']') {
        j++;
      }
      if (j >= path.length) {
        return const PathParseResult.fail('unterminated [');
      }
      final inner = path.substring(i, j);
      i = j + 1;
      if (_indexRe.hasMatch(inner) &&
          (inner == '\$index' ||
              inner == '\$self' ||
              inner == '\$parent' ||
              inner == '\$root')) {
        accessors.add(inner);
      } else {
        final num = int.tryParse(inner);
        if (num == null || num < 0) {
          return PathParseResult.fail("invalid index '$inner'");
        }
        accessors.add(num);
      }
    } else {
      return PathParseResult.fail("unexpected character '$ch'");
    }
  }

  return PathParseResult.ok(ParsedPath(root: rootStr, accessors: accessors));
}

/// Quick structural validity check for a path string.
bool isValidPath(String path) => parsePath(path).ok;
