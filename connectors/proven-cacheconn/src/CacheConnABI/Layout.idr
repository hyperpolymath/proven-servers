-- SPDX-License-Identifier: PMPL-1.0-or-later
-- Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
--
-- CacheConnABI.Layout: C-ABI-compatible numeric representations of each type.
--
-- Maps every constructor of the five core sum types (CacheOp, CacheResult,
-- EvictionPolicy, CacheState, CacheError) to a fixed Bits8 value for C interop.
-- Each type gets:
--   * a size constant (always 1 byte for these enumerations)
--   * a total encoder  (xToTag : X -> Bits8)
--   * a partial decoder (tagToX : Bits8 -> Maybe X)
--   * a roundtrip lemma proving that decoding an encoded value is the identity
--
-- Tag values here MUST match the C header (generated/abi/cacheconn.h) and the
-- Zig FFI enums (ffi/zig/src/cacheconn.zig) exactly.

module CacheConnABI.Layout

import CacheConn.Types

%default total

---------------------------------------------------------------------------
-- CacheOp (8 constructors, tags 0-7)
---------------------------------------------------------------------------

||| C-ABI representation size for CacheOp (1 byte).
public export
cacheOpSize : Nat
cacheOpSize = 1

||| Map CacheOp to its C-ABI byte value.
public export
cacheOpToTag : CacheOp -> Bits8
cacheOpToTag Get       = 0
cacheOpToTag Set       = 1
cacheOpToTag Delete    = 2
cacheOpToTag Exists    = 3
cacheOpToTag Expire    = 4
cacheOpToTag Increment = 5
cacheOpToTag Decrement = 6
cacheOpToTag Flush     = 7

||| Recover CacheOp from its C-ABI byte value.
public export
tagToCacheOp : Bits8 -> Maybe CacheOp
tagToCacheOp 0 = Just Get
tagToCacheOp 1 = Just Set
tagToCacheOp 2 = Just Delete
tagToCacheOp 3 = Just Exists
tagToCacheOp 4 = Just Expire
tagToCacheOp 5 = Just Increment
tagToCacheOp 6 = Just Decrement
tagToCacheOp 7 = Just Flush
tagToCacheOp _ = Nothing

||| Proof: encoding then decoding CacheOp is the identity.
public export
cacheOpRoundtrip : (op : CacheOp) -> tagToCacheOp (cacheOpToTag op) = Just op
cacheOpRoundtrip Get       = Refl
cacheOpRoundtrip Set       = Refl
cacheOpRoundtrip Delete    = Refl
cacheOpRoundtrip Exists    = Refl
cacheOpRoundtrip Expire    = Refl
cacheOpRoundtrip Increment = Refl
cacheOpRoundtrip Decrement = Refl
cacheOpRoundtrip Flush     = Refl

---------------------------------------------------------------------------
-- CacheResult (6 constructors, tags 0-5)
---------------------------------------------------------------------------

||| C-ABI representation size for CacheResult (1 byte).
public export
cacheResultSize : Nat
cacheResultSize = 1

||| Map CacheResult to its C-ABI byte value.
public export
cacheResultToTag : CacheResult -> Bits8
cacheResultToTag Hit     = 0
cacheResultToTag Miss    = 1
cacheResultToTag Stored  = 2
cacheResultToTag Deleted = 3
cacheResultToTag Expired = 4
cacheResultToTag Error   = 5

||| Recover CacheResult from its C-ABI byte value.
public export
tagToCacheResult : Bits8 -> Maybe CacheResult
tagToCacheResult 0 = Just Hit
tagToCacheResult 1 = Just Miss
tagToCacheResult 2 = Just Stored
tagToCacheResult 3 = Just Deleted
tagToCacheResult 4 = Just Expired
tagToCacheResult 5 = Just Error
tagToCacheResult _ = Nothing

||| Proof: encoding then decoding CacheResult is the identity.
public export
cacheResultRoundtrip : (r : CacheResult) -> tagToCacheResult (cacheResultToTag r) = Just r
cacheResultRoundtrip Hit     = Refl
cacheResultRoundtrip Miss    = Refl
cacheResultRoundtrip Stored  = Refl
cacheResultRoundtrip Deleted = Refl
cacheResultRoundtrip Expired = Refl
cacheResultRoundtrip Error   = Refl

---------------------------------------------------------------------------
-- EvictionPolicy (6 constructors, tags 0-5)
---------------------------------------------------------------------------

||| C-ABI representation size for EvictionPolicy (1 byte).
public export
evictionPolicySize : Nat
evictionPolicySize = 1

