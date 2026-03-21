-- SPDX-License-Identifier: PMPL-1.0-or-later
-- Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
--
-- CacheABI.Types: C-ABI-compatible numeric representations of proven-cache types.
--
-- Maps every constructor of the core cache sum types to fixed Bits8 values
-- for C interop.  Each type gets a total encoder, partial decoder, and
-- roundtrip proof guaranteeing encoding/decoding never loses information.
--
-- Tag values here MUST match the Zig FFI enums (ffi/zig/src/cache.zig) exactly.
--
-- Types covered:
--   Command         (13 constructors, tags 0-12)
--   EvictionPolicy  (5 constructors, tags 0-4)
--   DataType        (5 constructors, tags 0-4)
--   ErrorCode       (6 constructors, tags 0-5)
--   ReplicationMode (4 constructors, tags 0-3)

module CacheABI.Types

import Cache.Types

%default total

---------------------------------------------------------------------------
-- Command (13 constructors, tags 0-12)
---------------------------------------------------------------------------

public export
commandSize : Nat
commandSize = 1

||| Encode Command to its ABI tag value.
public export
commandToTag : Command -> Bits8
commandToTag Get     = 0
commandToTag Set     = 1
commandToTag Delete  = 2
commandToTag Exists  = 3
commandToTag Expire  = 4
commandToTag TTL     = 5
commandToTag Keys    = 6
commandToTag Flush   = 7
commandToTag Incr    = 8
commandToTag Decr    = 9
commandToTag Append  = 10
commandToTag Prepend = 11
commandToTag CAS     = 12

public export
tagToCommand : Bits8 -> Maybe Command
tagToCommand 0  = Just Get
tagToCommand 1  = Just Set
tagToCommand 2  = Just Delete
tagToCommand 3  = Just Exists
tagToCommand 4  = Just Expire
tagToCommand 5  = Just TTL
tagToCommand 6  = Just Keys
tagToCommand 7  = Just Flush
tagToCommand 8  = Just Incr
tagToCommand 9  = Just Decr
tagToCommand 10 = Just Append
tagToCommand 11 = Just Prepend
tagToCommand 12 = Just CAS
tagToCommand _  = Nothing

public export
commandRoundtrip : (c : Command) -> tagToCommand (commandToTag c) = Just c
commandRoundtrip Get     = Refl
commandRoundtrip Set     = Refl
commandRoundtrip Delete  = Refl
commandRoundtrip Exists  = Refl
commandRoundtrip Expire  = Refl
commandRoundtrip TTL     = Refl
commandRoundtrip Keys    = Refl
commandRoundtrip Flush   = Refl
commandRoundtrip Incr    = Refl
commandRoundtrip Decr    = Refl
commandRoundtrip Append  = Refl
commandRoundtrip Prepend = Refl
commandRoundtrip CAS     = Refl

---------------------------------------------------------------------------
-- EvictionPolicy (5 constructors, tags 0-4)
---------------------------------------------------------------------------

public export
evictionPolicySize : Nat
evictionPolicySize = 1

||| Encode EvictionPolicy to its ABI tag value.
public export
evictionPolicyToTag : EvictionPolicy -> Bits8
evictionPolicyToTag LRU        = 0
evictionPolicyToTag LFU        = 1
evictionPolicyToTag Random     = 2
evictionPolicyToTag EvictTTL   = 3
evictionPolicyToTag NoEviction = 4

public export
tagToEvictionPolicy : Bits8 -> Maybe EvictionPolicy
tagToEvictionPolicy 0 = Just LRU
tagToEvictionPolicy 1 = Just LFU
tagToEvictionPolicy 2 = Just Random
tagToEvictionPolicy 3 = Just EvictTTL
tagToEvictionPolicy 4 = Just NoEviction
tagToEvictionPolicy _ = Nothing

public export
evictionPolicyRoundtrip : (p : EvictionPolicy) -> tagToEvictionPolicy (evictionPolicyToTag p) = Just p
evictionPolicyRoundtrip LRU        = Refl
evictionPolicyRoundtrip LFU        = Refl
evictionPolicyRoundtrip Random     = Refl
evictionPolicyRoundtrip EvictTTL   = Refl
evictionPolicyRoundtrip NoEviction = Refl

