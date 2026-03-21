//// SPDX-License-Identifier: MPL-2.0
//// (PMPL-1.0-or-later preferred; MPL-2.0 required for Gleam ecosystem)
//// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
////
//// Git Protocol protocol types for the proven-servers ABI.
////
//// Mirrors the Idris2 module `GitABI.Types`.
//// All tag values match the Idris2 ABI definitions exactly.

// ===========================================================================
// Git Protocol Constants
// ===========================================================================

/// Git Port constant.
pub const git_port = 9418

// ===========================================================================
// Command
// ===========================================================================

/// Git protocol commands.
/// 
/// Matches `Command` in `GitABI.Types`.
pub type Command {
  /// git-upload-pack (tag 0).
  UploadPack
  /// git-receive-pack (tag 1).
  ReceivePack
  /// git-upload-archive (tag 2).
  UploadArchive
}

/// Convert a `Command` to its C-ABI tag value.
pub fn command_to_int(value: Command) -> Int {
  case value {
    UploadPack -> 0
    ReceivePack -> 1
    UploadArchive -> 2
  }
}

/// Decode from a C-ABI tag value.
pub fn command_from_int(tag: Int) -> Result(Command, Nil) {
  case tag {
    0 -> Ok(UploadPack)
    1 -> Ok(ReceivePack)
    2 -> Ok(UploadArchive)
    _ -> Error(Nil)
  }
}

// ===========================================================================
// PacketType
// ===========================================================================

/// Git protocol packet types.
/// 
/// Matches `PacketType` in `GitABI.Types`.
pub type PacketType {
  /// Flush (tag 0).
  Flush
  /// Delimiter (tag 1).
  Delimiter
  /// ResponseEnd (tag 2).
  ResponseEnd
  /// Data (tag 3).
  Data
  /// Error packet (tag 4).
  PktError
  /// SidebandData (tag 5).
  SidebandData
  /// SidebandProgress (tag 6).
  SidebandProgress
  /// SidebandError (tag 7).
  SidebandError
}

/// Convert a `PacketType` to its C-ABI tag value.
pub fn packet_type_to_int(value: PacketType) -> Int {
  case value {
    Flush -> 0
    Delimiter -> 1
    ResponseEnd -> 2
    Data -> 3
    PktError -> 4
    SidebandData -> 5
    SidebandProgress -> 6
    SidebandError -> 7
  }
}

/// Decode from a C-ABI tag value.
pub fn packet_type_from_int(tag: Int) -> Result(PacketType, Nil) {
  case tag {
    0 -> Ok(Flush)
    1 -> Ok(Delimiter)
    2 -> Ok(ResponseEnd)
    3 -> Ok(Data)
    4 -> Ok(PktError)
    5 -> Ok(SidebandData)
    6 -> Ok(SidebandProgress)
    7 -> Ok(SidebandError)
    _ -> Error(Nil)
  }
}

// ===========================================================================
// RefType
// ===========================================================================

/// Git reference types.
/// 
/// Matches `RefType` in `GitABI.Types`.
pub type RefType {
  /// Branch (tag 0).
  Branch
  /// Tag (tag 1).
  Tag
  /// Head (tag 2).
  Head
  /// Remote (tag 3).
  Remote
  /// Note (tag 4).
  GitNote
}

/// Convert a `RefType` to its C-ABI tag value.
pub fn ref_type_to_int(value: RefType) -> Int {
  case value {
    Branch -> 0
    Tag -> 1
    Head -> 2
    Remote -> 3
    GitNote -> 4
  }
}

/// Decode from a C-ABI tag value.
pub fn ref_type_from_int(tag: Int) -> Result(RefType, Nil) {
  case tag {
    0 -> Ok(Branch)
    1 -> Ok(Tag)
    2 -> Ok(Head)
    3 -> Ok(Remote)
    4 -> Ok(GitNote)
    _ -> Error(Nil)
  }
}

// ===========================================================================
// Capability
// ===========================================================================

/// Git protocol capabilities.
/// 
/// Matches `Capability` in `GitABI.Types`.
pub type Capability {
  /// MultiAck (tag 0).
  MultiAck
  /// ThinPack (tag 1).
  ThinPack
  /// SideBand64k (tag 2).
  SideBand64k
  /// OFS-delta (tag 3).
  OfsDelta
  /// Shallow (tag 4).
  Shallow
  /// DeepenSince (tag 5).
  DeepenSince
  /// DeepenNot (tag 6).
  DeepenNot
  /// FilterSpec (tag 7).
  FilterSpec
  /// ObjectFormat (tag 8).
  ObjectFormat
}

/// Convert a `Capability` to its C-ABI tag value.
pub fn capability_to_int(value: Capability) -> Int {
  case value {
    MultiAck -> 0
    ThinPack -> 1
    SideBand64k -> 2
    OfsDelta -> 3
    Shallow -> 4
    DeepenSince -> 5
    DeepenNot -> 6
    FilterSpec -> 7
    ObjectFormat -> 8
  }
}

/// Decode from a C-ABI tag value.
pub fn capability_from_int(tag: Int) -> Result(Capability, Nil) {
  case tag {
    0 -> Ok(MultiAck)
    1 -> Ok(ThinPack)
    2 -> Ok(SideBand64k)
    3 -> Ok(OfsDelta)
    4 -> Ok(Shallow)
    5 -> Ok(DeepenSince)
    6 -> Ok(DeepenNot)
    7 -> Ok(FilterSpec)
    8 -> Ok(ObjectFormat)
    _ -> Error(Nil)
  }
}

// ===========================================================================
// HookResult
// ===========================================================================

/// Git hook results.
/// 
/// Matches `HookResult` in `GitABI.Types`.
pub type HookResult {
  /// Accept (tag 0).
  Accept
  /// Reject (tag 1).
  Reject
}

/// Convert a `HookResult` to its C-ABI tag value.
pub fn hook_result_to_int(value: HookResult) -> Int {
  case value {
    Accept -> 0
    Reject -> 1
  }
}

/// Decode from a C-ABI tag value.
pub fn hook_result_from_int(tag: Int) -> Result(HookResult, Nil) {
  case tag {
    0 -> Ok(Accept)
    1 -> Ok(Reject)
    _ -> Error(Nil)
  }
}

// ===========================================================================
// ServerState
// ===========================================================================

/// Git server states.
/// 
/// Matches `ServerState` in `GitABI.Types`.
pub type ServerState {
  /// Idle (tag 0).
  Idle
  /// Discovery (tag 1).
  Discovery
  /// Negotiating (tag 2).
  Negotiating
  /// Transfer (tag 3).
  Transfer
  /// Shutdown (tag 4).
  Shutdown
}

/// Convert a `ServerState` to its C-ABI tag value.
pub fn server_state_to_int(value: ServerState) -> Int {
  case value {
    Idle -> 0
    Discovery -> 1
    Negotiating -> 2
    Transfer -> 3
    Shutdown -> 4
  }
}

/// Decode from a C-ABI tag value.
pub fn server_state_from_int(tag: Int) -> Result(ServerState, Nil) {
  case tag {
    0 -> Ok(Idle)
    1 -> Ok(Discovery)
    2 -> Ok(Negotiating)
    3 -> Ok(Transfer)
    4 -> Ok(Shutdown)
    _ -> Error(Nil)
  }
}

