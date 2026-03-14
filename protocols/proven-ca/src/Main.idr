-- SPDX-License-Identifier: PMPL-1.0-or-later
-- Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
--
-- Main : Entry point for proven-ca. Prints server identity and
-- enumerates all protocol type constructors.

module Main

import CA

---------------------------------------------------------------------------
-- Main
---------------------------------------------------------------------------

allCertTypes : List CertType
allCertTypes = [Root, Intermediate, EndEntity, CrossSigned, CodeSigning, EmailProtection, OCSPSigning]

allKeyAlgorithms : List KeyAlgorithm
allKeyAlgorithms = [RSA2048, RSA4096, ECDSA_P256, ECDSA_P384, Ed25519, Ed448]

allSignatureAlgorithms : List SignatureAlgorithm
allSignatureAlgorithms =
  [ SHA256WithRSA, SHA384WithRSA, SHA512WithRSA
  , SHA256WithECDSA, SHA384WithECDSA, PureEd25519, PureEd448
  ]

allCertStates : List CertState
allCertStates = [Pending, Active, Revoked, Expired, Suspended]

allRevocationReasons : List RevocationReason
allRevocationReasons =
  [ Unspecified, KeyCompromise, CACompromise
  , AffiliationChanged, Superseded, CessationOfOperation, CertificateHold
  ]

allCRLStatuses : List CRLStatus
allCRLStatuses = [CRLCurrent, CRLExpired, CRLPending, CRLError]

allOCSPStatuses : List OCSPStatus
allOCSPStatuses = [OCSPGood, OCSPRevoked, OCSPUnknown, OCSPUnavailable]

allExtensions : List Extension
allExtensions =
  [ BasicConstraints, KeyUsage, ExtKeyUsage
  , SubjectAltName, AuthorityInfoAccess, CRLDistributionPoints
  ]

main : IO ()
main = do
  putStrLn "proven-ca : Certificate Authority server"
  putStrLn $ "  Max path length: " ++ show maxPathLength
  putStrLn $ "  Default validity: " ++ show defaultValidityDays ++ " days"
  putStrLn $ "  CRL update interval: " ++ show crlUpdateHours ++ " hours"
  putStrLn $ "  CertTypes:           " ++ show allCertTypes
  putStrLn $ "  KeyAlgorithms:       " ++ show allKeyAlgorithms
  putStrLn $ "  SignatureAlgorithms: " ++ show allSignatureAlgorithms
  putStrLn $ "  CertStates:          " ++ show allCertStates
  putStrLn $ "  RevocationReasons:   " ++ show allRevocationReasons
  putStrLn $ "  CRLStatuses:         " ++ show allCRLStatuses
  putStrLn $ "  OCSPStatuses:        " ++ show allOCSPStatuses
  putStrLn $ "  Extensions:          " ++ show allExtensions
