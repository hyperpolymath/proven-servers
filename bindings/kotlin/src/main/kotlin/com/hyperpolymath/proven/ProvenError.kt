// SPDX-License-Identifier: MPL-2.0
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
// Unified error type for all proven-servers Kotlin/JNI wrappers.
// Maps the slot-based context pool pattern to Kotlin Result types.

package com.hyperpolymath.proven

/**
 * Exception thrown by proven-servers JNI wrapper methods when the native
 * Zig FFI returns an error result.
 *
 * Error codes match the `Result` type in the Idris2 ABI
 * (`ProvenServers.ABI.Types`):
 * - 0 = Ok (never thrown)
 * - 1 = Error (generic) / InvalidState
 * - 2 = ValidationFailed / InvalidParam
 * - 3 = OutOfMemory
 * - 4 = NullPointer
 * - 5 = InvalidSlot
 * - 6 = InvalidState
 * - 7 = PoolExhausted
 * - 8 = CapacityExceeded
 *
 * @property code The ABI error code tag.
 * @author Jonathan D.A. Jewell
 */
public class ProvenError(
    message: String,
    public val code: Int = 1
) : Exception(message) {

    public companion object {

        /**
         * Convert an ABI status byte to a descriptive string.
         *
         * @param status The ABI status byte.
         * @return Human-readable description.
         */
        @JvmStatic
        public fun describeStatus(status: Int): String = when (status) {
            0 -> "Ok"
            1 -> "Invalid state"
            2 -> "Validation failed"
            3 -> "Out of memory"
            4 -> "Null pointer"
            5 -> "Invalid slot"
            6 -> "Invalid state"
            7 -> "Pool exhausted"
            8 -> "Capacity exceeded"
            else -> "Unknown error (code $status)"
        }

        /**
         * Check an ABI status byte and throw if it indicates failure.
         *
         * @param status The ABI status byte returned by a native call.
         * @throws ProvenError if `status != 0`.
         */
        @JvmStatic
        @Throws(ProvenError::class)
        internal fun checkStatus(status: Int) {
            if (status != 0) {
                throw ProvenError(describeStatus(status), status)
            }
        }

        /**
         * Check a slot-creation result (negative means failure).
         *
         * @param slot The slot index returned by a native create call.
         * @return The valid slot index.
         * @throws ProvenError if `slot < 0`.
         */
        @JvmStatic
        @Throws(ProvenError::class)
        internal fun checkSlot(slot: Int): Int {
            if (slot < 0) {
                throw ProvenError("Pool exhausted: no free context slots", 7)
            }
            return slot
        }

        /**
         * Wrap a throwing operation into a Kotlin [Result].
         *
         * @param block The operation that may throw [ProvenError].
         * @return [Result.success] with the value, or [Result.failure] with the error.
         */
        internal inline fun <T> runCatching(block: () -> T): Result<T> =
            kotlin.runCatching(block)
    }
}
