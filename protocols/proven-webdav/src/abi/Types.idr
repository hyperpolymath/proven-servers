-- SPDX-License-Identifier: MPL-2.0
-- Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
--
-- WebDAVABI.Types: C-ABI-compatible numeric representations of WebDAV types.
--
-- Maps every constructor of the core WebDAV sum types to fixed Bits8 values
-- for C interop. Each type gets a total encoder, partial decoder, and
-- roundtrip proof (encode then decode = identity).
--
-- Tag values here MUST match the C header (generated/abi/webdav.h) and the
-- Zig FFI enums (ffi/zig/src/webdav.zig) exactly.
--
-- Types covered:
--   Method      (7 constructors, tags 0-6)
--   StatusCode  (5 constructors, tags 0-4)
--   LockScope   (2 constructors, tags 0-1)
--   LockType    (1 constructor, tag 0)
--   Depth       (3 constructors, tags 0-2)
--   PropertyOp  (2 constructors, tags 0-1)

module WebDAVABI.Types

import WebDAV.Types

%default total

---------------------------------------------------------------------------
-- Method (7 constructors, tags 0-6)
---------------------------------------------------------------------------

public export
methodSize : Nat
methodSize = 1

||| Encode a Method to its ABI tag value.
public export
methodToTag : Method -> Bits8
methodToTag Propfind  = 0
methodToTag Proppatch = 1
methodToTag Mkcol     = 2
methodToTag Copy      = 3
methodToTag Move      = 4
methodToTag Lock      = 5
methodToTag Unlock    = 6

||| Decode an ABI tag to a Method.
public export
tagToMethod : Bits8 -> Maybe Method
tagToMethod 0 = Just Propfind
tagToMethod 1 = Just Proppatch
tagToMethod 2 = Just Mkcol
tagToMethod 3 = Just Copy
tagToMethod 4 = Just Move
tagToMethod 5 = Just Lock
tagToMethod 6 = Just Unlock
tagToMethod _ = Nothing

||| Roundtrip proof: decoding an encoded Method yields the original.
public export
methodRoundtrip : (m : Method) -> tagToMethod (methodToTag m) = Just m
methodRoundtrip Propfind  = Refl
methodRoundtrip Proppatch = Refl
methodRoundtrip Mkcol     = Refl
methodRoundtrip Copy      = Refl
methodRoundtrip Move      = Refl
methodRoundtrip Lock      = Refl
methodRoundtrip Unlock    = Refl

---------------------------------------------------------------------------
-- StatusCode (5 constructors, tags 0-4)
---------------------------------------------------------------------------

public export
statusCodeSize : Nat
statusCodeSize = 1

||| Encode a StatusCode to its ABI tag value.
public export
statusCodeToTag : StatusCode -> Bits8
statusCodeToTag MultiStatus         = 0
statusCodeToTag UnprocessableEntity = 1
statusCodeToTag Locked              = 2
statusCodeToTag FailedDependency    = 3
statusCodeToTag InsufficientStorage = 4

||| Decode an ABI tag to a StatusCode.
public export
tagToStatusCode : Bits8 -> Maybe StatusCode
tagToStatusCode 0 = Just MultiStatus
tagToStatusCode 1 = Just UnprocessableEntity
tagToStatusCode 2 = Just Locked
tagToStatusCode 3 = Just FailedDependency
tagToStatusCode 4 = Just InsufficientStorage
tagToStatusCode _ = Nothing

||| Roundtrip proof: decoding an encoded StatusCode yields the original.
public export
statusCodeRoundtrip : (s : StatusCode) -> tagToStatusCode (statusCodeToTag s) = Just s
statusCodeRoundtrip MultiStatus         = Refl
statusCodeRoundtrip UnprocessableEntity = Refl
statusCodeRoundtrip Locked              = Refl
statusCodeRoundtrip FailedDependency    = Refl
statusCodeRoundtrip InsufficientStorage = Refl

---------------------------------------------------------------------------
-- LockScope (2 constructors, tags 0-1)
---------------------------------------------------------------------------

public export
lockScopeSize : Nat
lockScopeSize = 1

||| Encode a LockScope to its ABI tag value.
public export
lockScopeToTag : LockScope -> Bits8
lockScopeToTag Exclusive = 0
lockScopeToTag Shared    = 1

||| Decode an ABI tag to a LockScope.
public export
tagToLockScope : Bits8 -> Maybe LockScope
tagToLockScope 0 = Just Exclusive
tagToLockScope 1 = Just Shared
tagToLockScope _ = Nothing

||| Roundtrip proof: decoding an encoded LockScope yields the original.
public export
lockScopeRoundtrip : (l : LockScope) -> tagToLockScope (lockScopeToTag l) = Just l
lockScopeRoundtrip Exclusive = Refl
lockScopeRoundtrip Shared    = Refl

---------------------------------------------------------------------------
-- LockType (1 constructor, tag 0)
---------------------------------------------------------------------------

public export
lockTypeSize : Nat
lockTypeSize = 1

||| Encode a LockType to its ABI tag value.
public export
lockTypeToTag : LockType -> Bits8
lockTypeToTag Write = 0

||| Decode an ABI tag to a LockType.
public export
tagToLockType : Bits8 -> Maybe LockType
tagToLockType 0 = Just Write
tagToLockType _ = Nothing

||| Roundtrip proof: decoding an encoded LockType yields the original.
public export
lockTypeRoundtrip : (l : LockType) -> tagToLockType (lockTypeToTag l) = Just l
lockTypeRoundtrip Write = Refl

---------------------------------------------------------------------------
-- Depth (3 constructors, tags 0-2)
---------------------------------------------------------------------------

public export
depthSize : Nat
depthSize = 1

||| Encode a Depth to its ABI tag value.
public export
depthToTag : Depth -> Bits8
depthToTag Zero     = 0
depthToTag One      = 1
depthToTag Infinity = 2

||| Decode an ABI tag to a Depth.
public export
tagToDepth : Bits8 -> Maybe Depth
tagToDepth 0 = Just Zero
tagToDepth 1 = Just One
tagToDepth 2 = Just Infinity
tagToDepth _ = Nothing

||| Roundtrip proof: decoding an encoded Depth yields the original.
public export
depthRoundtrip : (d : Depth) -> tagToDepth (depthToTag d) = Just d
depthRoundtrip Zero     = Refl
depthRoundtrip One      = Refl
depthRoundtrip Infinity = Refl

---------------------------------------------------------------------------
-- PropertyOp (2 constructors, tags 0-1)
---------------------------------------------------------------------------

public export
propertyOpSize : Nat
propertyOpSize = 1

||| Encode a PropertyOp to its ABI tag value.
public export
propertyOpToTag : PropertyOp -> Bits8
propertyOpToTag Set    = 0
propertyOpToTag Remove = 1

||| Decode an ABI tag to a PropertyOp.
public export
tagToPropertyOp : Bits8 -> Maybe PropertyOp
tagToPropertyOp 0 = Just Set
tagToPropertyOp 1 = Just Remove
tagToPropertyOp _ = Nothing

||| Roundtrip proof: decoding an encoded PropertyOp yields the original.
public export
propertyOpRoundtrip : (p : PropertyOp) -> tagToPropertyOp (propertyOpToTag p) = Just p
propertyOpRoundtrip Set    = Refl
propertyOpRoundtrip Remove = Refl
