-- SPDX-License-Identifier: MPL-2.0
-- Copyright (c) Jonathan D.A. Jewell <j.d.a.jewell@open.ac.uk>
--
-- CAABI.Emit: ABI tag-manifest emitter (single source of truth).
-- Prints `KIND NAME DECIMAL` lines from the proven *ToTag encoders;
-- tools/gen-abi.sh renders them into ca_abi_gen.zig for the comptime guard.

module CAABI.Emit

import CA.Types
import CAABI.Layout
import CAABI.Foreign

%default total

line : String -> String -> Bits8 -> String
line kind name val = kind ++ " " ++ name ++ " " ++ show val

manifest : List String
manifest =
  [ "ABI_VERSION " ++ show abiVersion
  , line "CT" "ROOT"             (certTypeToTag Root)
  , line "CT" "INTERMEDIATE"     (certTypeToTag Intermediate)
  , line "CT" "END_ENTITY"       (certTypeToTag EndEntity)
  , line "CT" "CROSS_SIGNED"     (certTypeToTag CrossSigned)
  , line "CT" "CODE_SIGNING"     (certTypeToTag CodeSigning)
  , line "CT" "EMAIL_PROTECTION" (certTypeToTag EmailProtection)
  , line "CT" "OCSP_SIGNING"     (certTypeToTag OCSPSigning)
  , line "KA" "RSA2048"    (keyAlgorithmToTag RSA2048)
  , line "KA" "RSA4096"    (keyAlgorithmToTag RSA4096)
  , line "KA" "ECDSA_P256" (keyAlgorithmToTag ECDSA_P256)
  , line "KA" "ECDSA_P384" (keyAlgorithmToTag ECDSA_P384)
  , line "KA" "ED25519"    (keyAlgorithmToTag Ed25519)
  , line "KA" "ED448"      (keyAlgorithmToTag Ed448)
  , line "SA" "SHA256_WITH_RSA"   (signatureAlgorithmToTag SHA256WithRSA)
  , line "SA" "SHA384_WITH_RSA"   (signatureAlgorithmToTag SHA384WithRSA)
  , line "SA" "SHA512_WITH_RSA"   (signatureAlgorithmToTag SHA512WithRSA)
  , line "SA" "SHA256_WITH_ECDSA" (signatureAlgorithmToTag SHA256WithECDSA)
  , line "SA" "SHA384_WITH_ECDSA" (signatureAlgorithmToTag SHA384WithECDSA)
  , line "SA" "PURE_ED25519"      (signatureAlgorithmToTag PureEd25519)
  , line "SA" "PURE_ED448"        (signatureAlgorithmToTag PureEd448)
  , line "CS" "PENDING"   (certStateToTag Pending)
  , line "CS" "ACTIVE"    (certStateToTag Active)
  , line "CS" "REVOKED"   (certStateToTag Revoked)
  , line "CS" "EXPIRED"   (certStateToTag Expired)
  , line "CS" "SUSPENDED" (certStateToTag Suspended)
  , line "RR" "UNSPECIFIED"            (revocationReasonToTag Unspecified)
  , line "RR" "KEY_COMPROMISE"         (revocationReasonToTag KeyCompromise)
  , line "RR" "CA_COMPROMISE"          (revocationReasonToTag CACompromise)
  , line "RR" "AFFILIATION_CHANGED"    (revocationReasonToTag AffiliationChanged)
  , line "RR" "SUPERSEDED"             (revocationReasonToTag Superseded)
  , line "RR" "CESSATION_OF_OPERATION" (revocationReasonToTag CessationOfOperation)
  , line "RR" "CERTIFICATE_HOLD"       (revocationReasonToTag CertificateHold)
  , line "CRL" "CURRENT" (crlStatusToTag CRLCurrent)
  , line "CRL" "EXPIRED" (crlStatusToTag CRLExpired)
  , line "CRL" "PENDING" (crlStatusToTag CRLPending)
  , line "CRL" "ERROR"   (crlStatusToTag CRLError)
  , line "OCSP" "GOOD"        (ocspStatusToTag OCSPGood)
  , line "OCSP" "REVOKED"     (ocspStatusToTag OCSPRevoked)
  , line "OCSP" "UNKNOWN"     (ocspStatusToTag OCSPUnknown)
  , line "OCSP" "UNAVAILABLE" (ocspStatusToTag OCSPUnavailable)
  , line "EXT" "BASIC_CONSTRAINTS"       (extensionToTag BasicConstraints)
  , line "EXT" "KEY_USAGE"               (extensionToTag KeyUsage)
  , line "EXT" "EXT_KEY_USAGE"           (extensionToTag ExtKeyUsage)
  , line "EXT" "SUBJECT_ALT_NAME"        (extensionToTag SubjectAltName)
  , line "EXT" "AUTHORITY_INFO_ACCESS"   (extensionToTag AuthorityInfoAccess)
  , line "EXT" "CRL_DISTRIBUTION_POINTS" (extensionToTag CRLDistributionPoints)
  , line "KU" "DIGITAL_SIGNATURE" (keyUsageBitToTag DigitalSignature)
  , line "KU" "NON_REPUDIATION"   (keyUsageBitToTag NonRepudiation)
  , line "KU" "KEY_ENCIPHERMENT"  (keyUsageBitToTag KeyEncipherment)
  , line "KU" "DATA_ENCIPHERMENT" (keyUsageBitToTag DataEncipherment)
  , line "KU" "KEY_AGREEMENT"     (keyUsageBitToTag KeyAgreement)
  , line "KU" "KEY_CERT_SIGN"     (keyUsageBitToTag KeyCertSign)
  , line "KU" "CRL_SIGN"          (keyUsageBitToTag CRLSign)
  , line "KU" "ENCIPHER_ONLY"     (keyUsageBitToTag EncipherOnly)
  , line "KU" "DECIPHER_ONLY"     (keyUsageBitToTag DecipherOnly)
  ]

covering
main : IO ()
main = traverse_ putStrLn manifest
