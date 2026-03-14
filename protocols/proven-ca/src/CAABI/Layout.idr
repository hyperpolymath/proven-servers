-- SPDX-License-Identifier: PMPL-1.0-or-later
-- Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
--
-- CAABI.Layout: C-ABI-compatible numeric representations of CA types.
--
-- Maps every constructor of the nine core sum types (CertType, KeyAlgorithm,
-- SignatureAlgorithm, CertState, RevocationReason, CRLStatus, OCSPStatus,
-- Extension) to fixed Bits8 values for C interop.  Each type gets a total
-- encoder, partial decoder, and roundtrip proof.
--
-- Tag values here MUST match the C header (generated/abi/ca.h) and the
-- Zig FFI enums (ffi/zig/src/ca.zig) exactly.

module CAABI.Layout

import CA.Types

%default total

---------------------------------------------------------------------------
-- CertType (7 constructors, tags 0-6)
---------------------------------------------------------------------------

public export
certTypeSize : Nat
certTypeSize = 1

public export
certTypeToTag : CertType -> Bits8
certTypeToTag Root            = 0
certTypeToTag Intermediate    = 1
certTypeToTag EndEntity       = 2
certTypeToTag CrossSigned     = 3
certTypeToTag CodeSigning     = 4
certTypeToTag EmailProtection = 5
certTypeToTag OCSPSigning     = 6

public export
tagToCertType : Bits8 -> Maybe CertType
tagToCertType 0 = Just Root
tagToCertType 1 = Just Intermediate
tagToCertType 2 = Just EndEntity
tagToCertType 3 = Just CrossSigned
tagToCertType 4 = Just CodeSigning
tagToCertType 5 = Just EmailProtection
tagToCertType 6 = Just OCSPSigning
tagToCertType _ = Nothing

public export
certTypeRoundtrip : (t : CertType) -> tagToCertType (certTypeToTag t) = Just t
certTypeRoundtrip Root            = Refl
certTypeRoundtrip Intermediate    = Refl
certTypeRoundtrip EndEntity       = Refl
certTypeRoundtrip CrossSigned     = Refl
certTypeRoundtrip CodeSigning     = Refl
certTypeRoundtrip EmailProtection = Refl
certTypeRoundtrip OCSPSigning     = Refl

---------------------------------------------------------------------------
-- KeyAlgorithm (6 constructors, tags 0-5)
---------------------------------------------------------------------------

public export
keyAlgorithmSize : Nat
keyAlgorithmSize = 1

public export
keyAlgorithmToTag : KeyAlgorithm -> Bits8
keyAlgorithmToTag RSA2048    = 0
keyAlgorithmToTag RSA4096    = 1
keyAlgorithmToTag ECDSA_P256 = 2
keyAlgorithmToTag ECDSA_P384 = 3
keyAlgorithmToTag Ed25519    = 4
keyAlgorithmToTag Ed448      = 5

public export
tagToKeyAlgorithm : Bits8 -> Maybe KeyAlgorithm
tagToKeyAlgorithm 0 = Just RSA2048
tagToKeyAlgorithm 1 = Just RSA4096
tagToKeyAlgorithm 2 = Just ECDSA_P256
tagToKeyAlgorithm 3 = Just ECDSA_P384
tagToKeyAlgorithm 4 = Just Ed25519
tagToKeyAlgorithm 5 = Just Ed448
tagToKeyAlgorithm _ = Nothing

public export
keyAlgorithmRoundtrip : (k : KeyAlgorithm) -> tagToKeyAlgorithm (keyAlgorithmToTag k) = Just k
keyAlgorithmRoundtrip RSA2048    = Refl
keyAlgorithmRoundtrip RSA4096    = Refl
keyAlgorithmRoundtrip ECDSA_P256 = Refl
keyAlgorithmRoundtrip ECDSA_P384 = Refl
keyAlgorithmRoundtrip Ed25519    = Refl
keyAlgorithmRoundtrip Ed448      = Refl

---------------------------------------------------------------------------
-- SignatureAlgorithm (7 constructors, tags 0-6)
---------------------------------------------------------------------------

public export
signatureAlgorithmSize : Nat
signatureAlgorithmSize = 1

