//// SPDX-License-Identifier: MPL-2.0
//// (PMPL-1.0-or-later preferred; MPL-2.0 required for Gleam ecosystem)
//// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
////
//// Federation (ActivityPub) protocol types for the proven-servers ABI.
////
//// Mirrors the Idris2 module `FederationABI.Types`.
//// All tag values match the Idris2 ABI definitions exactly.

// ===========================================================================
// ActivityType
// ===========================================================================

/// ActivityPub activity types.
/// 
/// Matches `ActivityType` in `FederationABI.Types`.
pub type ActivityType {
  /// Create (tag 0).
  Create
  /// Update (tag 1).
  Update
  /// Delete (tag 2).
  Delete
  /// Follow (tag 3).
  Follow
  /// Accept (tag 4).
  Accept
  /// Reject (tag 5).
  Reject
  /// Announce (tag 6).
  Announce
  /// Like (tag 7).
  Like
  /// Undo (tag 8).
  Undo
  /// Block (tag 9).
  Block
  /// Flag (tag 10).
  Flag
}

/// Convert a `ActivityType` to its C-ABI tag value.
pub fn activity_type_to_int(value: ActivityType) -> Int {
  case value {
    Create -> 0
    Update -> 1
    Delete -> 2
    Follow -> 3
    Accept -> 4
    Reject -> 5
    Announce -> 6
    Like -> 7
    Undo -> 8
    Block -> 9
    Flag -> 10
  }
}

/// Decode from a C-ABI tag value.
pub fn activity_type_from_int(tag: Int) -> Result(ActivityType, Nil) {
  case tag {
    0 -> Ok(Create)
    1 -> Ok(Update)
    2 -> Ok(Delete)
    3 -> Ok(Follow)
    4 -> Ok(Accept)
    5 -> Ok(Reject)
    6 -> Ok(Announce)
    7 -> Ok(Like)
    8 -> Ok(Undo)
    9 -> Ok(Block)
    10 -> Ok(Flag)
    _ -> Error(Nil)
  }
}

// ===========================================================================
// ActorType
// ===========================================================================

/// ActivityPub actor types.
/// 
/// Matches `ActorType` in `FederationABI.Types`.
pub type ActorType {
  /// Person (tag 0).
  Person
  /// Service (tag 1).
  Service
  /// Application (tag 2).
  Application
  /// Group (tag 3).
  Group
  /// Organization (tag 4).
  Organization
}

/// Convert a `ActorType` to its C-ABI tag value.
pub fn actor_type_to_int(value: ActorType) -> Int {
  case value {
    Person -> 0
    Service -> 1
    Application -> 2
    Group -> 3
    Organization -> 4
  }
}

/// Decode from a C-ABI tag value.
pub fn actor_type_from_int(tag: Int) -> Result(ActorType, Nil) {
  case tag {
    0 -> Ok(Person)
    1 -> Ok(Service)
    2 -> Ok(Application)
    3 -> Ok(Group)
    4 -> Ok(Organization)
    _ -> Error(Nil)
  }
}

// ===========================================================================
// DeliveryStatus
// ===========================================================================

/// Federation delivery statuses.
/// 
/// Matches `DeliveryStatus` in `FederationABI.Types`.
pub type DeliveryStatus {
  /// Pending (tag 0).
  Pending
  /// Delivered (tag 1).
  Delivered
  /// Failed (tag 2).
  Failed
  /// Rejected (tag 3).
  Rejected
  /// Deferred (tag 4).
  Deferred
}

/// Convert a `DeliveryStatus` to its C-ABI tag value.
pub fn delivery_status_to_int(value: DeliveryStatus) -> Int {
  case value {
    Pending -> 0
    Delivered -> 1
    Failed -> 2
    Rejected -> 3
    Deferred -> 4
  }
}

