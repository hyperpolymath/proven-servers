// SPDX-License-Identifier: PMPL-1.0-or-later
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
/// @file lpd.hpp
/// @brief LPD protocol types for proven-servers.

#ifndef PROVEN_LPD_HPP
#define PROVEN_LPD_HPP

#include <cstdint>

namespace proven {

/// @brief CommandCode matching the Idris2 ABI tags.
enum class CommandCode : uint8_t {
    PrintJob = 0,
    ReceiveJob = 1,
    ShortQueue = 2,
    LongQueue = 3,
    RemoveJobs = 4
};

/// @brief SubCommandCode matching the Idris2 ABI tags.
enum class SubCommandCode : uint8_t {
    AbortJob = 0,
    ControlFile = 1,
    DataFile = 2
};

/// @brief JobStatus matching the Idris2 ABI tags.
enum class JobStatus : uint8_t {
    Pending = 0,
    Printing = 1,
    Complete = 2,
    Failed = 3
};

} // namespace proven

#endif // PROVEN_LPD_HPP
