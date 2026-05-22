-- SPDX-License-Identifier: MPL-2.0
-- Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
--
-- KMSABI.Layout: C-ABI-compatible numeric representations of KMS types.
--
-- Maps every constructor of the KMS domain types (ObjectType, Operation,
-- KeyState, Algorithm) to fixed Bits8 values for C interop.  Each type gets:
--   * a size constant (always 1 byte for these enumerations)
--   * a total encoder  (xToTag : X -> Bits8)
--   * a partial decoder (tagToX : Bits8 -> Maybe X)
--   * a roundtrip lemma proving that decoding an encoded value is the identity
--
-- The roundtrip proofs are formal verification: they guarantee at compile time
-- that encoding/decoding never loses information.  These proofs compile away
-- to zero runtime overhead thanks to Idris2's erasure.
--
-- Tag values here MUST match the C header (generated/abi/kms.h) and the
-- Zig FFI enums (ffi/zig/src/kms.zig) exactly.

module KMSABI.Layout

import KMS.Types

%default total

---------------------------------------------------------------------------
-- ObjectType (6 constructors, tags 0-5)
---------------------------------------------------------------------------

||| C-ABI representation size for ObjectType (1 byte).
public export
objectTypeSize : Nat
objectTypeSize = 1

||| Map ObjectType to its C-ABI byte value.
|||
||| Tag assignments:
|||   SymmetricKey = 0
|||   PublicKey    = 1
|||   PrivateKey   = 2
|||   SecretData   = 3
|||   Certificate  = 4
|||   OpaqueData   = 5
public export
objectTypeToTag : ObjectType -> Bits8
objectTypeToTag SymmetricKey = 0
objectTypeToTag PublicKey    = 1
objectTypeToTag PrivateKey   = 2
objectTypeToTag SecretData   = 3
objectTypeToTag Certificate  = 4
objectTypeToTag OpaqueData   = 5

||| Recover ObjectType from its C-ABI byte value.
||| Returns Nothing for any value outside the valid range 0-5.
public export
tagToObjectType : Bits8 -> Maybe ObjectType
tagToObjectType 0 = Just SymmetricKey
tagToObjectType 1 = Just PublicKey
tagToObjectType 2 = Just PrivateKey
tagToObjectType 3 = Just SecretData
tagToObjectType 4 = Just Certificate
tagToObjectType 5 = Just OpaqueData
tagToObjectType _ = Nothing

||| Proof: encoding then decoding ObjectType is the identity.
public export
objectTypeRoundtrip : (o : ObjectType) -> tagToObjectType (objectTypeToTag o) = Just o
objectTypeRoundtrip SymmetricKey = Refl
objectTypeRoundtrip PublicKey    = Refl
objectTypeRoundtrip PrivateKey   = Refl
objectTypeRoundtrip SecretData   = Refl
objectTypeRoundtrip Certificate  = Refl
objectTypeRoundtrip OpaqueData   = Refl

---------------------------------------------------------------------------
-- Operation (15 constructors, tags 0-14)
---------------------------------------------------------------------------

||| C-ABI representation size for Operation (1 byte).
public export
operationSize : Nat
operationSize = 1

||| Map Operation to its C-ABI byte value.
|||
||| Tag assignments:
|||   Create   = 0    Get      = 1    Activate = 2
|||   Revoke   = 3    Destroy  = 4    Locate   = 5
|||   Register = 6    Rekey    = 7    Encrypt  = 8
|||   Decrypt  = 9    Sign     = 10   Verify   = 11
|||   Wrap     = 12   Unwrap   = 13   MAC      = 14
public export
operationToTag : Operation -> Bits8
operationToTag Create   = 0
operationToTag Get      = 1
operationToTag Activate = 2
operationToTag Revoke   = 3
operationToTag Destroy  = 4
operationToTag Locate   = 5
operationToTag Register = 6
operationToTag Rekey    = 7
operationToTag Encrypt  = 8
operationToTag Decrypt  = 9
operationToTag Sign     = 10
operationToTag Verify   = 11
operationToTag Wrap     = 12
operationToTag Unwrap   = 13
operationToTag MAC      = 14

||| Recover Operation from its C-ABI byte value.
||| Returns Nothing for any value outside the valid range 0-14.
public export
tagToOperation : Bits8 -> Maybe Operation
tagToOperation 0  = Just Create
tagToOperation 1  = Just Get
tagToOperation 2  = Just Activate
tagToOperation 3  = Just Revoke
tagToOperation 4  = Just Destroy
tagToOperation 5  = Just Locate
tagToOperation 6  = Just Register
tagToOperation 7  = Just Rekey
tagToOperation 8  = Just Encrypt
tagToOperation 9  = Just Decrypt
tagToOperation 10 = Just Sign
tagToOperation 11 = Just Verify
tagToOperation 12 = Just Wrap
tagToOperation 13 = Just Unwrap
tagToOperation 14 = Just MAC
tagToOperation _  = Nothing

