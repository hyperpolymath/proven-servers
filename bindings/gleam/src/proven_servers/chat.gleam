//// SPDX-License-Identifier: MPL-2.0
//// (PMPL-1.0-or-later preferred; MPL-2.0 required for Gleam ecosystem)
//// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
////
//// Chat protocol types for the proven-servers ABI.
////
//// Mirrors the Idris2 module `ChatABI.Types`.
//// All tag values match the Idris2 ABI definitions exactly.

// ===========================================================================
// MessageType
// ===========================================================================

/// Chat message types.
/// 
/// Matches `MessageType` in `ChatABI.Types`.
pub type MessageType {
  /// Text (tag 0).
  Text
  /// Image (tag 1).
  Image
  /// File (tag 2).
  File
  /// System (tag 3).
  System
  /// Reaction (tag 4).
  Reaction
  /// Edit (tag 5).
  Edit
  /// Delete (tag 6).
  Delete
  /// Reply (tag 7).
  Reply
  /// Thread (tag 8).
  Thread
}

/// Convert a `MessageType` to its C-ABI tag value.
pub fn message_type_to_int(value: MessageType) -> Int {
  case value {
    Text -> 0
    Image -> 1
    File -> 2
    System -> 3
    Reaction -> 4
    Edit -> 5
    Delete -> 6
    Reply -> 7
    Thread -> 8
  }
}

/// Decode from a C-ABI tag value.
pub fn message_type_from_int(tag: Int) -> Result(MessageType, Nil) {
  case tag {
    0 -> Ok(Text)
    1 -> Ok(Image)
    2 -> Ok(File)
    3 -> Ok(System)
    4 -> Ok(Reaction)
    5 -> Ok(Edit)
    6 -> Ok(Delete)
    7 -> Ok(Reply)
    8 -> Ok(Thread)
    _ -> Error(Nil)
  }
}

// ===========================================================================
// PresenceStatus
// ===========================================================================

/// User presence statuses.
/// 
/// Matches `PresenceStatus` in `ChatABI.Types`.
pub type PresenceStatus {
  /// Online (tag 0).
  Online
  /// Away (tag 1).
  Away
  /// Do Not Disturb (tag 2).
  Dnd
  /// Invisible (tag 3).
  Invisible
  /// Offline (tag 4).
  Offline
}

/// Convert a `PresenceStatus` to its C-ABI tag value.
pub fn presence_status_to_int(value: PresenceStatus) -> Int {
  case value {
    Online -> 0
    Away -> 1
    Dnd -> 2
    Invisible -> 3
    Offline -> 4
  }
}

/// Decode from a C-ABI tag value.
pub fn presence_status_from_int(tag: Int) -> Result(PresenceStatus, Nil) {
  case tag {
    0 -> Ok(Online)
    1 -> Ok(Away)
    2 -> Ok(Dnd)
    3 -> Ok(Invisible)
    4 -> Ok(Offline)
    _ -> Error(Nil)
  }
}

// ===========================================================================
// RoomType
// ===========================================================================

/// Chat room types.
/// 
/// Matches `RoomType` in `ChatABI.Types`.
pub type RoomType {
  /// Direct (tag 0).
  Direct
  /// Group (tag 1).
  Group
  /// Channel (tag 2).
  Channel
  /// Broadcast (tag 3).
  Broadcast
}

/// Convert a `RoomType` to its C-ABI tag value.
pub fn room_type_to_int(value: RoomType) -> Int {
  case value {
    Direct -> 0
    Group -> 1
    Channel -> 2
    Broadcast -> 3
  }
}

/// Decode from a C-ABI tag value.
pub fn room_type_from_int(tag: Int) -> Result(RoomType, Nil) {
  case tag {
    0 -> Ok(Direct)
    1 -> Ok(Group)
    2 -> Ok(Channel)
    3 -> Ok(Broadcast)
    _ -> Error(Nil)
  }
}

// ===========================================================================
// Permission
// ===========================================================================

/// Chat permissions.
/// 
/// Matches `Permission` in `ChatABI.Types`.
pub type Permission {
  /// Read (tag 0).
  Read
  /// Write (tag 1).
  Write
  /// Admin (tag 2).
  Admin
  /// Invite (tag 3).
  Invite
  /// Kick (tag 4).
  Kick
  /// Ban (tag 5).
  Ban
  /// Pin (tag 6).
  Pin
  /// DeleteOthers (tag 7).
  DeleteOthers
}

/// Convert a `Permission` to its C-ABI tag value.
pub fn permission_to_int(value: Permission) -> Int {
  case value {
    Read -> 0
    Write -> 1
    Admin -> 2
    Invite -> 3
    Kick -> 4
    Ban -> 5
    Pin -> 6
    DeleteOthers -> 7
  }
}

/// Decode from a C-ABI tag value.
pub fn permission_from_int(tag: Int) -> Result(Permission, Nil) {
  case tag {
    0 -> Ok(Read)
    1 -> Ok(Write)
    2 -> Ok(Admin)
    3 -> Ok(Invite)
    4 -> Ok(Kick)
    5 -> Ok(Ban)
    6 -> Ok(Pin)
    7 -> Ok(DeleteOthers)
    _ -> Error(Nil)
  }
}

// ===========================================================================
// Event
// ===========================================================================

/// Chat events.
/// 
/// Matches `Event` in `ChatABI.Types`.
pub type Event {
  /// MessageSent (tag 0).
  MessageSent
  /// MessageDelivered (tag 1).
  MessageDelivered
  /// MessageRead (tag 2).
  MessageRead
  /// UserJoined (tag 3).
  UserJoined
  /// UserLeft (tag 4).
  UserLeft
  /// Typing (tag 5).
  Typing
  /// RoomCreated (tag 6).
  RoomCreated
}

/// Convert a `Event` to its C-ABI tag value.
pub fn event_to_int(value: Event) -> Int {
  case value {
    MessageSent -> 0
    MessageDelivered -> 1
    MessageRead -> 2
    UserJoined -> 3
    UserLeft -> 4
    Typing -> 5
    RoomCreated -> 6
  }
}

/// Decode from a C-ABI tag value.
pub fn event_from_int(tag: Int) -> Result(Event, Nil) {
  case tag {
    0 -> Ok(MessageSent)
    1 -> Ok(MessageDelivered)
    2 -> Ok(MessageRead)
    3 -> Ok(UserJoined)
    4 -> Ok(UserLeft)
    5 -> Ok(Typing)
    6 -> Ok(RoomCreated)
    _ -> Error(Nil)
  }
}

