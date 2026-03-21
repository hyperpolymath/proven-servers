// SPDX-License-Identifier: PMPL-1.0-or-later
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
/// GraphQL protocol bindings for proven-servers.
///
/// Mirrors the Idris2 module `GraphQL.Types` which defines
/// `OperationType`, `TypeKind`, `DirectiveLocation`, and `ErrorCategory`.
///
/// See `protocols/proven-graphql/src/` for the Idris2 definitions.

import 'dart:ffi';

import 'error.dart';
import 'ffi.dart';

// ---------------------------------------------------------------------------
// OperationType (tags 0-2)
// ---------------------------------------------------------------------------

/// GraphQL root operation types.
///
/// Matches `OperationType` in `GraphQL.Types`.
enum GqlOperationType {
  query(0, 'query'),
  mutation(1, 'mutation'),
  subscription(2, 'subscription');

  final int tag;
  final String keyword;
  const GqlOperationType(this.tag, this.keyword);

  static GqlOperationType? fromTag(int tag) {
    if (tag >= 0 && tag < values.length) return values[tag];
    return null;
  }
}

// ---------------------------------------------------------------------------
// TypeKind (__TypeKind introspection, tags 0-7)
// ---------------------------------------------------------------------------

/// GraphQL introspection type kinds.
enum GqlTypeKind {
  scalar(0),
  object(1),
  interface_(2),
  union(3),
  enum_(4),
  inputObject(5),
  list(6),
  nonNull(7);

  final int tag;
  const GqlTypeKind(this.tag);

  static GqlTypeKind? fromTag(int tag) {
    if (tag >= 0 && tag < values.length) return values[tag];
    return null;
  }
}

// ---------------------------------------------------------------------------
// DirectiveLocation (tags 0-12)
// ---------------------------------------------------------------------------

/// GraphQL directive locations (executable and type system).
enum GqlDirectiveLocation {
  // Executable locations
  query(0),
  mutation(1),
  subscription(2),
  field(3),
  fragmentDefinition(4),
  fragmentSpread(5),
  inlineFragment(6),
  // Type system locations
  schema(7),
  scalar(8),
  object(9),
  fieldDefinition(10),
  argumentDefinition(11),
  enumValue(12);

  final int tag;
  const GqlDirectiveLocation(this.tag);

  static GqlDirectiveLocation? fromTag(int tag) {
    if (tag >= 0 && tag < values.length) return values[tag];
    return null;
  }
}

// ---------------------------------------------------------------------------
// ErrorCategory (tags 0-4)
// ---------------------------------------------------------------------------

/// Structured GraphQL error classifications.
enum GqlErrorCategory {
  syntax(0),
  validation(1),
  execution(2),
  internal(3),
  transport(4);

  final int tag;
  const GqlErrorCategory(this.tag);

  static GqlErrorCategory? fromTag(int tag) {
    if (tag >= 0 && tag < values.length) return values[tag];
    return null;
  }
}

// ---------------------------------------------------------------------------
// GraphqlContext — safe wrapper with dispose pattern
// ---------------------------------------------------------------------------

/// A GraphQL context slot in the Zig FFI pool.
///
/// Wraps the `graphql_*` C functions with automatic resource cleanup.
class GraphqlContext {
  final ProvenFfi _ffi;
  final int _slot;
  bool _disposed = false;

  late final _destroy = _ffi.lookupDestroyContext('graphql_destroy_context');
  late final _getOperationType =
      _ffi.lookupGetTag('graphql_get_operation_type');
  late final _validate = _ffi.lookupSend('graphql_validate');

  GraphqlContext._(this._ffi, this._slot);

  /// Create a new GraphQL context.
  ///
  /// Throws [ProvenError] if the pool is exhausted.
  factory GraphqlContext.create(ProvenFfi ffi) {
    final create = ffi.lookupCreateContext('graphql_create_context');
    final slot = ProvenError.checkSlot(create());
    return GraphqlContext._(ffi, slot);
  }

  /// Release the context slot back to the pool.
  void dispose() {
    if (!_disposed) {
      _destroy(_slot);
      _disposed = true;
    }
  }

  void _checkDisposed() {
    if (_disposed) throw const ProvenError('context already disposed');
  }

  /// Get the parsed operation type.
  GqlOperationType? getOperationType() {
    _checkDisposed();
    return GqlOperationType.fromTag(_getOperationType(_slot));
  }

  /// Validate the parsed query against a schema.
  ///
  /// Throws [ProvenError] on validation failure.
  void validate() {
    _checkDisposed();
    ProvenError.checkStatus(_validate(_slot));
  }
}
