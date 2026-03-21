// SPDX-License-Identifier: PMPL-1.0-or-later
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
//! MQTT protocol types for the proven-servers ABI.
//!
//! Mirrors the Idris2 modules:
//! - `MQTT.QoS`        — quality of service levels (MQTT 3.1.1 Section 4.3)
//! - `MQTT.PacketType`  — control packet types (MQTT 3.1.1 Section 2.2)
//!
//! All numeric encodings match the MQTT 3.1.1 specification wire values.

use std::fmt;

// ===========================================================================
// QoS (MQTT.QoS, MQTT 3.1.1 Section 4.3)
// ===========================================================================

/// MQTT Quality of Service levels.
///
/// Matches the `QoS` type in `MQTT.QoS`.
/// Discriminant values are the 2-bit QoS wire codes.
#[derive(Debug, Clone, Copy, PartialEq, Eq, Hash, PartialOrd, Ord)]
#[repr(u8)]
pub enum QoS {
    /// QoS 0: At most once delivery (fire and forget).
    AtMostOnce = 0,
    /// QoS 1: At least once delivery (PUBACK required).
    AtLeastOnce = 1,
    /// QoS 2: Exactly once delivery (PUBREC/PUBREL/PUBCOMP handshake).
    ExactlyOnce = 2,
}

impl QoS {
    /// Decode from a 2-bit numeric code.
    ///
    /// Returns `None` for the reserved value 3 and any invalid input.
    /// Matches `qosFromCode` in `MQTT.QoS`.
    pub fn from_code(code: u8) -> Option<Self> {
        match code {
            0 => Some(Self::AtMostOnce),
            1 => Some(Self::AtLeastOnce),
            2 => Some(Self::ExactlyOnce),
            _ => None,
        }
    }

    /// Convert to the 2-bit numeric code.
    ///
    /// Matches `qosCode` in `MQTT.QoS`.
    pub fn to_code(self) -> u8 {
        self as u8
    }

    /// Whether this QoS level requires acknowledgement from the receiver.
    ///
    /// QoS 0 is fire-and-forget; QoS 1 and 2 require ack flows.
    /// Matches `requiresAck` in `MQTT.QoS`.
    pub fn requires_ack(self) -> bool {
        !matches!(self, Self::AtMostOnce)
    }

    /// The number of acknowledgement packets needed to complete a QoS flow.
    ///
    /// QoS 0: 0 (fire and forget)
    /// QoS 1: 1 (PUBACK)
    /// QoS 2: 3 (PUBREC, PUBREL, PUBCOMP)
    /// Matches `ackPacketCount` in `MQTT.QoS`.
    pub fn ack_packet_count(self) -> u8 {
        match self {
            Self::AtMostOnce => 0,
            Self::AtLeastOnce => 1,
            Self::ExactlyOnce => 3,
        }
    }

    /// Determine the effective QoS for a subscription.
    ///
    /// MQTT 3.1.1 Section 3.8.4: the effective QoS is the minimum of
    /// the requested and granted levels.
    /// Matches `effectiveQoS` in `MQTT.QoS`.
    pub fn effective(requested: QoS, granted: QoS) -> QoS {
        std::cmp::min(requested, granted)
    }

    /// Determine the QoS for delivering a message to a subscriber.
    ///
    /// MQTT 3.1.1 Section 3.3.1.2: the delivery QoS is the minimum of
    /// the message QoS and the subscription's maximum QoS.
    /// Matches `deliveryQoS` in `MQTT.QoS`.
    pub fn delivery(message_qos: QoS, subscription_max: QoS) -> QoS {
        std::cmp::min(message_qos, subscription_max)
    }
}

impl fmt::Display for QoS {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        match self {
            Self::AtMostOnce => write!(f, "QoS 0 (At Most Once)"),
            Self::AtLeastOnce => write!(f, "QoS 1 (At Least Once)"),
            Self::ExactlyOnce => write!(f, "QoS 2 (Exactly Once)"),
        }
    }
}

// ===========================================================================
// SUBACK Return Code (MQTT.QoS.SubAckCode)
// ===========================================================================

/// SUBACK return code for a single topic subscription.
///
/// MQTT 3.1.1 Section 3.9.3.
/// Matches `SubAckCode` in `MQTT.QoS`.
#[derive(Debug, Clone, Copy, PartialEq, Eq, Hash)]
#[repr(u8)]
pub enum SubAckCode {
    /// Subscription accepted with maximum QoS 0.
    GrantedQoS0 = 0x00,
    /// Subscription accepted with maximum QoS 1.
    GrantedQoS1 = 0x01,
    /// Subscription accepted with maximum QoS 2.
    GrantedQoS2 = 0x02,
    /// Subscription rejected by the server.
    Failure = 0x80,
}

impl SubAckCode {
    /// Decode from a byte value.
    ///
    /// Matches `subAckCodeFromByte` in `MQTT.QoS`.
    pub fn from_byte(byte: u8) -> Option<Self> {
        match byte {
            0x00 => Some(Self::GrantedQoS0),
            0x01 => Some(Self::GrantedQoS1),
            0x02 => Some(Self::GrantedQoS2),
            0x80 => Some(Self::Failure),
            _ => None,
        }
    }

