// SPDX-License-Identifier: MPL-2.0
// Copyright (c) Jonathan D.A. Jewell <j.d.a.jewell@open.ac.uk>
//

//! Application Server types for the proven-servers ABI.
//!
//! Formally verified application server types.
//! Mirrors the Idris2 module `AppserverABI.Types`.
//!
//! - `RequestType` -- Request protocol types.
//! - `LifecycleState` -- Application lifecycle states.
//! - `HealthCheck` -- Health check types.
//! - `DeployStrategy` -- Deployment strategies.
//! - `ErrorCategory` -- Application error categories.
//!
//! All discriminant values match the Idris2 ABI tag definitions exactly.

use std::fmt;

// ===========================================================================
// Application Server Constants
// ===========================================================================

/// Standard application server port.
pub const APP_PORT: u16 = 8080;

// ===========================================================================
// RequestType (tags 0-3)
// ===========================================================================

/// Request protocol types.
///
/// Matches `RequestType` in `AppserverABI.Types`.
#[derive(Debug, Clone, Copy, PartialEq, Eq, Hash)]
#[repr(u8)]
pub enum RequestType {
    /// HTTP (tag 0).
    Http = 0,
    /// WebSocket (tag 1).
    WebSocket = 1,
    /// gRPC (tag 2).
    Grpc = 2,
    /// GraphQL (tag 3).
    GraphQl = 3,
}

impl RequestType {
    /// Decode from an ABI tag value.
    pub fn from_tag(tag: u8) -> Option<Self> {
        match tag {
            0 => Some(Self::Http),
            1 => Some(Self::WebSocket),
            2 => Some(Self::Grpc),
            3 => Some(Self::GraphQl),
            _ => None,
        }
    }

    /// Encode to the ABI tag value.
    pub fn to_tag(self) -> u8 {
        self as u8
    }

    /// All variants of this type.
    pub const ALL: [RequestType; 4] = [
        Self::Http, Self::WebSocket, Self::Grpc, Self::GraphQl,
    ];
}

impl fmt::Display for RequestType {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        fmt::Debug::fmt(self, f)
    }
}

// ===========================================================================
// LifecycleState (tags 0-5)
// ===========================================================================

/// Application lifecycle states.
///
/// Matches `LifecycleState` in `AppserverABI.Types`.
#[derive(Debug, Clone, Copy, PartialEq, Eq, Hash)]
#[repr(u8)]
pub enum LifecycleState {
    /// Initializing (tag 0).
    Initializing = 0,
    /// Starting (tag 1).
    Starting = 1,
    /// Running (tag 2).
    Running = 2,
    /// Draining (tag 3).
    Draining = 3,
    /// Stopping (tag 4).
    Stopping = 4,
    /// Stopped (tag 5).
    Stopped = 5,
}

impl LifecycleState {
    /// Decode from an ABI tag value.
    pub fn from_tag(tag: u8) -> Option<Self> {
        match tag {
            0 => Some(Self::Initializing),
            1 => Some(Self::Starting),
            2 => Some(Self::Running),
            3 => Some(Self::Draining),
            4 => Some(Self::Stopping),
            5 => Some(Self::Stopped),
            _ => None,
        }
    }

    /// Encode to the ABI tag value.
    pub fn to_tag(self) -> u8 {
        self as u8
    }

    /// Whether the server is ready to handle requests.
    pub fn is_ready(self) -> bool {
        matches!(self, Self::Running)
    }

    /// All variants of this type.
    pub const ALL: [LifecycleState; 6] = [
        Self::Initializing, Self::Starting, Self::Running, Self::Draining, Self::Stopping, Self::Stopped,
    ];
}

impl fmt::Display for LifecycleState {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        fmt::Debug::fmt(self, f)
    }
}

// ===========================================================================
// HealthCheck (tags 0-2)
// ===========================================================================

/// Health check types.
///
/// Matches `HealthCheck` in `AppserverABI.Types`.
#[derive(Debug, Clone, Copy, PartialEq, Eq, Hash)]
#[repr(u8)]
pub enum HealthCheck {
    /// Liveness (tag 0).
    Liveness = 0,
    /// Readiness (tag 1).
    Readiness = 1,
    /// Startup (tag 2).
    Startup = 2,
}

impl HealthCheck {
    /// Decode from an ABI tag value.
    pub fn from_tag(tag: u8) -> Option<Self> {
        match tag {
            0 => Some(Self::Liveness),
            1 => Some(Self::Readiness),
            2 => Some(Self::Startup),
            _ => None,
        }
    }

    /// Encode to the ABI tag value.
    pub fn to_tag(self) -> u8 {
        self as u8
    }