public export
signatureAlgorithmToTag : SignatureAlgorithm -> Bits8
signatureAlgorithmToTag SHA256WithRSA   = 0
signatureAlgorithmToTag SHA384WithRSA   = 1
signatureAlgorithmToTag SHA512WithRSA   = 2
signatureAlgorithmToTag SHA256WithECDSA = 3
signatureAlgorithmToTag SHA384WithECDSA = 4
signatureAlgorithmToTag PureEd25519     = 5
signatureAlgorithmToTag PureEd448       = 6

public export
tagToSignatureAlgorithm : Bits8 -> Maybe SignatureAlgorithm
tagToSignatureAlgorithm 0 = Just SHA256WithRSA
tagToSignatureAlgorithm 1 = Just SHA384WithRSA
tagToSignatureAlgorithm 2 = Just SHA512WithRSA
tagToSignatureAlgorithm 3 = Just SHA256WithECDSA
tagToSignatureAlgorithm 4 = Just SHA384WithECDSA
tagToSignatureAlgorithm 5 = Just PureEd25519
tagToSignatureAlgorithm 6 = Just PureEd448
tagToSignatureAlgorithm _ = Nothing

public export
signatureAlgorithmRoundtrip : (s : SignatureAlgorithm)
                            -> tagToSignatureAlgorithm (signatureAlgorithmToTag s) = Just s
signatureAlgorithmRoundtrip SHA256WithRSA   = Refl
signatureAlgorithmRoundtrip SHA384WithRSA   = Refl
signatureAlgorithmRoundtrip SHA512WithRSA   = Refl
signatureAlgorithmRoundtrip SHA256WithECDSA = Refl
signatureAlgorithmRoundtrip SHA384WithECDSA = Refl
signatureAlgorithmRoundtrip PureEd25519     = Refl
signatureAlgorithmRoundtrip PureEd448       = Refl

---------------------------------------------------------------------------
-- CertState (5 constructors, tags 0-4)
---------------------------------------------------------------------------

public export
certStateSize : Nat
certStateSize = 1

public export
certStateToTag : CertState -> Bits8
certStateToTag Pending   = 0
certStateToTag Active    = 1
certStateToTag Revoked   = 2
certStateToTag Expired   = 3
certStateToTag Suspended = 4

public export
tagToCertState : Bits8 -> Maybe CertState
tagToCertState 0 = Just Pending
tagToCertState 1 = Just Active
tagToCertState 2 = Just Revoked
tagToCertState 3 = Just Expired
tagToCertState 4 = Just Suspended
tagToCertState _ = Nothing

public export
certStateRoundtrip : (s : CertState) -> tagToCertState (certStateToTag s) = Just s
certStateRoundtrip Pending   = Refl
certStateRoundtrip Active    = Refl
certStateRoundtrip Revoked   = Refl
certStateRoundtrip Expired   = Refl
certStateRoundtrip Suspended = Refl

---------------------------------------------------------------------------
-- RevocationReason (7 constructors, tags 0-6)
---------------------------------------------------------------------------

public export
revocationReasonSize : Nat
revocationReasonSize = 1

public export
revocationReasonToTag : RevocationReason -> Bits8
revocationReasonToTag Unspecified          = 0
revocationReasonToTag KeyCompromise        = 1
revocationReasonToTag CACompromise         = 2
revocationReasonToTag AffiliationChanged   = 3
revocationReasonToTag Superseded           = 4
revocationReasonToTag CessationOfOperation = 5
revocationReasonToTag CertificateHold      = 6

public export
tagToRevocationReason : Bits8 -> Maybe RevocationReason
tagToRevocationReason 0 = Just Unspecified
tagToRevocationReason 1 = Just KeyCompromise
tagToRevocationReason 2 = Just CACompromise
tagToRevocationReason 3 = Just AffiliationChanged
tagToRevocationReason 4 = Just Superseded
tagToRevocationReason 5 = Just CessationOfOperation
tagToRevocationReason 6 = Just CertificateHold
tagToRevocationReason _ = Nothing

public export
revocationReasonRoundtrip : (r : RevocationReason)
                          -> tagToRevocationReason (revocationReasonToTag r) = Just r
