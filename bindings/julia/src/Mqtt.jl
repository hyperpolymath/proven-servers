# SPDX-License-Identifier: MPL-2.0
# Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
#
# Julia bindings for the proven-mqtt protocol (MQTT broker).
#
# Wraps the C-ABI functions from protocols/proven-mqtt/ffi/zig/src/mqtt.zig
# via ccall into libproven_mqtt.so.

module Mqtt

using ..ProvenServers: check_status, check_slot, SlotId

export MqttSessionState, QoS, MqttVersion,
       abi_version, create, destroy, get_state, get_version,
       can_publish, can_subscribe, subscription_count,
       subscribe, unsubscribe, publish, puback, pubrec, pubrel, pubcomp,
       mqtt_disconnect, retained_count, can_transition

const LIB = "libproven_mqtt"

# --------------------------------------------------------------------------
# Enumeration types matching Idris2 ABI
# --------------------------------------------------------------------------

"""MQTT broker session states."""
@enum MqttSessionState::UInt8 begin
    STATE_IDLE         = 0
    STATE_CONNECTED    = 1
    STATE_DISCONNECTED = 2
end

"""MQTT Quality of Service levels."""
@enum QoS::UInt8 begin
    QOS_0 = 0
    QOS_1 = 1
    QOS_2 = 2
end

"""MQTT protocol versions."""
@enum MqttVersion::UInt8 begin
    MQTT_3_1_1 = 0
    MQTT_5_0   = 1
end

# --------------------------------------------------------------------------
# ccall declarations
# --------------------------------------------------------------------------

"""Return the ABI version of the linked libproven_mqtt."""
function abi_version()::UInt32
    ccall((:mqtt_abi_version, LIB), UInt32, ())
end

"""
    create(version::MqttVersion, clean_session::Bool, keep_alive::UInt16) -> SlotId

Create a new MQTT session. Throws on pool exhaustion.
"""
function create(version::MqttVersion, clean_session::Bool, keep_alive::UInt16)::SlotId
    clean_flag = clean_session ? UInt8(1) : UInt8(0)
    check_slot(ccall((:mqtt_create, LIB), Cint,
                     (UInt8, UInt8, UInt16),
                     UInt8(version), clean_flag, keep_alive))
end

"""
    destroy(slot::SlotId)

Release the given MQTT context slot.
"""
function destroy(slot::SlotId)::Nothing
    ccall((:mqtt_destroy, LIB), Cvoid, (Cint,), slot)
    nothing
end

"""
    get_state(slot::SlotId) -> MqttSessionState

Get the current MQTT session state.
"""
function get_state(slot::SlotId)::MqttSessionState
    MqttSessionState(ccall((:mqtt_state, LIB), UInt8, (Cint,), slot))
end

"""
    get_version(slot::SlotId) -> MqttVersion

Get the MQTT protocol version for this session.
"""
function get_version(slot::SlotId)::MqttVersion
    MqttVersion(ccall((:mqtt_version, LIB), UInt8, (Cint,), slot))
end

"""
    can_publish(slot::SlotId) -> Bool

Check if the session can publish messages.
"""
function can_publish(slot::SlotId)::Bool
    ccall((:mqtt_can_publish, LIB), UInt8, (Cint,), slot) == 0x01
end

"""
    can_subscribe(slot::SlotId) -> Bool

Check if the session can subscribe to topics.
"""
function can_subscribe(slot::SlotId)::Bool
    ccall((:mqtt_can_subscribe, LIB), UInt8, (Cint,), slot) == 0x01
end

"""
    subscription_count(slot::SlotId) -> UInt32

Get the number of active subscriptions.
"""
function subscription_count(slot::SlotId)::UInt32
    ccall((:mqtt_subscription_count, LIB), UInt32, (Cint,), slot)
end

