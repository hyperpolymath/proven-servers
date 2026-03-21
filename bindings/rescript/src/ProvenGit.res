// SPDX-License-Identifier: PMPL-1.0-or-later
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
// Git Server types for the proven-servers ABI.
//
// Mirrors the Idris2 module GitABI.Types.
// All tag values match the Idris2 ABI tag definitions exactly.

// ===========================================================================
// Constants
// ===========================================================================

/// Standard Git daemon port.
let gitPort = 9418

// ===========================================================================
// Command (tags 0-2)
// ===========================================================================

/// Standard Git daemon port.
type command =
  | @as(0) UploadPack
  | @as(1) ReceivePack
  | @as(2) UploadArchive

/// Decode from the C-ABI tag value.
let commandFromTag = (tag: int): option<command> =>
  switch tag {
  | 0 => Some(UploadPack)
  | 1 => Some(ReceivePack)
  | 2 => Some(UploadArchive)
  | _ => None
  }

/// Encode to the C-ABI tag value.
let commandToTag = (v: command): int =>
  switch v {
  | UploadPack => 0
  | ReceivePack => 1
  | UploadArchive => 2
  }

// ===========================================================================
// PacketType (tags 0-7)
// ===========================================================================

/// Decode from an ABI tag value.
type packetType =
  | @as(0) Flush
  | @as(1) Delimiter
  | @as(2) ResponseEnd
  | @as(3) Data
  | @as(4) PktError
  | @as(5) SidebandData
  | @as(6) SidebandProgress
  | @as(7) SidebandError

/// Decode from the C-ABI tag value.
let packetTypeFromTag = (tag: int): option<packetType> =>
  switch tag {
  | 0 => Some(Flush)
  | 1 => Some(Delimiter)
  | 2 => Some(ResponseEnd)
  | 3 => Some(Data)
  | 4 => Some(PktError)
  | 5 => Some(SidebandData)
  | 6 => Some(SidebandProgress)
  | 7 => Some(SidebandError)
  | _ => None
  }

/// Encode to the C-ABI tag value.
let packetTypeToTag = (v: packetType): int =>
  switch v {
  | Flush => 0
  | Delimiter => 1
  | ResponseEnd => 2
  | Data => 3
  | PktError => 4
  | SidebandData => 5
  | SidebandProgress => 6
  | SidebandError => 7
  }

// ===========================================================================
// RefType (tags 0-4)
// ===========================================================================

/// Decode from an ABI tag value.
type refType =
  | @as(0) Branch
  | @as(1) Tag
  | @as(2) Head
  | @as(3) Remote
  | @as(4) GitNote

/// Decode from the C-ABI tag value.
let refTypeFromTag = (tag: int): option<refType> =>
  switch tag {
  | 0 => Some(Branch)
  | 1 => Some(Tag)
  | 2 => Some(Head)
  | 3 => Some(Remote)
  | 4 => Some(GitNote)
  | _ => None
  }

/// Encode to the C-ABI tag value.
let refTypeToTag = (v: refType): int =>
  switch v {
  | Branch => 0
  | Tag => 1
  | Head => 2
  | Remote => 3
  | GitNote => 4
  }

// ===========================================================================
// Capability (tags 0-8)
// ===========================================================================

/// Decode from an ABI tag value.
type capability =
  | @as(0) MultiAck
  | @as(1) ThinPack
  | @as(2) SideBand64k
  | @as(3) OfsDelta
  | @as(4) Shallow
  | @as(5) DeepenSince
  | @as(6) DeepenNot
  | @as(7) FilterSpec
  | @as(8) ObjectFormat

/// Decode from the C-ABI tag value.
let capabilityFromTag = (tag: int): option<capability> =>
  switch tag {
  | 0 => Some(MultiAck)
  | 1 => Some(ThinPack)
  | 2 => Some(SideBand64k)
  | 3 => Some(OfsDelta)
  | 4 => Some(Shallow)
  | 5 => Some(DeepenSince)
  | 6 => Some(DeepenNot)
  | 7 => Some(FilterSpec)
  | 8 => Some(ObjectFormat)
  | _ => None
  }

/// Encode to the C-ABI tag value.
let capabilityToTag = (v: capability): int =>
  switch v {
  | MultiAck => 0
  | ThinPack => 1
  | SideBand64k => 2
  | OfsDelta => 3
  | Shallow => 4
  | DeepenSince => 5
  | DeepenNot => 6
  | FilterSpec => 7
  | ObjectFormat => 8
  }

// ===========================================================================
// HookResult (tags 0-1)
// ===========================================================================

/// Decode from an ABI tag value.
type hookResult =
  | @as(0) Accept
  | @as(1) Reject

/// Decode from the C-ABI tag value.
let hookResultFromTag = (tag: int): option<hookResult> =>
  switch tag {
  | 0 => Some(Accept)
  | 1 => Some(Reject)
  | _ => None
  }

/// Encode to the C-ABI tag value.
let hookResultToTag = (v: hookResult): int =>
  switch v {
  | Accept => 0
  | Reject => 1
  }

// ===========================================================================
// ServerState (tags 0-4)
// ===========================================================================

/// Decode from an ABI tag value.
type serverState =
  | @as(0) Idle
  | @as(1) Discovery
  | @as(2) Negotiating
  | @as(3) Transfer
  | @as(4) Shutdown

/// Decode from the C-ABI tag value.
let serverStateFromTag = (tag: int): option<serverState> =>
  switch tag {
  | 0 => Some(Idle)
  | 1 => Some(Discovery)
  | 2 => Some(Negotiating)
  | 3 => Some(Transfer)
  | 4 => Some(Shutdown)
  | _ => None
  }

/// Encode to the C-ABI tag value.
let serverStateToTag = (v: serverState): int =>
  switch v {
  | Idle => 0
  | Discovery => 1
  | Negotiating => 2
  | Transfer => 3
  | Shutdown => 4
  }

