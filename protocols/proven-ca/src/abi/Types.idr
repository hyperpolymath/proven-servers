-- SPDX-License-Identifier: PMPL-1.0-or-later
-- Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
--
-- CaABI.Types: C-ABI-compatible numeric representations of Ca types.
--
-- Maps every constructor of the core Ca sum types to fixed Bits8 values
-- for C interop. Each type gets a total encoder, partial decoder, and
-- roundtrip proof (encode then decode = identity).
--
-- Tag values here MUST match the C header and the
-- Zig FFI enums (ffi/zig/src/ca.zig) exactly.
--
-- Types covered:
--   CertType                  (7 constructors, tags 0-6)
--   KeyAlgorithm              (6 constructors, tags 0-5)
--   SignatureAlgorithm        (7 constructors, tags 0-6)
--   CertState                 (5 constructors, tags 0-4)
--   RevocationReason          (7 constructors, tags 0-6)
--   CRLStatus                 (4 constructors, tags 0-3)
--   OCSPStatus                (4 constructors, tags 0-3)
--   Extension                 (6 constructors, tags 0-5)
--   KeyUsageBit               (9 constructors, tags 0-8)

module CaABI.Types

%default total

---------------------------------------------------------------------------
-- CertType (7 constructors, tags 0-6)
---------------------------------------------------------------------------

public export
cert_typeSize : Nat
cert_typeSize = 1

||| CertType sum type for ABI encoding.
public export
data CertType : Type where
  Root : CertType
  Intermediate : CertType
  EndEntity : CertType
  CrossSigned : CertType
  CodeSigning : CertType
  EmailProtection : CertType
  OcspSigning : CertType

||| Encode a CertType to its ABI tag value.
public export
cert_typeToTag : CertType -> Bits8
cert_typeToTag Root = 0
cert_typeToTag Intermediate = 1
cert_typeToTag EndEntity = 2
cert_typeToTag CrossSigned = 3
cert_typeToTag CodeSigning = 4
cert_typeToTag EmailProtection = 5
cert_typeToTag OcspSigning = 6

||| Decode an ABI tag to a CertType.
public export
tagToCertType : Bits8 -> Maybe CertType
tagToCertType 0 = Just Root
tagToCertType 1 = Just Intermediate
tagToCertType 2 = Just EndEntity
tagToCertType 3 = Just CrossSigned
tagToCertType 4 = Just CodeSigning
tagToCertType 5 = Just EmailProtection
tagToCertType 6 = Just OcspSigning
tagToCertType _ = Nothing

||| Roundtrip proof: decoding an encoded CertType yields the original.
public export
cert_typeRoundtrip : (x : CertType) -> tagToCertType (cert_typeToTag x) = Just x
cert_typeRoundtrip Root = Refl
cert_typeRoundtrip Intermediate = Refl
cert_typeRoundtrip EndEntity = Refl
cert_typeRoundtrip CrossSigned = Refl
cert_typeRoundtrip CodeSigning = Refl
cert_typeRoundtrip EmailProtection = Refl
cert_typeRoundtrip OcspSigning = Refl

---------------------------------------------------------------------------
-- KeyAlgorithm (6 constructors, tags 0-5)
---------------------------------------------------------------------------

public export
key_algorithmSize : Nat
key_algorithmSize = 1

||| KeyAlgorithm sum type for ABI encoding.
public export
data KeyAlgorithm : Type where
  Rsa2048 : KeyAlgorithm
  Rsa4096 : KeyAlgorithm
  EcdsaP256 : KeyAlgorithm
  EcdsaP384 : KeyAlgorithm
  Ed25519 : KeyAlgorithm
  Ed448 : KeyAlgorithm

||| Encode a KeyAlgorithm to its ABI tag value.
public export
key_algorithmToTag : KeyAlgorithm -> Bits8
key_algorithmToTag Rsa2048 = 0
key_algorithmToTag Rsa4096 = 1
key_algorithmToTag EcdsaP256 = 2
key_algorithmToTag EcdsaP384 = 3
key_algorithmToTag Ed25519 = 4
key_algorithmToTag Ed448 = 5

