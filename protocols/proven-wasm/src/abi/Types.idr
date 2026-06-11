-- SPDX-License-Identifier: MPL-2.0
-- Copyright (c) Jonathan D.A. Jewell <j.d.a.jewell@open.ac.uk>
--
-- WASMABI.Types: C-ABI-compatible numeric representations of WASM types.
--
-- Maps every constructor of the core WASM sum types to fixed Bits8 values
-- for C interop. Each type gets a total encoder, partial decoder, and
-- roundtrip proof (encode then decode = identity).
--
-- Tag values here MUST match the C header (generated/abi/wasm.h) and the
-- Zig FFI enums (ffi/zig/src/wasm.zig) exactly.
--
-- Types covered:
--   ValType     (7 constructors, tags 0-6)
--   ExternKind  (4 constructors, tags 0-3)
--   Mutability  (2 constructors, tags 0-1)

module WASMABI.Types

import WASM.ValType
import WASM.Types

%default total

---------------------------------------------------------------------------
-- ValType (7 constructors, tags 0-6)
---------------------------------------------------------------------------

public export
valTypeTagSize : Nat
valTypeTagSize = 1

||| Encode a ValType to its ABI tag value.
public export
valTypeToTag : ValType -> Bits8
valTypeToTag I32       = 0
valTypeToTag I64       = 1
valTypeToTag F32       = 2
valTypeToTag F64       = 3
valTypeToTag V128      = 4
valTypeToTag FuncRef   = 5
valTypeToTag ExternRef = 6

||| Decode an ABI tag to a ValType.
public export
tagToValType : Bits8 -> Maybe ValType
tagToValType 0 = Just I32
tagToValType 1 = Just I64
tagToValType 2 = Just F32
tagToValType 3 = Just F64
tagToValType 4 = Just V128
tagToValType 5 = Just FuncRef
tagToValType 6 = Just ExternRef
tagToValType _ = Nothing

||| Roundtrip proof: decoding an encoded ValType yields the original.
public export
valTypeRoundtrip : (v : ValType) -> tagToValType (valTypeToTag v) = Just v
valTypeRoundtrip I32       = Refl
valTypeRoundtrip I64       = Refl
valTypeRoundtrip F32       = Refl
valTypeRoundtrip F64       = Refl
valTypeRoundtrip V128      = Refl
valTypeRoundtrip FuncRef   = Refl
valTypeRoundtrip ExternRef = Refl

---------------------------------------------------------------------------
-- ExternKind (4 constructors, tags 0-3)
---------------------------------------------------------------------------

public export
externKindSize : Nat
externKindSize = 1

||| Encode an ExternKind to its ABI tag value.
public export
externKindToTag : ExternKind -> Bits8
externKindToTag FuncExtern   = 0
externKindToTag TableExtern  = 1
externKindToTag MemExtern    = 2
externKindToTag GlobalExtern = 3

||| Decode an ABI tag to an ExternKind.
public export
tagToExternKind : Bits8 -> Maybe ExternKind
tagToExternKind 0 = Just FuncExtern
tagToExternKind 1 = Just TableExtern
tagToExternKind 2 = Just MemExtern
tagToExternKind 3 = Just GlobalExtern
tagToExternKind _ = Nothing

||| Roundtrip proof: decoding an encoded ExternKind yields the original.
public export
externKindRoundtrip : (e : ExternKind) -> tagToExternKind (externKindToTag e) = Just e
externKindRoundtrip FuncExtern   = Refl
externKindRoundtrip TableExtern  = Refl
externKindRoundtrip MemExtern    = Refl
externKindRoundtrip GlobalExtern = Refl

---------------------------------------------------------------------------
-- Mutability (2 constructors, tags 0-1)
---------------------------------------------------------------------------

public export
mutabilitySize : Nat
mutabilitySize = 1

||| Encode a Mutability to its ABI tag value.
public export
mutabilityToTag : Mutability -> Bits8
mutabilityToTag Immutable = 0
mutabilityToTag Mutable   = 1

||| Decode an ABI tag to a Mutability.
public export
tagToMutability : Bits8 -> Maybe Mutability
tagToMutability 0 = Just Immutable
tagToMutability 1 = Just Mutable
tagToMutability _ = Nothing

||| Roundtrip proof: decoding an encoded Mutability yields the original.
public export
mutabilityRoundtrip : (m : Mutability) -> tagToMutability (mutabilityToTag m) = Just m
mutabilityRoundtrip Immutable = Refl
mutabilityRoundtrip Mutable   = Refl
