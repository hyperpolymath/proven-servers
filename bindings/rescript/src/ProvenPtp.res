// SPDX-License-Identifier: MPL-2.0
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
// PTP types for the proven-servers ABI.
//
// Mirrors the Idris2 module PtpABI.Types.
// All tag values match the Idris2 ABI tag definitions exactly.

// ===========================================================================
// Constants
// ===========================================================================

/// PTP event port.
let ptpEventPort = 319

/// PTP general port.
let ptpGeneralPort = 320

// ===========================================================================
// PtpMessageType (tags 0-9)
// ===========================================================================

/// PTP event port.
type ptpMessageType =
  | @as(0) Sync
  | @as(1) DelayReq
  | @as(2) PdelayReq
  | @as(3) PdelayResp
  | @as(4) FollowUp
  | @as(5) DelayResp
  | @as(6) PdelayRespFollowUp
  | @as(7) Announce
  | @as(8) Signaling
  | @as(9) Management

/// Decode from the C-ABI tag value.
let ptpMessageTypeFromTag = (tag: int): option<ptpMessageType> =>
  switch tag {
  | 0 => Some(Sync)
  | 1 => Some(DelayReq)
  | 2 => Some(PdelayReq)
  | 3 => Some(PdelayResp)
  | 4 => Some(FollowUp)
  | 5 => Some(DelayResp)
  | 6 => Some(PdelayRespFollowUp)
  | 7 => Some(Announce)
  | 8 => Some(Signaling)
  | 9 => Some(Management)
  | _ => None
  }

/// Encode to the C-ABI tag value.
let ptpMessageTypeToTag = (v: ptpMessageType): int =>
  switch v {
  | Sync => 0
  | DelayReq => 1
  | PdelayReq => 2
  | PdelayResp => 3
  | FollowUp => 4
  | DelayResp => 5
  | PdelayRespFollowUp => 6
  | Announce => 7
  | Signaling => 8
  | Management => 9
  }

// ===========================================================================
// ClockClass (tags 0-3)
// ===========================================================================

/// Decode from an ABI tag value.
type clockClass =
  | @as(0) PrimaryClock
  | @as(1) ApplicationSpecific
  | @as(2) SlaveOnly
  | @as(3) DefaultClass

/// Decode from the C-ABI tag value.
let clockClassFromTag = (tag: int): option<clockClass> =>
  switch tag {
  | 0 => Some(PrimaryClock)
  | 1 => Some(ApplicationSpecific)
  | 2 => Some(SlaveOnly)
  | 3 => Some(DefaultClass)
  | _ => None
  }

/// Encode to the C-ABI tag value.
let clockClassToTag = (v: clockClass): int =>
  switch v {
  | PrimaryClock => 0
  | ApplicationSpecific => 1
  | SlaveOnly => 2
  | DefaultClass => 3
  }

// ===========================================================================
// PtpPortState (tags 0-8)
// ===========================================================================

/// Decode from an ABI tag value.
type ptpPortState =
  | @as(0) Initializing
  | @as(1) Faulty
  | @as(2) Disabled
  | @as(3) Listening
  | @as(4) PreMaster
  | @as(5) Master
  | @as(6) Passive
  | @as(7) Uncalibrated
  | @as(8) Slave

/// Decode from the C-ABI tag value.
let ptpPortStateFromTag = (tag: int): option<ptpPortState> =>
  switch tag {
  | 0 => Some(Initializing)
  | 1 => Some(Faulty)
  | 2 => Some(Disabled)
  | 3 => Some(Listening)
  | 4 => Some(PreMaster)
  | 5 => Some(Master)
  | 6 => Some(Passive)
  | 7 => Some(Uncalibrated)
  | 8 => Some(Slave)
  | _ => None
  }

/// Encode to the C-ABI tag value.
let ptpPortStateToTag = (v: ptpPortState): int =>
  switch v {
  | Initializing => 0
  | Faulty => 1
  | Disabled => 2
  | Listening => 3
  | PreMaster => 4
  | Master => 5
  | Passive => 6
  | Uncalibrated => 7
  | Slave => 8
  }

// ===========================================================================
// DelayMechanism (tags 0-2)
// ===========================================================================

/// Decode from an ABI tag value.
type delayMechanism =
  | @as(0) E2E
  | @as(1) P2P
  | @as(2) DmDisabled

/// Decode from the C-ABI tag value.
let delayMechanismFromTag = (tag: int): option<delayMechanism> =>
  switch tag {
  | 0 => Some(E2E)
  | 1 => Some(P2P)
  | 2 => Some(DmDisabled)
  | _ => None
  }

/// Encode to the C-ABI tag value.
let delayMechanismToTag = (v: delayMechanism): int =>
  switch v {
  | E2E => 0
  | P2P => 1
  | DmDisabled => 2
  }

