-- SPDX-License-Identifier: PMPL-1.0-or-later
-- Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
--
-- FederationABI.Types: C-ABI-compatible numeric representations of
-- federation protocol types.
--
-- Maps every constructor of the core Federation sum types to fixed Bits8
-- values for C interop. Each type gets a total encoder, partial decoder,
-- and roundtrip proof (encode then decode = identity).
--
-- Tag values here MUST match the Zig FFI enums (ffi/zig/src/federation.zig)
-- exactly.
--
-- Types covered:
--   ActivityType   (11 constructors, tags 0-10)
--   ActorType      (5 constructors,  tags 0-4)
--   DeliveryStatus (5 constructors,  tags 0-4)
--   TrustLevel     (5 constructors,  tags 0-4)
--   ObjectType     (9 constructors,  tags 0-8)
--   ServerState    (5 constructors,  tags 0-4)

module FederationABI.Types

import Federation.Types

%default total

---------------------------------------------------------------------------
-- ActivityType (11 constructors, tags 0-10)
---------------------------------------------------------------------------

public export
activityTypeToTag : ActivityType -> Bits8
activityTypeToTag Create   = 0
activityTypeToTag Update   = 1
activityTypeToTag Delete   = 2
activityTypeToTag Follow   = 3
activityTypeToTag Accept   = 4
activityTypeToTag Reject   = 5
activityTypeToTag Announce = 6
activityTypeToTag Like     = 7
activityTypeToTag Undo     = 8
activityTypeToTag Block    = 9
activityTypeToTag Flag     = 10

public export
tagToActivityType : Bits8 -> Maybe ActivityType
tagToActivityType 0  = Just Create
tagToActivityType 1  = Just Update
tagToActivityType 2  = Just Delete
tagToActivityType 3  = Just Follow
tagToActivityType 4  = Just Accept
tagToActivityType 5  = Just Reject
tagToActivityType 6  = Just Announce
tagToActivityType 7  = Just Like
tagToActivityType 8  = Just Undo
tagToActivityType 9  = Just Block
tagToActivityType 10 = Just Flag
tagToActivityType _  = Nothing

public export
activityTypeRoundtrip : (a : ActivityType) -> tagToActivityType (activityTypeToTag a) = Just a
activityTypeRoundtrip Create   = Refl
activityTypeRoundtrip Update   = Refl
activityTypeRoundtrip Delete   = Refl
activityTypeRoundtrip Follow   = Refl
activityTypeRoundtrip Accept   = Refl
activityTypeRoundtrip Reject   = Refl
activityTypeRoundtrip Announce = Refl
activityTypeRoundtrip Like     = Refl
activityTypeRoundtrip Undo     = Refl
activityTypeRoundtrip Block    = Refl
activityTypeRoundtrip Flag     = Refl

---------------------------------------------------------------------------
-- ActorType (5 constructors, tags 0-4)
---------------------------------------------------------------------------

public export
actorTypeToTag : ActorType -> Bits8
actorTypeToTag Person       = 0
actorTypeToTag Service      = 1
actorTypeToTag Application  = 2
actorTypeToTag Group        = 3
actorTypeToTag Organization = 4

public export
tagToActorType : Bits8 -> Maybe ActorType
tagToActorType 0 = Just Person
tagToActorType 1 = Just Service
tagToActorType 2 = Just Application
tagToActorType 3 = Just Group
tagToActorType 4 = Just Organization
tagToActorType _ = Nothing

public export
actorTypeRoundtrip : (a : ActorType) -> tagToActorType (actorTypeToTag a) = Just a
actorTypeRoundtrip Person       = Refl
actorTypeRoundtrip Service      = Refl
actorTypeRoundtrip Application  = Refl
actorTypeRoundtrip Group        = Refl
actorTypeRoundtrip Organization = Refl

---------------------------------------------------------------------------
-- DeliveryStatus (5 constructors, tags 0-4)
---------------------------------------------------------------------------

public export
deliveryStatusToTag : DeliveryStatus -> Bits8
deliveryStatusToTag Pending   = 0
deliveryStatusToTag Delivered = 1
deliveryStatusToTag Failed    = 2
deliveryStatusToTag Rejected  = 3
deliveryStatusToTag Deferred  = 4

