// SPDX-License-Identifier: MPL-2.0
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
/// @file caldav.hpp
/// @brief CalDAV protocol types for proven-servers.

#ifndef PROVEN_CALDAV_HPP
#define PROVEN_CALDAV_HPP

#include <cstdint>

namespace proven {

/// @brief ComponentType matching the Idris2 ABI tags.
enum class ComponentType : uint8_t {
    Vevent = 0,
    Vtodo = 1,
    Vjournal = 2,
    Vfreebusy = 3
};

/// @brief CalMethod matching the Idris2 ABI tags.
enum class CalMethod : uint8_t {
    Get = 0,
    Put = 1,
    Delete = 2,
    Propfind = 3,
    Proppatch = 4,
    Report = 5,
    Mkcalendar = 6
};

/// @brief ScheduleStatus matching the Idris2 ABI tags.
enum class ScheduleStatus : uint8_t {
    NeedsAction = 0,
    Accepted = 1,
    Declined = 2,
    Tentative = 3,
    Delegated = 4
};

/// @brief CalError matching the Idris2 ABI tags.
enum class CalError : uint8_t {
    ValidCalendarData = 0,
    NoResourceTypeChange = 1,
    SupportedComponentMismatch = 2,
    MaxResourceSize = 3,
    UidConflict = 4,
    PreconditionFailed = 5
};

/// @brief ServerState matching the Idris2 ABI tags.
enum class ServerState : uint8_t {
    Idle = 0,
    Bound = 1,
    Serving = 2,
    Scheduling = 3,
    Shutdown = 4
};

} // namespace proven

#endif // PROVEN_CALDAV_HPP
