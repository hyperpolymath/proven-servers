-- SPDX-License-Identifier: PMPL-1.0-or-later
-- Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
--
-- DdsABI.Types: C-ABI-compatible numeric representations of Dds types.
--
-- Maps every constructor of the core Dds sum types to fixed Bits8 values
-- for C interop. Each type gets a total encoder, partial decoder, and
-- roundtrip proof (encode then decode = identity).
--
-- Tag values here MUST match the C header and the
-- Zig FFI enums (ffi/zig/src/dds.zig) exactly.
--
-- Types covered:
--   ReliabilityKind           (2 constructors, tags 0-1)
--   DurabilityKind            (3 constructors, tags 0-3)
--   HistoryKind               (2 constructors, tags 0-1)
--   OwnershipKind             (2 constructors, tags 0-1)
--   EntityType                (6 constructors, tags 0-5)
--   ParticipantState          (5 constructors, tags 0-4)

module DdsABI.Types

%default total

---------------------------------------------------------------------------
-- ReliabilityKind (2 constructors, tags 0-1)
---------------------------------------------------------------------------

public export
reliability_kindSize : Nat
reliability_kindSize = 1

||| ReliabilityKind sum type for ABI encoding.
public export
data ReliabilityKind : Type where
  BestEffort : ReliabilityKind
  Reliable : ReliabilityKind

||| Encode a ReliabilityKind to its ABI tag value.
public export
reliability_kindToTag : ReliabilityKind -> Bits8
reliability_kindToTag BestEffort = 0
reliability_kindToTag Reliable = 1

||| Decode an ABI tag to a ReliabilityKind.
public export
tagToReliabilityKind : Bits8 -> Maybe ReliabilityKind
tagToReliabilityKind 0 = Just BestEffort
tagToReliabilityKind 1 = Just Reliable
tagToReliabilityKind _ = Nothing

||| Roundtrip proof: decoding an encoded ReliabilityKind yields the original.
public export
reliability_kindRoundtrip : (x : ReliabilityKind) -> tagToReliabilityKind (reliability_kindToTag x) = Just x
reliability_kindRoundtrip BestEffort = Refl
reliability_kindRoundtrip Reliable = Refl

---------------------------------------------------------------------------
-- DurabilityKind (3 constructors, tags 0-3)
---------------------------------------------------------------------------

public export
durability_kindSize : Nat
durability_kindSize = 1

||| DurabilityKind sum type for ABI encoding.
public export
data DurabilityKind : Type where
  TransientLocal : DurabilityKind
  Transient : DurabilityKind
  Persistent : DurabilityKind

||| Encode a DurabilityKind to its ABI tag value.
public export
durability_kindToTag : DurabilityKind -> Bits8
durability_kindToTag TransientLocal = 1
durability_kindToTag Transient = 2
durability_kindToTag Persistent = 3

||| Decode an ABI tag to a DurabilityKind.
public export
tagToDurabilityKind : Bits8 -> Maybe DurabilityKind
tagToDurabilityKind 1 = Just TransientLocal
tagToDurabilityKind 2 = Just Transient
tagToDurabilityKind 3 = Just Persistent
tagToDurabilityKind _ = Nothing

||| Roundtrip proof: decoding an encoded DurabilityKind yields the original.
public export
durability_kindRoundtrip : (x : DurabilityKind) -> tagToDurabilityKind (durability_kindToTag x) = Just x
durability_kindRoundtrip TransientLocal = Refl
durability_kindRoundtrip Transient = Refl
durability_kindRoundtrip Persistent = Refl

---------------------------------------------------------------------------
-- HistoryKind (2 constructors, tags 0-1)
---------------------------------------------------------------------------

public export
history_kindSize : Nat
history_kindSize = 1

||| HistoryKind sum type for ABI encoding.
public export
data HistoryKind : Type where
  KeepLast : HistoryKind
  KeepAll : HistoryKind

||| Encode a HistoryKind to its ABI tag value.
public export
history_kindToTag : HistoryKind -> Bits8
history_kindToTag KeepLast = 0
history_kindToTag KeepAll = 1

||| Decode an ABI tag to a HistoryKind.
public export
tagToHistoryKind : Bits8 -> Maybe HistoryKind
tagToHistoryKind 0 = Just KeepLast
tagToHistoryKind 1 = Just KeepAll
tagToHistoryKind _ = Nothing

||| Roundtrip proof: decoding an encoded HistoryKind yields the original.
public export
history_kindRoundtrip : (x : HistoryKind) -> tagToHistoryKind (history_kindToTag x) = Just x
history_kindRoundtrip KeepLast = Refl
history_kindRoundtrip KeepAll = Refl

