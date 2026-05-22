// SPDX-License-Identifier: MPL-2.0
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
/// @file siem.hpp
/// @brief SIEM protocol types for proven-servers.

#ifndef PROVEN_SIEM_HPP
#define PROVEN_SIEM_HPP

#include <cstdint>

namespace proven {

/// @brief EventSeverity matching the Idris2 ABI tags.
enum class EventSeverity : uint8_t {
    Info = 0,
    Low = 1,
    Medium = 2,
    High = 3,
    Critical = 4
};

/// @brief EventCategory matching the Idris2 ABI tags.
enum class EventCategory : uint8_t {
    Authentication = 0,
    NetworkTraffic = 1,
    FileActivity = 2,
    ProcessExecution = 3,
    PolicyViolation = 4,
    Malware = 5,
    DataExfiltration = 6
};

/// @brief CorrelationRule matching the Idris2 ABI tags.
enum class CorrelationRule : uint8_t {
    Threshold = 0,
    Sequence = 1,
    Aggregation = 2,
    Absence = 3,
    Statistical = 4
};

/// @brief AlertState matching the Idris2 ABI tags.
enum class AlertState : uint8_t {
    New = 0,
    Acknowledged = 1,
    InProgress = 2,
    Resolved = 3,
    FalsePositive = 4
};

} // namespace proven

#endif // PROVEN_SIEM_HPP