    /// All variants of this type.
    pub const ALL: [HealthCheck; 3] = [
        Self::Liveness, Self::Readiness, Self::Startup,
    ];
}

impl fmt::Display for HealthCheck {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        fmt::Debug::fmt(self, f)
    }
}

// ===========================================================================
// DeployStrategy (tags 0-3)
// ===========================================================================

/// Deployment strategies.
///
/// Matches `DeployStrategy` in `AppserverABI.Types`.
#[derive(Debug, Clone, Copy, PartialEq, Eq, Hash)]
#[repr(u8)]
pub enum DeployStrategy {
    /// RollingUpdate (tag 0).
    RollingUpdate = 0,
    /// BlueGreen (tag 1).
    BlueGreen = 1,
    /// Canary (tag 2).
    Canary = 2,
    /// Recreate (tag 3).
    Recreate = 3,
}

impl DeployStrategy {
    /// Decode from an ABI tag value.
    pub fn from_tag(tag: u8) -> Option<Self> {
        match tag {
            0 => Some(Self::RollingUpdate),
            1 => Some(Self::BlueGreen),
            2 => Some(Self::Canary),
            3 => Some(Self::Recreate),
            _ => None,
        }
    }

    /// Encode to the ABI tag value.
    pub fn to_tag(self) -> u8 {
        self as u8
    }

    /// All variants of this type.
    pub const ALL: [DeployStrategy; 4] = [
        Self::RollingUpdate, Self::BlueGreen, Self::Canary, Self::Recreate,
    ];
}

impl fmt::Display for DeployStrategy {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        fmt::Debug::fmt(self, f)
    }
}

// ===========================================================================
// ErrorCategory (tags 0-4)
// ===========================================================================

/// Application error categories.
///
/// Matches `ErrorCategory` in `AppserverABI.Types`.
#[derive(Debug, Clone, Copy, PartialEq, Eq, Hash)]
#[repr(u8)]
pub enum ErrorCategory {
    /// ClientError (tag 0).
    ClientError = 0,
    /// ServerError (tag 1).
    ServerError = 1,
    /// Timeout (tag 2).
    Timeout = 2,
    /// CircuitOpen (tag 3).
    CircuitOpen = 3,
    /// RateLimited (tag 4).
    RateLimited = 4,
}

impl ErrorCategory {
    /// Decode from an ABI tag value.
    pub fn from_tag(tag: u8) -> Option<Self> {
        match tag {
            0 => Some(Self::ClientError),
            1 => Some(Self::ServerError),
            2 => Some(Self::Timeout),
            3 => Some(Self::CircuitOpen),
            4 => Some(Self::RateLimited),
            _ => None,
        }
    }

    /// Encode to the ABI tag value.
    pub fn to_tag(self) -> u8 {
        self as u8
    }

    /// All variants of this type.
    pub const ALL: [ErrorCategory; 5] = [
        Self::ClientError, Self::ServerError, Self::Timeout, Self::CircuitOpen, Self::RateLimited,
    ];
}

impl fmt::Display for ErrorCategory {
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
    fn request_type_roundtrip() {
        for v in RequestType::ALL {
            let tag = v.to_tag();
            let decoded = RequestType::from_tag(tag).expect("valid tag");
            assert_eq!(decoded, v);
        }
        assert!(RequestType::from_tag(4).is_none());
    }

    #[test]
    fn lifecycle_state_roundtrip() {
        for v in LifecycleState::ALL {
            let tag = v.to_tag();
            let decoded = LifecycleState::from_tag(tag).expect("valid tag");
            assert_eq!(decoded, v);
        }
        assert!(LifecycleState::from_tag(6).is_none());
    }

    #[test]
    fn health_check_roundtrip() {
        for v in HealthCheck::ALL {
            let tag = v.to_tag();
            let decoded = HealthCheck::from_tag(tag).expect("valid tag");
            assert_eq!(decoded, v);
        }
        assert!(HealthCheck::from_tag(3).is_none());
    }

    #[test]
    fn deploy_strategy_roundtrip() {
        for v in DeployStrategy::ALL {
            let tag = v.to_tag();
            let decoded = DeployStrategy::from_tag(tag).expect("valid tag");
            assert_eq!(decoded, v);
        }
        assert!(DeployStrategy::from_tag(4).is_none());
    }

    #[test]
    fn error_category_roundtrip() {
        for v in ErrorCategory::ALL {
            let tag = v.to_tag();
            let decoded = ErrorCategory::from_tag(tag).expect("valid tag");
            assert_eq!(decoded, v);
        }
        assert!(ErrorCategory::from_tag(5).is_none());
    }

    #[test]
    fn constants_match_idris() {
        assert_eq!(APP_PORT, 8080);
    }

}
