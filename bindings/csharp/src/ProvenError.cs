// SPDX-License-Identifier: MPL-2.0
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
// Exception class for all proven-servers native errors.
// Maps to the Result type in ProvenServers.ABI.Types (Idris2).

using System;

namespace ProvenServers
{
    /// <summary>
    /// Exception thrown by proven-servers P/Invoke wrapper methods when the
    /// native Zig FFI returns an error result.
    /// </summary>
    /// <remarks>
    /// <para>Error codes match the <c>Result</c> type in the Idris2 ABI
    /// (<c>ProvenServers.ABI.Types</c>):</para>
    /// <list type="bullet">
    /// <item><description>0 = Ok (never thrown)</description></item>
    /// <item><description>1 = Error (generic)</description></item>
    /// <item><description>2 = InvalidParam</description></item>
    /// <item><description>3 = OutOfMemory</description></item>
    /// <item><description>4 = NullPointer</description></item>
    /// <item><description>5 = InvalidSlot</description></item>
    /// <item><description>6 = InvalidState</description></item>
    /// <item><description>7 = PoolExhausted</description></item>
    /// <item><description>8 = CapacityExceeded</description></item>
    /// </list>
    /// </remarks>
    public class ProvenError : Exception
    {
        /// <summary>ABI error code tag. 0 means no error; all others indicate failure.</summary>
        public int Code { get; }

        /// <summary>Construct a ProvenError with a message and generic error code.</summary>
        public ProvenError(string message) : base(message)
        {
            Code = 1;
        }

        /// <summary>Construct a ProvenError with a message and specific ABI error code.</summary>
        public ProvenError(string message, int code) : base(message)
        {
            Code = code;
        }

        /// <summary>Convert an ABI status byte to a descriptive string.</summary>
        public static string DescribeStatus(int status) => status switch
        {
            0 => "Ok",
            1 => "Error (generic)",
            2 => "Invalid parameter",
            3 => "Out of memory",
            4 => "Null pointer",
            5 => "Invalid slot",
            6 => "Invalid state",
            7 => "Pool exhausted",
            8 => "Capacity exceeded",
            _ => $"Unknown error (code {status})"
        };

        /// <summary>
        /// Check an ABI status byte and throw if it indicates failure.
        /// </summary>
        /// <param name="status">The ABI status byte returned by a native call.</param>
        /// <exception cref="ProvenError">Thrown when <paramref name="status"/> is non-zero.</exception>
        internal static void CheckStatus(int status)
        {
            if (status != 0)
                throw new ProvenError(DescribeStatus(status), status);
        }

        /// <summary>
        /// Check a slot-creation result (negative means failure).
        /// </summary>
        /// <param name="slot">The slot index returned by a native create call.</param>
        /// <returns>The valid slot index.</returns>
        /// <exception cref="ProvenError">Thrown when <paramref name="slot"/> is negative.</exception>
        internal static int CheckSlot(int slot)
        {
            if (slot < 0)
                throw new ProvenError("Pool exhausted: no free context slots", 7);
            return slot;
        }
    }
}
