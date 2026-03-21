// SPDX-License-Identifier: PMPL-1.0-or-later
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
// Shared error class for the proven-servers JavaScript bindings.
//
// Maps the slot-based context pool error pattern used by every Zig FFI
// implementation to JavaScript exceptions. All protocol modules throw
// ProvenError with an appropriate error code.

/**
 * Error codes matching the proven-servers Zig FFI status conventions.
 *
 * Every Zig FFI function returns a u8 status:
 *   0 = success
 *   1 = invalid state (wrong lifecycle phase)
 *   2 = validation failed (bad input)
 * Slot-creating functions return c_int: -1 = pool exhausted.
 *
 * @readonly
 * @enum {number}
 */
export const ErrorCode = Object.freeze({
    POOL_EXHAUSTED: -1,
    INVALID_SLOT: -2,
    INVALID_STATE: 1,
    VALIDATION_FAILED: 2,
    INVALID_PARAMETER: 3,
    CAPACITY_EXCEEDED: 4,
    UNKNOWN: 255,
});

/** @type {Record<number, string>} */
const DEFAULT_MESSAGES = Object.freeze({
    [-1]: "context pool exhausted (64-slot limit)",
    [-2]: "invalid or inactive context slot",
    [1]: "operation rejected: wrong lifecycle state",
    [2]: "input validation failed",
    [3]: "parameter value outside valid ABI tag range",
    [4]: "fixed-size buffer or array capacity exceeded",
    [255]: "unknown FFI error",
});

/**
 * Exception thrown by proven-servers FFI wrapper functions.
 */
export class ProvenError extends Error {
    /**
     * @param {number} code - The ErrorCode describing the failure category.
     * @param {number} [rawCode=0] - The raw integer returned by the FFI function.
     * @param {string} [message] - Optional human-readable message override.
     */
    constructor(code, rawCode = 0, message) {
        const msg = message || DEFAULT_MESSAGES[code] || `unknown FFI error (code ${rawCode})`;
        super(msg);
        this.name = "ProvenError";
        /** @type {number} */
        this.code = code;
        /** @type {number} */
        this.rawCode = rawCode;
    }
}

/**
 * Interpret a slot-returning FFI call (c_int).
 * Returns the slot index for non-negative values.
 *
 * @param {number} raw - The raw c_int returned by the FFI create function.
 * @returns {number} The valid slot index.
 * @throws {ProvenError} If no free slot is available.
 */
export function checkSlot(raw) {
    if (raw >= 0) {
        return raw;
    }
    throw new ProvenError(ErrorCode.POOL_EXHAUSTED, raw);
}

/** @type {Record<number, number>} */
const STATUS_MAP = { 1: ErrorCode.INVALID_STATE, 2: ErrorCode.VALIDATION_FAILED };

/**
 * Interpret a status-returning FFI call (u8).
 * 0 = success, 1 = invalid state, 2 = validation failed.
 *
 * @param {number} raw - The raw u8 status returned by the FFI function.
 * @throws {ProvenError} If the status indicates failure.
 */
export function checkStatus(raw) {
    if (raw === 0) {
        return;
    }
    const code = STATUS_MAP[raw] ?? ErrorCode.UNKNOWN;
    throw new ProvenError(code, raw);
}
