// SPDX-License-Identifier: MPL-2.0
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
// Chat Server types for the proven-servers ABI.
//
// Mirrors the Idris2 module ChatABI.Types.
// All tag values match the Idris2 ABI tag definitions exactly.

// ===========================================================================
// MessageType (tags 0-8)
// ===========================================================================

/// Chat message types.
type messageType =
  | @as(0) Text
  | @as(1) Image
  | @as(2) File
  | @as(3) System
  | @as(4) Reaction
  | @as(5) Edit
  | @as(6) Delete
  | @as(7) Reply
  | @as(8) Thread

/// Decode from the C-ABI tag value.
let messageTypeFromTag = (tag: int): option<messageType> =>
  switch tag {
  | 0 => Some(Text)
  | 1 => Some(Image)
  | 2 => Some(File)
  | 3 => Some(System)
  | 4 => Some(Reaction)
  | 5 => Some(Edit)
  | 6 => Some(Delete)
  | 7 => Some(Reply)
  | 8 => Some(Thread)
  | _ => None
  }

/// Encode to the C-ABI tag value.
let messageTypeToTag = (v: messageType): int =>
  switch v {
  | Text => 0
  | Image => 1
  | File => 2
  | System => 3
  | Reaction => 4
  | Edit => 5
  | Delete => 6
  | Reply => 7
  | Thread => 8
  }

// ===========================================================================
// PresenceStatus (tags 0-4)
// ===========================================================================

/// Decode from an ABI tag value.
type presenceStatus =
  | @as(0) Online
  | @as(1) Away
  | @as(2) Dnd
  | @as(3) Invisible
  | @as(4) Offline

/// Decode from the C-ABI tag value.
let presenceStatusFromTag = (tag: int): option<presenceStatus> =>
  switch tag {
  | 0 => Some(Online)
  | 1 => Some(Away)
  | 2 => Some(Dnd)
  | 3 => Some(Invisible)
  | 4 => Some(Offline)
  | _ => None
  }

/// Encode to the C-ABI tag value.
let presenceStatusToTag = (v: presenceStatus): int =>
  switch v {
  | Online => 0
  | Away => 1
  | Dnd => 2
  | Invisible => 3
  | Offline => 4
  }

// ===========================================================================
// RoomType (tags 0-3)
// ===========================================================================

/// Decode from an ABI tag value.
type roomType =
  | @as(0) Direct
  | @as(1) Group
  | @as(2) Channel
  | @as(3) Broadcast

/// Decode from the C-ABI tag value.
let roomTypeFromTag = (tag: int): option<roomType> =>
  switch tag {
  | 0 => Some(Direct)
  | 1 => Some(Group)
  | 2 => Some(Channel)
  | 3 => Some(Broadcast)
  | _ => None
  }

/// Encode to the C-ABI tag value.
let roomTypeToTag = (v: roomType): int =>
  switch v {
  | Direct => 0
  | Group => 1
  | Channel => 2
  | Broadcast => 3
  }

// ===========================================================================
// Permission (tags 0-7)
// ===========================================================================

/// Decode from an ABI tag value.
type permission =
  | @as(0) Read
  | @as(1) Write
  | @as(2) Admin
  | @as(3) Invite
  | @as(4) Kick
  | @as(5) Ban
  | @as(6) Pin
  | @as(7) DeleteOthers

/// Decode from the C-ABI tag value.
let permissionFromTag = (tag: int): option<permission> =>
  switch tag {
  | 0 => Some(Read)
  | 1 => Some(Write)
  | 2 => Some(Admin)
  | 3 => Some(Invite)
  | 4 => Some(Kick)
  | 5 => Some(Ban)
  | 6 => Some(Pin)
  | 7 => Some(DeleteOthers)
  | _ => None
  }

/// Encode to the C-ABI tag value.
let permissionToTag = (v: permission): int =>
  switch v {
  | Read => 0
  | Write => 1
  | Admin => 2
  | Invite => 3
  | Kick => 4
  | Ban => 5
  | Pin => 6
  | DeleteOthers => 7
  }

// ===========================================================================
// Event (tags 0-6)
// ===========================================================================

/// Decode from an ABI tag value.
type event =
  | @as(0) MessageSent
  | @as(1) MessageDelivered
  | @as(2) MessageRead
  | @as(3) UserJoined
  | @as(4) UserLeft
  | @as(5) Typing
  | @as(6) RoomCreated

/// Decode from the C-ABI tag value.
let eventFromTag = (tag: int): option<event> =>
  switch tag {
  | 0 => Some(MessageSent)
  | 1 => Some(MessageDelivered)
  | 2 => Some(MessageRead)
  | 3 => Some(UserJoined)
  | 4 => Some(UserLeft)
  | 5 => Some(Typing)
  | 6 => Some(RoomCreated)
  | _ => None
  }

/// Encode to the C-ABI tag value.
let eventToTag = (v: event): int =>
  switch v {
  | MessageSent => 0
  | MessageDelivered => 1
  | MessageRead => 2
  | UserJoined => 3
  | UserLeft => 4
  | Typing => 5
  | RoomCreated => 6
  }

