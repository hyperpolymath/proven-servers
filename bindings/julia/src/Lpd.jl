# SPDX-License-Identifier: PMPL-1.0-or-later
# Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
#
# Julia bindings for the proven-lpd protocol (Line Printer Daemon (RFC 1179)).
#
# Wraps the C-ABI functions from protocols/proven-lpd/ffi/zig/src/lpd.zig
# via ccall into libproven_lpd.so.

module Lpd

using ..ProvenServers: check_status, check_slot, SlotId

export CommandCode, SubCommandCode, JobStatus,
       abi_version, create_context, destroy_context, get_state, can_transition

const LIB = "libproven_lpd"

# --------------------------------------------------------------------------
# Enumeration types matching Idris2 ABI
# --------------------------------------------------------------------------

"""LPD command codes (RFC 1179).  Matches `CommandCode` in `LpdABI.Types`."""
@enum CommandCode::UInt8 begin
    PRINT_JOB = 1
    RECEIVE_JOB = 2
    SHORT_QUEUE = 3
    LONG_QUEUE = 4
    REMOVE_JOBS = 5
end


"""LPD sub-command codes.  Matches `SubCommandCode` in `LpdABI.Types`."""
@enum SubCommandCode::UInt8 begin
    ABORT_JOB = 1
    CONTROL_FILE = 2
    DATA_FILE = 3
end


"""Print job status.  Matches `JobStatus` in `LpdABI.Types`."""
@enum JobStatus::UInt8 begin
    PENDING = 0
    PRINTING = 1
    COMPLETE = 2
    FAILED = 3
end

# --------------------------------------------------------------------------
# ccall declarations
# --------------------------------------------------------------------------

"""Return the ABI version of the linked libproven_lpd."""
function abi_version()::UInt32
    ccall((:lpd_abi_version, LIB), UInt32, ())
end

"""
    create_context() -> SlotId

Create a new Line Printer Daemon (RFC 1179) context. Throws on pool exhaustion.
"""
function create_context()::SlotId
    check_slot(ccall((:lpd_create_context, LIB), Cint, ()))
end

"""
    destroy_context(slot::SlotId)

Release the given Line Printer Daemon (RFC 1179) context slot.
"""
function destroy_context(slot::SlotId)::Nothing
    ccall((:lpd_destroy_context, LIB), Cvoid, (Cint,), slot)
    nothing
end

"""
    get_state(slot::SlotId) -> JobStatus

Get the current Line Printer Daemon (RFC 1179) lifecycle state.
"""
function get_state(slot::SlotId)::JobStatus
    JobStatus(ccall((:lpd_state, LIB), UInt8, (Cint,), slot))
end

"""
    can_transition(from::JobStatus, to::JobStatus) -> Bool

Check whether a Line Printer Daemon (RFC 1179) state transition is valid.
"""
function can_transition(from::JobStatus, to::JobStatus)::Bool
    ccall((:lpd_can_transition, LIB), UInt8,
          (UInt8, UInt8), UInt8(from), UInt8(to)) == 0x01
end

end # module Lpd
