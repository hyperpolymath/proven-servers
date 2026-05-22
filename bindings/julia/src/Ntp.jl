# SPDX-License-Identifier: MPL-2.0
# Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
#
# Julia bindings for the proven-ntp protocol (NTP (RFC 5905) server).
#
# Wraps the C-ABI functions from protocols/proven-ntp/ffi/zig/src/ntp.zig
# via ccall into libproven_ntp.so.

module Ntp

using ..ProvenServers: check_status, check_slot, SlotId

export NTP_PORT,
       LeapIndicator,
       NtpMode,
       ExchangeState,
       ClockDisciplineState,
       KissCode,
       NtpError,
       abi_version,
       create_context,
       destroy_context,
       get_state,
       can_transition

const LIB = "libproven_ntp"

# --------------------------------------------------------------------------
# Constants
# --------------------------------------------------------------------------

"""NTP_PORT: protocol constant."""
const NTP_PORT = UInt16(123)

# --------------------------------------------------------------------------
# Enumeration types matching Idris2 ABI
# --------------------------------------------------------------------------

"""NTP leap second indicator."""
@enum LeapIndicator::UInt8 begin
    LI_NO_WARNING = 0
    LI_LAST_MINUTE_61 = 1
    LI_LAST_MINUTE_59 = 2
    LI_UNSYNCHRONISED = 3
end

"""NTP association mode."""
@enum NtpMode::UInt8 begin
    MODE_RESERVED = 0
    MODE_SYMMETRIC_ACTIVE = 1
    MODE_SYMMETRIC_PASSIVE = 2
    MODE_CLIENT = 3
    MODE_SERVER = 4
    MODE_BROADCAST = 5
    MODE_CONTROL_MESSAGE = 6
    MODE_PRIVATE = 7
end

"""NTP request/response exchange states."""
@enum ExchangeState::UInt8 begin
    STATE_IDLE = 0
    STATE_REQUEST_RECEIVED = 1
    STATE_TIMESTAMP_CALCULATED = 2
    STATE_RESPONSE_SENT = 3
end

"""Clock discipline algorithm states."""
@enum ClockDisciplineState::UInt8 begin
    CLOCK_UNSET = 0
    CLOCK_SPIKE = 1
    CLOCK_FREQ = 2
    CLOCK_SYNC = 3
    CLOCK_PANIC = 4
end

"""NTP Kiss-o'-Death codes."""
@enum KissCode::UInt8 begin
    KISS_DENY = 0
    KISS_RSTR = 1
    KISS_RATE = 2
    KISS_OTHER = 3
end

"""NTP error codes."""
@enum NtpError::UInt8 begin
    ERR_OK = 0
    ERR_INVALID_SLOT = 1
    ERR_NOT_ACTIVE = 2
    ERR_INVALID_PACKET = 3
    ERR_KISS_OF_DEATH = 4
    ERR_STRATUM_TOO_HIGH = 5
end

# --------------------------------------------------------------------------
# ccall declarations
# --------------------------------------------------------------------------

"""Return the ABI version of the linked libproven_ntp."""
function abi_version()::UInt32
    ccall((:ntp_abi_version, LIB), UInt32, ())
end

"""
    create_context() -> SlotId

Create a new Ntp context. Throws on pool exhaustion.
"""
function create_context()::SlotId
    check_slot(ccall((:ntp_create_context, LIB), Cint, ()))
end

"""
    destroy_context(slot::SlotId)

Release the given Ntp context slot.
"""
function destroy_context(slot::SlotId)::Nothing
    ccall((:ntp_destroy_context, LIB), Cvoid, (Cint,), slot)
    nothing
end

"""
    get_state(slot::SlotId) -> ClockDisciplineState

Get the current Ntp lifecycle state.
"""
function get_state(slot::SlotId)::ClockDisciplineState
    ClockDisciplineState(ccall((:ntp_state, LIB), UInt8, (Cint,), slot))
end

"""
    can_transition(from::ClockDisciplineState, to::ClockDisciplineState) -> Bool

Check whether a Ntp state transition is valid.
"""
function can_transition(from::ClockDisciplineState, to::ClockDisciplineState)::Bool
    ccall((:ntp_can_transition, LIB), UInt8,
          (UInt8, UInt8), UInt8(from), UInt8(to)) == 0x01
end

end # module Ntp
