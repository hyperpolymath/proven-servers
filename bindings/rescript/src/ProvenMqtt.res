// SPDX-License-Identifier: PMPL-1.0-or-later
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
// MQTT protocol types for the proven-servers ABI.
//
// Mirrors the Idris2 modules:
// - MQTT.QoS        -- quality of service levels (MQTT 3.1.1 Section 4.3)
// - MQTT.PacketType -- control packet types (MQTT 3.1.1 Section 2.2)
//
// All numeric encodings match the MQTT 3.1.1 specification wire values.

// ===========================================================================
// QoS (MQTT.QoS, MQTT 3.1.1 Section 4.3)
// ===========================================================================

/// MQTT Quality of Service levels.
/// Matches the QoS type in MQTT.QoS.
/// Discriminant values are the 2-bit QoS wire codes.
type qos =
  | @as(0) AtMostOnce
  | @as(1) AtLeastOnce
  | @as(2) ExactlyOnce

/// Decode from a 2-bit numeric code.
/// Returns None for the reserved value 3 and any invalid input.
/// Matches qosFromCode in MQTT.QoS.
let qosFromCode = (code: int): option<qos> =>
  switch code {
  | 0 => Some(AtMostOnce)
  | 1 => Some(AtLeastOnce)
  | 2 => Some(ExactlyOnce)
  | _ => None
  }

/// Convert to the 2-bit numeric code.
/// Matches qosCode in MQTT.QoS.
let qosToCode = (q: qos): int =>
  switch q {
  | AtMostOnce => 0
  | AtLeastOnce => 1
  | ExactlyOnce => 2
  }

/// Whether this QoS level requires acknowledgement from the receiver.
/// Matches requiresAck in MQTT.QoS.
let qosRequiresAck = (q: qos): bool =>
  switch q {
  | AtMostOnce => false
  | AtLeastOnce | ExactlyOnce => true
  }

/// The number of acknowledgement packets needed to complete a QoS flow.
/// QoS 0: 0, QoS 1: 1 (PUBACK), QoS 2: 3 (PUBREC/PUBREL/PUBCOMP).
/// Matches ackPacketCount in MQTT.QoS.
let qosAckPacketCount = (q: qos): int =>
  switch q {
  | AtMostOnce => 0
  | AtLeastOnce => 1
  | ExactlyOnce => 3
  }

/// Determine the effective QoS for a subscription.
/// MQTT 3.1.1 Section 3.8.4: effective QoS = min(requested, granted).
/// Matches effectiveQoS in MQTT.QoS.
let qosEffective = (requested: qos, granted: qos): qos => {
  let reqCode = qosToCode(requested)
  let grantCode = qosToCode(granted)
  let minCode = if reqCode < grantCode {
    reqCode
  } else {
    grantCode
  }
  // Safe: minCode is always 0, 1, or 2 when inputs are valid
  switch qosFromCode(minCode) {
  | Some(q) => q
  | None => AtMostOnce
  }
}

/// Determine the QoS for delivering a message to a subscriber.
/// MQTT 3.1.1 Section 3.3.1.2: delivery QoS = min(message, subscription max).
/// Matches deliveryQoS in MQTT.QoS.
let qosDelivery = (messageQos: qos, subscriptionMax: qos): qos =>
  qosEffective(messageQos, subscriptionMax)

/// Display string for QoS level.
let qosAsStr = (q: qos): string =>
  switch q {
  | AtMostOnce => "QoS 0 (At Most Once)"
  | AtLeastOnce => "QoS 1 (At Least Once)"
  | ExactlyOnce => "QoS 2 (Exactly Once)"
  }

// ===========================================================================
// SUBACK Return Code (MQTT.QoS.SubAckCode)
// ===========================================================================

/// SUBACK return code for a single topic subscription.
/// MQTT 3.1.1 Section 3.9.3.
/// Matches SubAckCode in MQTT.QoS.
type subAckCode =
  | @as(0x00) GrantedQoS0
  | @as(0x01) GrantedQoS1
  | @as(0x02) GrantedQoS2
  | @as(0x80) Failure

/// Decode from a byte value.
/// Matches subAckCodeFromByte in MQTT.QoS.
let subAckCodeFromByte = (byte: int): option<subAckCode> =>
  switch byte {
  | 0x00 => Some(GrantedQoS0)
  | 0x01 => Some(GrantedQoS1)
  | 0x02 => Some(GrantedQoS2)
  | 0x80 => Some(Failure)
  | _ => None
  }