||| Decode an ABI tag to a KeyAlgorithm.
public export
tagToKeyAlgorithm : Bits8 -> Maybe KeyAlgorithm
tagToKeyAlgorithm 0 = Just Rsa2048
tagToKeyAlgorithm 1 = Just Rsa4096
tagToKeyAlgorithm 2 = Just EcdsaP256
tagToKeyAlgorithm 3 = Just EcdsaP384
tagToKeyAlgorithm 4 = Just Ed25519
tagToKeyAlgorithm 5 = Just Ed448
tagToKeyAlgorithm _ = Nothing

||| Roundtrip proof: decoding an encoded KeyAlgorithm yields the original.
public export
key_algorithmRoundtrip : (x : KeyAlgorithm) -> tagToKeyAlgorithm (key_algorithmToTag x) = Just x
key_algorithmRoundtrip Rsa2048 = Refl
key_algorithmRoundtrip Rsa4096 = Refl
key_algorithmRoundtrip EcdsaP256 = Refl
key_algorithmRoundtrip EcdsaP384 = Refl
key_algorithmRoundtrip Ed25519 = Refl
key_algorithmRoundtrip Ed448 = Refl

---------------------------------------------------------------------------
-- SignatureAlgorithm (7 constructors, tags 0-6)
---------------------------------------------------------------------------

public export
signature_algorithmSize : Nat
signature_algorithmSize = 1

||| SignatureAlgorithm sum type for ABI encoding.
public export
data SignatureAlgorithm : Type where
  Sha256WithRsa : SignatureAlgorithm
  Sha384WithRsa : SignatureAlgorithm
  Sha512WithRsa : SignatureAlgorithm
  Sha256WithEcdsa : SignatureAlgorithm
  Sha384WithEcdsa : SignatureAlgorithm
  PureEd25519 : SignatureAlgorithm
  PureEd448 : SignatureAlgorithm

||| Encode a SignatureAlgorithm to its ABI tag value.
public export
signature_algorithmToTag : SignatureAlgorithm -> Bits8
signature_algorithmToTag Sha256WithRsa = 0
signature_algorithmToTag Sha384WithRsa = 1
signature_algorithmToTag Sha512WithRsa = 2
signature_algorithmToTag Sha256WithEcdsa = 3
signature_algorithmToTag Sha384WithEcdsa = 4
signature_algorithmToTag PureEd25519 = 5
signature_algorithmToTag PureEd448 = 6

||| Decode an ABI tag to a SignatureAlgorithm.
public export
tagToSignatureAlgorithm : Bits8 -> Maybe SignatureAlgorithm
tagToSignatureAlgorithm 0 = Just Sha256WithRsa
tagToSignatureAlgorithm 1 = Just Sha384WithRsa
tagToSignatureAlgorithm 2 = Just Sha512WithRsa
tagToSignatureAlgorithm 3 = Just Sha256WithEcdsa
tagToSignatureAlgorithm 4 = Just Sha384WithEcdsa
tagToSignatureAlgorithm 5 = Just PureEd25519
tagToSignatureAlgorithm 6 = Just PureEd448
tagToSignatureAlgorithm _ = Nothing

||| Roundtrip proof: decoding an encoded SignatureAlgorithm yields the original.
public export
signature_algorithmRoundtrip : (x : SignatureAlgorithm) -> tagToSignatureAlgorithm (signature_algorithmToTag x) = Just x
signature_algorithmRoundtrip Sha256WithRsa = Refl
signature_algorithmRoundtrip Sha384WithRsa = Refl
signature_algorithmRoundtrip Sha512WithRsa = Refl
signature_algorithmRoundtrip Sha256WithEcdsa = Refl
signature_algorithmRoundtrip Sha384WithEcdsa = Refl
signature_algorithmRoundtrip PureEd25519 = Refl
signature_algorithmRoundtrip PureEd448 = Refl