    /// Convert to the byte value.
    ///
    /// Matches `subAckCodeToByte` in `MQTT.QoS`.
    pub fn to_byte(self) -> u8 {
        self as u8
    }

    /// Convert a granted QoS code to the corresponding QoS level.
    ///
    /// Returns `None` for `Failure`.
    /// Matches `subAckToQoS` in `MQTT.QoS`.
    pub fn to_qos(self) -> Option<QoS> {
        match self {
            Self::GrantedQoS0 => Some(QoS::AtMostOnce),
            Self::GrantedQoS1 => Some(QoS::AtLeastOnce),
            Self::GrantedQoS2 => Some(QoS::ExactlyOnce),
            Self::Failure => None,
        }
    }
}

impl fmt::Display for SubAckCode {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        match self {
            Self::GrantedQoS0 => write!(f, "Granted QoS 0"),
            Self::GrantedQoS1 => write!(f, "Granted QoS 1"),
            Self::GrantedQoS2 => write!(f, "Granted QoS 2"),
            Self::Failure => write!(f, "Subscription Failure"),
        }
    }
}

// ===========================================================================
// Packet Type (MQTT.PacketType, MQTT 3.1.1 Section 2.2)
// ===========================================================================

/// MQTT control packet types (MQTT 3.1.1 Section 2.2.1).
///
/// Each variant corresponds to a 4-bit type code in the fixed header.
/// Matches the `PacketType` type in `MQTT.PacketType`.
#[derive(Debug, Clone, Copy, PartialEq, Eq, Hash)]
#[repr(u8)]
pub enum PacketType {
    /// Client request to connect to server (type 1).
    Connect = 1,
    /// Server acknowledgement of connection (type 2).
    Connack = 2,
    /// Publish message (type 3).
    Publish = 3,
    /// Publish acknowledgement for QoS 1 (type 4).
    Puback = 4,
    /// Publish received for QoS 2, step 1 (type 5).
    Pubrec = 5,
    /// Publish release for QoS 2, step 2 (type 6).
    Pubrel = 6,
    /// Publish complete for QoS 2, step 3 (type 7).
    Pubcomp = 7,
    /// Client subscribe request (type 8).
    Subscribe = 8,
    /// Server subscribe acknowledgement (type 9).
    Suback = 9,
    /// Client unsubscribe request (type 10).
    Unsubscribe = 10,
    /// Server unsubscribe acknowledgement (type 11).
    Unsuback = 11,
    /// Client ping request (type 12).
    Pingreq = 12,
    /// Server ping response (type 13).
    Pingresp = 13,
    /// Client disconnect notification (type 14).
    Disconnect = 14,
    /// Authentication exchange (MQTTv5, type 15).
    Auth = 15,
}

impl PacketType {
    /// Decode from a 4-bit numeric code.
    ///
    /// Returns `None` for the reserved code 0.
    /// Matches `packetTypeFromCode` in `MQTT.PacketType`.
    pub fn from_code(code: u8) -> Option<Self> {
        match code {
            1 => Some(Self::Connect),
            2 => Some(Self::Connack),
            3 => Some(Self::Publish),
            4 => Some(Self::Puback),
            5 => Some(Self::Pubrec),
            6 => Some(Self::Pubrel),
            7 => Some(Self::Pubcomp),
            8 => Some(Self::Subscribe),
            9 => Some(Self::Suback),
            10 => Some(Self::Unsubscribe),
            11 => Some(Self::Unsuback),
            12 => Some(Self::Pingreq),
            13 => Some(Self::Pingresp),
            14 => Some(Self::Disconnect),
            15 => Some(Self::Auth),
            _ => None,
        }
    }

    /// Convert to the 4-bit numeric code.
    ///
    /// Matches `packetTypeCode` in `MQTT.PacketType`.
    pub fn to_code(self) -> u8 {
        self as u8
    }

    /// Determine the allowed direction for this packet type.
    ///
    /// Matches `packetDirection` in `MQTT.PacketType`.
    pub fn direction(self) -> PacketDirection {
        match self {
            Self::Connect | Self::Subscribe | Self::Unsubscribe | Self::Pingreq | Self::Disconnect => {
                PacketDirection::ClientToServer
            }
            Self::Connack | Self::Suback | Self::Unsuback | Self::Pingresp => {
                PacketDirection::ServerToClient
            }
            Self::Publish
            | Self::Puback
            | Self::Pubrec
            | Self::Pubrel
            | Self::Pubcomp
            | Self::Auth => PacketDirection::Bidirectional,
        }
    }

    /// Check whether this packet type requires a packet identifier.
    ///
    /// Matches `requiresPacketId` in `MQTT.PacketType`.
    pub fn requires_packet_id(self) -> bool {
        matches!(
            self,
            Self::Puback
                | Self::Pubrec
                | Self::Pubrel
                | Self::Pubcomp
                | Self::Subscribe
                | Self::Suback
                | Self::Unsubscribe
                | Self::Unsuback
        )
    }
}

