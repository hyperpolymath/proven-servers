// SPDX-License-Identifier: PMPL-1.0-or-later
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
/// Shared error types for proven-servers Dart bindings.
///
/// Maps the Idris2 `Result` type from `src/abi/Types.idr` and the
/// Rust `ProvenError` enum to Dart exceptions.

/// ABI result codes matching the Idris2 `Result` type.
///
/// Integer values match `resultToInt` in `ProvenServers.ABI.Types`.
enum ResultCode {
  /// Operation succeeded (0).
  ok(0),

  /// Generic error (1).
  error(1),

  /// Invalid parameter provided (2).
  invalidParam(2),

  /// Out of memory (3).
  outOfMemory(3),

  /// Null pointer encountered (4).
  nullPointer(4);

  /// The integer value matching the C-ABI tag.
  final int value;

  const ResultCode(this.value);

  /// Decode from a C-ABI integer.
  ///
  /// Returns `null` for unknown codes.
  static ResultCode? fromValue(int value) {
    for (final code in ResultCode.values) {
      if (code.value == value) return code;
    }
    return null;
  }
}

/// Unified exception for all proven-servers FFI operations.
///
/// Maps the slot-based context pool pattern used by every Zig FFI
/// implementation to descriptive Dart exceptions.
class ProvenError implements Exception {
  /// Human-readable description of the error.
  final String message;

  /// The raw FFI return code, if available.
  final int? rawCode;

  const ProvenError(this.message, {this.rawCode});

  /// No free context slots in the 64-slot pool.
  const ProvenError.poolExhausted()
      : message = 'context pool exhausted (64-slot limit)',
        rawCode = -1;

  /// The slot index is invalid or the context is not active.
  const ProvenError.invalidSlot()
      : message = 'invalid or inactive context slot',
        rawCode = null;

  /// Wrong lifecycle state for the requested transition.
  const ProvenError.invalidState()
      : message = 'operation rejected: wrong lifecycle state',
        rawCode = 1;

  /// Parameter value outside the valid ABI tag range.
  const ProvenError.invalidParameter()
      : message = 'parameter value outside valid ABI tag range',
        rawCode = null;

  /// Fixed-size buffer or array capacity exceeded.
  const ProvenError.capacityExceeded()
      : message = 'fixed-size buffer or array capacity exceeded',
        rawCode = null;

  /// Input validation failed.
  const ProvenError.validationFailed()
      : message = 'input validation failed',
        rawCode = 2;

  /// Unknown FFI error with a raw code.
  ProvenError.unknown(int code)
      : message = 'unknown FFI error (code $code)',
        rawCode = code;

  /// Interpret a slot-returning FFI call.
  ///
  /// Returns the slot index for non-negative values.
  /// Throws [ProvenError.poolExhausted] for -1.
  static int checkSlot(int raw) {
    if (raw >= 0) return raw;
    throw const ProvenError.poolExhausted();
  }

  /// Interpret a status-returning FFI call (0 = success).
  ///
  /// Throws the appropriate [ProvenError] for non-zero values.
  static void checkStatus(int raw) {
    switch (raw) {
      case 0:
        return;
      case 1:
        throw const ProvenError.invalidState();
      case 2:
        throw const ProvenError.validationFailed();
      default:
        throw ProvenError.unknown(raw);
    }
  }

  /// Interpret a parameter-status FFI call (0 = success, 1 = invalid).
  static void checkParamStatus(int raw) {
    switch (raw) {
      case 0:
        return;
      case 1:
        throw const ProvenError.invalidParameter();
      default:
        throw ProvenError.unknown(raw);
    }
  }

  @override
  String toString() => 'ProvenError: $message';
}