---------------------------------------------------------------------------
-- CertState (5 constructors, tags 0-4)
---------------------------------------------------------------------------

public export
cert_stateSize : Nat
cert_stateSize = 1

||| CertState sum type for ABI encoding.
public export
data CertState : Type where
  Pending : CertState
  Active : CertState
  Revoked : CertState
  Expired : CertState
  Suspended : CertState

||| Encode a CertState to its ABI tag value.
public export
cert_stateToTag : CertState -> Bits8
cert_stateToTag Pending = 0
cert_stateToTag Active = 1
cert_stateToTag Revoked = 2
cert_stateToTag Expired = 3
cert_stateToTag Suspended = 4

||| Decode an ABI tag to a CertState.
public export
tagToCertState : Bits8 -> Maybe CertState
tagToCertState 0 = Just Pending
tagToCertState 1 = Just Active
tagToCertState 2 = Just Revoked
tagToCertState 3 = Just Expired
tagToCertState 4 = Just Suspended
tagToCertState _ = Nothing

||| Roundtrip proof: decoding an encoded CertState yields the original.
public export
cert_stateRoundtrip : (x : CertState) -> tagToCertState (cert_stateToTag x) = Just x
cert_stateRoundtrip Pending = Refl
cert_stateRoundtrip Active = Refl
cert_stateRoundtrip Revoked = Refl
cert_stateRoundtrip Expired = Refl
cert_stateRoundtrip Suspended = Refl

---------------------------------------------------------------------------
-- RevocationReason (7 constructors, tags 0-6)
---------------------------------------------------------------------------

public export
revocation_reasonSize : Nat
revocation_reasonSize = 1

||| RevocationReason sum type for ABI encoding.
public export
data RevocationReason : Type where
  Unspecified : RevocationReason
  KeyCompromise : RevocationReason
  CaCompromise : RevocationReason
  AffiliationChanged : RevocationReason
  Superseded : RevocationReason
  CessationOfOperation : RevocationReason
  CertificateHold : RevocationReason

||| Encode a RevocationReason to its ABI tag value.
public export
revocation_reasonToTag : RevocationReason -> Bits8
revocation_reasonToTag Unspecified = 0
revocation_reasonToTag KeyCompromise = 1
revocation_reasonToTag CaCompromise = 2
revocation_reasonToTag AffiliationChanged = 3
revocation_reasonToTag Superseded = 4
revocation_reasonToTag CessationOfOperation = 5
revocation_reasonToTag CertificateHold = 6

||| Decode an ABI tag to a RevocationReason.
public export
tagToRevocationReason : Bits8 -> Maybe RevocationReason
tagToRevocationReason 0 = Just Unspecified
tagToRevocationReason 1 = Just KeyCompromise
tagToRevocationReason 2 = Just CaCompromise
tagToRevocationReason 3 = Just AffiliationChanged
tagToRevocationReason 4 = Just Superseded
tagToRevocationReason 5 = Just CessationOfOperation
tagToRevocationReason 6 = Just CertificateHold
tagToRevocationReason _ = Nothing

||| Roundtrip proof: decoding an encoded RevocationReason yields the original.
public export
revocation_reasonRoundtrip : (x : RevocationReason) -> tagToRevocationReason (revocation_reasonToTag x) = Just x
revocation_reasonRoundtrip Unspecified = Refl
revocation_reasonRoundtrip KeyCompromise = Refl
revocation_reasonRoundtrip CaCompromise = Refl
revocation_reasonRoundtrip AffiliationChanged = Refl
revocation_reasonRoundtrip Superseded = Refl
revocation_reasonRoundtrip CessationOfOperation = Refl
revocation_reasonRoundtrip CertificateHold = Refl

---------------------------------------------------------------------------
-- CRLStatus (4 constructors, tags 0-3)
---------------------------------------------------------------------------