/// Convert to the byte value.
/// Matches subAckCodeToByte in MQTT.QoS.
let subAckCodeToByte = (code: subAckCode): int =>
  switch code {
  | GrantedQoS0 => 0x00
  | GrantedQoS1 => 0x01
  | GrantedQoS2 => 0x02
  | Failure => 0x80
  }

/// Convert a granted QoS code to the corresponding QoS level.
/// Returns None for Failure.
/// Matches subAckToQoS in MQTT.QoS.
let subAckCodeToQos = (code: subAckCode): option<qos> =>
  switch code {
  | GrantedQoS0 => Some(AtMostOnce)
  | GrantedQoS1 => Some(AtLeastOnce)
  | GrantedQoS2 => Some(ExactlyOnce)
  | Failure => None
  }

// ===========================================================================
// Packet Type (MQTT.PacketType, MQTT 3.1.1 Section 2.2)
// ===========================================================================

/// MQTT control packet types (MQTT 3.1.1 Section 2.2.1).
/// Each variant corresponds to a 4-bit type code in the fixed header.
/// Matches the PacketType type in MQTT.PacketType.
type packetType =
  | @as(1) Connect
  | @as(2) Connack
  | @as(3) Publish
  | @as(4) Puback
  | @as(5) Pubrec
  | @as(6) Pubrel
  | @as(7) Pubcomp
  | @as(8) Subscribe
  | @as(9) Suback
  | @as(10) Unsubscribe
  | @as(11) Unsuback
  | @as(12) Pingreq
  | @as(13) Pingresp
  | @as(14) Disconnect
  | @as(15) Auth

/// Decode from a 4-bit numeric code.
/// Returns None for the reserved code 0.
/// Matches packetTypeFromCode in MQTT.PacketType.
let packetTypeFromCode = (code: int): option<packetType> =>
  switch code {
  | 1 => Some(Connect)
  | 2 => Some(Connack)
  | 3 => Some(Publish)
  | 4 => Some(Puback)
  | 5 => Some(Pubrec)
  | 6 => Some(Pubrel)
  | 7 => Some(Pubcomp)
  | 8 => Some(Subscribe)
  | 9 => Some(Suback)
  | 10 => Some(Unsubscribe)
  | 11 => Some(Unsuback)
  | 12 => Some(Pingreq)
  | 13 => Some(Pingresp)
  | 14 => Some(Disconnect)
  | 15 => Some(Auth)
  | _ => None
  }

/// Convert to the 4-bit numeric code.
/// Matches packetTypeCode in MQTT.PacketType.
let packetTypeToCode = (pt: packetType): int =>
  switch pt {
  | Connect => 1
  | Connack => 2
  | Publish => 3
  | Puback => 4
  | Pubrec => 5
  | Pubrel => 6
  | Pubcomp => 7
  | Subscribe => 8
  | Suback => 9
  | Unsubscribe => 10
  | Unsuback => 11
  | Pingreq => 12
  | Pingresp => 13
  | Disconnect => 14
  | Auth => 15
  }

// ===========================================================================
// Packet Direction (MQTT.PacketType.PacketDirection)
// ===========================================================================

/// Direction of an MQTT packet.
/// Matches PacketDirection in MQTT.PacketType.
type packetDirection =
  | @as(0) ClientToServer
  | @as(1) ServerToClient
  | @as(2) Bidirectional

/// Determine the allowed direction for a packet type.
/// Matches packetDirection in MQTT.PacketType.
let packetTypeDirection = (pt: packetType): packetDirection =>
  switch pt {
  | Connect | Subscribe | Unsubscribe | Pingreq | Disconnect => ClientToServer
  | Connack | Suback | Unsuback | Pingresp => ServerToClient
  | Publish | Puback | Pubrec | Pubrel | Pubcomp | Auth => Bidirectional
  }

/// Check whether this packet type requires a packet identifier.
/// Matches requiresPacketId in MQTT.PacketType.
let packetTypeRequiresPacketId = (pt: packetType): bool =>
  switch pt {
  | Puback | Pubrec | Pubrel | Pubcomp | Subscribe | Suback | Unsubscribe | Unsuback => true
  | Connect | Connack | Publish | Pingreq | Pingresp | Disconnect | Auth => false
  }

/// Display string for packet direction.
let packetDirectionAsStr = (d: packetDirection): string =>
  switch d {
  | ClientToServer => "Client->Server"
  | ServerToClient => "Server->Client"
  | Bidirectional => "Bidirectional"
  }