---------------------------------------------------------------------------
-- DataType (5 constructors, tags 0-4)
---------------------------------------------------------------------------

public export
dataTypeSize : Nat
dataTypeSize = 1

||| Encode DataType to its ABI tag value.
public export
dataTypeToTag : DataType -> Bits8
dataTypeToTag StringVal = 0
dataTypeToTag IntVal    = 1
dataTypeToTag ListVal   = 2
dataTypeToTag SetVal    = 3
dataTypeToTag HashVal   = 4

public export
tagToDataType : Bits8 -> Maybe DataType
tagToDataType 0 = Just StringVal
tagToDataType 1 = Just IntVal
tagToDataType 2 = Just ListVal
tagToDataType 3 = Just SetVal
tagToDataType 4 = Just HashVal
tagToDataType _ = Nothing

public export
dataTypeRoundtrip : (d : DataType) -> tagToDataType (dataTypeToTag d) = Just d
dataTypeRoundtrip StringVal = Refl
dataTypeRoundtrip IntVal    = Refl
dataTypeRoundtrip ListVal   = Refl
dataTypeRoundtrip SetVal    = Refl
dataTypeRoundtrip HashVal   = Refl

---------------------------------------------------------------------------
-- ErrorCode (6 constructors, tags 0-5)
---------------------------------------------------------------------------

public export
errorCodeSize : Nat
errorCodeSize = 1

||| Encode ErrorCode to its ABI tag value.
public export
errorCodeToTag : ErrorCode -> Bits8
errorCodeToTag NotFound      = 0
errorCodeToTag TypeMismatch  = 1
errorCodeToTag OutOfMemory   = 2
errorCodeToTag KeyTooLong    = 3
errorCodeToTag ValueTooLarge = 4
errorCodeToTag CASConflict   = 5

public export
tagToErrorCode : Bits8 -> Maybe ErrorCode
tagToErrorCode 0 = Just NotFound
tagToErrorCode 1 = Just TypeMismatch
tagToErrorCode 2 = Just OutOfMemory
tagToErrorCode 3 = Just KeyTooLong
tagToErrorCode 4 = Just ValueTooLarge
tagToErrorCode 5 = Just CASConflict
tagToErrorCode _ = Nothing

public export
errorCodeRoundtrip : (e : ErrorCode) -> tagToErrorCode (errorCodeToTag e) = Just e
errorCodeRoundtrip NotFound      = Refl
errorCodeRoundtrip TypeMismatch  = Refl
errorCodeRoundtrip OutOfMemory   = Refl
errorCodeRoundtrip KeyTooLong    = Refl
errorCodeRoundtrip ValueTooLarge = Refl
errorCodeRoundtrip CASConflict   = Refl

---------------------------------------------------------------------------
-- ReplicationMode (4 constructors, tags 0-3)
---------------------------------------------------------------------------

public export
replicationModeSize : Nat
replicationModeSize = 1

||| Encode ReplicationMode to its ABI tag value.
public export
replicationModeToTag : ReplicationMode -> Bits8
replicationModeToTag RNone    = 0
replicationModeToTag Primary  = 1
replicationModeToTag Replica  = 2
replicationModeToTag Sentinel = 3

public export
tagToReplicationMode : Bits8 -> Maybe ReplicationMode
tagToReplicationMode 0 = Just RNone
tagToReplicationMode 1 = Just Primary
tagToReplicationMode 2 = Just Replica
tagToReplicationMode 3 = Just Sentinel
tagToReplicationMode _ = Nothing

public export
replicationModeRoundtrip : (m : ReplicationMode) -> tagToReplicationMode (replicationModeToTag m) = Just m
replicationModeRoundtrip RNone    = Refl
replicationModeRoundtrip Primary  = Refl
replicationModeRoundtrip Replica  = Refl
replicationModeRoundtrip Sentinel = Refl
