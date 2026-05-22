// SPDX-License-Identifier: MPL-2.0
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
/// @file federation.hpp
/// @brief Federation protocol types for proven-servers.

#ifndef PROVEN_FEDERATION_HPP
#define PROVEN_FEDERATION_HPP

#include <cstdint>

namespace proven {

/// @brief ActivityType matching the Idris2 ABI tags.
enum class ActivityType : uint8_t {
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
};

/// @brief ActorType matching the Idris2 ABI tags.
enum class ActorType : uint8_t {
    Person = 0,
    Service = 1,
    Application = 2,
    Group = 3,
    Organization = 4
};

/// @brief DeliveryStatus matching the Idris2 ABI tags.
enum class DeliveryStatus : uint8_t {
    Pending = 0,
    Delivered = 1,
    Failed = 2,
    Rejected = 3,
    Deferred = 4
};

/// @brief TrustLevel matching the Idris2 ABI tags.
enum class TrustLevel : uint8_t {
    SelfSigned = 0,
    PeerVerified = 1,
    FederationTrusted = 2,
    Revoked = 3,
    Unknown = 4
};

/// @brief ObjectType matching the Idris2 ABI tags.
enum class ObjectType : uint8_t {
    Note = 0,
    Article = 1,
    Image = 2,
    Video = 3,
    Audio = 4,
    Document = 5,
    Event = 6,
    Collection = 7,
    OrderedCollection = 8
};

/// @brief ServerState matching the Idris2 ABI tags.
enum class ServerState : uint8_t {
    Idle = 0,
    Active = 1,
    Processing = 2,
    Delivering = 3,
    Shutdown = 4
};

} // namespace proven

#endif // PROVEN_FEDERATION_HPP
