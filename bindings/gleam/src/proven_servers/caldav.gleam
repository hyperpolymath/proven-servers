//// SPDX-License-Identifier: MPL-2.0
//// (MPL-2.0 preferred; MPL-2.0 required for Gleam ecosystem)
//// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
////
//// CalDAV protocol types for the proven-servers ABI.
////
//// Mirrors the Idris2 module `CaldavABI.Types`.
//// All tag values match the Idris2 ABI definitions exactly.

// ===========================================================================
// CalDAV Constants
// ===========================================================================

/// Caldav Port constant.
pub const caldav_port = 443

// ===========================================================================
// ComponentType
// ===========================================================================

/// iCalendar component types.
/// 
/// Matches `ComponentType` in `CaldavABI.Types`.
pub type ComponentType {
  /// VEVENT (tag 0).
  Vevent
  /// VTODO (tag 1).
  Vtodo
  /// VJOURNAL (tag 2).
  Vjournal
  /// VFREEBUSY (tag 3).
  Vfreebusy
}

/// Convert a `ComponentType` to its C-ABI tag value.
pub fn component_type_to_int(value: ComponentType) -> Int {
  case value {
    Vevent -> 0
    Vtodo -> 1
    Vjournal -> 2
    Vfreebusy -> 3
  }
}

/// Decode from a C-ABI tag value.
pub fn component_type_from_int(tag: Int) -> Result(ComponentType, Nil) {
  case tag {
    0 -> Ok(Vevent)
    1 -> Ok(Vtodo)
    2 -> Ok(Vjournal)
    3 -> Ok(Vfreebusy)
    _ -> Error(Nil)
  }
}

// ===========================================================================
// CalMethod
// ===========================================================================

/// CalDAV methods.
/// 
/// Matches `CalMethod` in `CaldavABI.Types`.
pub type CalMethod {
  /// Get (tag 0).
  Get
  /// Put (tag 1).
  Put
  /// Delete (tag 2).
  Delete
  /// PROPFIND (tag 3).
  Propfind
  /// PROPPATCH (tag 4).
  Proppatch
  /// REPORT (tag 5).
  Report
  /// MKCALENDAR (tag 6).
  Mkcalendar
}

/// Convert a `CalMethod` to its C-ABI tag value.
pub fn cal_method_to_int(value: CalMethod) -> Int {
  case value {
    Get -> 0
    Put -> 1
    Delete -> 2
    Propfind -> 3
    Proppatch -> 4
    Report -> 5
    Mkcalendar -> 6
  }
}

/// Decode from a C-ABI tag value.
pub fn cal_method_from_int(tag: Int) -> Result(CalMethod, Nil) {
  case tag {
    0 -> Ok(Get)
    1 -> Ok(Put)
    2 -> Ok(Delete)
    3 -> Ok(Propfind)
    4 -> Ok(Proppatch)
    5 -> Ok(Report)
    6 -> Ok(Mkcalendar)
    _ -> Error(Nil)
  }
}

// ===========================================================================
// ScheduleStatus
// ===========================================================================

/// CalDAV scheduling statuses.
/// 
/// Matches `ScheduleStatus` in `CaldavABI.Types`.
pub type ScheduleStatus {
  /// NeedsAction (tag 0).
  NeedsAction
  /// Accepted (tag 1).
  Accepted
  /// Declined (tag 2).
  Declined
  /// Tentative (tag 3).
  Tentative
  /// Delegated (tag 4).
  Delegated
}

/// Convert a `ScheduleStatus` to its C-ABI tag value.
pub fn schedule_status_to_int(value: ScheduleStatus) -> Int {
  case value {
    NeedsAction -> 0
    Accepted -> 1
    Declined -> 2
    Tentative -> 3
    Delegated -> 4
  }
}

/// Decode from a C-ABI tag value.
pub fn schedule_status_from_int(tag: Int) -> Result(ScheduleStatus, Nil) {
  case tag {
    0 -> Ok(NeedsAction)
    1 -> Ok(Accepted)
    2 -> Ok(Declined)
    3 -> Ok(Tentative)
    4 -> Ok(Delegated)
    _ -> Error(Nil)
  }
}

// ===========================================================================
// CalError
// ===========================================================================

/// CalDAV error codes.
/// 
/// Matches `CalError` in `CaldavABI.Types`.
pub type CalError {
  /// ValidCalendarData (tag 0).
  ValidCalendarData
  /// NoResourceTypeChange (tag 1).
  NoResourceTypeChange
  /// SupportedComponentMismatch (tag 2).
  SupportedComponentMismatch
  /// MaxResourceSize (tag 3).
  MaxResourceSize
  /// UidConflict (tag 4).
  UidConflict
  /// PreconditionFailed (tag 5).
  PreconditionFailed
}

/// Convert a `CalError` to its C-ABI tag value.
pub fn cal_error_to_int(value: CalError) -> Int {
  case value {
    ValidCalendarData -> 0
    NoResourceTypeChange -> 1
    SupportedComponentMismatch -> 2
    MaxResourceSize -> 3
    UidConflict -> 4
    PreconditionFailed -> 5
  }
}

/// Decode from a C-ABI tag value.
pub fn cal_error_from_int(tag: Int) -> Result(CalError, Nil) {
  case tag {
    0 -> Ok(ValidCalendarData)
    1 -> Ok(NoResourceTypeChange)
    2 -> Ok(SupportedComponentMismatch)
    3 -> Ok(MaxResourceSize)
    4 -> Ok(UidConflict)
    5 -> Ok(PreconditionFailed)
    _ -> Error(Nil)
  }
}

// ===========================================================================
// ServerState
// ===========================================================================

/// CalDAV server lifecycle states.
/// 
/// Matches `ServerState` in `CaldavABI.Types`.
pub type ServerState {
  /// Idle (tag 0).
  Idle
  /// Bound (tag 1).
  Bound
  /// Serving (tag 2).
  Serving
  /// Scheduling (tag 3).
  Scheduling
  /// Shutdown (tag 4).
  Shutdown
}

/// Convert a `ServerState` to its C-ABI tag value.
pub fn server_state_to_int(value: ServerState) -> Int {
  case value {
    Idle -> 0
    Bound -> 1
    Serving -> 2
    Scheduling -> 3
    Shutdown -> 4
  }
}

/// Decode from a C-ABI tag value.
pub fn server_state_from_int(tag: Int) -> Result(ServerState, Nil) {
  case tag {
    0 -> Ok(Idle)
    1 -> Ok(Bound)
    2 -> Ok(Serving)
    3 -> Ok(Scheduling)
    4 -> Ok(Shutdown)
    _ -> Error(Nil)
  }
}