public export
tagToDeliveryStatus : Bits8 -> Maybe DeliveryStatus
tagToDeliveryStatus 0 = Just Pending
tagToDeliveryStatus 1 = Just Delivered
tagToDeliveryStatus 2 = Just Failed
tagToDeliveryStatus 3 = Just Rejected
tagToDeliveryStatus 4 = Just Deferred
tagToDeliveryStatus _ = Nothing

public export
deliveryStatusRoundtrip : (d : DeliveryStatus) -> tagToDeliveryStatus (deliveryStatusToTag d) = Just d
deliveryStatusRoundtrip Pending   = Refl
deliveryStatusRoundtrip Delivered = Refl
deliveryStatusRoundtrip Failed    = Refl
deliveryStatusRoundtrip Rejected  = Refl
deliveryStatusRoundtrip Deferred  = Refl

---------------------------------------------------------------------------
-- TrustLevel (5 constructors, tags 0-4)
---------------------------------------------------------------------------

public export
trustLevelToTag : TrustLevel -> Bits8
trustLevelToTag SelfSigned        = 0
trustLevelToTag PeerVerified      = 1
trustLevelToTag FederationTrusted = 2
trustLevelToTag Revoked           = 3
trustLevelToTag Unknown           = 4

public export
tagToTrustLevel : Bits8 -> Maybe TrustLevel
tagToTrustLevel 0 = Just SelfSigned
tagToTrustLevel 1 = Just PeerVerified
tagToTrustLevel 2 = Just FederationTrusted
tagToTrustLevel 3 = Just Revoked
tagToTrustLevel 4 = Just Unknown
tagToTrustLevel _ = Nothing

public export
trustLevelRoundtrip : (t : TrustLevel) -> tagToTrustLevel (trustLevelToTag t) = Just t
trustLevelRoundtrip SelfSigned        = Refl
trustLevelRoundtrip PeerVerified      = Refl
trustLevelRoundtrip FederationTrusted = Refl
trustLevelRoundtrip Revoked           = Refl
trustLevelRoundtrip Unknown           = Refl

---------------------------------------------------------------------------
-- ObjectType (9 constructors, tags 0-8)
---------------------------------------------------------------------------

public export
objectTypeToTag : ObjectType -> Bits8
objectTypeToTag Note              = 0
objectTypeToTag Article           = 1
objectTypeToTag Image             = 2
objectTypeToTag Video             = 3
objectTypeToTag Audio             = 4
objectTypeToTag Document          = 5
objectTypeToTag Event             = 6
objectTypeToTag Collection        = 7
objectTypeToTag OrderedCollection = 8

public export
tagToObjectType : Bits8 -> Maybe ObjectType
tagToObjectType 0 = Just Note
tagToObjectType 1 = Just Article
tagToObjectType 2 = Just Image
tagToObjectType 3 = Just Video
tagToObjectType 4 = Just Audio
tagToObjectType 5 = Just Document
tagToObjectType 6 = Just Event
tagToObjectType 7 = Just Collection
tagToObjectType 8 = Just OrderedCollection
tagToObjectType _ = Nothing

public export
objectTypeRoundtrip : (o : ObjectType) -> tagToObjectType (objectTypeToTag o) = Just o
objectTypeRoundtrip Note              = Refl
objectTypeRoundtrip Article           = Refl
objectTypeRoundtrip Image             = Refl
objectTypeRoundtrip Video             = Refl
objectTypeRoundtrip Audio             = Refl
objectTypeRoundtrip Document          = Refl
objectTypeRoundtrip Event             = Refl
objectTypeRoundtrip Collection        = Refl
objectTypeRoundtrip OrderedCollection = Refl

---------------------------------------------------------------------------
-- ServerState (5 constructors, tags 0-4)
-- Composite lifecycle state used by the FFI for simplified management.
---------------------------------------------------------------------------

