// SPDX-License-Identifier: PMPL-1.0-or-later
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
// CalDAV protocol types for proven-servers.

/// ComponentType matching the Idris2 ABI tags.
public enum ComponentType: UInt8, CaseIterable, Sendable {
    case vevent = 0
    case vtodo = 1
    case vjournal = 2
    case vfreebusy = 3
}

/// CalMethod matching the Idris2 ABI tags.
public enum CalMethod: UInt8, CaseIterable, Sendable {
    case get = 0
    case put = 1
    case delete = 2
    case propfind = 3
    case proppatch = 4
    case report = 5
    case mkcalendar = 6
}

/// ScheduleStatus matching the Idris2 ABI tags.
public enum ScheduleStatus: UInt8, CaseIterable, Sendable {
    case needsAction = 0
    case accepted = 1
    case declined = 2
    case tentative = 3
    case delegated = 4
}

/// CalError matching the Idris2 ABI tags.
public enum CalError: UInt8, CaseIterable, Sendable {
    case validCalendarData = 0
    case noResourceTypeChange = 1
    case supportedComponentMismatch = 2
    case maxResourceSize = 3
    case uidConflict = 4
    case preconditionFailed = 5
}

/// ServerState matching the Idris2 ABI tags.
public enum ServerState: UInt8, CaseIterable, Sendable {
    case idle = 0
    case bound = 1
    case serving = 2
    case scheduling = 3
    case shutdown = 4
}
