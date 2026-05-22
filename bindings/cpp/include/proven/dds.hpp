// SPDX-License-Identifier: MPL-2.0
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
/// @file dds.hpp
/// @brief DDS protocol types for proven-servers.

#ifndef PROVEN_DDS_HPP
#define PROVEN_DDS_HPP

#include <cstdint>

namespace proven {

/// @brief ReliabilityKind matching the Idris2 ABI tags.
enum class ReliabilityKind : uint8_t {
    BestEffort = 0,
    Reliable = 1
};

/// @brief DurabilityKind matching the Idris2 ABI tags.
enum class DurabilityKind : uint8_t {
    TransientLocal = 0,
    Transient = 1,
    Persistent = 2
};

/// @brief HistoryKind matching the Idris2 ABI tags.
enum class HistoryKind : uint8_t {
    KeepLast = 0,
    KeepAll = 1
};

/// @brief OwnershipKind matching the Idris2 ABI tags.
enum class OwnershipKind : uint8_t {
    Shared = 0,
    Exclusive = 1
};

/// @brief EntityType matching the Idris2 ABI tags.
enum class EntityType : uint8_t {
    Participant = 0,
    Publisher = 1,
    Subscriber = 2,
    Topic = 3,
    DataWriter = 4,
    DataReader = 5
};

/// @brief ParticipantState matching the Idris2 ABI tags.
enum class ParticipantState : uint8_t {
    Idle = 0,
    Joined = 1,
    Publishing = 2,
    Subscribing = 3,
    Leaving = 4
};

} // namespace proven

#endif // PROVEN_DDS_HPP
