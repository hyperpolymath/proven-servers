-- SPDX-License-Identifier: MPL-2.0
-- Copyright (c) Jonathan D.A. Jewell <j.d.a.jewell@open.ac.uk>
--
-- DDSABI.Types: C-ABI-compatible numeric representations of DDS types.
--
-- Maps every constructor of the core DDS sum types to fixed Bits8 values
-- for C interop. Each type gets a total encoder, partial decoder, and
-- roundtrip proof (encode then decode = identity).
--
-- Tag values here MUST match the C header (generated/abi/dds.h) and the
-- Zig FFI enums (ffi/zig/src/dds.zig) exactly.
--
-- Types covered:
--   ReliabilityKind (2 constructors, tags 0-1)
--   DurabilityKind  (4 constructors, tags 0-3)
--   HistoryKind     (2 constructors, tags 0-1)
--   OwnershipKind   (2 constructors, tags 0-1)
--   EntityType      (6 constructors, tags 0-5)
--   ParticipantState (5 constructors, tags 0-4)

module DDSABI.Types

import DDS.Types

%default total

---------------------------------------------------------------------------
-- ReliabilityKind (2 constructors, tags 0-1)
---------------------------------------------------------------------------

public export
reliabilityKindToTag : ReliabilityKind -> Bits8
reliabilityKindToTag BestEffort = 0
reliabilityKindToTag Reliable   = 1

public export
tagToReliabilityKind : Bits8 -> Maybe ReliabilityKind
tagToReliabilityKind 0 = Just BestEffort
tagToReliabilityKind 1 = Just Reliable
tagToReliabilityKind _ = Nothing

public export
reliabilityKindRoundtrip : (r : ReliabilityKind) -> tagToReliabilityKind (reliabilityKindToTag r) = Just r
reliabilityKindRoundtrip BestEffort = Refl
reliabilityKindRoundtrip Reliable   = Refl

---------------------------------------------------------------------------
-- DurabilityKind (4 constructors, tags 0-3)
---------------------------------------------------------------------------

public export
durabilityKindToTag : DurabilityKind -> Bits8
durabilityKindToTag Volatile       = 0
durabilityKindToTag TransientLocal = 1
durabilityKindToTag Transient      = 2
durabilityKindToTag Persistent     = 3

public export
tagToDurabilityKind : Bits8 -> Maybe DurabilityKind
tagToDurabilityKind 0 = Just Volatile
tagToDurabilityKind 1 = Just TransientLocal
tagToDurabilityKind 2 = Just Transient
tagToDurabilityKind 3 = Just Persistent
tagToDurabilityKind _ = Nothing

public export
durabilityKindRoundtrip : (d : DurabilityKind) -> tagToDurabilityKind (durabilityKindToTag d) = Just d
durabilityKindRoundtrip Volatile       = Refl
durabilityKindRoundtrip TransientLocal = Refl
durabilityKindRoundtrip Transient      = Refl
durabilityKindRoundtrip Persistent     = Refl

---------------------------------------------------------------------------
-- HistoryKind (2 constructors, tags 0-1)
---------------------------------------------------------------------------

public export
historyKindToTag : HistoryKind -> Bits8
historyKindToTag KeepLast = 0
historyKindToTag KeepAll  = 1

public export
tagToHistoryKind : Bits8 -> Maybe HistoryKind
tagToHistoryKind 0 = Just KeepLast
tagToHistoryKind 1 = Just KeepAll
tagToHistoryKind _ = Nothing

public export
historyKindRoundtrip : (h : HistoryKind) -> tagToHistoryKind (historyKindToTag h) = Just h
historyKindRoundtrip KeepLast = Refl
historyKindRoundtrip KeepAll  = Refl

---------------------------------------------------------------------------
-- OwnershipKind (2 constructors, tags 0-1)
---------------------------------------------------------------------------

public export
ownershipKindToTag : OwnershipKind -> Bits8
ownershipKindToTag Shared    = 0
ownershipKindToTag Exclusive = 1

