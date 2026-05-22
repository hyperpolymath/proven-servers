# SPDX-License-Identifier: MPL-2.0
# Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
#
# Julia bindings for the proven-mcp protocol (MCP (Model Context Protocol) server).
#
# Wraps the C-ABI functions from protocols/proven-mcp/ffi/zig/src/mcp.zig
# via ccall into libproven_mcp.so.

module Mcp

using ..ProvenServers: check_status, check_slot, SlotId

export McpMessageType,
       Transport,
       McpContentType,
       McpErrorCode,
       McpCapability,
       SessionState,
       abi_version,
       create_context,
       destroy_context,
       get_state,
       can_transition

const LIB = "libproven_mcp"

# --------------------------------------------------------------------------
# Enumeration types matching Idris2 ABI
# --------------------------------------------------------------------------

"""MCP message types."""
@enum McpMessageType::UInt8 begin
    MSG_INITIALIZE = 0
    MSG_INITIALIZED = 1
    MSG_PING = 2
    MSG_CALL_TOOL = 3
    MSG_TOOL_RESULT = 4
    MSG_LIST_TOOLS = 5
    MSG_LIST_RESOURCES = 6
    MSG_READ_RESOURCE = 7
    MSG_LIST_PROMPTS = 8
    MSG_GET_PROMPT = 9
    MSG_SUBSCRIBE = 10
    MSG_UNSUBSCRIBE = 11
    MSG_NOTIFICATION = 12
    MSG_CANCEL = 13
end

"""MCP transport types."""
@enum Transport::UInt8 begin
    TRANSPORT_STDIO = 0
    TRANSPORT_SSE = 1
    TRANSPORT_WEBSOCKET = 2
    TRANSPORT_STREAMABLE_HTTP = 3
end

"""MCP content types."""
@enum McpContentType::UInt8 begin
    CONTENT_TEXT = 0
    CONTENT_IMAGE = 1
    CONTENT_RESOURCE = 2
    CONTENT_EMBEDDING = 3
end

"""MCP error codes."""
@enum McpErrorCode::UInt8 begin
    ERR_PARSE = 0
    ERR_INVALID_REQUEST = 1
    ERR_METHOD_NOT_FOUND = 2
    ERR_INVALID_PARAMS = 3
    ERR_INTERNAL = 4
    ERR_TIMEOUT = 5
end

"""MCP server capabilities."""
@enum McpCapability::UInt8 begin
    CAP_TOOLS = 0
    CAP_RESOURCES = 1
    CAP_PROMPTS = 2
    CAP_LOGGING = 3
    CAP_SAMPLING = 4
end

"""MCP session lifecycle states."""
@enum SessionState::UInt8 begin
    STATE_IDLE = 0
    STATE_CONNECTING = 1
    STATE_READY = 2
    STATE_PROCESSING = 3
    STATE_DISCONNECTING = 4
end

# --------------------------------------------------------------------------
# ccall declarations
# --------------------------------------------------------------------------

"""Return the ABI version of the linked libproven_mcp."""
function abi_version()::UInt32
    ccall((:mcp_abi_version, LIB), UInt32, ())
end

"""
    create_context() -> SlotId

Create a new Mcp context. Throws on pool exhaustion.
"""
function create_context()::SlotId
    check_slot(ccall((:mcp_create_context, LIB), Cint, ()))
end

"""
    destroy_context(slot::SlotId)

Release the given Mcp context slot.
"""
function destroy_context(slot::SlotId)::Nothing
    ccall((:mcp_destroy_context, LIB), Cvoid, (Cint,), slot)
    nothing
end

"""
    get_state(slot::SlotId) -> SessionState

Get the current Mcp lifecycle state.
"""
function get_state(slot::SlotId)::SessionState
    SessionState(ccall((:mcp_state, LIB), UInt8, (Cint,), slot))
end

"""
    can_transition(from::SessionState, to::SessionState) -> Bool

Check whether a Mcp state transition is valid.
"""
function can_transition(from::SessionState, to::SessionState)::Bool
    ccall((:mcp_can_transition, LIB), UInt8,
          (UInt8, UInt8), UInt8(from), UInt8(to)) == 0x01
end

end # module Mcp
