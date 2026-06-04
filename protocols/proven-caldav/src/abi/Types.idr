-- SPDX-License-Identifier: MPL-2.0
-- Copyright (c) Jonathan D.A. Jewell <j.d.a.jewell@open.ac.uk>
--
-- CaldavABI.Types: C-ABI-compatible numeric representations of Caldav types.
--
-- Maps every constructor of the core Caldav sum types to fixed Bits8 values
-- for C interop. Each type gets a total encoder, partial decoder, and
-- roundtrip proof (encode then decode = identity).
--
-- Tag values here MUST match the C header and the
-- Zig FFI enums (ffi/zig/src/caldav.zig) exactly.
--
-- Types covered:
--   ComponentType             (4 constructors, tags 0-3)
--   CalMethod                 (7 constructors, tags 0-6)
--   ScheduleStatus            (5 constructors, tags 0-4)
--   CalError                  (6 constructors, tags 0-5)
--   ServerState               (5 constructors, tags 0-4)

module CaldavABI.Types

%default total

---------------------------------------------------------------------------
-- ComponentType (4 constructors, tags 0-3)
---------------------------------------------------------------------------

public export
component_typeSize : Nat
component_typeSize = 1

||| ComponentType sum type for ABI encoding.
public export
data ComponentType : Type where
  Vevent : ComponentType
  Vtodo : ComponentType
  Vjournal : ComponentType
  Vfreebusy : ComponentType

||| Encode a ComponentType to its ABI tag value.
public export
component_typeToTag : ComponentType -> Bits8
component_typeToTag Vevent = 0
component_typeToTag Vtodo = 1
component_typeToTag Vjournal = 2
component_typeToTag Vfreebusy = 3

||| Decode an ABI tag to a ComponentType.
public export
tagToComponentType : Bits8 -> Maybe ComponentType
tagToComponentType 0 = Just Vevent
tagToComponentType 1 = Just Vtodo
tagToComponentType 2 = Just Vjournal
tagToComponentType 3 = Just Vfreebusy
tagToComponentType _ = Nothing

||| Roundtrip proof: decoding an encoded ComponentType yields the original.
public export
component_typeRoundtrip : (x : ComponentType) -> tagToComponentType (component_typeToTag x) = Just x
component_typeRoundtrip Vevent = Refl
component_typeRoundtrip Vtodo = Refl
component_typeRoundtrip Vjournal = Refl
component_typeRoundtrip Vfreebusy = Refl

---------------------------------------------------------------------------
-- CalMethod (7 constructors, tags 0-6)
---------------------------------------------------------------------------

public export
cal_methodSize : Nat
cal_methodSize = 1

||| CalMethod sum type for ABI encoding.
public export
data CalMethod : Type where
  Get : CalMethod
  Put : CalMethod
  Delete : CalMethod
  Propfind : CalMethod
  Proppatch : CalMethod
  Report : CalMethod
  Mkcalendar : CalMethod

||| Encode a CalMethod to its ABI tag value.
public export
cal_methodToTag : CalMethod -> Bits8
cal_methodToTag Get = 0
cal_methodToTag Put = 1
cal_methodToTag Delete = 2
cal_methodToTag Propfind = 3
cal_methodToTag Proppatch = 4
cal_methodToTag Report = 5
cal_methodToTag Mkcalendar = 6

||| Decode an ABI tag to a CalMethod.
public export
tagToCalMethod : Bits8 -> Maybe CalMethod
tagToCalMethod 0 = Just Get
tagToCalMethod 1 = Just Put
tagToCalMethod 2 = Just Delete
tagToCalMethod 3 = Just Propfind
tagToCalMethod 4 = Just Proppatch
tagToCalMethod 5 = Just Report
tagToCalMethod 6 = Just Mkcalendar
tagToCalMethod _ = Nothing

||| Roundtrip proof: decoding an encoded CalMethod yields the original.
public export
cal_methodRoundtrip : (x : CalMethod) -> tagToCalMethod (cal_methodToTag x) = Just x
cal_methodRoundtrip Get = Refl
cal_methodRoundtrip Put = Refl
cal_methodRoundtrip Delete = Refl
cal_methodRoundtrip Propfind = Refl
cal_methodRoundtrip Proppatch = Refl
cal_methodRoundtrip Report = Refl
cal_methodRoundtrip Mkcalendar = Refl

---------------------------------------------------------------------------
-- ScheduleStatus (5 constructors, tags 0-4)
---------------------------------------------------------------------------

public export
schedule_statusSize : Nat
schedule_statusSize = 1

||| ScheduleStatus sum type for ABI encoding.
public export
data ScheduleStatus : Type where
  NeedsAction : ScheduleStatus
  Accepted : ScheduleStatus
  Declined : ScheduleStatus
  Tentative : ScheduleStatus
  Delegated : ScheduleStatus

