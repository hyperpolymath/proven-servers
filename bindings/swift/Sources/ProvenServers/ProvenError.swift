// SPDX-License-Identifier: PMPL-1.0-or-later
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
// Unified error type for all proven-servers Swift FFI wrappers.
// Maps the slot-based context pool pattern (c_int return values) and
// status byte codes to descriptive Swift errors.

import Foundation

/// Errors thrown by proven-servers FFI wrapper methods.
///
/// All protocol FFI implementations use the same slot-based context pool
/// pattern. This enum maps the C-ABI return conventions to Swift:
/// - Slot creation: negative return = ``poolExhausted``
/// - Status bytes: 0 = success, non-zero = specific error
public enum ProvenError: Error, Equatable, Sendable {

    /// No free context slots available in the pool (64-slot limit).
    case poolExhausted

    /// The slot index is invalid or the context is not active.
    case invalidSlot

    /// The operation was rejected because the context is in the wrong
    /// lifecycle state for the requested transition.
    case invalidState

    /// A parameter value is outside the valid ABI tag range.
    case invalidParameter

    /// The operation would exceed a fixed-size buffer or array limit.
    case capacityExceeded

    /// A path or name failed validation (e.g. traversal attack, too long).
    case validationFailed

    /// The FFI returned an unexpected or undocumented error code.
    case unknown(code: Int32)
}

// MARK: - Internal helpers

extension ProvenError {

    /// Interpret a slot-returning FFI call (returns `Int32`).
    ///
    /// Returns the valid slot index or throws ``poolExhausted`` for negative values.
    /// - Parameter raw: The raw `c_int` return value from the FFI.
    /// - Returns: The valid slot index.
    /// - Throws: ``ProvenError/poolExhausted`` if `raw < 0`.
    static func checkSlot(_ raw: Int32) throws -> Int32 {
        guard raw >= 0 else {
            throw ProvenError.poolExhausted
        }
        return raw
    }

    /// Interpret a status-returning FFI call (0 = success).
    ///
    /// - Parameter raw: The raw `UInt8` status byte from the FFI.
    /// - Throws: The appropriate ``ProvenError`` variant for non-zero values.
    static func checkStatus(_ raw: UInt8) throws {
        switch raw {
        case 0:
            return
        case 1:
            throw ProvenError.invalidState
        case 2:
            throw ProvenError.validationFailed
        default:
            throw ProvenError.unknown(code: Int32(raw))
        }
    }

    /// Interpret a parameter-status FFI call (0 = success, 1 = invalid param).
    ///
    /// - Parameter raw: The raw `UInt8` status byte from the FFI.
    /// - Throws: ``ProvenError/invalidParameter`` for code 1.
    static func checkParamStatus(_ raw: UInt8) throws {
        switch raw {
        case 0:
            return
        case 1:
            throw ProvenError.invalidParameter
        default:
            throw ProvenError.unknown(code: Int32(raw))
        }
    }
}

// MARK: - LocalizedError conformance

extension ProvenError: LocalizedError {

    public var errorDescription: String? {
        switch self {
        case .poolExhausted:
            return "Context pool exhausted (64-slot limit)"
        case .invalidSlot:
            return "Invalid or inactive context slot"
        case .invalidState:
            return "Operation rejected: wrong lifecycle state"
        case .invalidParameter:
            return "Parameter value outside valid ABI tag range"
        case .capacityExceeded:
            return "Fixed-size buffer or array capacity exceeded"
        case .validationFailed:
            return "Input validation failed"
        case .unknown(let code):
            return "Unknown FFI error (code \(code))"
        }
    }
}