||| Proof: encoding then decoding Operation is the identity.
public export
operationRoundtrip : (o : Operation) -> tagToOperation (operationToTag o) = Just o
operationRoundtrip Create   = Refl
operationRoundtrip Get      = Refl
operationRoundtrip Activate = Refl
operationRoundtrip Revoke   = Refl
operationRoundtrip Destroy  = Refl
operationRoundtrip Locate   = Refl
operationRoundtrip Register = Refl
operationRoundtrip Rekey    = Refl
operationRoundtrip Encrypt  = Refl
operationRoundtrip Decrypt  = Refl
operationRoundtrip Sign     = Refl
operationRoundtrip Verify   = Refl
operationRoundtrip Wrap     = Refl
operationRoundtrip Unwrap   = Refl
operationRoundtrip MAC      = Refl

---------------------------------------------------------------------------
-- KeyState (6 constructors, tags 0-5)
---------------------------------------------------------------------------

||| C-ABI representation size for KeyState (1 byte).
public export
keyStateSize : Nat
keyStateSize = 1

||| Map KeyState to its C-ABI byte value.
|||
||| Tag assignments:
|||   PreActive            = 0
|||   Active               = 1
|||   Deactivated          = 2
|||   Compromised          = 3
|||   Destroyed            = 4
|||   DestroyedCompromised = 5
public export
keyStateToTag : KeyState -> Bits8
keyStateToTag PreActive            = 0
keyStateToTag Active               = 1
keyStateToTag Deactivated          = 2
keyStateToTag Compromised          = 3
keyStateToTag Destroyed            = 4
keyStateToTag DestroyedCompromised = 5

||| Recover KeyState from its C-ABI byte value.
||| Returns Nothing for any value outside the valid range 0-5.
public export
tagToKeyState : Bits8 -> Maybe KeyState
tagToKeyState 0 = Just PreActive
tagToKeyState 1 = Just Active
tagToKeyState 2 = Just Deactivated
tagToKeyState 3 = Just Compromised
tagToKeyState 4 = Just Destroyed
tagToKeyState 5 = Just DestroyedCompromised
tagToKeyState _ = Nothing

||| Proof: encoding then decoding KeyState is the identity.
public export
keyStateRoundtrip : (s : KeyState) -> tagToKeyState (keyStateToTag s) = Just s
keyStateRoundtrip PreActive            = Refl
keyStateRoundtrip Active               = Refl
keyStateRoundtrip Deactivated          = Refl
keyStateRoundtrip Compromised          = Refl
keyStateRoundtrip Destroyed            = Refl
keyStateRoundtrip DestroyedCompromised = Refl

---------------------------------------------------------------------------
-- Algorithm (9 constructors, tags 0-8)
---------------------------------------------------------------------------

||| C-ABI representation size for Algorithm (1 byte).
public export
algorithmSize : Nat
algorithmSize = 1

||| Map Algorithm to its C-ABI byte value.
|||
||| Tag assignments:
|||   AES128           = 0    AES256           = 1
|||   RSA2048          = 2    RSA4096          = 3
|||   ECDSA_P256       = 4    ECDSA_P384       = 5
|||   Ed25519          = 6    ChaCha20Poly1305 = 7
|||   HMAC_SHA256      = 8
public export
algorithmToTag : Algorithm -> Bits8
algorithmToTag AES128           = 0
algorithmToTag AES256           = 1
algorithmToTag RSA2048          = 2
algorithmToTag RSA4096          = 3
algorithmToTag ECDSA_P256       = 4
algorithmToTag ECDSA_P384       = 5
algorithmToTag Ed25519          = 6
algorithmToTag ChaCha20Poly1305 = 7
algorithmToTag HMAC_SHA256      = 8

||| Recover Algorithm from its C-ABI byte value.
||| Returns Nothing for any value outside the valid range 0-8.
public export
tagToAlgorithm : Bits8 -> Maybe Algorithm
tagToAlgorithm 0 = Just AES128
tagToAlgorithm 1 = Just AES256
tagToAlgorithm 2 = Just RSA2048
tagToAlgorithm 3 = Just RSA4096
tagToAlgorithm 4 = Just ECDSA_P256
tagToAlgorithm 5 = Just ECDSA_P384
tagToAlgorithm 6 = Just Ed25519
tagToAlgorithm 7 = Just ChaCha20Poly1305
tagToAlgorithm 8 = Just HMAC_SHA256
tagToAlgorithm _ = Nothing