/// Decode from a C-ABI tag value.
pub fn delivery_status_from_int(tag: Int) -> Result(DeliveryStatus, Nil) {
  case tag {
    0 -> Ok(Pending)
    1 -> Ok(Delivered)
    2 -> Ok(Failed)
    3 -> Ok(Rejected)
    4 -> Ok(Deferred)
    _ -> Error(Nil)
  }
}

// ===========================================================================
// TrustLevel
// ===========================================================================

/// Federation trust levels.
/// 
/// Matches `TrustLevel` in `FederationABI.Types`.
pub type TrustLevel {
  /// SelfSigned (tag 0).
  SelfSigned
  /// PeerVerified (tag 1).
  PeerVerified
  /// FederationTrusted (tag 2).
  FederationTrusted
  /// Revoked (tag 3).
  Revoked
  /// Unknown (tag 4).
  Unknown
}

/// Convert a `TrustLevel` to its C-ABI tag value.
pub fn trust_level_to_int(value: TrustLevel) -> Int {
  case value {
    SelfSigned -> 0
    PeerVerified -> 1
    FederationTrusted -> 2
    Revoked -> 3
    Unknown -> 4
  }
}

/// Decode from a C-ABI tag value.
pub fn trust_level_from_int(tag: Int) -> Result(TrustLevel, Nil) {
  case tag {
    0 -> Ok(SelfSigned)
    1 -> Ok(PeerVerified)
    2 -> Ok(FederationTrusted)
    3 -> Ok(Revoked)
    4 -> Ok(Unknown)
    _ -> Error(Nil)
  }
}

// ===========================================================================
// ObjectType
// ===========================================================================

/// ActivityPub object types.
/// 
/// Matches `ObjectType` in `FederationABI.Types`.
pub type ObjectType {
  /// Note (tag 0).
  Note
  /// Article (tag 1).
  Article
  /// Image (tag 2).
  Image
  /// Video (tag 3).
  Video
  /// Audio (tag 4).
  Audio
  /// Document (tag 5).
  Document
  /// Event (tag 6).
  Event
  /// Collection (tag 7).
  Collection
  /// OrderedCollection (tag 8).
  OrderedCollection
}

/// Convert a `ObjectType` to its C-ABI tag value.
pub fn object_type_to_int(value: ObjectType) -> Int {
  case value {
    Note -> 0
    Article -> 1
    Image -> 2
    Video -> 3
    Audio -> 4
    Document -> 5
    Event -> 6
    Collection -> 7
    OrderedCollection -> 8
  }
}

/// Decode from a C-ABI tag value.
pub fn object_type_from_int(tag: Int) -> Result(ObjectType, Nil) {
  case tag {
    0 -> Ok(Note)
    1 -> Ok(Article)
    2 -> Ok(Image)
    3 -> Ok(Video)
    4 -> Ok(Audio)
    5 -> Ok(Document)
    6 -> Ok(Event)
    7 -> Ok(Collection)
    8 -> Ok(OrderedCollection)
    _ -> Error(Nil)
  }
}

// ===========================================================================
// ServerState
// ===========================================================================

/// Federation server states.
/// 
/// Matches `ServerState` in `FederationABI.Types`.
pub type ServerState {
  /// Idle (tag 0).
  Idle
  /// Active (tag 1).
  Active
  /// Processing (tag 2).
  Processing
  /// Delivering (tag 3).
  Delivering
  /// Shutdown (tag 4).
  Shutdown
}

/// Convert a `ServerState` to its C-ABI tag value.
pub fn server_state_to_int(value: ServerState) -> Int {
  case value {
    Idle -> 0
    Active -> 1
    Processing -> 2
    Delivering -> 3
    Shutdown -> 4
  }
}

/// Decode from a C-ABI tag value.
pub fn server_state_from_int(tag: Int) -> Result(ServerState, Nil) {
  case tag {
    0 -> Ok(Idle)
    1 -> Ok(Active)
    2 -> Ok(Processing)
    3 -> Ok(Delivering)
    4 -> Ok(Shutdown)
    _ -> Error(Nil)
  }
}

