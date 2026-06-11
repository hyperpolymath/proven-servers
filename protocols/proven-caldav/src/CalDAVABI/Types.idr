-- SPDX-License-Identifier: MPL-2.0
-- Copyright (c) Jonathan D.A. Jewell <j.d.a.jewell@open.ac.uk>
--
-- CalDAVABI.Types: C-ABI-compatible numeric representations of CalDAV types.
--
-- Maps every constructor of the core CalDAV sum types to fixed Bits8 values
-- for C interop. Each type gets a total encoder, partial decoder, and
-- roundtrip proof (encode then decode = identity).
--
-- Tag values here MUST match the C header (generated/abi/caldav.h) and the
-- Zig FFI enums (ffi/zig/src/caldav.zig) exactly.
--
-- Types covered:
--   ComponentType   (4 constructors, tags 0-3)
--   CalMethod       (7 constructors, tags 0-6)
--   ScheduleStatus  (5 constructors, tags 0-4)
--   CalError        (6 constructors, tags 0-5)
--   ServerState     (5 constructors, tags 0-4)

module CalDAVABI.Types

import CalDAV.Types

%default total

---------------------------------------------------------------------------
-- ComponentType (4 constructors, tags 0-3)
---------------------------------------------------------------------------

public export
componentTypeToTag : ComponentType -> Bits8
componentTypeToTag VEvent    = 0
componentTypeToTag VTodo     = 1
componentTypeToTag VJournal  = 2
componentTypeToTag VFreeBusy = 3

public export
tagToComponentType : Bits8 -> Maybe ComponentType
tagToComponentType 0 = Just VEvent
tagToComponentType 1 = Just VTodo
tagToComponentType 2 = Just VJournal
tagToComponentType 3 = Just VFreeBusy
tagToComponentType _ = Nothing

public export
componentTypeRoundtrip : (c : ComponentType) -> tagToComponentType (componentTypeToTag c) = Just c
componentTypeRoundtrip VEvent    = Refl
componentTypeRoundtrip VTodo     = Refl
componentTypeRoundtrip VJournal  = Refl
componentTypeRoundtrip VFreeBusy = Refl

---------------------------------------------------------------------------
-- CalMethod (7 constructors, tags 0-6)
---------------------------------------------------------------------------

public export
calMethodToTag : CalMethod -> Bits8
calMethodToTag CalGet        = 0
calMethodToTag CalPut        = 1
calMethodToTag CalDelete     = 2
calMethodToTag CalPropfind   = 3
calMethodToTag CalProppatch  = 4
calMethodToTag CalReport     = 5
calMethodToTag CalMkcalendar = 6

public export
tagToCalMethod : Bits8 -> Maybe CalMethod
tagToCalMethod 0 = Just CalGet
tagToCalMethod 1 = Just CalPut
tagToCalMethod 2 = Just CalDelete
tagToCalMethod 3 = Just CalPropfind
tagToCalMethod 4 = Just CalProppatch
tagToCalMethod 5 = Just CalReport
tagToCalMethod 6 = Just CalMkcalendar
tagToCalMethod _ = Nothing

public export
calMethodRoundtrip : (m : CalMethod) -> tagToCalMethod (calMethodToTag m) = Just m
calMethodRoundtrip CalGet        = Refl
calMethodRoundtrip CalPut        = Refl
calMethodRoundtrip CalDelete     = Refl
calMethodRoundtrip CalPropfind   = Refl
calMethodRoundtrip CalProppatch  = Refl
calMethodRoundtrip CalReport     = Refl
calMethodRoundtrip CalMkcalendar = Refl

---------------------------------------------------------------------------
-- ScheduleStatus (5 constructors, tags 0-4)
---------------------------------------------------------------------------

public export
scheduleStatusToTag : ScheduleStatus -> Bits8
scheduleStatusToTag NeedsAction = 0
scheduleStatusToTag Accepted    = 1
scheduleStatusToTag Declined    = 2
scheduleStatusToTag Tentative   = 3
scheduleStatusToTag Delegated   = 4