"""
    subscribe(slot::SlotId, topic::String, qos::QoS)

Subscribe to a topic. Throws on invalid state.
"""
function subscribe(slot::SlotId, topic::String, qos::QoS)::Nothing
    data = Vector{UInt8}(topic)
    check_status(ccall((:mqtt_subscribe, LIB), UInt8,
                       (Cint, Ptr{UInt8}, UInt32, UInt8),
                       slot, data, UInt32(length(data)), UInt8(qos)))
end

"""
    unsubscribe(slot::SlotId, topic::String)

Unsubscribe from a topic. Throws on invalid state.
"""
function unsubscribe(slot::SlotId, topic::String)::Nothing
    data = Vector{UInt8}(topic)
    check_status(ccall((:mqtt_unsubscribe, LIB), UInt8,
                       (Cint, Ptr{UInt8}, UInt32),
                       slot, data, UInt32(length(data))))
end

"""
    publish(slot::SlotId, topic::String, payload::Vector{UInt8},
            qos::QoS, retain::Bool, packet_id::UInt16)

Publish a message. Throws on invalid state.
"""
function publish(slot::SlotId, topic::String, payload::Vector{UInt8},
                 qos::QoS, retain::Bool, packet_id::UInt16)::Nothing
    topic_data = Vector{UInt8}(topic)
    retain_flag = retain ? UInt8(1) : UInt8(0)
    check_status(ccall((:mqtt_publish, LIB), UInt8,
                       (Cint, Ptr{UInt8}, UInt32, Ptr{UInt8}, UInt32,
                        UInt8, UInt8, UInt16),
                       slot, topic_data, UInt32(length(topic_data)),
                       payload, UInt32(length(payload)),
                       UInt8(qos), retain_flag, packet_id))
end

"""
    puback(slot::SlotId, packet_id::UInt16)

Acknowledge QoS 1 publish. Throws on invalid state.
"""
function puback(slot::SlotId, packet_id::UInt16)::Nothing
    check_status(ccall((:mqtt_puback, LIB), UInt8,
                       (Cint, UInt16), slot, packet_id))
end

"""
    pubrec(slot::SlotId, packet_id::UInt16)

QoS 2 publish received. Throws on invalid state.
"""
function pubrec(slot::SlotId, packet_id::UInt16)::Nothing
    check_status(ccall((:mqtt_pubrec, LIB), UInt8,
                       (Cint, UInt16), slot, packet_id))
end

"""
    pubrel(slot::SlotId, packet_id::UInt16)

QoS 2 publish release. Throws on invalid state.
"""
function pubrel(slot::SlotId, packet_id::UInt16)::Nothing
    check_status(ccall((:mqtt_pubrel, LIB), UInt8,
                       (Cint, UInt16), slot, packet_id))
end

"""
    pubcomp(slot::SlotId, packet_id::UInt16)

QoS 2 publish complete. Throws on invalid state.
"""
function pubcomp(slot::SlotId, packet_id::UInt16)::Nothing
    check_status(ccall((:mqtt_pubcomp, LIB), UInt8,
                       (Cint, UInt16), slot, packet_id))
end

"""
    mqtt_disconnect(slot::SlotId)

Disconnect the MQTT session. Throws on invalid state.
"""
function mqtt_disconnect(slot::SlotId)::Nothing
    check_status(ccall((:mqtt_disconnect, LIB), UInt8, (Cint,), slot))
end

"""
    retained_count() -> UInt32

Get the total number of retained messages across all sessions.
"""
function retained_count()::UInt32
    ccall((:mqtt_retained_count, LIB), UInt32, ())
end

"""
    can_transition(from::MqttSessionState, to::MqttSessionState) -> Bool

Check whether an MQTT state transition is valid.
"""
function can_transition(from::MqttSessionState, to::MqttSessionState)::Bool
    ccall((:mqtt_can_transition, LIB), UInt8,
          (UInt8, UInt8), UInt8(from), UInt8(to)) == 0x01
end

end # module Mqtt
