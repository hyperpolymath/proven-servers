// SPDX-License-Identifier: MPL-2.0
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
// Federation protocol types for proven-servers.

namespace Proven;

/// <summary>ActivityType matching the Idris2 ABI tags (0-10).</summary>
public enum ActivityType : byte
{
    Create = 0,
    Update = 1,
    Delete = 2,
    Follow = 3,
    Accept = 4,
    Reject = 5,
    Announce = 6,
    Like = 7,
    Undo = 8,
    Block = 9,
    Flag = 10
}

/// <summary>ActorType matching the Idris2 ABI tags (0-4).</summary>
public enum ActorType : byte
{
    Person = 0,
    Service = 1,
    Application = 2,
    Group = 3,
    Organization = 4
}

/// <summary>DeliveryStatus matching the Idris2 ABI tags (0-4).</summary>
public enum DeliveryStatus : byte
{
    Pending = 0,
    Delivered = 1,
    Failed = 2,
    Rejected = 3,
    Deferred = 4
}

/// <summary>TrustLevel matching the Idris2 ABI tags (0-4).</summary>
public enum TrustLevel : byte
{
    SelfSigned = 0,
    PeerVerified = 1,
    FederationTrusted = 2,
    Revoked = 3,
    Unknown = 4
}

/// <summary>ObjectType matching the Idris2 ABI tags (0-8).</summary>
public enum ObjectType : byte
{
    Note = 0,
    Article = 1,
    Image = 2,
    Video = 3,
    Audio = 4,
    Document = 5,
    Event = 6,
    Collection = 7,
    OrderedCollection = 8
}

/// <summary>ServerState matching the Idris2 ABI tags (0-4).</summary>
public enum ServerState : byte
{
    Idle = 0,
    Active = 1,
    Processing = 2,
    Delivering = 3,
    Shutdown = 4
}
