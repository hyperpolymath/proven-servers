# SPDX-License-Identifier: PMPL-1.0-or-later
# Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
#
# Julia bindings for the proven-ws protocol (WebSocket server).
#
# Wraps the C-ABI functions from protocols/proven-ws/ffi/zig/src/websocket.zig
# via ccall into libproven_ws.so. WebSocket opcodes and close codes
# follow RFC 6455.

module Websocket

using ..ProvenServers: check_status, check_slot, SlotId

export WsOpcode, WsCloseCode, WsState,
       abi_version, create_context, destroy_context, get_state,
       open_connection, send_frame, close_connection,
       ping, pong, can_transition

const LIB = "libproven_ws"

# --------------------------------------------------------------------------
# Enumeration types matching Idris2 ABI (RFC 6455)
# --------------------------------------------------------------------------

"""WebSocket frame opcodes (RFC 6455 Section 5.2)."""
@enum WsOpcode::UInt8 begin
    OPCODE_CONTINUATION = 0x0
    OPCODE_TEXT         = 0x1
    OPCODE_BINARY       = 0x2
    OPCODE_CLOSE        = 0x8
    OPCODE_PING         = 0x9
    OPCODE_PONG         = 0xA
end

"""WebSocket close status codes (RFC 6455 Section 7.4.1)."""
@enum WsCloseCode::UInt16 begin
    CLOSE_NORMAL            = 1000
    CLOSE_GOING_AWAY        = 1001
    CLOSE_PROTOCOL_ERROR    = 1002
    CLOSE_UNSUPPORTED_DATA  = 1003
    CLOSE_NO_STATUS         = 1005
    CLOSE_ABNORMAL          = 1006
    CLOSE_INVALID_PAYLOAD   = 1007
    CLOSE_POLICY_VIOLATION  = 1008
    CLOSE_MESSAGE_TOO_BIG   = 1009
    CLOSE_MISSING_EXTENSION = 1010
    CLOSE_INTERNAL_ERROR    = 1011
    CLOSE_TLS_HANDSHAKE     = 1015
end

"""WebSocket connection states."""
@enum WsState::UInt8 begin
    STATE_CONNECTING = 0
    STATE_OPEN       = 1
    STATE_CLOSING    = 2
    STATE_CLOSED     = 3
end

# --------------------------------------------------------------------------
# ccall declarations
# --------------------------------------------------------------------------

"""Return the ABI version of the linked libproven_ws."""
function abi_version()::UInt32
    ccall((:ws_abi_version, LIB), UInt32, ())
end

"""
    create_context() -> SlotId

Create a new WebSocket context. Throws on pool exhaustion.
"""
function create_context()::SlotId
    check_slot(ccall((:ws_create_context, LIB), Cint, ()))
end

"""
    destroy_context(slot::SlotId)

Release the given WebSocket context slot.
"""
function destroy_context(slot::SlotId)::Nothing
    ccall((:ws_destroy_context, LIB), Cvoid, (Cint,), slot)
    nothing
end

"""
    get_state(slot::SlotId) -> WsState

Get the current WebSocket connection state.
"""
function get_state(slot::SlotId)::WsState
    WsState(ccall((:ws_state, LIB), UInt8, (Cint,), slot))
end

"""
    open_connection(slot::SlotId)

Open the WebSocket connection (Connecting -> Open). Throws on invalid state.
"""
function open_connection(slot::SlotId)::Nothing
    check_status(ccall((:ws_open, LIB), UInt8, (Cint,), slot))
end

"""
    send_frame(slot::SlotId, opcode::WsOpcode, data::Vector{UInt8};
               fin::Bool=true)

Send a WebSocket frame. Throws on invalid state.
"""
function send_frame(slot::SlotId, opcode::WsOpcode, data::Vector{UInt8};
                    fin::Bool=true)::Nothing
    fin_flag = fin ? UInt8(1) : UInt8(0)
    check_status(ccall((:ws_send_frame, LIB), UInt8,
                       (Cint, UInt8, Ptr{UInt8}, UInt32, UInt8),
                       slot, UInt8(opcode), data, UInt32(length(data)), fin_flag))
end

"""
    close_connection(slot::SlotId, code::WsCloseCode)

Initiate WebSocket close. Throws on invalid state.
"""
function close_connection(slot::SlotId, code::WsCloseCode)::Nothing
    check_status(ccall((:ws_close, LIB), UInt8,
                       (Cint, UInt16), slot, UInt16(code)))
end

"""
    ping(slot::SlotId)

Send a WebSocket Ping frame. Throws on invalid state.
"""
function ping(slot::SlotId)::Nothing
    check_status(ccall((:ws_ping, LIB), UInt8, (Cint,), slot))
end

"""
    pong(slot::SlotId)

Send a WebSocket Pong frame. Throws on invalid state.
"""
function pong(slot::SlotId)::Nothing
    check_status(ccall((:ws_pong, LIB), UInt8, (Cint,), slot))
end

"""
    can_transition(from::WsState, to::WsState) -> Bool

Check whether a WebSocket state transition is valid.
"""
function can_transition(from::WsState, to::WsState)::Bool
    ccall((:ws_can_transition, LIB), UInt8,
          (UInt8, UInt8), UInt8(from), UInt8(to)) == 0x01
end

end # module Websocket
