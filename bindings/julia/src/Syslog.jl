# SPDX-License-Identifier: PMPL-1.0-or-later
# Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
#
# Julia bindings for the proven-syslog protocol (Syslog (RFC 5424) server).
#
# Wraps the C-ABI functions from protocols/proven-syslog/ffi/zig/src/syslog.zig
# via ccall into libproven_syslog.so.

module Syslog

using ..ProvenServers: check_status, check_slot, SlotId

export SYSLOG_UDP_PORT,
       SYSLOG_TLS_PORT,
       SyslogSeverity,
       Facility,
       SyslogTransport,
       abi_version,
       create_context,
       destroy_context,
       get_state,
       can_transition

const LIB = "libproven_syslog"

# --------------------------------------------------------------------------
# Constants
# --------------------------------------------------------------------------

"""SYSLOG_UDP_PORT: protocol constant."""
const SYSLOG_UDP_PORT = UInt16(514)

"""SYSLOG_TLS_PORT: protocol constant."""
const SYSLOG_TLS_PORT = UInt16(6514)

# --------------------------------------------------------------------------
# Enumeration types matching Idris2 ABI
# --------------------------------------------------------------------------

"""Syslog severity levels."""
@enum SyslogSeverity::UInt8 begin
    SEV_EMERGENCY = 0
    SEV_ALERT = 1
    SEV_CRITICAL = 2
    SEV_ERROR = 3
    SEV_WARNING = 4
    SEV_NOTICE = 5
    SEV_INFORMATIONAL = 6
    SEV_DEBUG = 7
end

"""Syslog facility codes."""
@enum Facility::UInt8 begin
    FAC_KERN = 0
    FAC_USER = 1
    FAC_MAIL = 2
    FAC_DAEMON = 3
    FAC_AUTH = 4
    FAC_SYSLOG = 5
    FAC_LPR = 6
    FAC_NEWS = 7
    FAC_UUCP = 8
    FAC_CRON = 9
    FAC_AUTHPRIV = 10
    FAC_FTP = 11
    FAC_NTP = 12
    FAC_AUDIT = 13
    FAC_ALERT = 14
    FAC_CLOCK = 15
    FAC_LOCAL0 = 16
    FAC_LOCAL1 = 17
    FAC_LOCAL2 = 18
    FAC_LOCAL3 = 19
    FAC_LOCAL4 = 20
    FAC_LOCAL5 = 21
    FAC_LOCAL6 = 22
    FAC_LOCAL7 = 23
end

"""Syslog transport protocols."""
@enum SyslogTransport::UInt8 begin
    TRANSPORT_UDP_514 = 0
    TRANSPORT_TCP_514 = 1
    TRANSPORT_TLS_6514 = 2
end

# --------------------------------------------------------------------------
# ccall declarations
# --------------------------------------------------------------------------

"""Return the ABI version of the linked libproven_syslog."""
function abi_version()::UInt32
    ccall((:syslog_abi_version, LIB), UInt32, ())
end

"""
    create_context() -> SlotId

Create a new Syslog context. Throws on pool exhaustion.
"""
function create_context()::SlotId
    check_slot(ccall((:syslog_create_context, LIB), Cint, ()))
end

"""
    destroy_context(slot::SlotId)

Release the given Syslog context slot.
"""
function destroy_context(slot::SlotId)::Nothing
    ccall((:syslog_destroy_context, LIB), Cvoid, (Cint,), slot)
    nothing
end

"""
    get_state(slot::SlotId) -> SyslogTransport

Get the current Syslog lifecycle state.
"""
function get_state(slot::SlotId)::SyslogTransport
    SyslogTransport(ccall((:syslog_state, LIB), UInt8, (Cint,), slot))
end

"""
    can_transition(from::SyslogTransport, to::SyslogTransport) -> Bool

Check whether a Syslog state transition is valid.
"""
function can_transition(from::SyslogTransport, to::SyslogTransport)::Bool
    ccall((:syslog_can_transition, LIB), UInt8,
          (UInt8, UInt8), UInt8(from), UInt8(to)) == 0x01
end

end # module Syslog
