// SPDX-License-Identifier: MPL-2.0
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//

//! Load Balancer types for the proven-servers ABI.
//!
//! Formally verified load balancer types.
//! Mirrors the Idris2 module `LoadbalancerABI.Types`.
//!
//! - `Algorithm` -- Load balancing algorithms.
//! - `HealthCheckType` -- Backend health check types.
//! - `BackendState` -- Backend server states.
//! - `SessionPersistence` -- Session persistence strategies.
//! - `LbProtocol` -- Load balancer protocols.
//!
//! All discriminant values match the Idris2 ABI tag definitions exactly.

use std::fmt;

// ===========================================================================
// Algorithm (tags 0-5)
// ===========================================================================

/// Load balancing algorithms.
///
/// Matches `Algorithm` in `LoadbalancerABI.Types`.
#[derive(Debug, Clone, Copy, PartialEq, Eq, Hash)]
#[repr(u8)]
pub enum Algorithm {
    /// RoundRobin (tag 0).
    RoundRobin = 0,
    /// LeastConnections (tag 1).
    LeastConnections = 1,
    /// IpHash (tag 2).
    IpHash = 2,
    /// Random (tag 3).
    Random = 3,
    /// WeightedRoundRobin (tag 4).
    WeightedRoundRobin = 4,
    /// LeastResponseTime (tag 5).
    LeastResponseTime = 5,
}

impl Algorithm {
    /// Decode from an ABI tag value.
    pub fn from_tag(tag: u8) -> Option<Self> {
        match tag {
            0 => Some(Self::RoundRobin),
            1 => Some(Self::LeastConnections),
            2 => Some(Self::IpHash),
            3 => Some(Self::Random),
            4 => Some(Self::WeightedRoundRobin),
            5 => Some(Self::LeastResponseTime),
            _ => None,
        }
    }

    /// Encode to the ABI tag value.
    pub fn to_tag(self) -> u8 {
        self as u8
    }

    /// All variants of this type.
    pub const ALL: [Algorithm; 6] = [
        Self::RoundRobin, Self::LeastConnections, Self::IpHash, Self::Random, Self::WeightedRoundRobin, Self::LeastResponseTime,
    ];
}

impl fmt::Display for Algorithm {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        fmt::Debug::fmt(self, f)
    }
}

// ===========================================================================
// HealthCheckType (tags 0-3)
// ===========================================================================

/// Backend health check types.
///
/// Matches `HealthCheckType` in `LoadbalancerABI.Types`.
#[derive(Debug, Clone, Copy, PartialEq, Eq, Hash)]
#[repr(u8)]
pub enum HealthCheckType {
    /// HTTP health check (tag 0).
    Http = 0,
    /// TCP health check (tag 1).
    Tcp = 1,
    /// gRPC health check (tag 2).
    Grpc = 2,
    /// Script (tag 3).
    Script = 3,
}

impl HealthCheckType {
    /// Decode from an ABI tag value.
    pub fn from_tag(tag: u8) -> Option<Self> {
        match tag {
            0 => Some(Self::Http),
            1 => Some(Self::Tcp),
            2 => Some(Self::Grpc),
            3 => Some(Self::Script),
            _ => None,
        }
    }

    /// Encode to the ABI tag value.
    pub fn to_tag(self) -> u8 {
        self as u8
    }

    /// All variants of this type.
    pub const ALL: [HealthCheckType; 4] = [
        Self::Http, Self::Tcp, Self::Grpc, Self::Script,
    ];
}

impl fmt::Display for HealthCheckType {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        fmt::Debug::fmt(self, f)
    }
}

// ===========================================================================
// BackendState (tags 0-3)
// ===========================================================================

/// Backend server states.
///
/// Matches `BackendState` in `LoadbalancerABI.Types`.
#[derive(Debug, Clone, Copy, PartialEq, Eq, Hash)]
#[repr(u8)]
pub enum BackendState {
    /// Healthy (tag 0).
    Healthy = 0,
    /// Unhealthy (tag 1).
    Unhealthy = 1,
    /// Draining (tag 2).
    Draining = 2,
    /// Disabled (tag 3).
    Disabled = 3,
}

impl BackendState {
    /// Decode from an ABI tag value.
    pub fn from_tag(tag: u8) -> Option<Self> {
        match tag {
            0 => Some(Self::Healthy),
            1 => Some(Self::Unhealthy),
            2 => Some(Self::Draining),
            3 => Some(Self::Disabled),
            _ => None,
        }
    }

    /// Encode to the ABI tag value.
    pub fn to_tag(self) -> u8 {
        self as u8
    }

    /// Whether this backend can receive new connections.
    pub fn can_receive_traffic(self) -> bool {
        matches!(self, Self::Healthy)
    }

