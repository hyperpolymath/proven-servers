// SPDX-License-Identifier: PMPL-1.0-or-later
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
/// gRPC/HTTP2 protocol bindings for proven-servers.
///
/// Mirrors the Idris2 modules `GRPC.Types`, `GRPCABI.Layout`, and
/// `GRPCABI.Transitions`. Status codes match the gRPC specification.
/// Stream states model RFC 7540 Section 5.1.
///
/// See `protocols/proven-grpc/src/` for the Idris2 definitions.

import 'dart:ffi';

import 'error.dart';
import 'ffi.dart';

// ---------------------------------------------------------------------------
// StatusCode (GRPC.Types.StatusCode, tags 0-16)
// ---------------------------------------------------------------------------

/// gRPC status codes per the gRPC specification.
///
/// Matches the `StatusCode` type in `GRPC.Types`.
enum GrpcStatusCode {
  ok(0),
  cancelled(1),
  unknown(2),
  invalidArgument(3),
  deadlineExceeded(4),
  notFound(5),
  alreadyExists(6),
  permissionDenied(7),
  resourceExhausted(8),
  failedPrecondition(9),
  aborted(10),
  outOfRange(11),
  unimplemented(12),
  internal(13),
  unavailable(14),
  dataLoss(15),
  unauthenticated(16);

  final int code;
  const GrpcStatusCode(this.code);

  static GrpcStatusCode? fromCode(int code) {
    if (code >= 0 && code < values.length) return values[code];
    return null;
  }
}

// ---------------------------------------------------------------------------
// StreamType (GRPC.Types.StreamType, tags 0-3)
// ---------------------------------------------------------------------------

/// gRPC stream types.
enum GrpcStreamType {
  unary(0),
  serverStreaming(1),
  clientStreaming(2),
  bidiStreaming(3);

  final int tag;
  const GrpcStreamType(this.tag);

  static GrpcStreamType? fromTag(int tag) {
    if (tag >= 0 && tag < values.length) return values[tag];
    return null;
  }
}

// ---------------------------------------------------------------------------
// StreamState (GRPCABI.Layout, RFC 7540 Section 5.1, tags 0-6)
// ---------------------------------------------------------------------------

/// HTTP/2 stream states.
///
/// Models the stream lifecycle from RFC 7540 Section 5.1.
enum GrpcStreamState {
  idle(0),
  reservedLocal(1),
  reservedRemote(2),
  open(3),
  halfClosedLocal(4),
  halfClosedRemote(5),
  closed(6);

  final int tag;
  const GrpcStreamState(this.tag);

  static GrpcStreamState? fromTag(int tag) {
    if (tag >= 0 && tag < values.length) return values[tag];
    return null;
  }
}

// ---------------------------------------------------------------------------
// Compression (GRPC.Types, tags 0-3)
// ---------------------------------------------------------------------------

/// gRPC compression algorithms.
enum GrpcCompression {
  none(0),
  gzip(1),
  deflate(2),
  snappy(3);

  final int tag;
  const GrpcCompression(this.tag);

  static GrpcCompression? fromTag(int tag) {
    if (tag >= 0 && tag < values.length) return values[tag];
    return null;
  }
}

// ---------------------------------------------------------------------------
// GrpcContext — safe wrapper with dispose pattern
// ---------------------------------------------------------------------------

/// A gRPC context slot in the Zig FFI pool.
///
/// Wraps the `grpc_*` C functions with automatic resource cleanup.
class GrpcContext {
  final ProvenFfi _ffi;
  final int _slot;
  bool _disposed = false;

  late final _destroy = _ffi.lookupDestroyContext('grpc_destroy_context');
  late final _getStreamState = _ffi.lookupGetTag('grpc_get_stream_state');
  late final _setStatus = _ffi.lookupSetTag('grpc_set_status');

  GrpcContext._(this._ffi, this._slot);

  /// Create a new gRPC context.
  ///
  /// Throws [ProvenError] if the pool is exhausted.
  factory GrpcContext.create(ProvenFfi ffi) {
    final create = ffi.lookupCreateContext('grpc_create_context');
    final slot = ProvenError.checkSlot(create());
    return GrpcContext._(ffi, slot);
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

  /// Get the current HTTP/2 stream state.
  GrpcStreamState? getStreamState() {
    _checkDisposed();
    return GrpcStreamState.fromTag(_getStreamState(_slot));
  }

  /// Set the gRPC response status.
  ///
  /// Throws [ProvenError] on invalid parameter.
  void setStatus(GrpcStatusCode status) {
    _checkDisposed();
    ProvenError.checkParamStatus(_setStatus(_slot, status.code));
  }
}
