/// Permission-Filtered Scope - Dart port of expressions/permission-scope.ts
/// (ADR-018 S7).
///
/// Builds a scope with unauthorized fields stripped BEFORE evaluation. Pure
/// function; never mutates the input. Mirrors buildPermissionFilteredScope.
library bitcode.ui_schema.expressions.permission_scope;

import 'scope.dart';

/// Build a permission-filtered scope. Drops any field the permission snapshot
/// does not allow. Returns a NEW scope; input is never mutated.
ExpressionScope buildPermissionFilteredScope(
  ExpressionScope scope,
) {
  final perm = scope.permissions;
  if (perm.superuser) {
    return scope;
  }

  return ExpressionScope(
    values: _filterMap(scope.values, perm.allowedValueFields),
    meta: scope.meta,
    data: _filterMap(scope.data, perm.allowedDataKeys),
    services: _filterMap(scope.services, perm.allowedServices),
    permissions: perm,
    args: scope.args,
  );
}

/// Returns a new map containing only keys present in [allow] when non-null.
/// When [allow] is null, denies everything (returns empty) unless the map is
/// `meta` (always public - no allow-list applies). Caller decides what to
/// pass.
Map<String, dynamic> _filterMap(
  Map<String, dynamic> map,
  Set<String>? allow,
) {
  if (allow == null) {
    // deny-all for the namespace (no explicit allow-list from host adapter).
    return <String, dynamic>{};
  }
  final result = <String, dynamic>{};
  for (final key in allow) {
    if (map.containsKey(key)) {
      result[key] = map[key];
    }
  }
  return result;
}

/// Result of a path authorization check.
class PathAuthorization {
  final bool authorized;
  final String? reason;

  const PathAuthorization.authorized() : authorized = true, reason = null;
  const PathAuthorization.denied(String this.reason) : authorized = false;
}

/// Check whether a path is authorized against a [PermissionSnapshot].
/// [root] is the scope root, [segment] is the first segment after the root
/// (or null if the path stops at root).
PathAuthorization pathAuthorization({
  required String root,
  String? segment,
  required PermissionSnapshot perm,
}) {
  if (perm.superuser) {
    return const PathAuthorization.authorized();
  }
  switch (root) {
    case 'values':
      if (perm.allowedValueFields == null) {
        return const PathAuthorization.denied('values namespace deny-all');
      }
      if (segment != null && !perm.allowedValueFields!.contains(segment)) {
        return PathAuthorization.denied(
            'values.$segment not in allow-list');
      }
      return const PathAuthorization.authorized();
    case 'data':
      if (perm.allowedDataKeys == null) {
        return const PathAuthorization.denied('data namespace deny-all');
      }
      if (segment != null && !perm.allowedDataKeys!.contains(segment)) {
        return PathAuthorization.denied('data.$segment not in allow-list');
      }
      return const PathAuthorization.authorized();
    case 'services':
      if (perm.allowedServices == null) {
        return const PathAuthorization.denied('services namespace deny-all');
      }
      if (segment != null && !perm.allowedServices!.contains(segment)) {
        return PathAuthorization.denied('services.$segment not in allow-list');
      }
      return const PathAuthorization.authorized();
    case 'meta':
    case 'permissions':
    case 'args':
    case '\$self':
    case '\$parent':
    case '\$root':
      return const PathAuthorization.authorized();
    default:
      return PathAuthorization.denied("unknown root '$root'");
  }
}
