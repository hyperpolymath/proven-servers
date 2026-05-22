// SPDX-License-Identifier: MPL-2.0
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
//! OSPF protocol types for the proven-servers ABI.
//!
//! Mirrors the Idris2 module `OSPFABI.Types` and its type definitions:
//! - `PacketType`     — OSPF packet types (5 constructors, tags 0-4)
//! - `NeighborState`  — OSPF neighbor state machine (8 constructors, tags 0-7)
//! - `LsaType`        — LSA types (5 constructors, tags 0-4)
//! - `AreaType`       — OSPF area types (4 constructors, tags 0-3)
//! - `OspfError`      — FFI error codes (7 constructors, tags 0-6)
//!
//! All discriminant values match the Idris2 ABI tag definitions exactly.

use std::fmt;

// ===========================================================================
// OSPF Constants
// ===========================================================================

/// OSPF protocol number (IP protocol 89).
pub const OSPF_PROTOCOL: u8 = 89;

/// OSPF AllSPFRouters multicast address.
pub const OSPF_ALL_SPF_ROUTERS: &str = "224.0.0.5";

/// OSPF AllDRouters multicast address.
pub const OSPF_ALL_D_ROUTERS: &str = "224.0.0.6";

// ===========================================================================
// PacketType (tags 0-4)
// ===========================================================================

/// OSPF packet types (RFC 2328 Section A.3).
///
/// Matches `PacketType` in `OSPFABI.Types`.
#[derive(Debug, Clone, Copy, PartialEq, Eq, Hash)]
#[repr(u8)]
pub enum PacketType {
    /// Hello — discover and maintain neighbors (tag 0).
    Hello = 0,
    /// Database Description — summarize LSDB contents (tag 1).
    DatabaseDescription = 1,
    /// Link State Request — request specific LSAs (tag 2).
    LinkStateRequest = 2,
    /// Link State Update — flood LSAs (tag 3).
    LinkStateUpdate = 3,
    /// Link State Acknowledgment — confirm LSA receipt (tag 4).
    LinkStateAck = 4,
}

impl PacketType {
    /// Decode from an ABI tag value.
    pub fn from_tag(tag: u8) -> Option<Self> {
        match tag {
            0 => Some(Self::Hello),
            1 => Some(Self::DatabaseDescription),
            2 => Some(Self::LinkStateRequest),
            3 => Some(Self::LinkStateUpdate),
            4 => Some(Self::LinkStateAck),
            _ => None,
        }
    }

    /// Encode to the ABI tag value.
    pub fn to_tag(self) -> u8 {
        self as u8
    }

    /// Whether this packet is part of database synchronization.
    pub fn is_db_sync(self) -> bool {
        matches!(
            self,
            Self::DatabaseDescription | Self::LinkStateRequest
                | Self::LinkStateUpdate | Self::LinkStateAck
        )
    }

    /// All supported packet types.
    pub const ALL: [PacketType; 5] = [
        Self::Hello, Self::DatabaseDescription, Self::LinkStateRequest,
        Self::LinkStateUpdate, Self::LinkStateAck,
    ];
}

impl fmt::Display for PacketType {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        fmt::Debug::fmt(self, f)
    }
}

// ===========================================================================
// NeighborState (tags 0-7)
// ===========================================================================

/// OSPF neighbor state machine (RFC 2328 Section 10.1).
///
/// Matches `NeighborState` in `OSPFABI.Types`.
#[derive(Debug, Clone, Copy, PartialEq, Eq, Hash)]
#[repr(u8)]
pub enum NeighborState {
    /// Down — no recent Hello received (tag 0).
    Down = 0,
    /// Attempt — NBMA networks, Hello sent (tag 1).
    Attempt = 1,
    /// Init — Hello received, no bidirectional (tag 2).
    Init = 2,
    /// 2-Way — bidirectional communication established (tag 3).
    TwoWay = 3,
    /// ExStart — master/slave negotiation (tag 4).
    ExStart = 4,
    /// Exchange — DD packets being exchanged (tag 5).
    Exchange = 5,
    /// Loading — LSAs being requested (tag 6).
    Loading = 6,
    /// Full — fully adjacent (tag 7).
    Full = 7,
}

impl NeighborState {
    /// Decode from an ABI tag value.
    pub fn from_tag(tag: u8) -> Option<Self> {
        match tag {
            0 => Some(Self::Down),
            1 => Some(Self::Attempt),
            2 => Some(Self::Init),
            3 => Some(Self::TwoWay),
            4 => Some(Self::ExStart),
            5 => Some(Self::Exchange),
            6 => Some(Self::Loading),
            7 => Some(Self::Full),
            _ => None,
        }
    }

