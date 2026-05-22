# SPDX-License-Identifier: MPL-2.0
# Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
#
# Julia bindings for the proven-cli protocol (CLI management interface).
#
# Wraps the C-ABI functions from protocols/proven-cli/ffi/zig/src/cli.zig
# via ccall into libproven_cli.so.

module Cli

using ..ProvenServers: check_status, check_slot, SlotId

export CommandType, OutputFormat, Verbosity, CompletionType, SessionState,
       abi_version, create_context, destroy_context, get_state, can_transition

const LIB = "libproven_cli"

# --------------------------------------------------------------------------
# Enumeration types matching Idris2 ABI
# --------------------------------------------------------------------------

"""CLI command execution types."""
@enum CommandType::UInt8 begin
    INTERACTIVE = 0
    BATCH = 1
    SCRIPT = 2
    PIPE = 3
end


"""CLI output format types."""
@enum OutputFormat::UInt8 begin
    TEXT = 0
    JSON = 1
    TABLE = 2
    CSV = 3
    YAML = 4
end


"""CLI verbosity levels."""
@enum Verbosity::UInt8 begin
    QUIET = 0
    NORMAL = 1
    VERBOSE = 2
    DEBUG = 3
end


"""Shell completion types."""
@enum CompletionType::UInt8 begin
    BASH = 0
    ZSH = 1
    FISH = 2
    POWERSHELL = 3
end


"""CLI session lifecycle states."""
@enum SessionState::UInt8 begin
    IDLE = 0
    RUNNING = 1
    WAITING = 2
    COMPLETE = 3
    ERROR = 4
end

# --------------------------------------------------------------------------
# ccall declarations
# --------------------------------------------------------------------------

"""Return the ABI version of the linked libproven_cli."""
function abi_version()::UInt32
    ccall((:cli_abi_version, LIB), UInt32, ())
end

"""
    create_context() -> SlotId

Create a new CLI management interface context. Throws on pool exhaustion.
"""
function create_context()::SlotId
    check_slot(ccall((:cli_create_context, LIB), Cint, ()))
end

"""
    destroy_context(slot::SlotId)

Release the given CLI management interface context slot.
"""
function destroy_context(slot::SlotId)::Nothing
    ccall((:cli_destroy_context, LIB), Cvoid, (Cint,), slot)
    nothing
end

"""
    get_state(slot::SlotId) -> SessionState

Get the current CLI management interface lifecycle state.
"""
function get_state(slot::SlotId)::SessionState
    SessionState(ccall((:cli_state, LIB), UInt8, (Cint,), slot))
end

"""
    can_transition(from::SessionState, to::SessionState) -> Bool

Check whether a CLI management interface state transition is valid.
"""
function can_transition(from::SessionState, to::SessionState)::Bool
    ccall((:cli_can_transition, LIB), UInt8,
          (UInt8, UInt8), UInt8(from), UInt8(to)) == 0x01
end

end # module Cli
