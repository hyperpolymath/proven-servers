# SPDX-License-Identifier: MPL-2.0
# Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
#
# Julia bindings for the proven-ptp protocol (PTP (IEEE 1588) server).
#
# Wraps the C-ABI functions from protocols/proven-ptp/ffi/zig/src/ptp.zig
# via ccall into libproven_ptp.so.

module Ptp

using ..ProvenServers: check_status, check_slot, SlotId

export PTP_EVENT_PORT,
       PTP_GENERAL_PORT,
       PtpMessageType,
       ClockClass,
       PtpPortState,
       DelayMechanism,
       abi_version,
       create_context,
       destroy_context,
       get_state,
       can_transition

const LIB = "libproven_ptp"

# --------------------------------------------------------------------------
# Constants
# --------------------------------------------------------------------------

"""PTP_EVENT_PORT: protocol constant."""
const PTP_EVENT_PORT = UInt16(319)

"""PTP_GENERAL_PORT: protocol constant."""
const PTP_GENERAL_PORT = UInt16(320)

# --------------------------------------------------------------------------
# Enumeration types matching Idris2 ABI
# --------------------------------------------------------------------------

"""PTP message types."""
@enum PtpMessageType::UInt8 begin
    MSG_SYNC = 0
    MSG_DELAY_REQ = 1
    MSG_PDELAY_REQ = 2
    MSG_PDELAY_RESP = 3
    MSG_FOLLOW_UP = 4
    MSG_DELAY_RESP = 5
    MSG_PDELAY_RESP_FOLLOW_UP = 6
    MSG_ANNOUNCE = 7
    MSG_SIGNALING = 8
    MSG_MANAGEMENT = 9
end

"""PTP clock classes."""
@enum ClockClass::UInt8 begin
    CLOCK_PRIMARY = 0
    CLOCK_APPLICATION_SPECIFIC = 1
    CLOCK_SLAVE_ONLY = 2
    CLOCK_DEFAULT = 3
end

"""PTP port states."""
@enum PtpPortState::UInt8 begin
    PORT_INITIALIZING = 0
    PORT_FAULTY = 1
    PORT_DISABLED = 2
    PORT_LISTENING = 3
    PORT_PRE_MASTER = 4
    PORT_MASTER = 5
    PORT_PASSIVE = 6
    PORT_UNCALIBRATED = 7
    PORT_SLAVE = 8
end

"""PTP delay mechanisms."""
@enum DelayMechanism::UInt8 begin
    DM_E2E = 0
    DM_P2P = 1
    DM_DISABLED = 2
end

# --------------------------------------------------------------------------
# ccall declarations
# --------------------------------------------------------------------------

"""Return the ABI version of the linked libproven_ptp."""
function abi_version()::UInt32
    ccall((:ptp_abi_version, LIB), UInt32, ())
end

"""
    create_context() -> SlotId

Create a new Ptp context. Throws on pool exhaustion.
"""
function create_context()::SlotId
    check_slot(ccall((:ptp_create_context, LIB), Cint, ()))
end

"""
    destroy_context(slot::SlotId)

Release the given Ptp context slot.
"""
function destroy_context(slot::SlotId)::Nothing
    ccall((:ptp_destroy_context, LIB), Cvoid, (Cint,), slot)
    nothing
end

"""
    get_state(slot::SlotId) -> PtpPortState

Get the current Ptp lifecycle state.
"""
function get_state(slot::SlotId)::PtpPortState
    PtpPortState(ccall((:ptp_state, LIB), UInt8, (Cint,), slot))
end

"""
    can_transition(from::PtpPortState, to::PtpPortState) -> Bool

Check whether a Ptp state transition is valid.
"""
function can_transition(from::PtpPortState, to::PtpPortState)::Bool
    ccall((:ptp_can_transition, LIB), UInt8,
          (UInt8, UInt8), UInt8(from), UInt8(to)) == 0x01
end

end # module Ptp
