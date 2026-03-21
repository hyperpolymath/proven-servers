-- SPDX-License-Identifier: PMPL-1.0-or-later
-- Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
--
-- KmsABI.Types: C-ABI-compatible numeric representations of Kms types.
--
-- Maps every constructor of the core Kms sum types to fixed Bits8 values
-- for C interop. Each type gets a total encoder, partial decoder, and
-- roundtrip proof (encode then decode = identity).
--
-- Tag values here MUST match the C header and the
-- Zig FFI enums (ffi/zig/src/kms.zig) exactly.
--
-- Types covered:
--   ObjectType                (6 constructors, tags 0-5)
--   Operation                 (15 constructors, tags 0-14)
--   KeyState                  (6 constructors, tags 0-5)
--   Algorithm                 (9 constructors, tags 0-8)
--   KMSError                  (8 constructors, tags 0-7)

module KmsABI.Types

%default total

---------------------------------------------------------------------------
-- ObjectType (6 constructors, tags 0-5)
---------------------------------------------------------------------------

public export
object_typeSize : Nat
object_typeSize = 1

||| ObjectType sum type for ABI encoding.
public export
data ObjectType : Type where
  SymmetricKey : ObjectType
  PublicKey : ObjectType
  PrivateKey : ObjectType
  SecretData : ObjectType
  Certificate : ObjectType
  OpaqueData : ObjectType

||| Encode a ObjectType to its ABI tag value.
public export
object_typeToTag : ObjectType -> Bits8
object_typeToTag SymmetricKey = 0
object_typeToTag PublicKey = 1
object_typeToTag PrivateKey = 2
object_typeToTag SecretData = 3
object_typeToTag Certificate = 4
object_typeToTag OpaqueData = 5

||| Decode an ABI tag to a ObjectType.
public export
tagToObjectType : Bits8 -> Maybe ObjectType
tagToObjectType 0 = Just SymmetricKey
tagToObjectType 1 = Just PublicKey
tagToObjectType 2 = Just PrivateKey
tagToObjectType 3 = Just SecretData
tagToObjectType 4 = Just Certificate
tagToObjectType 5 = Just OpaqueData
tagToObjectType _ = Nothing

||| Roundtrip proof: decoding an encoded ObjectType yields the original.
public export
object_typeRoundtrip : (x : ObjectType) -> tagToObjectType (object_typeToTag x) = Just x
object_typeRoundtrip SymmetricKey = Refl
object_typeRoundtrip PublicKey = Refl
object_typeRoundtrip PrivateKey = Refl
object_typeRoundtrip SecretData = Refl
object_typeRoundtrip Certificate = Refl
object_typeRoundtrip OpaqueData = Refl

---------------------------------------------------------------------------
-- Operation (15 constructors, tags 0-14)
---------------------------------------------------------------------------

public export
operationSize : Nat
operationSize = 1

||| Operation sum type for ABI encoding.
public export
data Operation : Type where
  Create : Operation
  Get : Operation
  Activate : Operation
  Revoke : Operation
  Destroy : Operation
  Locate : Operation
  Register : Operation
  Rekey : Operation
  Encrypt : Operation
  Decrypt : Operation
  Sign : Operation
  Verify : Operation
  Wrap : Operation
  Unwrap : Operation
  Mac : Operation

||| Encode a Operation to its ABI tag value.
public export
operationToTag : Operation -> Bits8
operationToTag Create = 0
operationToTag Get = 1
operationToTag Activate = 2
operationToTag Revoke = 3
operationToTag Destroy = 4
operationToTag Locate = 5
operationToTag Register = 6
operationToTag Rekey = 7
operationToTag Encrypt = 8
operationToTag Decrypt = 9
operationToTag Sign = 10
operationToTag Verify = 11
operationToTag Wrap = 12
operationToTag Unwrap = 13
operationToTag Mac = 14

