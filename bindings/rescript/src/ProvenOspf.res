// SPDX-License-Identifier: PMPL-1.0-or-later
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
// OSPF protocol types for the proven-servers ABI.
//
// Mirrors the Idris2 module OSPFABI.Types.
// All tag values match the Idris2 ABI tag definitions exactly.

// ===========================================================================
// Constants
// ===========================================================================

/// OSPF protocol number (IP protocol 89).
let ospfProtocol = 89

// ===========================================================================
// PacketType (tags 0-4)
// ===========================================================================

/// OSPF protocol number (IP protocol 89).
type packetType =
  | @as(0) Hello
  | @as(1) DatabaseDescription
  | @as(2) LinkStateRequest
  | @as(3) LinkStateUpdate
  | @as(4) LinkStateAck

/// Decode from the C-ABI tag value.
let packetTypeFromTag = (tag: int): option<packetType> =>
  switch tag {
  | 0 => Some(Hello)
  | 1 => Some(DatabaseDescription)
  | 2 => Some(LinkStateRequest)
  | 3 => Some(LinkStateUpdate)
  | 4 => Some(LinkStateAck)
  | _ => None
  }

/// Encode to the C-ABI tag value.
let packetTypeToTag = (v: packetType): int =>
  switch v {
  | Hello => 0
  | DatabaseDescription => 1
  | LinkStateRequest => 2
  | LinkStateUpdate => 3
  | LinkStateAck => 4
  }

/// Whether this packet is part of database synchronization.
let packetTypeIsDbSync = (v: packetType): bool =>
  switch v {
  | DatabaseDescription | LinkStateRequest | LinkStateUpdate | LinkStateAck => true
  | _ => false
  }

// ===========================================================================
// NeighborState (tags 0-7)
// ===========================================================================

/// Decode from an ABI tag value.
type neighborState =
  | @as(0) Down
  | @as(1) Attempt
  | @as(2) Init
  | @as(3) TwoWay
  | @as(4) ExStart
  | @as(5) Exchange
  | @as(6) Loading
  | @as(7) Full

/// Decode from the C-ABI tag value.
let neighborStateFromTag = (tag: int): option<neighborState> =>
  switch tag {
  | 0 => Some(Down)
  | 1 => Some(Attempt)
  | 2 => Some(Init)
  | 3 => Some(TwoWay)
  | 4 => Some(ExStart)
  | 5 => Some(Exchange)
  | 6 => Some(Loading)
  | 7 => Some(Full)
  | _ => None
  }

/// Encode to the C-ABI tag value.
let neighborStateToTag = (v: neighborState): int =>
  switch v {
  | Down => 0
  | Attempt => 1
  | Init => 2
  | TwoWay => 3
  | ExStart => 4
  | Exchange => 5
  | Loading => 6
  | Full => 7
  }

/// Whether the neighbor has achieved full adjacency.
let neighborStateIsAdjacent = (v: neighborState): bool =>
  switch v {
  | Full => true
  | _ => false
  }

/// Whether database synchronization is in progress.
let neighborStateIsSyncing = (v: neighborState): bool =>
  switch v {
  | ExStart | Exchange | Loading => true
  | _ => false
  }

/// Whether bidirectional communication exists.
let neighborStateIsBidirectional = (v: neighborState): bool =>
  switch v {
  | TwoWay | ExStart | Exchange | Loading | Full => true
  | _ => false
  }

// ===========================================================================
// LsaType (tags 0-4)
// ===========================================================================

/// Decode from an ABI tag value.
type lsaType =
  | @as(0) RouterLsa
  | @as(1) NetworkLsa
  | @as(2) SummaryLsa
  | @as(3) AsbrSummaryLsa
  | @as(4) AsExternalLsa

/// Decode from the C-ABI tag value.
let lsaTypeFromTag = (tag: int): option<lsaType> =>
  switch tag {
  | 0 => Some(RouterLsa)
  | 1 => Some(NetworkLsa)
  | 2 => Some(SummaryLsa)
  | 3 => Some(AsbrSummaryLsa)
  | 4 => Some(AsExternalLsa)
  | _ => None
  }

/// Encode to the C-ABI tag value.
let lsaTypeToTag = (v: lsaType): int =>
  switch v {
  | RouterLsa => 0
  | NetworkLsa => 1
  | SummaryLsa => 2
  | AsbrSummaryLsa => 3
  | AsExternalLsa => 4
  }

/// Whether this LSA has area-wide scope.
let lsaTypeIsAreaScope = (v: lsaType): bool =>
  switch v {
  | RouterLsa | NetworkLsa | SummaryLsa | AsbrSummaryLsa => true
  | _ => false
  }

/// Whether this LSA has AS-wide scope.
let lsaTypeIsAsScope = (v: lsaType): bool =>
  switch v {
  | AsExternalLsa => true
  | _ => false
  }

// ===========================================================================
// AreaType (tags 0-3)
// ===========================================================================

/// Decode from an ABI tag value.
type areaType =
  | @as(0) Normal
  | @as(1) Stub
  | @as(2) TotallyStub
  | @as(3) Nssa

/// Decode from the C-ABI tag value.
let areaTypeFromTag = (tag: int): option<areaType> =>
  switch tag {
  | 0 => Some(Normal)
  | 1 => Some(Stub)
  | 2 => Some(TotallyStub)
  | 3 => Some(Nssa)
  | _ => None
  }

/// Encode to the C-ABI tag value.
let areaTypeToTag = (v: areaType): int =>
  switch v {
  | Normal => 0
  | Stub => 1
  | TotallyStub => 2
  | Nssa => 3
  }

/// Whether this area type blocks external LSAs.
let areaTypeBlocksExternal = (v: areaType): bool =>
  switch v {
  | Stub | TotallyStub => true
  | _ => false
  }

// ===========================================================================
// OspfError (tags 0-6)
// ===========================================================================

/// Decode from an ABI tag value.
type ospfError =
  | @as(0) Ok
  | @as(1) InvalidSlot
  | @as(2) NotActive
  | @as(3) InvalidTransition
  | @as(4) InvalidPacket
  | @as(5) AreaError
  | @as(6) FloodLimit

/// Decode from the C-ABI tag value.
let ospfErrorFromTag = (tag: int): option<ospfError> =>
  switch tag {
  | 0 => Some(Ok)
  | 1 => Some(InvalidSlot)
  | 2 => Some(NotActive)
  | 3 => Some(InvalidTransition)
  | 4 => Some(InvalidPacket)
  | 5 => Some(AreaError)
  | 6 => Some(FloodLimit)
  | _ => None
  }

/// Encode to the C-ABI tag value.
let ospfErrorToTag = (v: ospfError): int =>
  switch v {
  | Ok => 0
  | InvalidSlot => 1
  | NotActive => 2
  | InvalidTransition => 3
  | InvalidPacket => 4
  | AreaError => 5
  | FloodLimit => 6
  }

/// Whether this error code indicates success.
let ospfErrorIsSuccess = (v: ospfError): bool =>
  switch v {
  | Ok => true
  | _ => false
  }