    /// Encode to the ABI tag value.
    pub fn to_tag(self) -> u8 {
        self as u8
    }

    /// Whether the neighbor has achieved full adjacency.
    pub fn is_adjacent(self) -> bool {
        matches!(self, Self::Full)
    }

    /// Whether database synchronization is in progress.
    pub fn is_syncing(self) -> bool {
        matches!(self, Self::ExStart | Self::Exchange | Self::Loading)
    }

    /// Whether bidirectional communication exists.
    pub fn is_bidirectional(self) -> bool {
        matches!(
            self,
            Self::TwoWay | Self::ExStart | Self::Exchange
                | Self::Loading | Self::Full
        )
    }

    /// All supported states.
    pub const ALL: [NeighborState; 8] = [
        Self::Down, Self::Attempt, Self::Init, Self::TwoWay,
        Self::ExStart, Self::Exchange, Self::Loading, Self::Full,
    ];
}

impl fmt::Display for NeighborState {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        fmt::Debug::fmt(self, f)
    }
}

// ===========================================================================
// LsaType (tags 0-4)
// ===========================================================================

/// OSPF LSA types (RFC 2328 Section A.4).
///
/// Matches `LSAType` in `OSPFABI.Types`.
#[derive(Debug, Clone, Copy, PartialEq, Eq, Hash)]
#[repr(u8)]
pub enum LsaType {
    /// Router LSA — describes router's links (tag 0).
    RouterLsa = 0,
    /// Network LSA — describes multi-access network (tag 1).
    NetworkLsa = 1,
    /// Summary LSA — inter-area routes (tag 2).
    SummaryLsa = 2,
    /// ASBR Summary LSA — routes to ASBRs (tag 3).
    AsbrSummaryLsa = 3,
    /// AS External LSA — external routes (tag 4).
    AsExternalLsa = 4,
}

impl LsaType {
    /// Decode from an ABI tag value.
    pub fn from_tag(tag: u8) -> Option<Self> {
        match tag {
            0 => Some(Self::RouterLsa),
            1 => Some(Self::NetworkLsa),
            2 => Some(Self::SummaryLsa),
            3 => Some(Self::AsbrSummaryLsa),
            4 => Some(Self::AsExternalLsa),
            _ => None,
        }
    }

    /// Encode to the ABI tag value.
    pub fn to_tag(self) -> u8 {
        self as u8
    }

    /// Whether this LSA has area-wide scope.
    pub fn is_area_scope(self) -> bool {
        matches!(
            self,
            Self::RouterLsa | Self::NetworkLsa | Self::SummaryLsa | Self::AsbrSummaryLsa
        )
    }

    /// Whether this LSA has AS-wide scope.
    pub fn is_as_scope(self) -> bool {
        matches!(self, Self::AsExternalLsa)
    }

    /// All supported LSA types.
    pub const ALL: [LsaType; 5] = [
        Self::RouterLsa, Self::NetworkLsa, Self::SummaryLsa,
        Self::AsbrSummaryLsa, Self::AsExternalLsa,
    ];
}

impl fmt::Display for LsaType {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        fmt::Debug::fmt(self, f)
    }
}

// ===========================================================================
// AreaType (tags 0-3)
// ===========================================================================

/// OSPF area types (RFC 2328, RFC 3101).
///
/// Matches `AreaType` in `OSPFABI.Types`.
#[derive(Debug, Clone, Copy, PartialEq, Eq, Hash)]
#[repr(u8)]
pub enum AreaType {
    /// Normal area (tag 0).
    Normal = 0,
    /// Stub area — no external LSAs (tag 1).
    Stub = 1,
    /// Totally stubby area — no external or inter-area LSAs (tag 2).
    TotallyStub = 2,
    /// Not-So-Stubby Area — limited external routes (tag 3).
    Nssa = 3,
}

impl AreaType {
    /// Decode from an ABI tag value.
    pub fn from_tag(tag: u8) -> Option<Self> {
        match tag {
            0 => Some(Self::Normal),
            1 => Some(Self::Stub),
            2 => Some(Self::TotallyStub),
            3 => Some(Self::Nssa),
            _ => None,
        }
    }

    /// Encode to the ABI tag value.
    pub fn to_tag(self) -> u8 {
        self as u8
    }

    /// Whether this area type blocks external LSAs.
    pub fn blocks_external(self) -> bool {
        matches!(self, Self::Stub | Self::TotallyStub)
    }

    /// All supported area types.
    pub const ALL: [AreaType; 4] = [Self::Normal, Self::Stub, Self::TotallyStub, Self::Nssa];
}

impl fmt::Display for AreaType {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        fmt::Debug::fmt(self, f)
    }
}

// ===========================================================================
// OspfError (tags 0-6)
// ===========================================================================

