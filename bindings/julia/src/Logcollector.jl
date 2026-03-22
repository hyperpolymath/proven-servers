# SPDX-License-Identifier: PMPL-1.0-or-later
# Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
#
# Julia bindings for the proven-logcollector protocol (log collector/aggregator).
#
# Wraps the C-ABI functions from protocols/proven-logcollector/ffi/zig/src/logcollector.zig
# via ccall into libproven_logcollector.so.

module Logcollector

using ..ProvenServers: check_status, check_slot, SlotId

export LogLevel, InputFormat, OutputTarget, FilterOp, PipelineStage,
       abi_version, create_context, destroy_context, get_state, can_transition

const LIB = "libproven_logcollector"

# --------------------------------------------------------------------------
# Enumeration types matching Idris2 ABI
# --------------------------------------------------------------------------

"""Log severity levels.  Matches `LogLevel` in `LogcollectorABI.Types`."""
@enum LogLevel::UInt8 begin
    TRACE = 0
    DEBUG = 1
    INFO = 2
    WARN = 3
    ERR = 4
    FATAL = 5
end


"""Log input formats.  Matches `InputFormat` in `LogcollectorABI.Types`."""
@enum InputFormat::UInt8 begin
    JSON = 0
    LOGFMT = 1
    SYSLOG = 2
    CEF = 3
    GELF = 4
    RAW = 5
end


"""Log output targets.  Matches `OutputTarget` in `LogcollectorABI.Types`."""
@enum OutputTarget::UInt8 begin
    FILE = 0
    ELASTICSEARCH = 1
    S3 = 2
    KAFKA = 3
    STDOUT = 4
end


"""Log filter operations.  Matches `FilterOp` in `LogcollectorABI.Types`."""
@enum FilterOp::UInt8 begin
    INCLUDE = 0
    EXCLUDE = 1
    TRANSFORM = 2
    REDACT = 3
    SAMPLE = 4
end


"""Log pipeline stages.  Matches `PipelineStage` in `LogcollectorABI.Types`."""
@enum PipelineStage::UInt8 begin
    INPUT = 0
    PARSE = 1
    FILTER = 2
    PIPELINE_TRANSFORM = 3
    OUTPUT = 4
end

# --------------------------------------------------------------------------
# ccall declarations
# --------------------------------------------------------------------------

"""Return the ABI version of the linked libproven_logcollector."""
function abi_version()::UInt32
    ccall((:logcollector_abi_version, LIB), UInt32, ())
end

"""
    create_context() -> SlotId

Create a new log collector/aggregator context. Throws on pool exhaustion.
"""
function create_context()::SlotId
    check_slot(ccall((:logcollector_create_context, LIB), Cint, ()))
end

"""
    destroy_context(slot::SlotId)

Release the given log collector/aggregator context slot.
"""
function destroy_context(slot::SlotId)::Nothing
    ccall((:logcollector_destroy_context, LIB), Cvoid, (Cint,), slot)
    nothing
end

"""
    get_state(slot::SlotId) -> LogLevel

Get the current log collector/aggregator lifecycle state.
"""
function get_state(slot::SlotId)::LogLevel
    LogLevel(ccall((:logcollector_state, LIB), UInt8, (Cint,), slot))
end

"""
    can_transition(from::LogLevel, to::LogLevel) -> Bool

Check whether a log collector/aggregator state transition is valid.
"""
function can_transition(from::LogLevel, to::LogLevel)::Bool
    ccall((:logcollector_can_transition, LIB), UInt8,
          (UInt8, UInt8), UInt8(from), UInt8(to)) == 0x01
end

end # module Logcollector
