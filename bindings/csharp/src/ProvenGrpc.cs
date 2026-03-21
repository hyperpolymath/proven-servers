// SPDX-License-Identifier: PMPL-1.0-or-later
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
// C# P/Invoke bindings for the proven-grpc protocol.
// Wraps the C-ABI functions from protocols/proven-grpc/ffi/zig/src/grpc.zig.

using System;
using System.Runtime.InteropServices;

namespace ProvenServers
{
    /// <summary>gRPC status codes (tags 0-16).</summary>
    public enum GrpcStatusCode : byte
    {
        Ok = 0, Cancelled = 1, Unknown = 2, InvalidArgument = 3,
        DeadlineExceeded = 4, NotFound = 5, AlreadyExists = 6,
        PermissionDenied = 7, ResourceExhausted = 8,
        FailedPrecondition = 9, Aborted = 10, OutOfRange = 11,
        Unimplemented = 12, Internal = 13, Unavailable = 14,
        DataLoss = 15, Unauthenticated = 16
    }

    /// <summary>HTTP/2 stream states (RFC 7540, tags 0-5).</summary>
    public enum StreamState : byte
    {
        Idle = 0, Open = 1, HalfClosedLocal = 2,
        HalfClosedRemote = 3, Closed = 4, Reserved = 5
    }

    /// <summary>gRPC compression algorithms (tags 0-4).</summary>
    public enum GrpcCompression : byte
    {
        Identity = 0, Gzip = 1, Deflate = 2, Snappy = 3, Zstd = 4
    }

    /// <summary>
    /// C# bindings for the proven gRPC protocol.
    /// Models HTTP/2 stream state machine (RFC 7540 Section 5.1).
    /// </summary>
    public static class ProvenGrpc
    {
        private const string Lib = "proven_grpc";

        [DllImport(Lib)] private static extern uint grpc_abi_version();
        [DllImport(Lib)] private static extern int grpc_create(byte compression);
        [DllImport(Lib)] private static extern void grpc_destroy(int slot);
        [DllImport(Lib)] private static extern byte grpc_stream_state(int slot);
        [DllImport(Lib)] private static extern byte grpc_compression(int slot);
        [DllImport(Lib)] private static extern byte grpc_status_code(int slot);
        [DllImport(Lib)] private static extern byte grpc_set_status(int slot, byte status);
        [DllImport(Lib)] private static extern uint grpc_stream_id(int slot);
        [DllImport(Lib)] private static extern byte grpc_send_headers(int slot);
        [DllImport(Lib)] private static extern byte grpc_local_end_stream(int slot);
        [DllImport(Lib)] private static extern byte grpc_remote_end_stream(int slot);
        [DllImport(Lib)] private static extern byte grpc_reset_stream(int slot, byte status);
        [DllImport(Lib)] private static extern byte grpc_close_half_local(int slot);
        [DllImport(Lib)] private static extern byte grpc_close_half_remote(int slot);
        [DllImport(Lib)] private static extern byte grpc_push_promise(int slot);
        [DllImport(Lib)] private static extern byte grpc_reserved_to_half(int slot);
        [DllImport(Lib)] private static extern byte grpc_can_send(int slot);
        [DllImport(Lib)] private static extern byte grpc_can_receive(int slot);
        [DllImport(Lib)] private static extern int grpc_send_window(int slot);
        [DllImport(Lib)] private static extern int grpc_recv_window(int slot);
        [DllImport(Lib)] private static extern byte grpc_update_send_window(int slot, int delta);
        [DllImport(Lib)] private static extern byte grpc_update_recv_window(int slot, int delta);
        [DllImport(Lib)] private static extern byte grpc_can_transition(byte from, byte to);

        public static uint AbiVersion() => grpc_abi_version();

        public static int Create(GrpcCompression compression) =>
            ProvenError.CheckSlot(grpc_create((byte)compression));

        public static void Destroy(int slot) => grpc_destroy(slot);

        public static StreamState? GetStreamState(int slot)
        {
            byte tag = grpc_stream_state(slot);
            return tag <= 5 ? (StreamState)tag : null;
        }

        public static byte Compression(int slot) => grpc_compression(slot);

        public static GrpcStatusCode? StatusCode(int slot)
        {
            byte tag = grpc_status_code(slot);
            return tag <= 16 ? (GrpcStatusCode)tag : null;
        }

        public static void SetStatus(int slot, GrpcStatusCode status) =>
            ProvenError.CheckStatus(grpc_set_status(slot, (byte)status));

        public static uint StreamId(int slot) => grpc_stream_id(slot);

        /// <summary>Send HEADERS frame. Transitions Idle -> Open.</summary>
        public static void SendHeaders(int slot) => ProvenError.CheckStatus(grpc_send_headers(slot));

        /// <summary>Local END_STREAM. Transitions Open -> HalfClosedLocal.</summary>
        public static void LocalEndStream(int slot) => ProvenError.CheckStatus(grpc_local_end_stream(slot));

        /// <summary>Remote END_STREAM. Transitions Open -> HalfClosedRemote.</summary>
        public static void RemoteEndStream(int slot) => ProvenError.CheckStatus(grpc_remote_end_stream(slot));

        /// <summary>RST_STREAM. Transitions to Closed.</summary>
        public static void ResetStream(int slot, GrpcStatusCode status) =>
            ProvenError.CheckStatus(grpc_reset_stream(slot, (byte)status));

        public static void CloseHalfLocal(int slot) => ProvenError.CheckStatus(grpc_close_half_local(slot));
        public static void CloseHalfRemote(int slot) => ProvenError.CheckStatus(grpc_close_half_remote(slot));

        /// <summary>PUSH_PROMISE. Transitions Idle -> Reserved.</summary>
        public static void PushPromise(int slot) => ProvenError.CheckStatus(grpc_push_promise(slot));

        /// <summary>Reserved -> HalfClosedRemote.</summary>
        public static void ReservedToHalf(int slot) => ProvenError.CheckStatus(grpc_reserved_to_half(slot));

        public static bool CanSend(int slot) => grpc_can_send(slot) == 1;
        public static bool CanReceive(int slot) => grpc_can_receive(slot) == 1;
        public static int SendWindow(int slot) => grpc_send_window(slot);
        public static int RecvWindow(int slot) => grpc_recv_window(slot);

        public static void UpdateSendWindow(int slot, int delta) =>
            ProvenError.CheckStatus(grpc_update_send_window(slot, delta));

        public static void UpdateRecvWindow(int slot, int delta) =>
            ProvenError.CheckStatus(grpc_update_recv_window(slot, delta));

        public static bool CanTransition(StreamState from, StreamState to) =>
            grpc_can_transition((byte)from, (byte)to) == 1;
    }
}