    /// All variants of this type.
    pub const ALL: [BackendState; 4] = [
        Self::Healthy, Self::Unhealthy, Self::Draining, Self::Disabled,
    ];
}

impl fmt::Display for BackendState {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        fmt::Debug::fmt(self, f)
    }
}

// ===========================================================================
// SessionPersistence (tags 0-3)
// ===========================================================================

/// Session persistence strategies.
///
/// Matches `SessionPersistence` in `LoadbalancerABI.Types`.
#[derive(Debug, Clone, Copy, PartialEq, Eq, Hash)]
#[repr(u8)]
pub enum SessionPersistence {
    /// None (tag 0).
    None = 0,
    /// Cookie (tag 1).
    Cookie = 1,
    /// Source IP affinity (tag 2).
    SourceIp = 2,
    /// Header (tag 3).
    Header = 3,
}

impl SessionPersistence {
    /// Decode from an ABI tag value.
    pub fn from_tag(tag: u8) -> Option<Self> {
        match tag {
            0 => Some(Self::None),
            1 => Some(Self::Cookie),
            2 => Some(Self::SourceIp),
            3 => Some(Self::Header),
            _ => None,
        }
    }

    /// Encode to the ABI tag value.
    pub fn to_tag(self) -> u8 {
        self as u8
    }

    /// All variants of this type.
    pub const ALL: [SessionPersistence; 4] = [
        Self::None, Self::Cookie, Self::SourceIp, Self::Header,
    ];
}

impl fmt::Display for SessionPersistence {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        fmt::Debug::fmt(self, f)
    }
}

// ===========================================================================
// LbProtocol (tags 0-4)
// ===========================================================================

/// Load balancer protocols.
///
/// Matches `LbProtocol` in `LoadbalancerABI.Types`.
#[derive(Debug, Clone, Copy, PartialEq, Eq, Hash)]
#[repr(u8)]
pub enum LbProtocol {
    /// HTTP (tag 0).
    Http = 0,
    /// HTTPS (tag 1).
    Https = 1,
    /// TCP (tag 2).
    Tcp = 2,
    /// UDP (tag 3).
    Udp = 3,
    /// gRPC (tag 4).
    Grpc = 4,
}

impl LbProtocol {
    /// Decode from an ABI tag value.
    pub fn from_tag(tag: u8) -> Option<Self> {
        match tag {
            0 => Some(Self::Http),
            1 => Some(Self::Https),
            2 => Some(Self::Tcp),
            3 => Some(Self::Udp),
            4 => Some(Self::Grpc),
            _ => None,
        }
    }

    /// Encode to the ABI tag value.
    pub fn to_tag(self) -> u8 {
        self as u8
    }

    /// All variants of this type.
    pub const ALL: [LbProtocol; 5] = [
        Self::Http, Self::Https, Self::Tcp, Self::Udp, Self::Grpc,
    ];
}

impl fmt::Display for LbProtocol {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        fmt::Debug::fmt(self, f)
    }
}

// ===========================================================================
// Tests
// ===========================================================================

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn algorithm_roundtrip() {
        for v in Algorithm::ALL {
            let tag = v.to_tag();
            let decoded = Algorithm::from_tag(tag).expect("valid tag");
            assert_eq!(decoded, v);
        }
        assert!(Algorithm::from_tag(6).is_none());
    }

    #[test]
    fn health_check_type_roundtrip() {
        for v in HealthCheckType::ALL {
            let tag = v.to_tag();
            let decoded = HealthCheckType::from_tag(tag).expect("valid tag");
            assert_eq!(decoded, v);
        }
        assert!(HealthCheckType::from_tag(4).is_none());
    }

    #[test]
    fn backend_state_roundtrip() {
        for v in BackendState::ALL {
            let tag = v.to_tag();
            let decoded = BackendState::from_tag(tag).expect("valid tag");
            assert_eq!(decoded, v);
        }
        assert!(BackendState::from_tag(4).is_none());
    }

    #[test]
    fn session_persistence_roundtrip() {
        for v in SessionPersistence::ALL {
            let tag = v.to_tag();
            let decoded = SessionPersistence::from_tag(tag).expect("valid tag");
            assert_eq!(decoded, v);
        }
        assert!(SessionPersistence::from_tag(4).is_none());
    }

    #[test]
    fn lb_protocol_roundtrip() {
        for v in LbProtocol::ALL {
            let tag = v.to_tag();
            let decoded = LbProtocol::from_tag(tag).expect("valid tag");
            assert_eq!(decoded, v);
        }
        assert!(LbProtocol::from_tag(5).is_none());
    }

}