||| Decode an ABI tag to a Operation.
public export
tagToOperation : Bits8 -> Maybe Operation
tagToOperation 0 = Just Create
tagToOperation 1 = Just Get
tagToOperation 2 = Just Activate
tagToOperation 3 = Just Revoke
tagToOperation 4 = Just Destroy
tagToOperation 5 = Just Locate
tagToOperation 6 = Just Register
tagToOperation 7 = Just Rekey
tagToOperation 8 = Just Encrypt
tagToOperation 9 = Just Decrypt
tagToOperation 10 = Just Sign
tagToOperation 11 = Just Verify
tagToOperation 12 = Just Wrap
tagToOperation 13 = Just Unwrap
tagToOperation 14 = Just Mac
tagToOperation _ = Nothing

||| Roundtrip proof: decoding an encoded Operation yields the original.
public export
operationRoundtrip : (x : Operation) -> tagToOperation (operationToTag x) = Just x
operationRoundtrip Create = Refl
operationRoundtrip Get = Refl
operationRoundtrip Activate = Refl
operationRoundtrip Revoke = Refl
operationRoundtrip Destroy = Refl
operationRoundtrip Locate = Refl
operationRoundtrip Register = Refl
operationRoundtrip Rekey = Refl
operationRoundtrip Encrypt = Refl
operationRoundtrip Decrypt = Refl
operationRoundtrip Sign = Refl
operationRoundtrip Verify = Refl
operationRoundtrip Wrap = Refl
operationRoundtrip Unwrap = Refl
operationRoundtrip Mac = Refl

---------------------------------------------------------------------------
-- KeyState (6 constructors, tags 0-5)
---------------------------------------------------------------------------

public export
key_stateSize : Nat
key_stateSize = 1

||| KeyState sum type for ABI encoding.
public export
data KeyState : Type where
  PreActive : KeyState
  Active : KeyState
  Deactivated : KeyState
  Compromised : KeyState
  Destroyed : KeyState
  DestroyedCompromised : KeyState

||| Encode a KeyState to its ABI tag value.
public export
key_stateToTag : KeyState -> Bits8
key_stateToTag PreActive = 0
key_stateToTag Active = 1
key_stateToTag Deactivated = 2
key_stateToTag Compromised = 3
key_stateToTag Destroyed = 4
key_stateToTag DestroyedCompromised = 5

||| Decode an ABI tag to a KeyState.
public export
tagToKeyState : Bits8 -> Maybe KeyState
tagToKeyState 0 = Just PreActive
tagToKeyState 1 = Just Active
tagToKeyState 2 = Just Deactivated
tagToKeyState 3 = Just Compromised
tagToKeyState 4 = Just Destroyed
tagToKeyState 5 = Just DestroyedCompromised
tagToKeyState _ = Nothing

||| Roundtrip proof: decoding an encoded KeyState yields the original.
public export
key_stateRoundtrip : (x : KeyState) -> tagToKeyState (key_stateToTag x) = Just x
key_stateRoundtrip PreActive = Refl
key_stateRoundtrip Active = Refl
key_stateRoundtrip Deactivated = Refl
key_stateRoundtrip Compromised = Refl
key_stateRoundtrip Destroyed = Refl
key_stateRoundtrip DestroyedCompromised = Refl

---------------------------------------------------------------------------
-- Algorithm (9 constructors, tags 0-8)
---------------------------------------------------------------------------

public export
algorithmSize : Nat
algorithmSize = 1

||| Algorithm sum type for ABI encoding.
public export
data Algorithm : Type where
  Aes128 : Algorithm
  Aes256 : Algorithm
  Rsa2048 : Algorithm
  Rsa4096 : Algorithm
  EcdsaP256 : Algorithm
  EcdsaP384 : Algorithm
  Ed25519 : Algorithm
  Chacha20Poly1305 : Algorithm
  HmacSha256 : Algorithm

||| Encode a Algorithm to its ABI tag value.
public export
algorithmToTag : Algorithm -> Bits8
algorithmToTag Aes128 = 0
algorithmToTag Aes256 = 1
algorithmToTag Rsa2048 = 2
algorithmToTag Rsa4096 = 3
algorithmToTag EcdsaP256 = 4
algorithmToTag EcdsaP384 = 5
algorithmToTag Ed25519 = 6
algorithmToTag Chacha20Poly1305 = 7
algorithmToTag HmacSha256 = 8