||| Map EvictionPolicy to its C-ABI byte value.
public export
evictionPolicyToTag : EvictionPolicy -> Bits8
evictionPolicyToTag LRU        = 0
evictionPolicyToTag LFU        = 1
evictionPolicyToTag FIFO       = 2
evictionPolicyToTag TTLBased   = 3
evictionPolicyToTag Random     = 4
evictionPolicyToTag NoEviction = 5

||| Recover EvictionPolicy from its C-ABI byte value.
public export
tagToEvictionPolicy : Bits8 -> Maybe EvictionPolicy
tagToEvictionPolicy 0 = Just LRU
tagToEvictionPolicy 1 = Just LFU
tagToEvictionPolicy 2 = Just FIFO
tagToEvictionPolicy 3 = Just TTLBased
tagToEvictionPolicy 4 = Just Random
tagToEvictionPolicy 5 = Just NoEviction
tagToEvictionPolicy _ = Nothing

||| Proof: encoding then decoding EvictionPolicy is the identity.
public export
evictionPolicyRoundtrip : (ep : EvictionPolicy) -> tagToEvictionPolicy (evictionPolicyToTag ep) = Just ep
evictionPolicyRoundtrip LRU        = Refl
evictionPolicyRoundtrip LFU        = Refl
evictionPolicyRoundtrip FIFO       = Refl
evictionPolicyRoundtrip TTLBased   = Refl
evictionPolicyRoundtrip Random     = Refl
evictionPolicyRoundtrip NoEviction = Refl

---------------------------------------------------------------------------
-- CacheState (4 constructors, tags 0-3)
---------------------------------------------------------------------------

||| C-ABI representation size for CacheState (1 byte).
public export
cacheStateSize : Nat
cacheStateSize = 1

||| Map CacheState to its C-ABI byte value.
public export
cacheStateToTag : CacheState -> Bits8
cacheStateToTag Disconnected = 0
cacheStateToTag Connected    = 1
cacheStateToTag Degraded     = 2
cacheStateToTag Failed       = 3

||| Recover CacheState from its C-ABI byte value.
public export
tagToCacheState : Bits8 -> Maybe CacheState
tagToCacheState 0 = Just Disconnected
tagToCacheState 1 = Just Connected
tagToCacheState 2 = Just Degraded
tagToCacheState 3 = Just Failed
tagToCacheState _ = Nothing

||| Proof: encoding then decoding CacheState is the identity.
public export
cacheStateRoundtrip : (s : CacheState) -> tagToCacheState (cacheStateToTag s) = Just s
cacheStateRoundtrip Disconnected = Refl
cacheStateRoundtrip Connected    = Refl
cacheStateRoundtrip Degraded     = Refl
cacheStateRoundtrip Failed       = Refl

---------------------------------------------------------------------------
-- CacheError (6 constructors, tags 1-6; 0 = no error)
---------------------------------------------------------------------------

||| C-ABI representation size for CacheError (1 byte).
||| Note: tag 0 is reserved for "no error" in the C header.
public export
cacheErrorSize : Nat
cacheErrorSize = 1

||| Map CacheError to its C-ABI byte value.
public export
cacheErrorToTag : CacheError -> Bits8
cacheErrorToTag ConnectionLost     = 1
cacheErrorToTag KeyNotFound        = 2
cacheErrorToTag ValueTooLarge      = 3
cacheErrorToTag CapacityExceeded   = 4
cacheErrorToTag SerializationError = 5
cacheErrorToTag Timeout            = 6

||| Recover CacheError from its C-ABI byte value.
public export
tagToCacheError : Bits8 -> Maybe CacheError
tagToCacheError 1 = Just ConnectionLost
tagToCacheError 2 = Just KeyNotFound
tagToCacheError 3 = Just ValueTooLarge
tagToCacheError 4 = Just CapacityExceeded
tagToCacheError 5 = Just SerializationError
tagToCacheError 6 = Just Timeout
tagToCacheError _ = Nothing

||| Proof: encoding then decoding CacheError is the identity.
public export
cacheErrorRoundtrip : (e : CacheError) -> tagToCacheError (cacheErrorToTag e) = Just e
cacheErrorRoundtrip ConnectionLost     = Refl
cacheErrorRoundtrip KeyNotFound        = Refl
cacheErrorRoundtrip ValueTooLarge      = Refl
cacheErrorRoundtrip CapacityExceeded   = Refl
cacheErrorRoundtrip SerializationError = Refl
cacheErrorRoundtrip Timeout            = Refl