public export
c_r_l_statusSize : Nat
c_r_l_statusSize = 1

||| CRLStatus sum type for ABI encoding.
public export
data CRLStatus : Type where
  Current : CRLStatus
  CrlExpired : CRLStatus
  CrlPending : CRLStatus
  CrlError : CRLStatus

||| Encode a CRLStatus to its ABI tag value.
public export
c_r_l_statusToTag : CRLStatus -> Bits8
c_r_l_statusToTag Current = 0
c_r_l_statusToTag CrlExpired = 1
c_r_l_statusToTag CrlPending = 2
c_r_l_statusToTag CrlError = 3

||| Decode an ABI tag to a CRLStatus.
public export
tagToCRLStatus : Bits8 -> Maybe CRLStatus
tagToCRLStatus 0 = Just Current
tagToCRLStatus 1 = Just CrlExpired
tagToCRLStatus 2 = Just CrlPending
tagToCRLStatus 3 = Just CrlError
tagToCRLStatus _ = Nothing

||| Roundtrip proof: decoding an encoded CRLStatus yields the original.
public export
c_r_l_statusRoundtrip : (x : CRLStatus) -> tagToCRLStatus (c_r_l_statusToTag x) = Just x
c_r_l_statusRoundtrip Current = Refl
c_r_l_statusRoundtrip CrlExpired = Refl
c_r_l_statusRoundtrip CrlPending = Refl
c_r_l_statusRoundtrip CrlError = Refl

---------------------------------------------------------------------------
-- OCSPStatus (4 constructors, tags 0-3)
---------------------------------------------------------------------------

public export
o_c_s_p_statusSize : Nat
o_c_s_p_statusSize = 1

||| OCSPStatus sum type for ABI encoding.
public export
data OCSPStatus : Type where
  Good : OCSPStatus
  OcspRevoked : OCSPStatus
  Unknown : OCSPStatus
  Unavailable : OCSPStatus

||| Encode a OCSPStatus to its ABI tag value.
public export
o_c_s_p_statusToTag : OCSPStatus -> Bits8
o_c_s_p_statusToTag Good = 0
o_c_s_p_statusToTag OcspRevoked = 1
o_c_s_p_statusToTag Unknown = 2
o_c_s_p_statusToTag Unavailable = 3

||| Decode an ABI tag to a OCSPStatus.
public export
tagToOCSPStatus : Bits8 -> Maybe OCSPStatus
tagToOCSPStatus 0 = Just Good
tagToOCSPStatus 1 = Just OcspRevoked
tagToOCSPStatus 2 = Just Unknown
tagToOCSPStatus 3 = Just Unavailable
tagToOCSPStatus _ = Nothing

||| Roundtrip proof: decoding an encoded OCSPStatus yields the original.
public export
o_c_s_p_statusRoundtrip : (x : OCSPStatus) -> tagToOCSPStatus (o_c_s_p_statusToTag x) = Just x
o_c_s_p_statusRoundtrip Good = Refl
o_c_s_p_statusRoundtrip OcspRevoked = Refl
o_c_s_p_statusRoundtrip Unknown = Refl
o_c_s_p_statusRoundtrip Unavailable = Refl

---------------------------------------------------------------------------
-- Extension (6 constructors, tags 0-5)
---------------------------------------------------------------------------

public export
extensionSize : Nat
extensionSize = 1

||| Extension sum type for ABI encoding.
public export
data Extension : Type where
  BasicConstraints : Extension
  KeyUsage : Extension
  ExtKeyUsage : Extension
  SubjectAltName : Extension
  AuthorityInfoAccess : Extension
  CrlDistributionPoints : Extension

||| Encode a Extension to its ABI tag value.
public export
extensionToTag : Extension -> Bits8
extensionToTag BasicConstraints = 0
extensionToTag KeyUsage = 1
extensionToTag ExtKeyUsage = 2
extensionToTag SubjectAltName = 3
extensionToTag AuthorityInfoAccess = 4
extensionToTag CrlDistributionPoints = 5

