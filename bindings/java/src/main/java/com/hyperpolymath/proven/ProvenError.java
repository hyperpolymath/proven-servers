// SPDX-License-Identifier: PMPL-1.0-or-later
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
// Exception class for all proven-servers native errors.
// Maps to the Result type in ProvenServers.ABI.Types (Idris2).

package com.hyperpolymath.proven;

/**
 * Exception thrown by proven-servers JNI wrapper methods when the native
 * Zig FFI returns an error result.
 *
 * <p>Error codes match the {@code Result} type in the Idris2 ABI
 * ({@code ProvenServers.ABI.Types}):</p>
 * <ul>
 *   <li>0 = Ok (never thrown)</li>
 *   <li>1 = Error (generic)</li>
 *   <li>2 = InvalidParam</li>
 *   <li>3 = OutOfMemory</li>
 *   <li>4 = NullPointer</li>
 *   <li>5 = InvalidSlot</li>
 *   <li>6 = InvalidState</li>
 *   <li>7 = PoolExhausted</li>
 *   <li>8 = CapacityExceeded</li>
 * </ul>
 *
 * @author Jonathan D.A. Jewell
 */
public class ProvenError extends Exception {

    private static final long serialVersionUID = 1L;

    /** ABI error code tag. 0 means "no error"; all others indicate failure. */
    private final int code;

    /**
     * Construct a ProvenError with a message and no ABI code.
     *
     * @param message human-readable description
     */
    public ProvenError(String message) {
        super(message);
        this.code = 1; // generic error
    }

    /**
     * Construct a ProvenError with a message and ABI error code.
     *
     * @param message human-readable description
     * @param code    ABI error code tag from the native library
     */
    public ProvenError(String message, int code) {
        super(message);
        this.code = code;
    }

    /**
     * Get the ABI error code.
     *
     * @return the numeric error code from the Idris2 {@code Result} type
     */
    public int getCode() {
        return code;
    }

    /**
     * Convert an ABI status byte to a descriptive string.
     *
     * @param status the ABI status byte
     * @return human-readable description
     */
    public static String describeStatus(int status) {
        return switch (status) {
            case 0 -> "Ok";
            case 1 -> "Error (generic)";
            case 2 -> "Invalid parameter";
            case 3 -> "Out of memory";
            case 4 -> "Null pointer";
            case 5 -> "Invalid slot";
            case 6 -> "Invalid state";
            case 7 -> "Pool exhausted";
            case 8 -> "Capacity exceeded";
            default -> "Unknown error (code " + status + ")";
        };
    }

    /**
     * Check an ABI status byte and throw if it indicates failure.
     *
     * @param status the ABI status byte returned by a native call
     * @throws ProvenError if {@code status != 0}
     */
    static void checkStatus(int status) throws ProvenError {
        if (status != 0) {
            throw new ProvenError(describeStatus(status), status);
        }
    }

    /**
     * Check a slot-creation result (negative means failure).
     *
     * @param slot the slot index returned by a native create call
     * @return the valid slot index
     * @throws ProvenError if {@code slot < 0}
     */
    static int checkSlot(int slot) throws ProvenError {
        if (slot < 0) {
            throw new ProvenError("Pool exhausted: no free context slots", 7);
        }
        return slot;
    }
}