/// OSPF FFI error codes.
///
/// Matches `OSPFError` in `OSPFABI.Types`.
#[derive(Debug, Clone, Copy, PartialEq, Eq, Hash)]
#[repr(u8)]
pub enum OspfError {
    /// No error (tag 0).
    Ok = 0,
    /// Invalid slot index (tag 1).
    InvalidSlot = 1,
    /// Neighbor not active (tag 2).
    NotActive = 2,
    /// Invalid state transition (tag 3).
    InvalidTransition = 3,
    /// Invalid packet type for current state (tag 4).
    InvalidPacket = 4,
    /// Area configuration error (tag 5).
    AreaError = 5,
    /// LSA flooding limit exceeded (tag 6).
    FloodLimit = 6,
}

impl OspfError {
    /// Decode from an ABI tag value.
    pub fn from_tag(tag: u8) -> Option<Self> {
        match tag {
            0 => Some(Self::Ok),
            1 => Some(Self::InvalidSlot),
            2 => Some(Self::NotActive),
            3 => Some(Self::InvalidTransition),
            4 => Some(Self::InvalidPacket),
            5 => Some(Self::AreaError),
            6 => Some(Self::FloodLimit),
            _ => None,
        }
    }

    /// Encode to the ABI tag value.
    pub fn to_tag(self) -> u8 {
        self as u8
    }

    /// Whether this error code indicates success.
    pub fn is_success(self) -> bool {
        matches!(self, Self::Ok)
    }

    /// All error codes.
    pub const ALL: [OspfError; 7] = [
        Self::Ok, Self::InvalidSlot, Self::NotActive, Self::InvalidTransition,
        Self::InvalidPacket, Self::AreaError, Self::FloodLimit,
    ];
}

impl fmt::Display for OspfError {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        fmt::Debug::fmt(self, f)
    }
}

impl std::error::Error for OspfError {}

// ===========================================================================
// Tests
// ===========================================================================

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn packet_type_roundtrip() {
        for pt in PacketType::ALL { assert_eq!(PacketType::from_tag(pt.to_tag()), Some(pt)); }
        assert!(PacketType::from_tag(5).is_none());
    }

    #[test]
    fn packet_type_db_sync() {
        assert!(!PacketType::Hello.is_db_sync());
        assert!(PacketType::DatabaseDescription.is_db_sync());
        assert!(PacketType::LinkStateUpdate.is_db_sync());
    }

    #[test]
    fn neighbor_state_roundtrip() {
        for ns in NeighborState::ALL { assert_eq!(NeighborState::from_tag(ns.to_tag()), Some(ns)); }
        assert!(NeighborState::from_tag(8).is_none());
    }

    #[test]
    fn neighbor_state_properties() {
        assert!(!NeighborState::Down.is_bidirectional());
        assert!(!NeighborState::Init.is_bidirectional());
        assert!(NeighborState::TwoWay.is_bidirectional());
        assert!(NeighborState::Full.is_bidirectional());
        assert!(NeighborState::Full.is_adjacent());
        assert!(!NeighborState::TwoWay.is_adjacent());
        assert!(NeighborState::ExStart.is_syncing());
        assert!(NeighborState::Loading.is_syncing());
        assert!(!NeighborState::Full.is_syncing());
    }

    #[test]
    fn lsa_type_roundtrip() {
        for lt in LsaType::ALL { assert_eq!(LsaType::from_tag(lt.to_tag()), Some(lt)); }
        assert!(LsaType::from_tag(5).is_none());
    }

    #[test]
    fn lsa_type_scope() {
        assert!(LsaType::RouterLsa.is_area_scope());
        assert!(!LsaType::AsExternalLsa.is_area_scope());
        assert!(LsaType::AsExternalLsa.is_as_scope());
        assert!(!LsaType::RouterLsa.is_as_scope());
    }

    #[test]
    fn area_type_roundtrip() {
        for at in AreaType::ALL { assert_eq!(AreaType::from_tag(at.to_tag()), Some(at)); }
        assert!(AreaType::from_tag(4).is_none());
    }

    #[test]
    fn area_type_external() {
        assert!(!AreaType::Normal.blocks_external());
        assert!(AreaType::Stub.blocks_external());
        assert!(AreaType::TotallyStub.blocks_external());
        assert!(!AreaType::Nssa.blocks_external());
    }

    #[test]
    fn ospf_error_roundtrip() {
        for oe in OspfError::ALL { assert_eq!(OspfError::from_tag(oe.to_tag()), Some(oe)); }
        assert!(OspfError::from_tag(7).is_none());
    }

    #[test]
    fn constants_match_idris() {
        assert_eq!(OSPF_PROTOCOL, 89);
    }
}
