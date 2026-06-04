-- SPDX-License-Identifier: MPL-2.0
-- Copyright (c) Jonathan D.A. Jewell <j.d.a.jewell@open.ac.uk>
--
-- DDS Core Protocol Types (OMG DDS Specification v1.4)
--
-- Defines Quality of Service policies, entity types, reliability kinds,
-- durability kinds, and error conditions as closed sum types with
-- Show/Eq instances. All constructors map to OMG DDS specification sections.

module DDS.Types

%default total

-- ============================================================================
-- DDS Reliability Kind (OMG DDS Section 7.1.3.6)
-- ============================================================================

||| DDS reliability QoS policy kinds.
public export
data ReliabilityKind : Type where
  ||| Best effort: no guarantees on delivery.
  BestEffort  : ReliabilityKind
  ||| Reliable: guaranteed delivery with acknowledgement.
  Reliable    : ReliabilityKind

public export
Eq ReliabilityKind where
  BestEffort == BestEffort = True
  Reliable   == Reliable   = True
  _          == _          = False

public export
Show ReliabilityKind where
  show BestEffort = "BEST_EFFORT"
  show Reliable   = "RELIABLE"

-- ============================================================================
-- DDS Durability Kind (OMG DDS Section 7.1.3.4)
-- ============================================================================

||| DDS durability QoS policy kinds.
public export
data DurabilityKind : Type where
  ||| Volatile: no persistence, only available to currently joined readers.
  Volatile         : DurabilityKind
  ||| Transient Local: available to late-joining readers within same process.
  TransientLocal   : DurabilityKind
  ||| Transient: available to late-joining readers across processes.
  Transient        : DurabilityKind
  ||| Persistent: survives system restarts.
  Persistent       : DurabilityKind

public export
Eq DurabilityKind where
  Volatile       == Volatile       = True
  TransientLocal == TransientLocal = True
  Transient      == Transient      = True
  Persistent     == Persistent     = True
  _              == _              = False

public export
Show DurabilityKind where
  show Volatile       = "VOLATILE"
  show TransientLocal = "TRANSIENT_LOCAL"
  show Transient      = "TRANSIENT"
  show Persistent     = "PERSISTENT"

-- ============================================================================
-- DDS History Kind (OMG DDS Section 7.1.3.5)
-- ============================================================================

||| DDS history QoS policy kinds.
public export
data HistoryKind : Type where
  ||| Keep last N samples per instance.
  KeepLast : HistoryKind
  ||| Keep all samples (bounded by resource limits).
  KeepAll  : HistoryKind

public export
Eq HistoryKind where
  KeepLast == KeepLast = True
  KeepAll  == KeepAll  = True
  _        == _        = False

public export
Show HistoryKind where
  show KeepLast = "KEEP_LAST"
  show KeepAll  = "KEEP_ALL"

-- ============================================================================
-- DDS Ownership Kind (OMG DDS Section 7.1.3.12)
-- ============================================================================

||| DDS ownership QoS policy kinds.
public export
data OwnershipKind : Type where
  ||| Shared: multiple writers can update the same instance.
  Shared    : OwnershipKind
  ||| Exclusive: highest-strength writer owns the instance.
  Exclusive : OwnershipKind

public export
Eq OwnershipKind where
  Shared    == Shared    = True
  Exclusive == Exclusive = True
  _         == _         = False

public export
Show OwnershipKind where
  show Shared    = "SHARED"
  show Exclusive = "EXCLUSIVE"

-- ============================================================================
-- DDS Entity Types
-- ============================================================================

||| DDS entity types in the DCPS layer.
public export
data EntityType : Type where
  ||| DomainParticipant: entry point to the DDS domain.
  Participant : EntityType
  ||| Publisher: groups DataWriters.
  Publisher   : EntityType
  ||| Subscriber: groups DataReaders.
  Subscriber  : EntityType
  ||| Topic: defines a named data type in the domain.
  TopicEntity : EntityType
  ||| DataWriter: publishes data of a specific topic.
  DataWriter  : EntityType
  ||| DataReader: subscribes to data of a specific topic.
  DataReader  : EntityType

public export
Eq EntityType where
  Participant == Participant = True
  Publisher   == Publisher   = True
  Subscriber  == Subscriber  = True
  TopicEntity == TopicEntity = True
  DataWriter  == DataWriter  = True
  DataReader  == DataReader  = True
  _           == _           = False

public export
Show EntityType where
  show Participant = "DomainParticipant"
  show Publisher   = "Publisher"
  show Subscriber  = "Subscriber"
  show TopicEntity = "Topic"
  show DataWriter  = "DataWriter"
  show DataReader  = "DataReader"

-- ============================================================================
-- DDS Return Codes (OMG DDS Section 2.2.1.1)
-- ============================================================================

||| DDS return codes per OMG specification.
public export
data ReturnCode : Type where
  ||| Operation completed successfully.
  Ok                 : ReturnCode
  ||| Generic, unspecified error.
  Error              : ReturnCode
  ||| Unsupported operation.
  Unsupported        : ReturnCode
  ||| Illegal parameter value.
  BadParameter       : ReturnCode
  ||| Precondition for operation not met.
  PreconditionNotMet : ReturnCode
  ||| Insufficient resources.
  OutOfResources     : ReturnCode
  ||| Entity not enabled.
  NotEnabled         : ReturnCode
  ||| Immutable policy change attempted.
  ImmutablePolicy    : ReturnCode
  ||| Inconsistent policy combination.
  InconsistentPolicy : ReturnCode
  ||| Entity already deleted.
  AlreadyDeleted     : ReturnCode
  ||| Timeout expired.
  Timeout            : ReturnCode
  ||| No data available.
  NoData             : ReturnCode

public export
Eq ReturnCode where
  Ok                 == Ok                 = True
  Error              == Error              = True
  Unsupported        == Unsupported        = True
  BadParameter       == BadParameter       = True
  PreconditionNotMet == PreconditionNotMet = True
  OutOfResources     == OutOfResources     = True
  NotEnabled         == NotEnabled         = True
  ImmutablePolicy    == ImmutablePolicy    = True
  InconsistentPolicy == InconsistentPolicy = True
  AlreadyDeleted     == AlreadyDeleted     = True
  Timeout            == Timeout            = True
  NoData             == NoData             = True
  _                  == _                  = False

public export
Show ReturnCode where
  show Ok                 = "OK"
  show Error              = "ERROR"
  show Unsupported        = "UNSUPPORTED"
  show BadParameter       = "BAD_PARAMETER"
  show PreconditionNotMet = "PRECONDITION_NOT_MET"
  show OutOfResources     = "OUT_OF_RESOURCES"
  show NotEnabled         = "NOT_ENABLED"
  show ImmutablePolicy    = "IMMUTABLE_POLICY"
  show InconsistentPolicy = "INCONSISTENT_POLICY"
  show AlreadyDeleted     = "ALREADY_DELETED"
  show Timeout            = "TIMEOUT"
  show NoData             = "NO_DATA"