impl fmt::Display for PacketType {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        fmt::Debug::fmt(self, f)
    }
}

// ===========================================================================
// Packet Direction (MQTT.PacketType.PacketDirection)
// ===========================================================================

/// Direction of an MQTT packet: client-to-server, server-to-client, or both.
///
/// Matches `PacketDirection` in `MQTT.PacketType`.
#[derive(Debug, Clone, Copy, PartialEq, Eq, Hash)]
#[repr(u8)]
pub enum PacketDirection {
    /// Sent from client to server only.
    ClientToServer = 0,
    /// Sent from server to client only.
    ServerToClient = 1,
    /// Can be sent in either direction.
    Bidirectional = 2,
}

impl fmt::Display for PacketDirection {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        match self {
            Self::ClientToServer => write!(f, "Client->Server"),
            Self::ServerToClient => write!(f, "Server->Client"),
            Self::Bidirectional => write!(f, "Bidirectional"),
        }
    }
}

// ===========================================================================
// Tests
// ===========================================================================

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn qos_roundtrip() {
        for code in 0u8..=2 {
            let qos = QoS::from_code(code).expect("valid code");
            assert_eq!(qos.to_code(), code);
        }
    }

    #[test]
    fn qos_reserved_rejected() {
        assert!(QoS::from_code(3).is_none());
    }

    #[test]
    fn qos_ordering() {
        assert!(QoS::AtMostOnce < QoS::AtLeastOnce);
        assert!(QoS::AtLeastOnce < QoS::ExactlyOnce);
    }

    #[test]
    fn qos_ack_requirements() {
        assert!(!QoS::AtMostOnce.requires_ack());
        assert!(QoS::AtLeastOnce.requires_ack());
        assert!(QoS::ExactlyOnce.requires_ack());

        assert_eq!(QoS::AtMostOnce.ack_packet_count(), 0);
        assert_eq!(QoS::AtLeastOnce.ack_packet_count(), 1);
        assert_eq!(QoS::ExactlyOnce.ack_packet_count(), 3);
    }

    #[test]
    fn qos_negotiation() {
        // Effective QoS is the minimum of requested and granted.
        assert_eq!(
            QoS::effective(QoS::ExactlyOnce, QoS::AtLeastOnce),
            QoS::AtLeastOnce
        );
        assert_eq!(
            QoS::effective(QoS::AtMostOnce, QoS::ExactlyOnce),
            QoS::AtMostOnce
        );
        assert_eq!(
            QoS::delivery(QoS::ExactlyOnce, QoS::AtMostOnce),
            QoS::AtMostOnce
        );
    }

    #[test]
    fn suback_code_roundtrip() {
        let codes = [(0x00, SubAckCode::GrantedQoS0), (0x01, SubAckCode::GrantedQoS1),
                     (0x02, SubAckCode::GrantedQoS2), (0x80, SubAckCode::Failure)];
        for (byte, expected) in codes {
            let decoded = SubAckCode::from_byte(byte).expect("valid byte");
            assert_eq!(decoded, expected);
            assert_eq!(decoded.to_byte(), byte);
        }
    }

    #[test]
    fn suback_to_qos() {
        assert_eq!(SubAckCode::GrantedQoS0.to_qos(), Some(QoS::AtMostOnce));
        assert_eq!(SubAckCode::GrantedQoS1.to_qos(), Some(QoS::AtLeastOnce));
        assert_eq!(SubAckCode::GrantedQoS2.to_qos(), Some(QoS::ExactlyOnce));
        assert_eq!(SubAckCode::Failure.to_qos(), None);
    }

    #[test]
    fn packet_type_roundtrip() {
        for code in 1u8..=15 {
            let pt = PacketType::from_code(code).expect("valid code");
            assert_eq!(pt.to_code(), code);
        }
    }

    #[test]
    fn packet_type_reserved_rejected() {
        assert!(PacketType::from_code(0).is_none());
        assert!(PacketType::from_code(16).is_none());
    }

    #[test]
    fn packet_type_direction() {
        assert_eq!(PacketType::Connect.direction(), PacketDirection::ClientToServer);
        assert_eq!(PacketType::Connack.direction(), PacketDirection::ServerToClient);
        assert_eq!(PacketType::Publish.direction(), PacketDirection::Bidirectional);
        assert_eq!(PacketType::Subscribe.direction(), PacketDirection::ClientToServer);
        assert_eq!(PacketType::Suback.direction(), PacketDirection::ServerToClient);
    }

    #[test]
    fn packet_type_packet_id() {
        assert!(PacketType::Puback.requires_packet_id());
        assert!(PacketType::Subscribe.requires_packet_id());
        assert!(!PacketType::Connect.requires_packet_id());
        assert!(!PacketType::Publish.requires_packet_id()); // PUBLISH only with QoS > 0
        assert!(!PacketType::Auth.requires_packet_id());
        assert!(!PacketType::Disconnect.requires_packet_id());
    }
}
