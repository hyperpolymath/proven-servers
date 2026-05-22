// SPDX-License-Identifier: MPL-2.0
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
// Swift bindings for the proven-grpc protocol.
// Wraps the C-ABI functions from protocols/proven-grpc/ffi/zig/src/grpc.zig.
// Enums match Idris2 ABI tags exactly (GRPCABI.Layout).

import Foundation

// MARK: - C interop declarations

@_silgen_name("grpc_abi_version")         private func grpc_abi_version() -> UInt32
@_silgen_name("grpc_create")              private func grpc_create(_ compression: UInt8) -> Int32
@_silgen_name("grpc_destroy")             private func grpc_destroy(_ slot: Int32)
@_silgen_name("grpc_stream_state")        private func grpc_stream_state(_ slot: Int32) -> UInt8
@_silgen_name("grpc_compression")         private func grpc_compression(_ slot: Int32) -> UInt8
@_silgen_name("grpc_status_code")         private func grpc_status_code(_ slot: Int32) -> UInt8
@_silgen_name("grpc_set_status")          private func grpc_set_status(_ slot: Int32, _ status: UInt8) -> UInt8
@_silgen_name("grpc_stream_id")           private func grpc_stream_id(_ slot: Int32) -> UInt32
@_silgen_name("grpc_send_headers")        private func grpc_send_headers(_ slot: Int32) -> UInt8
@_silgen_name("grpc_local_end_stream")    private func grpc_local_end_stream(_ slot: Int32) -> UInt8
@_silgen_name("grpc_remote_end_stream")   private func grpc_remote_end_stream(_ slot: Int32) -> UInt8
@_silgen_name("grpc_reset_stream")        private func grpc_reset_stream(_ slot: Int32, _ status: UInt8) -> UInt8
@_silgen_name("grpc_close_half_local")    private func grpc_close_half_local(_ slot: Int32) -> UInt8
@_silgen_name("grpc_close_half_remote")   private func grpc_close_half_remote(_ slot: Int32) -> UInt8
@_silgen_name("grpc_push_promise")        private func grpc_push_promise(_ slot: Int32) -> UInt8
@_silgen_name("grpc_reserved_to_half")    private func grpc_reserved_to_half(_ slot: Int32) -> UInt8
@_silgen_name("grpc_can_send")            private func grpc_can_send(_ slot: Int32) -> UInt8
@_silgen_name("grpc_can_receive")         private func grpc_can_receive(_ slot: Int32) -> UInt8
@_silgen_name("grpc_send_window")         private func grpc_send_window(_ slot: Int32) -> Int32
@_silgen_name("grpc_recv_window")         private func grpc_recv_window(_ slot: Int32) -> Int32
@_silgen_name("grpc_update_send_window")  private func grpc_update_send_window(_ slot: Int32, _ delta: Int32) -> UInt8
@_silgen_name("grpc_update_recv_window")  private func grpc_update_recv_window(_ slot: Int32, _ delta: Int32) -> UInt8
@_silgen_name("grpc_can_transition")      private func grpc_can_transition(_ from: UInt8, _ to: UInt8) -> UInt8

// MARK: - Enums matching Idris2 ABI tags

/// gRPC status codes per the gRPC specification (tags 0-16).
public enum GrpcStatusCode: Int, CaseIterable, Sendable {
    /// The operation completed successfully.
    case ok = 0
    /// The operation was cancelled.
    case cancelled = 1
    /// Unknown error.
    case unknown = 2
    /// The client specified an invalid argument.
    case invalidArgument = 3
    /// The deadline expired before the operation completed.
    case deadlineExceeded = 4
    /// The requested entity was not found.
    case notFound = 5
    /// The entity already exists.
    case alreadyExists = 6
    /// The caller does not have permission.
    case permissionDenied = 7
    /// Some resource has been exhausted.
    case resourceExhausted = 8
    /// The system is not in a state required for the operation.
    case failedPrecondition = 9
    /// The operation was aborted.
    case aborted = 10
    /// The operation was attempted past the valid range.
    case outOfRange = 11
    /// The operation is not implemented or supported.
    case unimplemented = 12
    /// Internal error.
    case `internal` = 13
    /// The service is currently unavailable.
    case unavailable = 14
    /// Unrecoverable data loss or corruption.
    case dataLoss = 15
    /// The request does not have valid authentication credentials.
    case unauthenticated = 16

    public init?(tag: UInt8) { self.init(rawValue: Int(tag)) }
    public var tag: UInt8 { UInt8(rawValue) }
}

/// HTTP/2 stream states (RFC 7540 Section 5.1, tags 0-5).
public enum GrpcStreamState: Int, CaseIterable, Sendable {
    /// Stream has not been opened.
    case idle = 0
    /// Stream is open in both directions.
    case open = 1
    /// Local side has sent END_STREAM.
    case halfClosedLocal = 2
    /// Remote side has sent END_STREAM.
    case halfClosedRemote = 3
    /// Reserved via PUSH_PROMISE.
    case reserved = 4
    /// Stream is closed (terminal state).
    case closed = 5

