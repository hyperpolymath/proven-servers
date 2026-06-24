-- SPDX-License-Identifier: MPL-2.0
-- Copyright (c) Jonathan D.A. Jewell <j.d.a.jewell@open.ac.uk>
--
-- DDSABI.Emit: ABI tag-manifest emitter (single source of truth).
-- Prints `KIND NAME DECIMAL` lines from the proven *ToTag encoders;
-- tools/gen-abi.sh renders them into dds_abi_gen.zig for the comptime guard.

module DDSABI.Emit

import DDS.Types
import DDSABI.Types
import DDSABI.Foreign

%default total

line : String -> String -> Bits8 -> String
line kind name val = kind ++ " " ++ name ++ " " ++ show val

manifest : List String
manifest =
  [ "ABI_VERSION " ++ show abiVersion
  , line "REL" "BEST_EFFORT" (reliabilityKindToTag BestEffort)
  , line "REL" "RELIABLE"    (reliabilityKindToTag Reliable)
  , line "DUR" "VOLATILE"        (durabilityKindToTag Volatile)
  , line "DUR" "TRANSIENT_LOCAL" (durabilityKindToTag TransientLocal)
  , line "DUR" "TRANSIENT"       (durabilityKindToTag Transient)
  , line "DUR" "PERSISTENT"      (durabilityKindToTag Persistent)
  , line "HIST" "KEEP_LAST" (historyKindToTag KeepLast)
  , line "HIST" "KEEP_ALL"  (historyKindToTag KeepAll)
  , line "OWN" "SHARED"    (ownershipKindToTag Shared)
  , line "OWN" "EXCLUSIVE" (ownershipKindToTag Exclusive)
  , line "ENT" "PARTICIPANT" (entityTypeToTag Participant)
  , line "ENT" "PUBLISHER"   (entityTypeToTag Publisher)
  , line "ENT" "SUBSCRIBER"  (entityTypeToTag Subscriber)
  , line "ENT" "TOPIC"       (entityTypeToTag TopicEntity)
  , line "ENT" "DATA_WRITER" (entityTypeToTag DataWriter)
  , line "ENT" "DATA_READER" (entityTypeToTag DataReader)
  , line "PSTATE" "IDLE"        (participantStateToTag PSIdle)
  , line "PSTATE" "JOINED"      (participantStateToTag PSJoined)
  , line "PSTATE" "PUBLISHING"  (participantStateToTag PSPublishing)
  , line "PSTATE" "SUBSCRIBING" (participantStateToTag PSSubscribing)
  , line "PSTATE" "LEAVING"     (participantStateToTag PSLeaving)
  ]

covering
main : IO ()
main = traverse_ putStrLn manifest
