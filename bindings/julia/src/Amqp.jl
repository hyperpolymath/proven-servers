# SPDX-License-Identifier: PMPL-1.0-or-later
# Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
#
# Julia bindings for the proven-amqp protocol (AMQP 0-9-1 message broker).
#
# Wraps the C-ABI functions from protocols/proven-amqp/ffi/zig/src/amqp.zig
# via ccall into libproven_amqp.so.

module Amqp

using ..ProvenServers: check_status, check_slot, SlotId

export FrameType, MethodClass, ExchangeType, DeliveryMode, ErrorSeverity, ConnectionState, ChannelState, BrokerState,
       abi_version, create_context, destroy_context, get_state, can_transition

const LIB = "libproven_amqp"

# --------------------------------------------------------------------------
# Enumeration types matching Idris2 ABI
# --------------------------------------------------------------------------

"""AMQP 0-9-1 frame types.  Matches `FrameType` in `AmqpABI.Types`."""
@enum FrameType::UInt8 begin
    METHOD = 0
    HEADER = 1
    BODY = 2
    HEARTBEAT = 3
end


"""AMQP 0-9-1 method classes.  Matches `MethodClass` in `AmqpABI.Types`."""
@enum MethodClass::UInt8 begin
    CONNECTION = 0
    CHANNEL = 1
    EXCHANGE = 2
    QUEUE = 3
    BASIC = 4
    TX = 5
    CONFIRM = 6
end


"""AMQP exchange routing types.  Matches `ExchangeType` in `AmqpABI.Types`."""
@enum ExchangeType::UInt8 begin
    DIRECT = 0
    FANOUT = 1
    TOPIC = 2
    HEADERS = 3
end


"""AMQP message delivery/persistence mode.  Matches `DeliveryMode` in `AmqpABI.Types`."""
@enum DeliveryMode::UInt8 begin
    NON_PERSISTENT = 0
    PERSISTENT = 1
end


"""AMQP error severity levels.  Matches `ErrorSeverity` in `AmqpABI.Types`."""
@enum ErrorSeverity::UInt8 begin
    CHANNEL_LEVEL = 0
    CONNECTION_LEVEL = 1
end


"""AMQP connection state machine.  Matches `ConnectionState` in `AmqpABI.Types`."""
@enum ConnectionState::UInt8 begin
    IDLE = 0
    NEGOTIATING = 1
    TUNING_OK = 2
    OPEN = 3
    CLOSING = 4
end


"""AMQP channel state machine.  Matches `ChannelState` in `AmqpABI.Types`."""
@enum ChannelState::UInt8 begin
    CLOSED = 0
    OPENING = 1
    CH_OPEN = 2
    CH_CLOSING = 3
end


"""AMQP broker lifecycle state machine.  Matches `BrokerState` in `AmqpABI.Types`."""
@enum BrokerState::UInt8 begin
    IDLE = 0
    CONNECTED = 1
    CHANNEL_OPEN = 2
    CONSUMING = 3
    PUBLISHING = 4
    DISCONNECTING = 5
end

# --------------------------------------------------------------------------
# ccall declarations
# --------------------------------------------------------------------------

"""Return the ABI version of the linked libproven_amqp."""
function abi_version()::UInt32
    ccall((:amqp_abi_version, LIB), UInt32, ())
end

"""
    create_context() -> SlotId

Create a new AMQP 0-9-1 message broker context. Throws on pool exhaustion.
"""
function create_context()::SlotId
    check_slot(ccall((:amqp_create_context, LIB), Cint, ()))
end

"""
    destroy_context(slot::SlotId)

Release the given AMQP 0-9-1 message broker context slot.
"""
function destroy_context(slot::SlotId)::Nothing
    ccall((:amqp_destroy_context, LIB), Cvoid, (Cint,), slot)
    nothing
end

"""
    get_state(slot::SlotId) -> BrokerState

Get the current AMQP 0-9-1 message broker lifecycle state.
"""
function get_state(slot::SlotId)::BrokerState
    BrokerState(ccall((:amqp_state, LIB), UInt8, (Cint,), slot))
end

"""
    can_transition(from::BrokerState, to::BrokerState) -> Bool

Check whether a AMQP 0-9-1 message broker state transition is valid.
"""
function can_transition(from::BrokerState, to::BrokerState)::Bool
    ccall((:amqp_can_transition, LIB), UInt8,
          (UInt8, UInt8), UInt8(from), UInt8(to)) == 0x01
end

end # module Amqp
