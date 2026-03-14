-- SPDX-License-Identifier: PMPL-1.0-or-later
-- Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
--
-- CA.Types : Core types for the Certificate Authority server.
--
-- Defines certificate types, key algorithms, signature algorithms,
-- certificate states, revocation reasons, CRL/OCSP status, and
-- X.509 extensions.  These types are the domain model; Layout.idr
-- maps them to fixed-width tags for the C ABI.

module CA.Types

%default total

---------------------------------------------------------------------------
-- CertType : Types of X.509 certificates the CA can issue.
---------------------------------------------------------------------------

||| Certificate purpose classifications (RFC 5280 + CA practice).
public export
data CertType : Type where
  Root            : CertType
  Intermediate    : CertType
  EndEntity       : CertType
  CrossSigned     : CertType
  CodeSigning     : CertType
  EmailProtection : CertType
  OCSPSigning     : CertType

export
Show CertType where
  show Root            = "Root"
  show Intermediate    = "Intermediate"
  show EndEntity       = "EndEntity"
  show CrossSigned     = "CrossSigned"
  show CodeSigning     = "CodeSigning"
  show EmailProtection = "EmailProtection"
  show OCSPSigning     = "OCSPSigning"

---------------------------------------------------------------------------
-- KeyAlgorithm : Cryptographic algorithms for key generation.
---------------------------------------------------------------------------

||| Supported key generation algorithms and their parameters.
public export
data KeyAlgorithm : Type where
  RSA2048    : KeyAlgorithm
  RSA4096    : KeyAlgorithm
  ECDSA_P256 : KeyAlgorithm
  ECDSA_P384 : KeyAlgorithm
  Ed25519    : KeyAlgorithm
  Ed448      : KeyAlgorithm

export
Show KeyAlgorithm where
  show RSA2048    = "RSA-2048"
  show RSA4096    = "RSA-4096"
  show ECDSA_P256 = "ECDSA-P256"
  show ECDSA_P384 = "ECDSA-P384"
  show Ed25519    = "Ed25519"
  show Ed448      = "Ed448"

---------------------------------------------------------------------------
-- SignatureAlgorithm : Algorithms used to sign certificates.
---------------------------------------------------------------------------

||| Signature algorithms for certificate and CRL signing.
public export
data SignatureAlgorithm : Type where
  SHA256WithRSA   : SignatureAlgorithm
  SHA384WithRSA   : SignatureAlgorithm
  SHA512WithRSA   : SignatureAlgorithm
  SHA256WithECDSA : SignatureAlgorithm
  SHA384WithECDSA : SignatureAlgorithm
  PureEd25519     : SignatureAlgorithm
  PureEd448       : SignatureAlgorithm

export
Show SignatureAlgorithm where
  show SHA256WithRSA   = "SHA256WithRSA"
  show SHA384WithRSA   = "SHA384WithRSA"
  show SHA512WithRSA   = "SHA512WithRSA"
  show SHA256WithECDSA = "SHA256WithECDSA"
  show SHA384WithECDSA = "SHA384WithECDSA"
  show PureEd25519     = "PureEd25519"
  show PureEd448       = "PureEd448"

---------------------------------------------------------------------------
-- CertState : Current lifecycle state of a certificate.
---------------------------------------------------------------------------

||| Lifecycle state of a certificate managed by the CA.
public export
data CertState : Type where
  Pending   : CertState
  Active    : CertState
  Revoked   : CertState
  Expired   : CertState
  Suspended : CertState

export
Show CertState where
  show Pending   = "Pending"
  show Active    = "Active"
  show Revoked   = "Revoked"
  show Expired   = "Expired"
  show Suspended = "Suspended"

---------------------------------------------------------------------------
-- RevocationReason : RFC 5280 CRL reason codes.
---------------------------------------------------------------------------

||| Reason for revoking a certificate, per RFC 5280 Section 5.3.1.
public export
data RevocationReason : Type where
  Unspecified          : RevocationReason
  KeyCompromise        : RevocationReason
  CACompromise         : RevocationReason
  AffiliationChanged   : RevocationReason
  Superseded           : RevocationReason
  CessationOfOperation : RevocationReason
  CertificateHold      : RevocationReason

export
Show RevocationReason where
  show Unspecified          = "Unspecified"
  show KeyCompromise        = "KeyCompromise"
  show CACompromise         = "CACompromise"
  show AffiliationChanged   = "AffiliationChanged"
  show Superseded           = "Superseded"
  show CessationOfOperation = "CessationOfOperation"
  show CertificateHold      = "CertificateHold"

---------------------------------------------------------------------------
-- CRLStatus : State of a CRL (Certificate Revocation List).
---------------------------------------------------------------------------

||| Status of a Certificate Revocation List.
public export
data CRLStatus : Type where
  CRLCurrent   : CRLStatus
  CRLExpired   : CRLStatus
  CRLPending   : CRLStatus
  CRLError     : CRLStatus

export
Show CRLStatus where
  show CRLCurrent = "Current"
  show CRLExpired = "Expired"
  show CRLPending = "Pending"
  show CRLError   = "Error"

---------------------------------------------------------------------------
-- OCSPStatus : Status of an OCSP responder.
---------------------------------------------------------------------------

||| OCSP (Online Certificate Status Protocol) responder status.
public export
data OCSPStatus : Type where
  OCSPGood        : OCSPStatus
  OCSPRevoked     : OCSPStatus
  OCSPUnknown     : OCSPStatus
  OCSPUnavailable : OCSPStatus

export
Show OCSPStatus where
  show OCSPGood        = "Good"
  show OCSPRevoked     = "Revoked"
  show OCSPUnknown     = "Unknown"
  show OCSPUnavailable = "Unavailable"

---------------------------------------------------------------------------
-- Extension : X.509v3 certificate extensions.
---------------------------------------------------------------------------

||| X.509v3 extensions the CA can include in issued certificates.
public export
data Extension : Type where
  BasicConstraints        : Extension
  KeyUsage                : Extension
  ExtKeyUsage             : Extension
  SubjectAltName          : Extension
  AuthorityInfoAccess     : Extension
  CRLDistributionPoints   : Extension

export
Show Extension where
  show BasicConstraints      = "BasicConstraints"
  show KeyUsage              = "KeyUsage"
  show ExtKeyUsage           = "ExtKeyUsage"
  show SubjectAltName        = "SubjectAltName"
  show AuthorityInfoAccess   = "AuthorityInfoAccess"
  show CRLDistributionPoints = "CRLDistributionPoints"
