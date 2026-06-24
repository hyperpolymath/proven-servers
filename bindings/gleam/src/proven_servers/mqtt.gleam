//// SPDX-License-Identifier: MPL-2.0
//// (MPL-2.0 preferred; MPL-2.0 required for Gleam ecosystem)
//// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
////
//// MQTT protocol types for the proven-servers ABI.
////
//// Mirrors the Idris2 modules:
//// - `MQTT.QoS`         -- quality of service levels (MQTT 3.1.1 Section 4.3)
//// - `MQTT.PacketType`  -- control packet types (MQTT 3.1.1 Section 2.2)

// ===========================================================================
// QoS (MQTT.QoS, MQTT 3.1.1 Section 4.3)
// ===========================================================================

/// MQTT Quality of Service levels.
pub type QoS {
  /// QoS 0: At most once delivery (fire and forget).
  AtMostOnce
  /// QoS 1: At least once delivery (PUBACK required).
  AtLeastOnce
  /// QoS 2: Exactly once delivery (PUBREC/PUBREL/PUBCOMP handshake).
  ExactlyOnce
}

/// Convert a `QoS` to its 2-bit numeric code.
pub fn qos_to_int(qos: QoS) -> Int {
  case qos {
    AtMostOnce -> 0
    AtLeastOnce -> 1
    ExactlyOnce -> 2
  }
}

/// Decode from a 2-bit numeric code.
///
/// Returns `Error(Nil)` for the reserved value 3 and any invalid input.
pub fn qos_from_int(code: Int) -> Result(QoS, Nil) {
  case code {
    0 -> Ok(AtMostOnce)
    1 -> Ok(AtLeastOnce)
    2 -> Ok(ExactlyOnce)
    _ -> Error(Nil)
  }
}

// qos_compare removed: unproven reimplementation. The verified check lives in the
// Idris2/Zig core; calling it needs @external FFI wiring not yet present here.
// Do not reimplement here. See docs/decisions/0003-keep-bindings-thin-abi-wrappers.md

/// Whether this QoS level requires acknowledgement from the receiver.
pub fn qos_requires_ack(qos: QoS) -> Bool {
  case qos {
    AtMostOnce -> False
    _ -> True
  }
}

/// The number of acknowledgement packets needed to complete a QoS flow.
///
/// QoS 0: 0, QoS 1: 1 (PUBACK), QoS 2: 3 (PUBREC, PUBREL, PUBCOMP).
pub fn qos_ack_packet_count(qos: QoS) -> Int {
  case qos {
    AtMostOnce -> 0
    AtLeastOnce -> 1
    ExactlyOnce -> 3
  }
}

// qos_effective and qos_delivery removed: unproven reimplementation (MQTT QoS
// negotiation rules). The verified check lives in the Idris2/Zig core; calling it
// needs @external FFI wiring not yet present here.
// Do not reimplement here. See docs/decisions/0003-keep-bindings-thin-abi-wrappers.md

// ===========================================================================
// SUBACK Return Code (MQTT.QoS.SubAckCode)
// ===========================================================================

/// SUBACK return code for a single topic subscription.
pub type SubAckCode {
  GrantedQoS0
  GrantedQoS1
  GrantedQoS2
  SubFailure
}

/// Convert a `SubAckCode` to its byte value.
pub fn suback_to_int(code: SubAckCode) -> Int {
  case code {
    GrantedQoS0 -> 0x00
    GrantedQoS1 -> 0x01
    GrantedQoS2 -> 0x02
    SubFailure -> 0x80
  }
}

/// Decode from a byte value.
pub fn suback_from_int(byte: Int) -> Result(SubAckCode, Nil) {
  case byte {
    0x00 -> Ok(GrantedQoS0)
    0x01 -> Ok(GrantedQoS1)
    0x02 -> Ok(GrantedQoS2)
    0x80 -> Ok(SubFailure)
    _ -> Error(Nil)
  }
}

/// Convert a granted QoS code to the corresponding QoS level.
///
/// Returns `Error(Nil)` for `SubFailure`.
pub fn suback_to_qos(code: SubAckCode) -> Result(QoS, Nil) {
  case code {
    GrantedQoS0 -> Ok(AtMostOnce)
    GrantedQoS1 -> Ok(AtLeastOnce)
    GrantedQoS2 -> Ok(ExactlyOnce)
    SubFailure -> Error(Nil)
  }
}

// ===========================================================================
// Packet Type (MQTT.PacketType, MQTT 3.1.1 Section 2.2)
// ===========================================================================

/// MQTT control packet types (MQTT 3.1.1 Section 2.2.1).
pub type PacketType {
  MqttConnect
  Connack
  Publish
  Puback
  Pubrec
  Pubrel
  Pubcomp
  Subscribe
  Suback
  Unsubscribe
  Unsuback
  Pingreq
  Pingresp
  Disconnect
  Auth
}

/// Convert a `PacketType` to its 4-bit numeric code.
pub fn packet_type_to_int(pt: PacketType) -> Int {
  case pt {
    MqttConnect -> 1
    Connack -> 2
    Publish -> 3
    Puback -> 4
    Pubrec -> 5
    Pubrel -> 6
    Pubcomp -> 7
    Subscribe -> 8
    Suback -> 9
    Unsubscribe -> 10
    Unsuback -> 11
    Pingreq -> 12
    Pingresp -> 13
    Disconnect -> 14
    Auth -> 15
  }
}

/// Decode from a 4-bit numeric code.
///
/// Returns `Error(Nil)` for the reserved code 0.
pub fn packet_type_from_int(code: Int) -> Result(PacketType, Nil) {
  case code {
    1 -> Ok(MqttConnect)
    2 -> Ok(Connack)
    3 -> Ok(Publish)
    4 -> Ok(Puback)
    5 -> Ok(Pubrec)
    6 -> Ok(Pubrel)
    7 -> Ok(Pubcomp)
    8 -> Ok(Subscribe)
    9 -> Ok(Suback)
    10 -> Ok(Unsubscribe)
    11 -> Ok(Unsuback)
    12 -> Ok(Pingreq)
    13 -> Ok(Pingresp)
    14 -> Ok(Disconnect)
    15 -> Ok(Auth)
    _ -> Error(Nil)
  }
}

// ===========================================================================
// Packet Direction (MQTT.PacketType.PacketDirection)
// ===========================================================================

/// Direction of an MQTT packet.
pub type PacketDirection {
  ClientToServer
  ServerToClient
  Bidirectional
}

/// Determine the allowed direction for a packet type.
pub fn packet_direction(pt: PacketType) -> PacketDirection {
  case pt {
    MqttConnect | Subscribe | Unsubscribe | Pingreq | Disconnect ->
      ClientToServer
    Connack | Suback | Unsuback | Pingresp -> ServerToClient
    Publish | Puback | Pubrec | Pubrel | Pubcomp | Auth -> Bidirectional
  }
}

/// Check whether a packet type requires a packet identifier.
pub fn packet_requires_id(pt: PacketType) -> Bool {
  case pt {
    Puback | Pubrec | Pubrel | Pubcomp | Subscribe | Suback | Unsubscribe
    | Unsuback -> True
    _ -> False
  }
}