||| Federation server lifecycle states.
||| Simplified view used by the FFI layer for the C ABI.
public export
data ServerState : Type where
  ||| Server not started. Initial and terminal state.
  FSIdle        : ServerState
  ||| Server running, accepting activities.
  FSActive      : ServerState
  ||| Processing an activity (creating, delivering, etc.).
  FSProcessing  : ServerState
  ||| Delivering activities to remote inboxes.
  FSDelivering  : ServerState
  ||| Server shutting down gracefully.
  FSShutdown    : ServerState

public export
Eq ServerState where
  FSIdle       == FSIdle       = True
  FSActive     == FSActive     = True
  FSProcessing == FSProcessing = True
  FSDelivering == FSDelivering = True
  FSShutdown   == FSShutdown   = True
  _            == _            = False

public export
Show ServerState where
  show FSIdle       = "Idle"
  show FSActive     = "Active"
  show FSProcessing = "Processing"
  show FSDelivering = "Delivering"
  show FSShutdown   = "Shutdown"

public export
serverStateToTag : ServerState -> Bits8
serverStateToTag FSIdle       = 0
serverStateToTag FSActive     = 1
serverStateToTag FSProcessing = 2
serverStateToTag FSDelivering = 3
serverStateToTag FSShutdown   = 4

public export
tagToServerState : Bits8 -> Maybe ServerState
tagToServerState 0 = Just FSIdle
tagToServerState 1 = Just FSActive
tagToServerState 2 = Just FSProcessing
tagToServerState 3 = Just FSDelivering
tagToServerState 4 = Just FSShutdown
tagToServerState _ = Nothing

public export
serverStateRoundtrip : (s : ServerState) -> tagToServerState (serverStateToTag s) = Just s
serverStateRoundtrip FSIdle       = Refl
serverStateRoundtrip FSActive     = Refl
serverStateRoundtrip FSProcessing = Refl
serverStateRoundtrip FSDelivering = Refl
serverStateRoundtrip FSShutdown   = Refl

---------------------------------------------------------------------------
-- Transition validation
---------------------------------------------------------------------------

||| Proof witness that a federation server state transition is valid.
public export
data ValidServerTransition : ServerState -> ServerState -> Type where
  ServerStarted        : ValidServerTransition FSIdle FSActive
  BeginProcessing      : ValidServerTransition FSActive FSProcessing
  ProcessingDone       : ValidServerTransition FSProcessing FSActive
  BeginDelivery        : ValidServerTransition FSProcessing FSDelivering
  DeliveryDone         : ValidServerTransition FSDelivering FSActive
  ShutdownFromActive   : ValidServerTransition FSActive FSShutdown
  ShutdownFromProc     : ValidServerTransition FSProcessing FSShutdown
  ShutdownFromDeliver  : ValidServerTransition FSDelivering FSShutdown
  CleanupDone          : ValidServerTransition FSShutdown FSIdle

||| Check whether a server state transition is valid.
public export
validateServerTransition : (from : ServerState) -> (to : ServerState)
                         -> Maybe (ValidServerTransition from to)
validateServerTransition FSIdle       FSActive     = Just ServerStarted
validateServerTransition FSActive     FSProcessing = Just BeginProcessing
validateServerTransition FSProcessing FSActive     = Just ProcessingDone
validateServerTransition FSProcessing FSDelivering = Just BeginDelivery
validateServerTransition FSDelivering FSActive     = Just DeliveryDone
validateServerTransition FSActive     FSShutdown   = Just ShutdownFromActive
validateServerTransition FSProcessing FSShutdown   = Just ShutdownFromProc
validateServerTransition FSDelivering FSShutdown   = Just ShutdownFromDeliver
validateServerTransition FSShutdown   FSIdle       = Just CleanupDone
validateServerTransition _            _            = Nothing

---------------------------------------------------------------------------
-- Impossibility proofs
---------------------------------------------------------------------------

||| Cannot process activities from Idle.
public export
idleCannotProcess : ValidServerTransition FSIdle FSProcessing -> Void
idleCannotProcess _ impossible

||| Cannot go from Shutdown back to Active directly.
public export
cannotResumeFromShutdown : ValidServerTransition FSShutdown FSActive -> Void
cannotResumeFromShutdown _ impossible
