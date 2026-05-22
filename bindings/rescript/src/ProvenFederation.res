// SPDX-License-Identifier: MPL-2.0
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
// Federation types for the proven-servers ABI.
//
// Mirrors the Idris2 module FederationABI.Types.
// All tag values match the Idris2 ABI tag definitions exactly.

// ===========================================================================
// ActivityType (tags 0-10)
// ===========================================================================

/// ActivityPub activity types.
type activityType =
  | @as(0) Create
  | @as(1) Update
  | @as(2) Delete
  | @as(3) Follow
  | @as(4) Accept
  | @as(5) Reject
  | @as(6) Announce
  | @as(7) Like
  | @as(8) Undo
  | @as(9) Block
  | @as(10) Flag

/// Decode from the C-ABI tag value.
let activityTypeFromTag = (tag: int): option<activityType> =>
  switch tag {
  | 0 => Some(Create)
  | 1 => Some(Update)
  | 2 => Some(Delete)
  | 3 => Some(Follow)
  | 4 => Some(Accept)
  | 5 => Some(Reject)
  | 6 => Some(Announce)
  | 7 => Some(Like)
  | 8 => Some(Undo)
  | 9 => Some(Block)
  | 10 => Some(Flag)
  | _ => None
  }

/// Encode to the C-ABI tag value.
let activityTypeToTag = (v: activityType): int =>
  switch v {
  | Create => 0
  | Update => 1
  | Delete => 2
  | Follow => 3
  | Accept => 4
  | Reject => 5
  | Announce => 6
  | Like => 7
  | Undo => 8
  | Block => 9
  | Flag => 10
  }

// ===========================================================================
// ActorType (tags 0-4)
// ===========================================================================

/// Decode from an ABI tag value.
type actorType =
  | @as(0) Person
  | @as(1) Service
  | @as(2) Application
  | @as(3) Group
  | @as(4) Organization

/// Decode from the C-ABI tag value.
let actorTypeFromTag = (tag: int): option<actorType> =>
  switch tag {
  | 0 => Some(Person)
  | 1 => Some(Service)
  | 2 => Some(Application)
  | 3 => Some(Group)
  | 4 => Some(Organization)
  | _ => None
  }

/// Encode to the C-ABI tag value.
let actorTypeToTag = (v: actorType): int =>
  switch v {
  | Person => 0
  | Service => 1
  | Application => 2
  | Group => 3
  | Organization => 4
  }

// ===========================================================================
// DeliveryStatus (tags 0-4)
// ===========================================================================

/// Decode from an ABI tag value.
type deliveryStatus =
  | @as(0) Pending
  | @as(1) Delivered
  | @as(2) Failed
  | @as(3) Rejected
  | @as(4) Deferred

/// Decode from the C-ABI tag value.
let deliveryStatusFromTag = (tag: int): option<deliveryStatus> =>
  switch tag {
  | 0 => Some(Pending)
  | 1 => Some(Delivered)
  | 2 => Some(Failed)
  | 3 => Some(Rejected)
  | 4 => Some(Deferred)
  | _ => None
  }

/// Encode to the C-ABI tag value.
let deliveryStatusToTag = (v: deliveryStatus): int =>
  switch v {
  | Pending => 0
  | Delivered => 1
  | Failed => 2
  | Rejected => 3
  | Deferred => 4
  }

// ===========================================================================
// TrustLevel (tags 0-4)
// ===========================================================================

/// Decode from an ABI tag value.
type trustLevel =
  | @as(0) SelfSigned
  | @as(1) PeerVerified
  | @as(2) FederationTrusted
  | @as(3) Revoked
  | @as(4) Unknown

/// Decode from the C-ABI tag value.
let trustLevelFromTag = (tag: int): option<trustLevel> =>
  switch tag {
  | 0 => Some(SelfSigned)
  | 1 => Some(PeerVerified)
  | 2 => Some(FederationTrusted)
  | 3 => Some(Revoked)
  | 4 => Some(Unknown)
  | _ => None
  }

/// Encode to the C-ABI tag value.
let trustLevelToTag = (v: trustLevel): int =>
  switch v {
  | SelfSigned => 0
  | PeerVerified => 1
  | FederationTrusted => 2
  | Revoked => 3
  | Unknown => 4
  }

// ===========================================================================
// ObjectType (tags 0-8)
// ===========================================================================

/// Decode from an ABI tag value.
type objectType =
  | @as(0) Note
  | @as(1) Article
  | @as(2) Image
  | @as(3) Video
  | @as(4) Audio
  | @as(5) Document
  | @as(6) Event
  | @as(7) Collection
  | @as(8) OrderedCollection

/// Decode from the C-ABI tag value.
let objectTypeFromTag = (tag: int): option<objectType> =>
  switch tag {
  | 0 => Some(Note)
  | 1 => Some(Article)
  | 2 => Some(Image)
  | 3 => Some(Video)
  | 4 => Some(Audio)
  | 5 => Some(Document)
  | 6 => Some(Event)
  | 7 => Some(Collection)
  | 8 => Some(OrderedCollection)
  | _ => None
  }

/// Encode to the C-ABI tag value.
let objectTypeToTag = (v: objectType): int =>
  switch v {
  | Note => 0
  | Article => 1
  | Image => 2
  | Video => 3
  | Audio => 4
  | Document => 5
  | Event => 6
  | Collection => 7
  | OrderedCollection => 8
  }

// ===========================================================================
// ServerState (tags 0-4)
// ===========================================================================

/// Decode from an ABI tag value.
type serverState =
  | @as(0) Idle
  | @as(1) Active
  | @as(2) Processing
  | @as(3) Delivering
  | @as(4) Shutdown

/// Decode from the C-ABI tag value.
let serverStateFromTag = (tag: int): option<serverState> =>
  switch tag {
  | 0 => Some(Idle)
  | 1 => Some(Active)
  | 2 => Some(Processing)
  | 3 => Some(Delivering)
  | 4 => Some(Shutdown)
  | _ => None
  }

/// Encode to the C-ABI tag value.
let serverStateToTag = (v: serverState): int =>
  switch v {
  | Idle => 0
  | Active => 1
  | Processing => 2
  | Delivering => 3
  | Shutdown => 4
  }

