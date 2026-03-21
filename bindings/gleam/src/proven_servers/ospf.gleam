//// SPDX-License-Identifier: MPL-2.0
//// (PMPL-1.0-or-later preferred; MPL-2.0 required for Gleam ecosystem)
//// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
////
//// OSPF protocol types for the proven-servers ABI.
////
//// Mirrors the Idris2 module `OspfABI.Types`.
//// All tag values match the Idris2 ABI definitions exactly.

// ===========================================================================
// OSPF Constants
// ===========================================================================

/// Ospf Protocol constant.
pub const ospf_protocol = 89

// ===========================================================================
// PacketType
// ===========================================================================

/// OSPF packet types (RFC 2328 Section A.3).
/// 
/// Matches `PacketType` in `OSPFABI.Types`.
pub type PacketType {
  /// Hello — discover and maintain neighbors (tag 0).
  Hello
  /// Database Description — summarize LSDB contents (tag 1).
  DatabaseDescription
  /// Link State Request — request specific LSAs (tag 2).
  LinkStateRequest
  /// Link State Update — flood LSAs (tag 3).
  LinkStateUpdate
  /// Link State Acknowledgment — confirm LSA receipt (tag 4).
  LinkStateAck
}

/// Convert a `PacketType` to its C-ABI tag value.
pub fn packet_type_to_int(value: PacketType) -> Int {
  case value {
    Hello -> 0
    DatabaseDescription -> 1
    LinkStateRequest -> 2
    LinkStateUpdate -> 3
    LinkStateAck -> 4
  }
}

/// Decode from a C-ABI tag value.
pub fn packet_type_from_int(tag: Int) -> Result(PacketType, Nil) {
  case tag {
    0 -> Ok(Hello)
    1 -> Ok(DatabaseDescription)
    2 -> Ok(LinkStateRequest)
    3 -> Ok(LinkStateUpdate)
    4 -> Ok(LinkStateAck)
    _ -> Error(Nil)
  }
}

// ===========================================================================
// NeighborState
// ===========================================================================

/// OSPF neighbor state machine (RFC 2328 Section 10.1).
/// 
/// Matches `NeighborState` in `OSPFABI.Types`.
pub type NeighborState {
  /// Down — no recent Hello received (tag 0).
  Down
  /// Attempt — NBMA networks, Hello sent (tag 1).
  Attempt
  /// Init — Hello received, no bidirectional (tag 2).
  Init
  /// 2-Way — bidirectional communication established (tag 3).
  TwoWay
  /// ExStart — master/slave negotiation (tag 4).
  ExStart
  /// Exchange — DD packets being exchanged (tag 5).
  Exchange
  /// Loading — LSAs being requested (tag 6).
  Loading
  /// Full — fully adjacent (tag 7).
  Full
}

/// Convert a `NeighborState` to its C-ABI tag value.
pub fn neighbor_state_to_int(value: NeighborState) -> Int {
  case value {
    Down -> 0
    Attempt -> 1
    Init -> 2
    TwoWay -> 3
    ExStart -> 4
    Exchange -> 5
    Loading -> 6
    Full -> 7
  }
}

/// Decode from a C-ABI tag value.
pub fn neighbor_state_from_int(tag: Int) -> Result(NeighborState, Nil) {
  case tag {
    0 -> Ok(Down)
    1 -> Ok(Attempt)
    2 -> Ok(Init)
    3 -> Ok(TwoWay)
    4 -> Ok(ExStart)
    5 -> Ok(Exchange)
    6 -> Ok(Loading)
    7 -> Ok(Full)
    _ -> Error(Nil)
  }
}

// ===========================================================================
// LsaType
// ===========================================================================

/// OSPF LSA types (RFC 2328 Section A.4).
/// 
/// Matches `LSAType` in `OSPFABI.Types`.
pub type LsaType {
  /// Router LSA — describes router's links (tag 0).
  RouterLsa
  /// Network LSA — describes multi-access network (tag 1).
  NetworkLsa
  /// Summary LSA — inter-area routes (tag 2).
  SummaryLsa
  /// ASBR Summary LSA — routes to ASBRs (tag 3).
  AsbrSummaryLsa
  /// AS External LSA — external routes (tag 4).
  AsExternalLsa
}

/// Convert a `LsaType` to its C-ABI tag value.
pub fn lsa_type_to_int(value: LsaType) -> Int {
  case value {
    RouterLsa -> 0
    NetworkLsa -> 1
    SummaryLsa -> 2
    AsbrSummaryLsa -> 3
    AsExternalLsa -> 4
  }
}

/// Decode from a C-ABI tag value.
pub fn lsa_type_from_int(tag: Int) -> Result(LsaType, Nil) {
  case tag {
    0 -> Ok(RouterLsa)
    1 -> Ok(NetworkLsa)
    2 -> Ok(SummaryLsa)
    3 -> Ok(AsbrSummaryLsa)
    4 -> Ok(AsExternalLsa)
    _ -> Error(Nil)
  }
}

// ===========================================================================
// AreaType
// ===========================================================================

/// OSPF area types (RFC 2328, RFC 3101).
/// 
/// Matches `AreaType` in `OSPFABI.Types`.
pub type AreaType {
  /// Normal area (tag 0).
  Normal
  /// Stub area — no external LSAs (tag 1).
  Stub
  /// Totally stubby area — no external or inter-area LSAs (tag 2).
  TotallyStub
  /// Not-So-Stubby Area — limited external routes (tag 3).
  Nssa
}

/// Convert a `AreaType` to its C-ABI tag value.
pub fn area_type_to_int(value: AreaType) -> Int {
  case value {
    Normal -> 0
    Stub -> 1
    TotallyStub -> 2
    Nssa -> 3
  }
}

/// Decode from a C-ABI tag value.
pub fn area_type_from_int(tag: Int) -> Result(AreaType, Nil) {
  case tag {
    0 -> Ok(Normal)
    1 -> Ok(Stub)
    2 -> Ok(TotallyStub)
    3 -> Ok(Nssa)
    _ -> Error(Nil)
  }
}

// ===========================================================================
// OspfError
// ===========================================================================

/// OSPF FFI error codes.
/// 
/// Matches `OSPFError` in `OSPFABI.Types`.
pub type OspfError {
  /// No error (tag 0).
  OspfErrorOk
  /// Invalid slot index (tag 1).
  InvalidSlot
  /// Neighbor not active (tag 2).
  NotActive
  /// Invalid state transition (tag 3).
  InvalidTransition
  /// Invalid packet type for current state (tag 4).
  InvalidPacket
  /// Area configuration error (tag 5).
  AreaError
  /// LSA flooding limit exceeded (tag 6).
  FloodLimit
}

/// Convert a `OspfError` to its C-ABI tag value.
pub fn ospf_error_to_int(value: OspfError) -> Int {
  case value {
    OspfErrorOk -> 0
    InvalidSlot -> 1
    NotActive -> 2
    InvalidTransition -> 3
    InvalidPacket -> 4
    AreaError -> 5
    FloodLimit -> 6
  }
}

/// Decode from a C-ABI tag value.
pub fn ospf_error_from_int(tag: Int) -> Result(OspfError, Nil) {
  case tag {
    0 -> Ok(OspfErrorOk)
    1 -> Ok(InvalidSlot)
    2 -> Ok(NotActive)
    3 -> Ok(InvalidTransition)
    4 -> Ok(InvalidPacket)
    5 -> Ok(AreaError)
    6 -> Ok(FloodLimit)
    _ -> Error(Nil)
  }
}

