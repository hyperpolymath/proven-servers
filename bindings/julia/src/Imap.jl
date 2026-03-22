# SPDX-License-Identifier: PMPL-1.0-or-later
# Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
#
# Julia bindings for the proven-imap protocol (IMAP (RFC 3501)).
#
# Wraps the C-ABI functions from protocols/proven-imap/ffi/zig/src/imap.zig
# via ccall into libproven_imap.so.

module Imap

using ..ProvenServers: check_status, check_slot, SlotId

export Command, State, Flag,
       abi_version, create_context, destroy_context, get_state, can_transition

const LIB = "libproven_imap"

# --------------------------------------------------------------------------
# Enumeration types matching Idris2 ABI
# --------------------------------------------------------------------------

"""IMAP protocol commands (RFC 3501).  Matches `Command` in `IMAPABI.Types`."""
@enum Command::UInt8 begin
    LOGIN = 0
    LOGOUT = 1
    SELECT = 2
    EXAMINE = 3
    CREATE = 4
    DELETE = 5
    RENAME = 6
    LIST = 7
    FETCH = 8
    STORE = 9
    SEARCH = 10
    COPY = 11
    NOOP = 12
    CAPABILITY = 13
end


"""IMAP session state machine (RFC 3501 Section 3).  Matches `State` in `IMAPABI.Types`.  The valid transitions are formally verified in the Idris2 source via the indexed `ValidStateTransition` type. The Rust equivalent is the [`State::can_transition_to`] validation function."""
@enum State::UInt8 begin
    NOT_AUTHENTICATED = 0
    AUTHENTICATED = 1
    SELECTED = 2
    LOGOUT = 3
end


"""IMAP message flags (RFC 3501 Section 2.3.2).  Matches `Flag` in `IMAPABI.Types`."""
@enum Flag::UInt8 begin
    SEEN = 0
    ANSWERED = 1
    FLAGGED = 2
    DELETED = 3
    DRAFT = 4
    RECENT = 5
end

# --------------------------------------------------------------------------
# ccall declarations
# --------------------------------------------------------------------------

"""Return the ABI version of the linked libproven_imap."""
function abi_version()::UInt32
    ccall((:imap_abi_version, LIB), UInt32, ())
end

"""
    create_context() -> SlotId

Create a new IMAP (RFC 3501) context. Throws on pool exhaustion.
"""
function create_context()::SlotId
    check_slot(ccall((:imap_create_context, LIB), Cint, ()))
end

"""
    destroy_context(slot::SlotId)

Release the given IMAP (RFC 3501) context slot.
"""
function destroy_context(slot::SlotId)::Nothing
    ccall((:imap_destroy_context, LIB), Cvoid, (Cint,), slot)
    nothing
end

"""
    get_state(slot::SlotId) -> State

Get the current IMAP (RFC 3501) lifecycle state.
"""
function get_state(slot::SlotId)::State
    State(ccall((:imap_state, LIB), UInt8, (Cint,), slot))
end

"""
    can_transition(from::State, to::State) -> Bool

Check whether a IMAP (RFC 3501) state transition is valid.
"""
function can_transition(from::State, to::State)::Bool
    ccall((:imap_can_transition, LIB), UInt8,
          (UInt8, UInt8), UInt8(from), UInt8(to)) == 0x01
end

end # module Imap
