// SPDX-License-Identifier: MPL-2.0
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
// Kotlin/JNI bindings for the proven-grpc protocol.
// Wraps the C-ABI functions from protocols/proven-grpc/ffi/zig/src/grpc.zig.
// Enum classes match Idris2 ABI tags exactly (GRPCABI.Layout).

package com.hyperpolymath.proven

/**
 * Kotlin bindings for the proven gRPC stream protocol.
 *
 * Follows the HTTP/2 stream state machine (RFC 7540 Section 5.1).
 *
 * @author Jonathan D.A. Jewell
 */
public class ProvenGrpc private constructor(private val slot: Int) : AutoCloseable {

    /** gRPC status codes (tags 0-16). */
    public enum class StatusCode(public val tag: Int) {
        OK(0), CANCELLED(1), UNKNOWN(2), INVALID_ARGUMENT(3),
        DEADLINE_EXCEEDED(4), NOT_FOUND(5), ALREADY_EXISTS(6),
        PERMISSION_DENIED(7), RESOURCE_EXHAUSTED(8), FAILED_PRECONDITION(9),
        ABORTED(10), OUT_OF_RANGE(11), UNIMPLEMENTED(12), INTERNAL(13),
        UNAVAILABLE(14), DATA_LOSS(15), UNAUTHENTICATED(16);

        public companion object {
            @JvmStatic public fun fromTag(tag: Int): StatusCode? = entries.find { it.tag == tag }
        }
    }

    /** HTTP/2 stream states (RFC 7540, tags 0-5). */
    public enum class StreamState(public val tag: Int) {
        IDLE(0), OPEN(1), HALF_CLOSED_LOCAL(2), HALF_CLOSED_REMOTE(3),
        RESERVED(4), CLOSED(5);

        public companion object {
            @JvmStatic public fun fromTag(tag: Int): StreamState? = entries.find { it.tag == tag }
        }
    }

    /** gRPC compression algorithms (tags 0-4). */
    public enum class Compression(public val tag: Int) {
        IDENTITY(0), GZIP(1), DEFLATE(2), SNAPPY(3), ZSTD(4);

        public companion object {
            @JvmStatic public fun fromTag(tag: Int): Compression? = entries.find { it.tag == tag }
        }
    }

    private companion object {
        @JvmStatic external fun grpc_abi_version(): Int
        @JvmStatic external fun grpc_create(compression: Int): Int
        @JvmStatic external fun grpc_destroy(slot: Int)
        @JvmStatic external fun grpc_stream_state(slot: Int): Int
        @JvmStatic external fun grpc_compression(slot: Int): Int
        @JvmStatic external fun grpc_status_code(slot: Int): Int
        @JvmStatic external fun grpc_set_status(slot: Int, status: Int): Int
        @JvmStatic external fun grpc_stream_id(slot: Int): Int
        @JvmStatic external fun grpc_send_headers(slot: Int): Int
        @JvmStatic external fun grpc_local_end_stream(slot: Int): Int
        @JvmStatic external fun grpc_remote_end_stream(slot: Int): Int
        @JvmStatic external fun grpc_reset_stream(slot: Int, status: Int): Int
        @JvmStatic external fun grpc_close_half_local(slot: Int): Int
        @JvmStatic external fun grpc_close_half_remote(slot: Int): Int
        @JvmStatic external fun grpc_push_promise(slot: Int): Int
        @JvmStatic external fun grpc_reserved_to_half(slot: Int): Int
        @JvmStatic external fun grpc_can_send(slot: Int): Int
        @JvmStatic external fun grpc_can_receive(slot: Int): Int
        @JvmStatic external fun grpc_send_window(slot: Int): Int
        @JvmStatic external fun grpc_recv_window(slot: Int): Int
        @JvmStatic external fun grpc_update_send_window(slot: Int, delta: Int): Int
        @JvmStatic external fun grpc_update_recv_window(slot: Int, delta: Int): Int
        @JvmStatic external fun grpc_can_transition(from: Int, to: Int): Int
    }

    override fun close() { grpc_destroy(slot) }

    public val streamState: StreamState? get() = StreamState.fromTag(grpc_stream_state(slot))
    public val compressionTag: Int get() = grpc_compression(slot)
    public val statusCode: StatusCode? get() = StatusCode.fromTag(grpc_status_code(slot))
    public val streamId: Int get() = grpc_stream_id(slot)
    public val canSend: Boolean get() = grpc_can_send(slot) == 1
    public val canReceive: Boolean get() = grpc_can_receive(slot) == 1
    public val sendWindow: Int get() = grpc_send_window(slot)
    public val recvWindow: Int get() = grpc_recv_window(slot)

    public fun setStatus(status: StatusCode): Result<Unit> = ProvenError.runCatching { ProvenError.checkStatus(grpc_set_status(slot, status.tag)) }
    public fun sendHeaders(): Result<Unit> = ProvenError.runCatching { ProvenError.checkStatus(grpc_send_headers(slot)) }
    public fun localEndStream(): Result<Unit> = ProvenError.runCatching { ProvenError.checkStatus(grpc_local_end_stream(slot)) }
    public fun remoteEndStream(): Result<Unit> = ProvenError.runCatching { ProvenError.checkStatus(grpc_remote_end_stream(slot)) }
    public fun resetStream(status: StatusCode): Result<Unit> = ProvenError.runCatching { ProvenError.checkStatus(grpc_reset_stream(slot, status.tag)) }
    public fun closeHalfLocal(): Result<Unit> = ProvenError.runCatching { ProvenError.checkStatus(grpc_close_half_local(slot)) }
    public fun closeHalfRemote(): Result<Unit> = ProvenError.runCatching { ProvenError.checkStatus(grpc_close_half_remote(slot)) }
    public fun pushPromise(): Result<Unit> = ProvenError.runCatching { ProvenError.checkStatus(grpc_push_promise(slot)) }
    public fun reservedToHalf(): Result<Unit> = ProvenError.runCatching { ProvenError.checkStatus(grpc_reserved_to_half(slot)) }
    public fun updateSendWindow(delta: Int): Result<Unit> = ProvenError.runCatching { ProvenError.checkStatus(grpc_update_send_window(slot, delta)) }
    public fun updateRecvWindow(delta: Int): Result<Unit> = ProvenError.runCatching { ProvenError.checkStatus(grpc_update_recv_window(slot, delta)) }

    public companion object {
        @JvmStatic public fun create(compression: Compression = Compression.IDENTITY): Result<ProvenGrpc> = ProvenError.runCatching {
            ProvenGrpc(ProvenError.checkSlot(grpc_create(compression.tag)))
        }

        @JvmStatic public fun abiVersion(): Int = grpc_abi_version()

        @JvmStatic public fun canTransition(from: StreamState, to: StreamState): Boolean =
            grpc_can_transition(from.tag, to.tag) == 1
    }
}