revocationReasonRoundtrip Unspecified          = Refl
revocationReasonRoundtrip KeyCompromise        = Refl
revocationReasonRoundtrip CACompromise         = Refl
revocationReasonRoundtrip AffiliationChanged   = Refl
revocationReasonRoundtrip Superseded           = Refl
revocationReasonRoundtrip CessationOfOperation = Refl
revocationReasonRoundtrip CertificateHold      = Refl

---------------------------------------------------------------------------
-- CRLStatus (4 constructors, tags 0-3)
---------------------------------------------------------------------------

public export
crlStatusSize : Nat
crlStatusSize = 1

public export
crlStatusToTag : CRLStatus -> Bits8
crlStatusToTag CRLCurrent = 0
crlStatusToTag CRLExpired = 1
crlStatusToTag CRLPending = 2
crlStatusToTag CRLError   = 3

public export
tagToCRLStatus : Bits8 -> Maybe CRLStatus
tagToCRLStatus 0 = Just CRLCurrent
tagToCRLStatus 1 = Just CRLExpired
tagToCRLStatus 2 = Just CRLPending
tagToCRLStatus 3 = Just CRLError
tagToCRLStatus _ = Nothing

public export
crlStatusRoundtrip : (s : CRLStatus) -> tagToCRLStatus (crlStatusToTag s) = Just s
crlStatusRoundtrip CRLCurrent = Refl
crlStatusRoundtrip CRLExpired = Refl
crlStatusRoundtrip CRLPending = Refl
crlStatusRoundtrip CRLError   = Refl

---------------------------------------------------------------------------
-- OCSPStatus (4 constructors, tags 0-3)
---------------------------------------------------------------------------

public export
ocspStatusSize : Nat
ocspStatusSize = 1

public export
ocspStatusToTag : OCSPStatus -> Bits8
ocspStatusToTag OCSPGood        = 0
ocspStatusToTag OCSPRevoked     = 1
ocspStatusToTag OCSPUnknown     = 2
ocspStatusToTag OCSPUnavailable = 3

public export
tagToOCSPStatus : Bits8 -> Maybe OCSPStatus
tagToOCSPStatus 0 = Just OCSPGood
tagToOCSPStatus 1 = Just OCSPRevoked
tagToOCSPStatus 2 = Just OCSPUnknown
tagToOCSPStatus 3 = Just OCSPUnavailable
tagToOCSPStatus _ = Nothing

public export
ocspStatusRoundtrip : (s : OCSPStatus) -> tagToOCSPStatus (ocspStatusToTag s) = Just s
ocspStatusRoundtrip OCSPGood        = Refl
ocspStatusRoundtrip OCSPRevoked     = Refl
ocspStatusRoundtrip OCSPUnknown     = Refl
ocspStatusRoundtrip OCSPUnavailable = Refl

---------------------------------------------------------------------------
-- Extension (6 constructors, tags 0-5)
---------------------------------------------------------------------------

public export
extensionSize : Nat
extensionSize = 1

public export
extensionToTag : Extension -> Bits8
extensionToTag BasicConstraints      = 0
extensionToTag KeyUsage              = 1
extensionToTag ExtKeyUsage           = 2
extensionToTag SubjectAltName        = 3
extensionToTag AuthorityInfoAccess   = 4
extensionToTag CRLDistributionPoints = 5

public export
tagToExtension : Bits8 -> Maybe Extension
tagToExtension 0 = Just BasicConstraints
tagToExtension 1 = Just KeyUsage
tagToExtension 2 = Just ExtKeyUsage
tagToExtension 3 = Just SubjectAltName
tagToExtension 4 = Just AuthorityInfoAccess
tagToExtension 5 = Just CRLDistributionPoints
tagToExtension _ = Nothing

public export
extensionRoundtrip : (e : Extension) -> tagToExtension (extensionToTag e) = Just e
extensionRoundtrip BasicConstraints      = Refl
extensionRoundtrip KeyUsage              = Refl
extensionRoundtrip ExtKeyUsage           = Refl
extensionRoundtrip SubjectAltName        = Refl
extensionRoundtrip AuthorityInfoAccess   = Refl
extensionRoundtrip CRLDistributionPoints = Refl