public export
tagToScheduleStatus : Bits8 -> Maybe ScheduleStatus
tagToScheduleStatus 0 = Just NeedsAction
tagToScheduleStatus 1 = Just Accepted
tagToScheduleStatus 2 = Just Declined
tagToScheduleStatus 3 = Just Tentative
tagToScheduleStatus 4 = Just Delegated
tagToScheduleStatus _ = Nothing

public export
scheduleStatusRoundtrip : (s : ScheduleStatus) -> tagToScheduleStatus (scheduleStatusToTag s) = Just s
scheduleStatusRoundtrip NeedsAction = Refl
scheduleStatusRoundtrip Accepted    = Refl
scheduleStatusRoundtrip Declined    = Refl
scheduleStatusRoundtrip Tentative   = Refl
scheduleStatusRoundtrip Delegated   = Refl

---------------------------------------------------------------------------
-- CalError (6 constructors, tags 0-5)
---------------------------------------------------------------------------

public export
calErrorToTag : CalError -> Bits8
calErrorToTag ValidCalendarData          = 0
calErrorToTag NoResourceTypeChange       = 1
calErrorToTag SupportedComponentMismatch = 2
calErrorToTag MaxResourceSize            = 3
calErrorToTag UIDConflict                = 4
calErrorToTag PreconditionFailed         = 5

public export
tagToCalError : Bits8 -> Maybe CalError
tagToCalError 0 = Just ValidCalendarData
tagToCalError 1 = Just NoResourceTypeChange
tagToCalError 2 = Just SupportedComponentMismatch
tagToCalError 3 = Just MaxResourceSize
tagToCalError 4 = Just UIDConflict
tagToCalError 5 = Just PreconditionFailed
tagToCalError _ = Nothing

public export
calErrorRoundtrip : (e : CalError) -> tagToCalError (calErrorToTag e) = Just e
calErrorRoundtrip ValidCalendarData          = Refl
calErrorRoundtrip NoResourceTypeChange       = Refl
calErrorRoundtrip SupportedComponentMismatch = Refl
calErrorRoundtrip MaxResourceSize            = Refl
calErrorRoundtrip UIDConflict                = Refl
calErrorRoundtrip PreconditionFailed         = Refl

---------------------------------------------------------------------------
-- ServerState (5 constructors, tags 0-4)
-- CalDAV server lifecycle state for the FFI layer.
---------------------------------------------------------------------------

||| CalDAV server lifecycle states.
public export
data ServerState : Type where
  ||| No server bound. Initial and terminal state.
  SSIdle     : ServerState
  ||| Server bound to HTTP port, ready to accept requests.
  SSBound    : ServerState
  ||| Actively serving calendars (at least one calendar collection exists).
  SSServing  : ServerState
  ||| Processing scheduling operations (RFC 6638).
  SSScheduling : ServerState
  ||| Shutting down (draining in-flight requests).
  SSShutdown : ServerState

public export
Eq ServerState where
  SSIdle       == SSIdle       = True
  SSBound      == SSBound      = True
  SSServing    == SSServing    = True
  SSScheduling == SSScheduling = True
  SSShutdown   == SSShutdown   = True
  _            == _            = False

public export
Show ServerState where
  show SSIdle       = "Idle"
  show SSBound      = "Bound"
  show SSServing    = "Serving"
  show SSScheduling = "Scheduling"
  show SSShutdown   = "Shutdown"

public export
serverStateToTag : ServerState -> Bits8
serverStateToTag SSIdle       = 0
serverStateToTag SSBound      = 1
serverStateToTag SSServing    = 2
serverStateToTag SSScheduling = 3
serverStateToTag SSShutdown   = 4

public export
tagToServerState : Bits8 -> Maybe ServerState
tagToServerState 0 = Just SSIdle
tagToServerState 1 = Just SSBound
tagToServerState 2 = Just SSServing
tagToServerState 3 = Just SSScheduling
tagToServerState 4 = Just SSShutdown
tagToServerState _ = Nothing

public export
serverStateRoundtrip : (s : ServerState) -> tagToServerState (serverStateToTag s) = Just s
serverStateRoundtrip SSIdle       = Refl
serverStateRoundtrip SSBound      = Refl
serverStateRoundtrip SSServing    = Refl
serverStateRoundtrip SSScheduling = Refl
serverStateRoundtrip SSShutdown   = Refl