||| Encode a ScheduleStatus to its ABI tag value.
public export
schedule_statusToTag : ScheduleStatus -> Bits8
schedule_statusToTag NeedsAction = 0
schedule_statusToTag Accepted = 1
schedule_statusToTag Declined = 2
schedule_statusToTag Tentative = 3
schedule_statusToTag Delegated = 4

||| Decode an ABI tag to a ScheduleStatus.
public export
tagToScheduleStatus : Bits8 -> Maybe ScheduleStatus
tagToScheduleStatus 0 = Just NeedsAction
tagToScheduleStatus 1 = Just Accepted
tagToScheduleStatus 2 = Just Declined
tagToScheduleStatus 3 = Just Tentative
tagToScheduleStatus 4 = Just Delegated
tagToScheduleStatus _ = Nothing

||| Roundtrip proof: decoding an encoded ScheduleStatus yields the original.
public export
schedule_statusRoundtrip : (x : ScheduleStatus) -> tagToScheduleStatus (schedule_statusToTag x) = Just x
schedule_statusRoundtrip NeedsAction = Refl
schedule_statusRoundtrip Accepted = Refl
schedule_statusRoundtrip Declined = Refl
schedule_statusRoundtrip Tentative = Refl
schedule_statusRoundtrip Delegated = Refl

---------------------------------------------------------------------------
-- CalError (6 constructors, tags 0-5)
---------------------------------------------------------------------------

public export
cal_errorSize : Nat
cal_errorSize = 1

||| CalError sum type for ABI encoding.
public export
data CalError : Type where
  ValidCalendarData : CalError
  NoResourceTypeChange : CalError
  SupportedComponentMismatch : CalError
  MaxResourceSize : CalError
  UidConflict : CalError
  PreconditionFailed : CalError

||| Encode a CalError to its ABI tag value.
public export
cal_errorToTag : CalError -> Bits8
cal_errorToTag ValidCalendarData = 0
cal_errorToTag NoResourceTypeChange = 1
cal_errorToTag SupportedComponentMismatch = 2
cal_errorToTag MaxResourceSize = 3
cal_errorToTag UidConflict = 4
cal_errorToTag PreconditionFailed = 5

||| Decode an ABI tag to a CalError.
public export
tagToCalError : Bits8 -> Maybe CalError
tagToCalError 0 = Just ValidCalendarData
tagToCalError 1 = Just NoResourceTypeChange
tagToCalError 2 = Just SupportedComponentMismatch
tagToCalError 3 = Just MaxResourceSize
tagToCalError 4 = Just UidConflict
tagToCalError 5 = Just PreconditionFailed
tagToCalError _ = Nothing

||| Roundtrip proof: decoding an encoded CalError yields the original.
public export
cal_errorRoundtrip : (x : CalError) -> tagToCalError (cal_errorToTag x) = Just x
cal_errorRoundtrip ValidCalendarData = Refl
cal_errorRoundtrip NoResourceTypeChange = Refl
cal_errorRoundtrip SupportedComponentMismatch = Refl
cal_errorRoundtrip MaxResourceSize = Refl
cal_errorRoundtrip UidConflict = Refl
cal_errorRoundtrip PreconditionFailed = Refl

---------------------------------------------------------------------------
-- ServerState (5 constructors, tags 0-4)
---------------------------------------------------------------------------

public export
server_stateSize : Nat
server_stateSize = 1

||| ServerState sum type for ABI encoding.
public export
data ServerState : Type where
  Idle : ServerState
  Bound : ServerState
  Serving : ServerState
  Scheduling : ServerState
  Shutdown : ServerState

||| Encode a ServerState to its ABI tag value.
public export
server_stateToTag : ServerState -> Bits8
server_stateToTag Idle = 0
server_stateToTag Bound = 1
server_stateToTag Serving = 2
server_stateToTag Scheduling = 3
server_stateToTag Shutdown = 4

||| Decode an ABI tag to a ServerState.
public export
tagToServerState : Bits8 -> Maybe ServerState
tagToServerState 0 = Just Idle
tagToServerState 1 = Just Bound
tagToServerState 2 = Just Serving
tagToServerState 3 = Just Scheduling
tagToServerState 4 = Just Shutdown
tagToServerState _ = Nothing

||| Roundtrip proof: decoding an encoded ServerState yields the original.
public export
server_stateRoundtrip : (x : ServerState) -> tagToServerState (server_stateToTag x) = Just x
server_stateRoundtrip Idle = Refl
server_stateRoundtrip Bound = Refl
server_stateRoundtrip Serving = Refl
server_stateRoundtrip Scheduling = Refl
server_stateRoundtrip Shutdown = Refl
