// SPDX-License-Identifier: PMPL-1.0-or-later
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
/// @file monitor.hpp
/// @brief Monitor protocol types for proven-servers.

#ifndef PROVEN_MONITOR_HPP
#define PROVEN_MONITOR_HPP

#include <cstdint>

namespace proven {

/// @brief CheckType matching the Idris2 ABI tags.
enum class CheckType : uint8_t {
    Http = 0,
    Tcp = 1,
    Udp = 2,
    Icmp = 3,
    Dns = 4,
    Certificate = 5,
    Disk = 6,
    Cpu = 7,
    Memory = 8,
    Process = 9,
    Custom = 10
};

/// @brief Status matching the Idris2 ABI tags.
enum class Status : uint8_t {
    Up = 0,
    Down = 1,
    Degraded = 2,
    Unknown = 3,
    Maintenance = 4
};

/// @brief AlertChannel matching the Idris2 ABI tags.
enum class AlertChannel : uint8_t {
    Email = 0,
    Sms = 1,
    Webhook = 2,
    Slack = 3,
    PagerDuty = 4
};

/// @brief Severity matching the Idris2 ABI tags.
enum class Severity : uint8_t {
    Info = 0,
    Warning = 1,
    Error = 2,
    Critical = 3
};

/// @brief CheckState matching the Idris2 ABI tags.
enum class CheckState : uint8_t {
    Pending = 0,
    Running = 1,
    Passed = 2,
    Failed = 3,
    Timeout = 4,
    CsError = 5
};

/// @brief MonitorState matching the Idris2 ABI tags.
enum class MonitorState : uint8_t {
    Idle = 0,
    Configured = 1,
    Running = 2,
    MonPaused = 3,
    Alerting = 4,
    Shutdown = 5
};

} // namespace proven

#endif // PROVEN_MONITOR_HPP
