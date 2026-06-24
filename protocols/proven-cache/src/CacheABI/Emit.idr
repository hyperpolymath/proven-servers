-- SPDX-License-Identifier: MPL-2.0
-- Copyright (c) Jonathan D.A. Jewell <j.d.a.jewell@open.ac.uk>
--
-- CacheABI.Emit: ABI tag-manifest emitter (single source of truth).
-- Prints `KIND NAME DECIMAL` lines from the proven *ToTag encoders;
-- tools/gen-abi.sh renders them into cache_abi_gen.zig for the comptime guard.

module CacheABI.Emit

import Cache.Types
import CacheABI.Types
import CacheABI.Foreign

%default total

line : String -> String -> Bits8 -> String
line kind name val = kind ++ " " ++ name ++ " " ++ show val

manifest : List String
manifest =
  [ "ABI_VERSION " ++ show abiVersion
  , line "CMD" "GET"     (commandToTag Get)
  , line "CMD" "SET"     (commandToTag Set)
  , line "CMD" "DELETE"  (commandToTag Delete)
  , line "CMD" "EXISTS"  (commandToTag Exists)
  , line "CMD" "EXPIRE"  (commandToTag Expire)
  , line "CMD" "TTL"     (commandToTag TTL)
  , line "CMD" "KEYS"    (commandToTag Keys)
  , line "CMD" "FLUSH"   (commandToTag Flush)
  , line "CMD" "INCR"    (commandToTag Incr)
  , line "CMD" "DECR"    (commandToTag Decr)
  , line "CMD" "APPEND"  (commandToTag Append)
  , line "CMD" "PREPEND" (commandToTag Prepend)
  , line "CMD" "CAS"     (commandToTag CAS)
  , line "EVICT" "LRU"         (evictionPolicyToTag LRU)
  , line "EVICT" "LFU"         (evictionPolicyToTag LFU)
  , line "EVICT" "RANDOM"      (evictionPolicyToTag Random)
  , line "EVICT" "EVICT_TTL"   (evictionPolicyToTag EvictTTL)
  , line "EVICT" "NO_EVICTION" (evictionPolicyToTag NoEviction)
  , line "DTYPE" "STRING_VAL" (dataTypeToTag StringVal)
  , line "DTYPE" "INT_VAL"    (dataTypeToTag IntVal)
  , line "DTYPE" "LIST_VAL"   (dataTypeToTag ListVal)
  , line "DTYPE" "SET_VAL"    (dataTypeToTag SetVal)
  , line "DTYPE" "HASH_VAL"   (dataTypeToTag HashVal)
  , line "ERR" "NOT_FOUND"       (errorCodeToTag NotFound)
  , line "ERR" "TYPE_MISMATCH"   (errorCodeToTag TypeMismatch)
  , line "ERR" "OUT_OF_MEMORY"   (errorCodeToTag OutOfMemory)
  , line "ERR" "KEY_TOO_LONG"    (errorCodeToTag KeyTooLong)
  , line "ERR" "VALUE_TOO_LARGE" (errorCodeToTag ValueTooLarge)
  , line "ERR" "CAS_CONFLICT"    (errorCodeToTag CASConflict)
  , line "REPL" "NONE"     (replicationModeToTag RNone)
  , line "REPL" "PRIMARY"  (replicationModeToTag Primary)
  , line "REPL" "REPLICA"  (replicationModeToTag Replica)
  , line "REPL" "SENTINEL" (replicationModeToTag Sentinel)
  ]

covering
main : IO ()
main = traverse_ putStrLn manifest
