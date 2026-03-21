// SPDX-License-Identifier: PMPL-1.0-or-later
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
/// WebSocket protocol bindings for proven-servers.
///
/// Mirrors the Idris2 modules `WS.Opcode`, `WS.CloseCode`, and `WS.Frame`.
/// All numeric encodings match the wire values from RFC 6455.
///
/// See `protocols/proven-ws/src/` for the Idris2 definitions.

import 'dart:ffi';

import 'error.dart';
import 'ffi.dart';

// ---------------------------------------------------------------------------
// Opcode (WS.Opcode, RFC 6455 Section 5.2)
// ---------------------------------------------------------------------------

/// WebSocket frame opcodes (RFC 6455 Section 11.8).
///
/// Discriminant values are the 4-bit wire values from the spec.
enum WsOpcode {
  /// Continuation frame (follows a fragmented message).
  continuation(0x0),

  /// Text frame (payload is UTF-8 encoded text).
  text(0x1),

  /// Binary frame (payload is arbitrary binary data).
  binary(0x2),

  /// Close frame (initiates or acknowledges connection close).
  close(0x8),

  /// Ping frame (heartbeat request).
  ping(0x9),

  /// Pong frame (heartbeat response).
  pong(0xA);

  /// The 4-bit wire value.
  final int nibble;

  const WsOpcode(this.nibble);

  /// Parse a 4-bit nibble to an opcode.
  ///
  /// Returns `null` for reserved opcodes (0x3-0x7, 0xB-0xF).
  static WsOpcode? fromNibble(int nibble) {
    for (final op in WsOpcode.values) {
      if (op.nibble == nibble) return op;
    }
    return null;
  }

  /// Whether this is a control frame (opcode >= 0x8).
  bool get isControl => nibble >= 0x8;

  /// Whether this is a data frame (opcode < 0x8).
  bool get isData => nibble < 0x8;
}

// ---------------------------------------------------------------------------
// CloseCode (WS.CloseCode, RFC 6455 Section 7.4)
// ---------------------------------------------------------------------------

/// WebSocket close status codes.
///
/// Values are the 16-bit status codes from RFC 6455 Section 7.4.1.
enum WsCloseCode {
  normalClosure(1000),
  goingAway(1001),
  protocolError(1002),
  unsupportedData(1003),
  noStatusReceived(1005),
  abnormalClosure(1006),
  invalidPayload(1007),
  policyViolation(1008),
  messageTooBig(1009),
  mandatoryExt(1010),
  internalError(1011);

  /// The 16-bit status code.
  final int code;

  const WsCloseCode(this.code);

  /// Decode from a 16-bit status code.
  static WsCloseCode? fromCode(int code) {
    for (final cc in WsCloseCode.values) {
      if (cc.code == code) return cc;
    }
    return null;
  }
}

// ---------------------------------------------------------------------------
// WsContext — safe wrapper with dispose pattern
// ---------------------------------------------------------------------------

/// A WebSocket context slot in the Zig FFI pool.
///
/// Wraps the `ws_*` C functions with automatic resource cleanup.
class WsContext {
  final ProvenFfi _ffi;
  final int _slot;
  bool _disposed = false;

  late final _destroy = _ffi.lookupDestroyContext('ws_destroy_context');
  late final _getOpcode = _ffi.lookupGetTag('ws_get_opcode');

  WsContext._(this._ffi, this._slot);

  /// Create a new WebSocket context.
  ///
  /// Throws [ProvenError] if the pool is exhausted.
  factory WsContext.create(ProvenFfi ffi) {
    final create = ffi.lookupCreateContext('ws_create_context');
    final slot = ProvenError.checkSlot(create());
    return WsContext._(ffi, slot);
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

  /// Get the opcode of the last parsed frame.
  WsOpcode? getOpcode() {
    _checkDisposed();
    return WsOpcode.fromNibble(_getOpcode(_slot));
  }
}