public export
tagToOwnershipKind : Bits8 -> Maybe OwnershipKind
tagToOwnershipKind 0 = Just Shared
tagToOwnershipKind 1 = Just Exclusive
tagToOwnershipKind _ = Nothing

public export
ownershipKindRoundtrip : (o : OwnershipKind) -> tagToOwnershipKind (ownershipKindToTag o) = Just o
ownershipKindRoundtrip Shared    = Refl
ownershipKindRoundtrip Exclusive = Refl

---------------------------------------------------------------------------
-- EntityType (6 constructors, tags 0-5)
---------------------------------------------------------------------------

public export
entityTypeToTag : EntityType -> Bits8
entityTypeToTag Participant = 0
entityTypeToTag Publisher   = 1
entityTypeToTag Subscriber  = 2
entityTypeToTag TopicEntity = 3
entityTypeToTag DataWriter  = 4
entityTypeToTag DataReader  = 5

public export
tagToEntityType : Bits8 -> Maybe EntityType
tagToEntityType 0 = Just Participant
tagToEntityType 1 = Just Publisher
tagToEntityType 2 = Just Subscriber
tagToEntityType 3 = Just TopicEntity
tagToEntityType 4 = Just DataWriter
tagToEntityType 5 = Just DataReader
tagToEntityType _ = Nothing

public export
entityTypeRoundtrip : (e : EntityType) -> tagToEntityType (entityTypeToTag e) = Just e
entityTypeRoundtrip Participant = Refl
entityTypeRoundtrip Publisher   = Refl
entityTypeRoundtrip Subscriber  = Refl
entityTypeRoundtrip TopicEntity = Refl
entityTypeRoundtrip DataWriter  = Refl
entityTypeRoundtrip DataReader  = Refl

---------------------------------------------------------------------------
-- ParticipantState (5 constructors, tags 0-4)
-- DDS participant lifecycle state for the FFI layer.
---------------------------------------------------------------------------

||| DDS DomainParticipant lifecycle states.
public export
data ParticipantState : Type where
  ||| No participant created. Initial and terminal state.
  PSIdle        : ParticipantState
  ||| Participant created, joined domain.
  PSJoined      : ParticipantState
  ||| Publishing data (at least one DataWriter exists).
  PSPublishing  : ParticipantState
  ||| Subscribing to data (at least one DataReader exists).
  PSSubscribing : ParticipantState
  ||| Leaving domain (cleanup in progress).
  PSLeaving     : ParticipantState

public export
Eq ParticipantState where
  PSIdle        == PSIdle        = True
  PSJoined      == PSJoined      = True
  PSPublishing  == PSPublishing  = True
  PSSubscribing == PSSubscribing = True
  PSLeaving     == PSLeaving     = True
  _             == _             = False

public export
Show ParticipantState where
  show PSIdle        = "Idle"
  show PSJoined      = "Joined"
  show PSPublishing  = "Publishing"
  show PSSubscribing = "Subscribing"
  show PSLeaving     = "Leaving"

public export
participantStateToTag : ParticipantState -> Bits8
participantStateToTag PSIdle        = 0
participantStateToTag PSJoined      = 1
participantStateToTag PSPublishing  = 2
participantStateToTag PSSubscribing = 3
participantStateToTag PSLeaving     = 4

public export
tagToParticipantState : Bits8 -> Maybe ParticipantState
tagToParticipantState 0 = Just PSIdle
tagToParticipantState 1 = Just PSJoined
tagToParticipantState 2 = Just PSPublishing
tagToParticipantState 3 = Just PSSubscribing
tagToParticipantState 4 = Just PSLeaving
tagToParticipantState _ = Nothing

public export
participantStateRoundtrip : (s : ParticipantState) -> tagToParticipantState (participantStateToTag s) = Just s
participantStateRoundtrip PSIdle        = Refl
participantStateRoundtrip PSJoined      = Refl
participantStateRoundtrip PSPublishing  = Refl
participantStateRoundtrip PSSubscribing = Refl
participantStateRoundtrip PSLeaving     = Refl