||| Proof: encoding then decoding Algorithm is the identity.
public export
algorithmRoundtrip : (a : Algorithm) -> tagToAlgorithm (algorithmToTag a) = Just a
algorithmRoundtrip AES128           = Refl
algorithmRoundtrip AES256           = Refl
algorithmRoundtrip RSA2048          = Refl
algorithmRoundtrip RSA4096          = Refl
algorithmRoundtrip ECDSA_P256       = Refl
algorithmRoundtrip ECDSA_P384       = Refl
algorithmRoundtrip Ed25519          = Refl
algorithmRoundtrip ChaCha20Poly1305 = Refl
algorithmRoundtrip HMAC_SHA256      = Refl

---------------------------------------------------------------------------
-- KMSError (8 constructors, tags 0-7)
-- Error codes returned by KMS FFI operations.
---------------------------------------------------------------------------

||| Error codes for KMS FFI operations.
public export
data KMSError : Type where
  ||| No error.
  KmsOk                : KMSError
  ||| Invalid slot index.
  KmsInvalidSlot       : KMSError
  ||| Key context not active.
  KmsNotActive         : KMSError
  ||| Invalid key state transition.
  KmsInvalidTransition : KMSError
  ||| Operation not permitted in current key state.
  KmsOperationDenied   : KMSError
  ||| Key slot capacity exhausted.
  KmsCapacityExhausted : KMSError
  ||| Algorithm not supported for this operation.
  KmsUnsupportedAlg    : KMSError
  ||| Key has been destroyed and cannot be used.
  KmsKeyDestroyed      : KMSError

public export
Eq KMSError where
  KmsOk                == KmsOk                = True
  KmsInvalidSlot       == KmsInvalidSlot       = True
  KmsNotActive         == KmsNotActive         = True
  KmsInvalidTransition == KmsInvalidTransition = True
  KmsOperationDenied   == KmsOperationDenied   = True
  KmsCapacityExhausted == KmsCapacityExhausted = True
  KmsUnsupportedAlg    == KmsUnsupportedAlg    = True
  KmsKeyDestroyed      == KmsKeyDestroyed      = True
  _                    == _                    = False

public export
Show KMSError where
  show KmsOk                = "Ok"
  show KmsInvalidSlot       = "InvalidSlot"
  show KmsNotActive         = "NotActive"
  show KmsInvalidTransition = "InvalidTransition"
  show KmsOperationDenied   = "OperationDenied"
  show KmsCapacityExhausted = "CapacityExhausted"
  show KmsUnsupportedAlg    = "UnsupportedAlgorithm"
  show KmsKeyDestroyed      = "KeyDestroyed"

||| C-ABI representation size for KMSError (1 byte).
public export
kmsErrorSize : Nat
kmsErrorSize = 1

||| Map KMSError to its C-ABI byte value.
public export
kmsErrorToTag : KMSError -> Bits8
kmsErrorToTag KmsOk                = 0
kmsErrorToTag KmsInvalidSlot       = 1
kmsErrorToTag KmsNotActive         = 2
kmsErrorToTag KmsInvalidTransition = 3
kmsErrorToTag KmsOperationDenied   = 4
kmsErrorToTag KmsCapacityExhausted = 5
kmsErrorToTag KmsUnsupportedAlg    = 6
kmsErrorToTag KmsKeyDestroyed      = 7

||| Recover KMSError from its C-ABI byte value.
public export
tagToKMSError : Bits8 -> Maybe KMSError
tagToKMSError 0 = Just KmsOk
tagToKMSError 1 = Just KmsInvalidSlot
tagToKMSError 2 = Just KmsNotActive
tagToKMSError 3 = Just KmsInvalidTransition
tagToKMSError 4 = Just KmsOperationDenied
tagToKMSError 5 = Just KmsCapacityExhausted
tagToKMSError 6 = Just KmsUnsupportedAlg
tagToKMSError 7 = Just KmsKeyDestroyed
tagToKMSError _ = Nothing

||| Proof: encoding then decoding KMSError is the identity.
public export
kmsErrorRoundtrip : (e : KMSError) -> tagToKMSError (kmsErrorToTag e) = Just e
kmsErrorRoundtrip KmsOk                = Refl
kmsErrorRoundtrip KmsInvalidSlot       = Refl
kmsErrorRoundtrip KmsNotActive         = Refl
kmsErrorRoundtrip KmsInvalidTransition = Refl
kmsErrorRoundtrip KmsOperationDenied   = Refl
kmsErrorRoundtrip KmsCapacityExhausted = Refl
kmsErrorRoundtrip KmsUnsupportedAlg    = Refl
kmsErrorRoundtrip KmsKeyDestroyed      = Refl
