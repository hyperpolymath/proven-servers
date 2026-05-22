// SPDX-License-Identifier: MPL-2.0
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
/// @file opcua.hpp
/// @brief OPC UA protocol types for proven-servers.

#ifndef PROVEN_OPCUA_HPP
#define PROVEN_OPCUA_HPP

#include <cstdint>

namespace proven {

/// @brief ServiceType matching the Idris2 ABI tags.
enum class ServiceType : uint8_t {
    Read = 0,
    Write = 1,
    Browse = 2,
    Subscribe = 3,
    Publish = 4,
    Call = 5,
    CreateSession = 6,
    ActivateSession = 7,
    CloseSession = 8,
    CreateSubscription = 9,
    DeleteSubscription = 10
};

/// @brief NodeClass matching the Idris2 ABI tags.
enum class NodeClass : uint8_t {
    Object = 0,
    Variable = 1,
    Method = 2,
    ObjectType = 3,
    VariableType = 4,
    ReferenceType = 5,
    DataType = 6,
    View = 7
};

/// @brief StatusCode matching the Idris2 ABI tags.
enum class StatusCode : uint8_t {
    Good = 0,
    Uncertain = 1,
    Bad = 2,
    BadNodeIdUnknown = 3,
    BadAttributeIdInvalid = 4,
    BadNotReadable = 5,
    BadNotWritable = 6,
    BadOutOfRange = 7,
    BadTypeMismatch = 8,
    BadSessionIdInvalid = 9,
    BadSubscriptionIdInvalid = 10,
    BadTimeout = 11
};

/// @brief SecurityMode matching the Idris2 ABI tags.
enum class SecurityMode : uint8_t {
    None = 0,
    Sign = 1,
    SignAndEncrypt = 2
};

/// @brief SessionState matching the Idris2 ABI tags.
enum class SessionState : uint8_t {
    Idle = 0,
    Connected = 1,
    Created = 2,
    Activated = 3,
    Monitoring = 4,
    Closing = 5
};

} // namespace proven

#endif // PROVEN_OPCUA_HPP