||| Decode an ABI tag to a Algorithm.
public export
tagToAlgorithm : Bits8 -> Maybe Algorithm
tagToAlgorithm 0 = Just Aes128
tagToAlgorithm 1 = Just Aes256
tagToAlgorithm 2 = Just Rsa2048
tagToAlgorithm 3 = Just Rsa4096
tagToAlgorithm 4 = Just EcdsaP256
tagToAlgorithm 5 = Just EcdsaP384
tagToAlgorithm 6 = Just Ed25519
tagToAlgorithm 7 = Just Chacha20Poly1305
tagToAlgorithm 8 = Just HmacSha256
tagToAlgorithm _ = Nothing

||| Roundtrip proof: decoding an encoded Algorithm yields the original.
public export
algorithmRoundtrip : (x : Algorithm) -> tagToAlgorithm (algorithmToTag x) = Just x
algorithmRoundtrip Aes128 = Refl
algorithmRoundtrip Aes256 = Refl
algorithmRoundtrip Rsa2048 = Refl
algorithmRoundtrip Rsa4096 = Refl
algorithmRoundtrip EcdsaP256 = Refl
algorithmRoundtrip EcdsaP384 = Refl
algorithmRoundtrip Ed25519 = Refl
algorithmRoundtrip Chacha20Poly1305 = Refl
algorithmRoundtrip HmacSha256 = Refl

---------------------------------------------------------------------------
-- KMSError (8 constructors, tags 0-7)
---------------------------------------------------------------------------

public export
k_m_s_errorSize : Nat
k_m_s_errorSize = 1

||| KMSError sum type for ABI encoding.
public export
data KMSError : Type where
  Ok : KMSError
  InvalidSlot : KMSError
  NotActive : KMSError
  InvalidTransition : KMSError
  OperationDenied : KMSError
  CapacityExhausted : KMSError
  UnsupportedAlg : KMSError
  KeyDestroyed : KMSError

||| Encode a KMSError to its ABI tag value.
public export
k_m_s_errorToTag : KMSError -> Bits8
k_m_s_errorToTag Ok = 0
k_m_s_errorToTag InvalidSlot = 1
k_m_s_errorToTag NotActive = 2
k_m_s_errorToTag InvalidTransition = 3
k_m_s_errorToTag OperationDenied = 4
k_m_s_errorToTag CapacityExhausted = 5
k_m_s_errorToTag UnsupportedAlg = 6
k_m_s_errorToTag KeyDestroyed = 7

||| Decode an ABI tag to a KMSError.
public export
tagToKMSError : Bits8 -> Maybe KMSError
tagToKMSError 0 = Just Ok
tagToKMSError 1 = Just InvalidSlot
tagToKMSError 2 = Just NotActive
tagToKMSError 3 = Just InvalidTransition
tagToKMSError 4 = Just OperationDenied
tagToKMSError 5 = Just CapacityExhausted
tagToKMSError 6 = Just UnsupportedAlg
tagToKMSError 7 = Just KeyDestroyed
tagToKMSError _ = Nothing

||| Roundtrip proof: decoding an encoded KMSError yields the original.
public export
k_m_s_errorRoundtrip : (x : KMSError) -> tagToKMSError (k_m_s_errorToTag x) = Just x
k_m_s_errorRoundtrip Ok = Refl
k_m_s_errorRoundtrip InvalidSlot = Refl
k_m_s_errorRoundtrip NotActive = Refl
k_m_s_errorRoundtrip InvalidTransition = Refl
k_m_s_errorRoundtrip OperationDenied = Refl
k_m_s_errorRoundtrip CapacityExhausted = Refl
k_m_s_errorRoundtrip UnsupportedAlg = Refl
k_m_s_errorRoundtrip KeyDestroyed = Refl