---------------------------------------------------------------------------
-- OwnershipKind (2 constructors, tags 0-1)
---------------------------------------------------------------------------

public export
ownership_kindSize : Nat
ownership_kindSize = 1

||| OwnershipKind sum type for ABI encoding.
public export
data OwnershipKind : Type where
  Shared : OwnershipKind
  Exclusive : OwnershipKind

||| Encode a OwnershipKind to its ABI tag value.
public export
ownership_kindToTag : OwnershipKind -> Bits8
ownership_kindToTag Shared = 0
ownership_kindToTag Exclusive = 1

||| Decode an ABI tag to a OwnershipKind.
public export
tagToOwnershipKind : Bits8 -> Maybe OwnershipKind
tagToOwnershipKind 0 = Just Shared
tagToOwnershipKind 1 = Just Exclusive
tagToOwnershipKind _ = Nothing

||| Roundtrip proof: decoding an encoded OwnershipKind yields the original.
public export
ownership_kindRoundtrip : (x : OwnershipKind) -> tagToOwnershipKind (ownership_kindToTag x) = Just x
ownership_kindRoundtrip Shared = Refl
ownership_kindRoundtrip Exclusive = Refl

---------------------------------------------------------------------------
-- EntityType (6 constructors, tags 0-5)
---------------------------------------------------------------------------

public export
entity_typeSize : Nat
entity_typeSize = 1

||| EntityType sum type for ABI encoding.
public export
data EntityType : Type where
  Participant : EntityType
  Publisher : EntityType
  Subscriber : EntityType
  Topic : EntityType
  DataWriter : EntityType
  DataReader : EntityType

||| Encode a EntityType to its ABI tag value.
public export
entity_typeToTag : EntityType -> Bits8
entity_typeToTag Participant = 0
entity_typeToTag Publisher = 1
entity_typeToTag Subscriber = 2
entity_typeToTag Topic = 3
entity_typeToTag DataWriter = 4
entity_typeToTag DataReader = 5

||| Decode an ABI tag to a EntityType.
public export
tagToEntityType : Bits8 -> Maybe EntityType
tagToEntityType 0 = Just Participant
tagToEntityType 1 = Just Publisher
tagToEntityType 2 = Just Subscriber
tagToEntityType 3 = Just Topic
tagToEntityType 4 = Just DataWriter
tagToEntityType 5 = Just DataReader
tagToEntityType _ = Nothing

||| Roundtrip proof: decoding an encoded EntityType yields the original.
public export
entity_typeRoundtrip : (x : EntityType) -> tagToEntityType (entity_typeToTag x) = Just x
entity_typeRoundtrip Participant = Refl
entity_typeRoundtrip Publisher = Refl
entity_typeRoundtrip Subscriber = Refl
entity_typeRoundtrip Topic = Refl
entity_typeRoundtrip DataWriter = Refl
entity_typeRoundtrip DataReader = Refl

---------------------------------------------------------------------------
-- ParticipantState (5 constructors, tags 0-4)
---------------------------------------------------------------------------

public export
participant_stateSize : Nat
participant_stateSize = 1

||| ParticipantState sum type for ABI encoding.
public export
data ParticipantState : Type where
  Idle : ParticipantState
  Joined : ParticipantState
  Publishing : ParticipantState
  Subscribing : ParticipantState
  Leaving : ParticipantState

||| Encode a ParticipantState to its ABI tag value.
public export
participant_stateToTag : ParticipantState -> Bits8
participant_stateToTag Idle = 0
participant_stateToTag Joined = 1
participant_stateToTag Publishing = 2
participant_stateToTag Subscribing = 3
participant_stateToTag Leaving = 4

||| Decode an ABI tag to a ParticipantState.
public export
tagToParticipantState : Bits8 -> Maybe ParticipantState
tagToParticipantState 0 = Just Idle
tagToParticipantState 1 = Just Joined
tagToParticipantState 2 = Just Publishing
tagToParticipantState 3 = Just Subscribing
tagToParticipantState 4 = Just Leaving
tagToParticipantState _ = Nothing

||| Roundtrip proof: decoding an encoded ParticipantState yields the original.
public export
participant_stateRoundtrip : (x : ParticipantState) -> tagToParticipantState (participant_stateToTag x) = Just x
participant_stateRoundtrip Idle = Refl
participant_stateRoundtrip Joined = Refl
participant_stateRoundtrip Publishing = Refl
participant_stateRoundtrip Subscribing = Refl
participant_stateRoundtrip Leaving = Refl
