//// SPDX-License-Identifier: MPL-2.0
//// (MPL-2.0 preferred; MPL-2.0 required for Gleam ecosystem)
//// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
////
//// PTP protocol types for the proven-servers ABI.
////
//// Mirrors the Idris2 module `PtpABI.Types`.
//// All tag values match the Idris2 ABI definitions exactly.

// ===========================================================================
// PTP Constants
// ===========================================================================

/// Ptp Event Port constant.
pub const ptp_event_port = 319

/// Ptp General Port constant.
pub const ptp_general_port = 320

// ===========================================================================
// PtpMessageType
// ===========================================================================

/// PTP message types.
/// 
/// Matches `PtpMessageType` in `PtpABI.Types`.
pub type PtpMessageType {
  /// Sync (tag 0).
  Sync
  /// DelayReq (tag 1).
  DelayReq
  /// PdelayReq (tag 2).
  PdelayReq
  /// PdelayResp (tag 3).
  PdelayResp
  /// FollowUp (tag 4).
  FollowUp
  /// DelayResp (tag 5).
  DelayResp
  /// PdelayRespFollowUp (tag 6).
  PdelayRespFollowUp
  /// Announce (tag 7).
  Announce
  /// Signaling (tag 8).
  Signaling
  /// Management (tag 9).
  Management
}

/// Convert a `PtpMessageType` to its C-ABI tag value.
pub fn ptp_message_type_to_int(value: PtpMessageType) -> Int {
  case value {
    Sync -> 0
    DelayReq -> 1
    PdelayReq -> 2
    PdelayResp -> 3
    FollowUp -> 4
    DelayResp -> 5
    PdelayRespFollowUp -> 6
    Announce -> 7
    Signaling -> 8
    Management -> 9
  }
}

/// Decode from a C-ABI tag value.
pub fn ptp_message_type_from_int(tag: Int) -> Result(PtpMessageType, Nil) {
  case tag {
    0 -> Ok(Sync)
    1 -> Ok(DelayReq)
    2 -> Ok(PdelayReq)
    3 -> Ok(PdelayResp)
    4 -> Ok(FollowUp)
    5 -> Ok(DelayResp)
    6 -> Ok(PdelayRespFollowUp)
    7 -> Ok(Announce)
    8 -> Ok(Signaling)
    9 -> Ok(Management)
    _ -> Error(Nil)
  }
}

// ===========================================================================
// ClockClass
// ===========================================================================

/// PTP clock classes.
/// 
/// Matches `ClockClass` in `PtpABI.Types`.
pub type ClockClass {
  /// PrimaryClock (tag 0).
  PrimaryClock
  /// ApplicationSpecific (tag 1).
  ApplicationSpecific
  /// SlaveOnly (tag 2).
  SlaveOnly
  /// DefaultClass (tag 3).
  DefaultClass
}

/// Convert a `ClockClass` to its C-ABI tag value.
pub fn clock_class_to_int(value: ClockClass) -> Int {
  case value {
    PrimaryClock -> 0
    ApplicationSpecific -> 1
    SlaveOnly -> 2
    DefaultClass -> 3
  }
}

/// Decode from a C-ABI tag value.
pub fn clock_class_from_int(tag: Int) -> Result(ClockClass, Nil) {
  case tag {
    0 -> Ok(PrimaryClock)
    1 -> Ok(ApplicationSpecific)
    2 -> Ok(SlaveOnly)
    3 -> Ok(DefaultClass)
    _ -> Error(Nil)
  }
}

// ===========================================================================
// PtpPortState
// ===========================================================================

/// PTP port states (IEEE 1588).
/// 
/// Matches `PtpPortState` in `PtpABI.Types`.
pub type PtpPortState {
  /// Initializing (tag 0).
  Initializing
  /// Faulty (tag 1).
  Faulty
  /// Disabled (tag 2).
  Disabled
  /// Listening (tag 3).
  Listening
  /// PreMaster (tag 4).
  PreMaster
  /// Master (tag 5).
  Master
  /// Passive (tag 6).
  Passive
  /// Uncalibrated (tag 7).
  Uncalibrated
  /// Slave (tag 8).
  Slave
}

/// Convert a `PtpPortState` to its C-ABI tag value.
pub fn ptp_port_state_to_int(value: PtpPortState) -> Int {
  case value {
    Initializing -> 0
    Faulty -> 1
    Disabled -> 2
    Listening -> 3
    PreMaster -> 4
    Master -> 5
    Passive -> 6
    Uncalibrated -> 7
    Slave -> 8
  }
}

/// Decode from a C-ABI tag value.
pub fn ptp_port_state_from_int(tag: Int) -> Result(PtpPortState, Nil) {
  case tag {
    0 -> Ok(Initializing)
    1 -> Ok(Faulty)
    2 -> Ok(Disabled)
    3 -> Ok(Listening)
    4 -> Ok(PreMaster)
    5 -> Ok(Master)
    6 -> Ok(Passive)
    7 -> Ok(Uncalibrated)
    8 -> Ok(Slave)
    _ -> Error(Nil)
  }
}

// ===========================================================================
// DelayMechanism
// ===========================================================================

/// PTP delay measurement mechanisms.
/// 
/// Matches `DelayMechanism` in `PtpABI.Types`.
pub type DelayMechanism {
  /// End-to-end (tag 0).
  E2E
  /// Peer-to-peer (tag 1).
  P2P
  /// Disabled (tag 2).
  DmDisabled
}

/// Convert a `DelayMechanism` to its C-ABI tag value.
pub fn delay_mechanism_to_int(value: DelayMechanism) -> Int {
  case value {
    E2E -> 0
    P2P -> 1
    DmDisabled -> 2
  }
}

/// Decode from a C-ABI tag value.
pub fn delay_mechanism_from_int(tag: Int) -> Result(DelayMechanism, Nil) {
  case tag {
    0 -> Ok(E2E)
    1 -> Ok(P2P)
    2 -> Ok(DmDisabled)
    _ -> Error(Nil)
  }
}

