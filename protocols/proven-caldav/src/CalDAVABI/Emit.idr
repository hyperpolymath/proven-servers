-- SPDX-License-Identifier: MPL-2.0
-- Copyright (c) Jonathan D.A. Jewell <j.d.a.jewell@open.ac.uk>
--
-- CalDAVABI.Emit: ABI tag-manifest emitter (single source of truth).
-- Prints `KIND NAME DECIMAL` lines from the proven *ToTag encoders;
-- tools/gen-abi.sh renders them into caldav_abi_gen.zig for the comptime guard.

module CalDAVABI.Emit

import CalDAV.Types
import CalDAVABI.Types
import CalDAVABI.Foreign

%default total

line : String -> String -> Bits8 -> String
line kind name val = kind ++ " " ++ name ++ " " ++ show val

manifest : List String
manifest =
  [ "ABI_VERSION " ++ show abiVersion
  , line "COMP" "VEVENT"    (componentTypeToTag VEvent)
  , line "COMP" "VTODO"     (componentTypeToTag VTodo)
  , line "COMP" "VJOURNAL"  (componentTypeToTag VJournal)
  , line "COMP" "VFREEBUSY" (componentTypeToTag VFreeBusy)
  , line "METHOD" "GET"        (calMethodToTag CalGet)
  , line "METHOD" "PUT"        (calMethodToTag CalPut)
  , line "METHOD" "DELETE"     (calMethodToTag CalDelete)
  , line "METHOD" "PROPFIND"   (calMethodToTag CalPropfind)
  , line "METHOD" "PROPPATCH"  (calMethodToTag CalProppatch)
  , line "METHOD" "REPORT"     (calMethodToTag CalReport)
  , line "METHOD" "MKCALENDAR" (calMethodToTag CalMkcalendar)
  , line "SCHED" "NEEDS_ACTION" (scheduleStatusToTag NeedsAction)
  , line "SCHED" "ACCEPTED"     (scheduleStatusToTag Accepted)
  , line "SCHED" "DECLINED"     (scheduleStatusToTag Declined)
  , line "SCHED" "TENTATIVE"    (scheduleStatusToTag Tentative)
  , line "SCHED" "DELEGATED"    (scheduleStatusToTag Delegated)
  , line "ERR" "VALID_CALENDAR_DATA"          (calErrorToTag ValidCalendarData)
  , line "ERR" "NO_RESOURCE_TYPE_CHANGE"      (calErrorToTag NoResourceTypeChange)
  , line "ERR" "SUPPORTED_COMPONENT_MISMATCH" (calErrorToTag SupportedComponentMismatch)
  , line "ERR" "MAX_RESOURCE_SIZE"            (calErrorToTag MaxResourceSize)
  , line "ERR" "UID_CONFLICT"                 (calErrorToTag UIDConflict)
  , line "ERR" "PRECONDITION_FAILED"          (calErrorToTag PreconditionFailed)
  , line "SRV" "IDLE"       (serverStateToTag SSIdle)
  , line "SRV" "BOUND"      (serverStateToTag SSBound)
  , line "SRV" "SERVING"    (serverStateToTag SSServing)
  , line "SRV" "SCHEDULING" (serverStateToTag SSScheduling)
  , line "SRV" "SHUTDOWN"   (serverStateToTag SSShutdown)
  ]

covering
main : IO ()
main = traverse_ putStrLn manifest
