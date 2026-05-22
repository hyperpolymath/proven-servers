// SPDX-License-Identifier: MPL-2.0
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
/// @file ptp.hpp
/// @brief PTP protocol types for proven-servers.

#ifndef PROVEN_PTP_HPP
#define PROVEN_PTP_HPP

#include <cstdint>

namespace proven {

/// @brief PtpMessageType matching the Idris2 ABI tags.
enum class PtpMessageType : uint8_t {
    Sync = 0,
    DelayReq = 1,
    PdelayReq = 2,
    PdelayResp = 3,
    FollowUp = 4,
    DelayResp = 5,
    PdelayRespFollowUp = 6,
    Announce = 7,
    Signaling = 8,
    Management = 9
};

/// @brief ClockClass matching the Idris2 ABI tags.
enum class ClockClass : uint8_t {
    PrimaryClock = 0,
    ApplicationSpecific = 1,
    SlaveOnly = 2,
    DefaultClass = 3
};

/// @brief PtpPortState matching the Idris2 ABI tags.
enum class PtpPortState : uint8_t {
    Initializing = 0,
    Faulty = 1,
    Disabled = 2,
    Listening = 3,
    PreMaster = 4,
    Master = 5,
    Passive = 6,
    Uncalibrated = 7,
    Slave = 8
};

/// @brief DelayMechanism matching the Idris2 ABI tags.
enum class DelayMechanism : uint8_t {
    E2E = 0,
    P2P = 1,
    DmDisabled = 2
};

} // namespace proven

#endif // PROVEN_PTP_HPP
