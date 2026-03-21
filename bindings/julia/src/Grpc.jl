# SPDX-License-Identifier: PMPL-1.0-or-later
# Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
#
# Julia bindings for the proven-grpc protocol (gRPC server).
#
# Wraps the C-ABI functions from protocols/proven-grpc/ffi/zig/src/grpc.zig
# via ccall into libproven_grpc.so.

module Grpc

using ..ProvenServers: check_status, check_slot, SlotId

export StreamState, GrpcCompression, GrpcStatusCode,
       abi_version, create, destroy, get_stream_state, get_compression,
       get_status_code, set_status, get_stream_id,
       send_headers, local_end_stream, remote_end_stream,
       reset_stream, close_half_local, close_half_remote,
       can_send, can_receive, send_window, recv_window,
       update_send_window, update_recv_window, can_transition

const LIB = "libproven_grpc"

# --------------------------------------------------------------------------
# Enumeration types matching Idris2 ABI
# --------------------------------------------------------------------------

"""gRPC stream states (HTTP/2 stream lifecycle)."""
@enum StreamState::UInt8 begin
    STREAM_IDLE                = 0
    STREAM_RESERVED_LOCAL      = 1
    STREAM_RESERVED_REMOTE     = 2
    STREAM_OPEN                = 3
    STREAM_HALF_CLOSED_LOCAL   = 4
    STREAM_HALF_CLOSED_REMOTE  = 5
    STREAM_CLOSED              = 6
end

"""gRPC compression modes."""
@enum GrpcCompression::UInt8 begin
    COMPRESS_NONE    = 0
    COMPRESS_GZIP    = 1
    COMPRESS_DEFLATE = 2
end

"""gRPC status codes."""
@enum GrpcStatusCode::UInt8 begin
    STATUS_OK                  = 0
    STATUS_CANCELLED           = 1
    STATUS_UNKNOWN             = 2
    STATUS_INVALID_ARGUMENT    = 3
    STATUS_DEADLINE_EXCEEDED   = 4
    STATUS_NOT_FOUND           = 5
    STATUS_ALREADY_EXISTS      = 6
    STATUS_PERMISSION_DENIED   = 7
    STATUS_RESOURCE_EXHAUSTED  = 8
    STATUS_FAILED_PRECONDITION = 9
    STATUS_ABORTED             = 10
    STATUS_OUT_OF_RANGE        = 11
    STATUS_UNIMPLEMENTED       = 12
    STATUS_INTERNAL            = 13
    STATUS_UNAVAILABLE         = 14
    STATUS_DATA_LOSS           = 15
    STATUS_UNAUTHENTICATED     = 16
end

# --------------------------------------------------------------------------
# ccall declarations
# --------------------------------------------------------------------------

"""Return the ABI version of the linked libproven_grpc."""
function abi_version()::UInt32
    ccall((:grpc_abi_version, LIB), UInt32, ())
end

"""
    create(compression::GrpcCompression) -> SlotId

Create a new gRPC stream context. Throws on pool exhaustion.
"""
function create(compression::GrpcCompression)::SlotId
    check_slot(ccall((:grpc_create, LIB), Cint, (UInt8,), UInt8(compression)))
end

"""
    destroy(slot::SlotId)

Release the given gRPC context slot.
"""
function destroy(slot::SlotId)::Nothing
    ccall((:grpc_destroy, LIB), Cvoid, (Cint,), slot)
    nothing
end

"""
    get_stream_state(slot::SlotId) -> StreamState

Get the current HTTP/2 stream state.
"""
function get_stream_state(slot::SlotId)::StreamState
    StreamState(ccall((:grpc_stream_state, LIB), UInt8, (Cint,), slot))
end

"""
    get_compression(slot::SlotId) -> GrpcCompression

Get the compression mode for this stream.
"""
function get_compression(slot::SlotId)::GrpcCompression
    GrpcCompression(ccall((:grpc_compression, LIB), UInt8, (Cint,), slot))
end

"""
    get_status_code(slot::SlotId) -> GrpcStatusCode

Get the gRPC status code.
"""
function get_status_code(slot::SlotId)::GrpcStatusCode
    GrpcStatusCode(ccall((:grpc_status_code, LIB), UInt8, (Cint,), slot))
