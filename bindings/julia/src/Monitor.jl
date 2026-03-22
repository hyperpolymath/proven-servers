# SPDX-License-Identifier: PMPL-1.0-or-later
# Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
#
# Julia bindings for the proven-monitor protocol (Monitoring/uptime server).
#
# Wraps the C-ABI functions from protocols/proven-monitor/ffi/zig/src/monitor.zig
# via ccall into libproven_monitor.so.

module Monitor

using ..ProvenServers: check_status, check_slot, SlotId

export CheckType,
       MonitorStatus,
       AlertChannel,
       Severity,
       CheckState,
       MonitorState,
       abi_version,
       create_context,
       destroy_context,
       get_state,
       can_transition

const LIB = "libproven_monitor"

# --------------------------------------------------------------------------
# Enumeration types matching Idris2 ABI
# --------------------------------------------------------------------------

"""Monitor check types."""
@enum CheckType::UInt8 begin
    CHECK_HTTP = 0
    CHECK_TCP = 1
    CHECK_UDP = 2
    CHECK_ICMP = 3
    CHECK_DNS = 4
    CHECK_CERTIFICATE = 5
    CHECK_DISK = 6
    CHECK_CPU = 7
    CHECK_MEMORY = 8
    CHECK_PROCESS = 9
    CHECK_CUSTOM = 10
end

"""Monitor status values."""
@enum MonitorStatus::UInt8 begin
    STATUS_UP = 0
    STATUS_DOWN = 1
    STATUS_DEGRADED = 2
    STATUS_UNKNOWN = 3
    STATUS_MAINTENANCE = 4
end

"""Alert notification channels."""
@enum AlertChannel::UInt8 begin
    CHANNEL_EMAIL = 0
    CHANNEL_SMS = 1
    CHANNEL_WEBHOOK = 2
    CHANNEL_SLACK = 3
    CHANNEL_PAGERDUTY = 4
end

"""Monitor severity levels."""
@enum Severity::UInt8 begin
    SEV_INFO = 0
    SEV_WARNING = 1
    SEV_ERROR = 2
    SEV_CRITICAL = 3
end

"""Monitor check execution states."""
@enum CheckState::UInt8 begin
    CS_PENDING = 0
    CS_RUNNING = 1
    CS_PASSED = 2
    CS_FAILED = 3
    CS_TIMEOUT = 4
    CS_ERROR = 5
end

"""Monitor service states."""
@enum MonitorState::UInt8 begin
    STATE_IDLE = 0
    STATE_CONFIGURED = 1
    STATE_RUNNING = 2
    STATE_PAUSED = 3
    STATE_ALERTING = 4
    STATE_SHUTDOWN = 5
end

# --------------------------------------------------------------------------
# ccall declarations
# --------------------------------------------------------------------------

"""Return the ABI version of the linked libproven_monitor."""
function abi_version()::UInt32
    ccall((:monitor_abi_version, LIB), UInt32, ())
end

"""
    create_context() -> SlotId

Create a new Monitor context. Throws on pool exhaustion.
"""
function create_context()::SlotId
    check_slot(ccall((:monitor_create_context, LIB), Cint, ()))
end

"""
    destroy_context(slot::SlotId)

Release the given Monitor context slot.
"""
function destroy_context(slot::SlotId)::Nothing
    ccall((:monitor_destroy_context, LIB), Cvoid, (Cint,), slot)
    nothing
end

"""
    get_state(slot::SlotId) -> MonitorState

Get the current Monitor lifecycle state.
"""
function get_state(slot::SlotId)::MonitorState
    MonitorState(ccall((:monitor_state, LIB), UInt8, (Cint,), slot))
end

"""
    can_transition(from::MonitorState, to::MonitorState) -> Bool

Check whether a Monitor state transition is valid.
"""
function can_transition(from::MonitorState, to::MonitorState)::Bool
    ccall((:monitor_can_transition, LIB), UInt8,
          (UInt8, UInt8), UInt8(from), UInt8(to)) == 0x01
end

end # module Monitor