||| Decode an ABI tag to a Extension.
public export
tagToExtension : Bits8 -> Maybe Extension
tagToExtension 0 = Just BasicConstraints
tagToExtension 1 = Just KeyUsage
tagToExtension 2 = Just ExtKeyUsage
tagToExtension 3 = Just SubjectAltName
tagToExtension 4 = Just AuthorityInfoAccess
tagToExtension 5 = Just CrlDistributionPoints
tagToExtension _ = Nothing

||| Roundtrip proof: decoding an encoded Extension yields the original.
public export
extensionRoundtrip : (x : Extension) -> tagToExtension (extensionToTag x) = Just x
extensionRoundtrip BasicConstraints = Refl
extensionRoundtrip KeyUsage = Refl
extensionRoundtrip ExtKeyUsage = Refl
extensionRoundtrip SubjectAltName = Refl
extensionRoundtrip AuthorityInfoAccess = Refl
extensionRoundtrip CrlDistributionPoints = Refl

---------------------------------------------------------------------------
-- KeyUsageBit (9 constructors, tags 0-8)
---------------------------------------------------------------------------

public export
key_usage_bitSize : Nat
key_usage_bitSize = 1

||| KeyUsageBit sum type for ABI encoding.
public export
data KeyUsageBit : Type where
  DigitalSignature : KeyUsageBit
  NonRepudiation : KeyUsageBit
  KeyEncipherment : KeyUsageBit
  DataEncipherment : KeyUsageBit
  KeyAgreement : KeyUsageBit
  KeyCertSign : KeyUsageBit
  CrlSign : KeyUsageBit
  EncipherOnly : KeyUsageBit
  DecipherOnly : KeyUsageBit

||| Encode a KeyUsageBit to its ABI tag value.
public export
key_usage_bitToTag : KeyUsageBit -> Bits8
key_usage_bitToTag DigitalSignature = 0
key_usage_bitToTag NonRepudiation = 1
key_usage_bitToTag KeyEncipherment = 2
key_usage_bitToTag DataEncipherment = 3
key_usage_bitToTag KeyAgreement = 4
key_usage_bitToTag KeyCertSign = 5
key_usage_bitToTag CrlSign = 6
key_usage_bitToTag EncipherOnly = 7
key_usage_bitToTag DecipherOnly = 8

||| Decode an ABI tag to a KeyUsageBit.
public export
tagToKeyUsageBit : Bits8 -> Maybe KeyUsageBit
tagToKeyUsageBit 0 = Just DigitalSignature
tagToKeyUsageBit 1 = Just NonRepudiation
tagToKeyUsageBit 2 = Just KeyEncipherment
tagToKeyUsageBit 3 = Just DataEncipherment
tagToKeyUsageBit 4 = Just KeyAgreement
tagToKeyUsageBit 5 = Just KeyCertSign
tagToKeyUsageBit 6 = Just CrlSign
tagToKeyUsageBit 7 = Just EncipherOnly
tagToKeyUsageBit 8 = Just DecipherOnly
tagToKeyUsageBit _ = Nothing

||| Roundtrip proof: decoding an encoded KeyUsageBit yields the original.
public export
key_usage_bitRoundtrip : (x : KeyUsageBit) -> tagToKeyUsageBit (key_usage_bitToTag x) = Just x
key_usage_bitRoundtrip DigitalSignature = Refl
key_usage_bitRoundtrip NonRepudiation = Refl
key_usage_bitRoundtrip KeyEncipherment = Refl
key_usage_bitRoundtrip DataEncipherment = Refl
key_usage_bitRoundtrip KeyAgreement = Refl
key_usage_bitRoundtrip KeyCertSign = Refl
key_usage_bitRoundtrip CrlSign = Refl
key_usage_bitRoundtrip EncipherOnly = Refl
key_usage_bitRoundtrip DecipherOnly = Refl