end

"""
    set_status(slot::SlotId, status::GrpcStatusCode)

Set the gRPC status code. Throws on invalid state.
"""
function set_status(slot::SlotId, status::GrpcStatusCode)::Nothing
    check_status(ccall((:grpc_set_status, LIB), UInt8,
                       (Cint, UInt8), slot, UInt8(status)))
end

"""
    get_stream_id(slot::SlotId) -> UInt32

Get the HTTP/2 stream ID.
"""
function get_stream_id(slot::SlotId)::UInt32
    ccall((:grpc_stream_id, LIB), UInt32, (Cint,), slot)
end

"""
    send_headers(slot::SlotId)

Send HEADERS frame. Throws on invalid state.
"""
function send_headers(slot::SlotId)::Nothing
    check_status(ccall((:grpc_send_headers, LIB), UInt8, (Cint,), slot))
end

"""
    local_end_stream(slot::SlotId)

End the local side of the stream. Throws on invalid state.
"""
function local_end_stream(slot::SlotId)::Nothing
    check_status(ccall((:grpc_local_end_stream, LIB), UInt8, (Cint,), slot))
end

"""
    remote_end_stream(slot::SlotId)

End the remote side of the stream. Throws on invalid state.
"""
function remote_end_stream(slot::SlotId)::Nothing
    check_status(ccall((:grpc_remote_end_stream, LIB), UInt8, (Cint,), slot))
end

"""
    reset_stream(slot::SlotId, status::GrpcStatusCode)

Reset the stream with the given status. Throws on invalid state.
"""
function reset_stream(slot::SlotId, status::GrpcStatusCode)::Nothing
    check_status(ccall((:grpc_reset_stream, LIB), UInt8,
                       (Cint, UInt8), slot, UInt8(status)))
end

"""
    close_half_local(slot::SlotId)

Half-close the local side. Throws on invalid state.
"""
function close_half_local(slot::SlotId)::Nothing
    check_status(ccall((:grpc_close_half_local, LIB), UInt8, (Cint,), slot))
end

"""
    close_half_remote(slot::SlotId)

Half-close the remote side. Throws on invalid state.
"""
function close_half_remote(slot::SlotId)::Nothing
    check_status(ccall((:grpc_close_half_remote, LIB), UInt8, (Cint,), slot))
end

"""
    can_send(slot::SlotId) -> Bool

Check if the stream can send data.
"""
function can_send(slot::SlotId)::Bool
    ccall((:grpc_can_send, LIB), UInt8, (Cint,), slot) == 0x01
end

"""
    can_receive(slot::SlotId) -> Bool

Check if the stream can receive data.
"""
function can_receive(slot::SlotId)::Bool
    ccall((:grpc_can_receive, LIB), UInt8, (Cint,), slot) == 0x01
end

"""
    send_window(slot::SlotId) -> Int32

Get the send flow control window size.
"""
function send_window(slot::SlotId)::Int32
    ccall((:grpc_send_window, LIB), Int32, (Cint,), slot)
end

"""
    recv_window(slot::SlotId) -> Int32

Get the receive flow control window size.
"""
function recv_window(slot::SlotId)::Int32
    ccall((:grpc_recv_window, LIB), Int32, (Cint,), slot)
end

"""
    update_send_window(slot::SlotId, delta::Int32)

Update the send window. Throws on invalid state.
"""
function update_send_window(slot::SlotId, delta::Int32)::Nothing
    check_status(ccall((:grpc_update_send_window, LIB), UInt8,
                       (Cint, Int32), slot, delta))
end

"""
    update_recv_window(slot::SlotId, delta::Int32)

Update the receive window. Throws on invalid state.
"""
function update_recv_window(slot::SlotId, delta::Int32)::Nothing
    check_status(ccall((:grpc_update_recv_window, LIB), UInt8,
                       (Cint, Int32), slot, delta))
end

"""
    can_transition(from::StreamState, to::StreamState) -> Bool

Check whether a stream state transition is valid.
"""
function can_transition(from::StreamState, to::StreamState)::Bool
    ccall((:grpc_can_transition, LIB), UInt8,
          (UInt8, UInt8), UInt8(from), UInt8(to)) == 0x01
end

end # module Grpc