    public init?(tag: UInt8) { self.init(rawValue: Int(tag)) }
    public var tag: UInt8 { UInt8(rawValue) }
}

/// gRPC compression algorithms (tags 0-4).
public enum GrpcCompression: Int, CaseIterable, Sendable {
    /// No compression (identity encoding).
    case identity = 0
    /// gzip compression.
    case gzip = 1
    /// DEFLATE compression.
    case deflate = 2
    /// Snappy compression.
    case snappy = 3
    /// Zstandard compression.
    case zstd = 4

    public init?(tag: UInt8) { self.init(rawValue: Int(tag)) }
    public var tag: UInt8 { UInt8(rawValue) }
}

// MARK: - Swift-idiomatic wrapper

/// Swift wrapper for the proven gRPC stream protocol FFI.
///
/// Manages an opaque gRPC stream context slot following the HTTP/2 stream
/// state machine (RFC 7540 Section 5.1). The context is automatically
/// destroyed when this object is deallocated.
public final class ProvenGrpc: @unchecked Sendable {

    private let slot: Int32

    /// Create a new gRPC stream context with the given compression algorithm.
    ///
    /// - Parameter compression: The compression algorithm to use.
    /// - Throws: ``ProvenError/poolExhausted`` if all 64 slots are in use.
    public init(compression: GrpcCompression = .identity) throws {
        self.slot = try ProvenError.checkSlot(grpc_create(compression.tag))
    }

    deinit { grpc_destroy(slot) }

    /// The ABI version.
    public static var abiVersion: UInt32 { grpc_abi_version() }

    /// The current HTTP/2 stream state.
    public var streamState: GrpcStreamState? { GrpcStreamState(tag: grpc_stream_state(slot)) }

    /// The compression algorithm.
    public var compressionTag: UInt8 { grpc_compression(slot) }

    /// The gRPC status code.
    public var statusCode: GrpcStatusCode? { GrpcStatusCode(tag: grpc_status_code(slot)) }

    /// Set the gRPC status code.
    public func setStatus(_ status: GrpcStatusCode) throws {
        try ProvenError.checkStatus(grpc_set_status(slot, status.tag))
    }

    /// The HTTP/2 stream ID.
    public var streamId: UInt32 { grpc_stream_id(slot) }

    /// Send HEADERS frame. Transitions Idle -> Open.
    public func sendHeaders() throws {
        try ProvenError.checkStatus(grpc_send_headers(slot))
    }

    /// Local END_STREAM. Transitions Open -> HalfClosedLocal.
    public func localEndStream() throws {
        try ProvenError.checkStatus(grpc_local_end_stream(slot))
    }

    /// Remote END_STREAM. Transitions Open -> HalfClosedRemote.
    public func remoteEndStream() throws {
        try ProvenError.checkStatus(grpc_remote_end_stream(slot))
    }

    /// RST_STREAM. Transitions Open -> Closed.
    public func resetStream(status: GrpcStatusCode) throws {
        try ProvenError.checkStatus(grpc_reset_stream(slot, status.tag))
    }

    /// Close from HalfClosedLocal -> Closed.
    public func closeHalfLocal() throws {
        try ProvenError.checkStatus(grpc_close_half_local(slot))
    }

    /// Close from HalfClosedRemote -> Closed.
    public func closeHalfRemote() throws {
        try ProvenError.checkStatus(grpc_close_half_remote(slot))
    }

    /// PUSH_PROMISE. Transitions Idle -> Reserved.
    public func pushPromise() throws {
        try ProvenError.checkStatus(grpc_push_promise(slot))
    }

    /// Reserved -> HalfClosedRemote.
    public func reservedToHalf() throws {
        try ProvenError.checkStatus(grpc_reserved_to_half(slot))
    }

    /// Whether DATA frames can be sent from this state.
    public var canSend: Bool { grpc_can_send(slot) == 1 }

    /// Whether DATA frames can be received in this state.
    public var canReceive: Bool { grpc_can_receive(slot) == 1 }

    /// The send-side flow control window.
    public var sendWindow: Int32 { grpc_send_window(slot) }

    /// The receive-side flow control window.
    public var recvWindow: Int32 { grpc_recv_window(slot) }

    /// Update the send-side flow control window.
    public func updateSendWindow(delta: Int32) throws {
        try ProvenError.checkStatus(grpc_update_send_window(slot, delta))
    }

    /// Update the receive-side flow control window.
    public func updateRecvWindow(delta: Int32) throws {
        try ProvenError.checkStatus(grpc_update_recv_window(slot, delta))
    }

    /// Stateless query: check whether a stream state transition is valid.
    public static func canTransition(from: GrpcStreamState, to: GrpcStreamState) -> Bool {
        grpc_can_transition(from.tag, to.tag) == 1
    }
}
