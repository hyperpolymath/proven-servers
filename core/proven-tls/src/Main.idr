-- SPDX-License-Identifier: PMPL-1.0-or-later
-- Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
--
-- Main: Entry point for proven-tls.
-- Prints the primitive name and shows all type constructors.

module Main

import TLS

%default total

||| Print a labelled list of constructors for a sum type.
covering
showConstructors : String -> List String -> IO ()
showConstructors label cs = do
  putStrLn $ "  " ++ label ++ ":"
  traverse_ (\c => putStrLn $ "    - " ++ c) cs

||| Entry point — display proven-tls type constructors and constants.
covering
main : IO ()
main = do
  putStrLn "proven-tls — TLS types in the verified core"
  putStrLn ""
  showConstructors "TLSVersion"
    [ show TLS12, show TLS13 ]
  showConstructors "CipherSuite"
    [ show TLS_AES_128_GCM_SHA256, show TLS_AES_256_GCM_SHA384
    , show TLS_CHACHA20_POLY1305_SHA256 ]
  showConstructors "HandshakeState"
    [ show ClientHello, show ServerHello, show EncryptedExtensions
    , show Certificate, show CertificateVerify, show Finished
    , show Established, show Closed ]
  showConstructors "CertValidation"
    [ show Valid, show Expired, show NotYetValid, show Revoked
    , show SelfSigned, show UnknownCA, show HostnameMismatch
    , show WeakKey, show WeakSignature ]
  showConstructors "AlertLevel"
    [ show Warning, show Fatal ]
  showConstructors "AlertDescription"
    [ show CloseNotify, show UnexpectedMessage, show BadRecordMAC
    , show DecryptionFailed, show RecordOverflow, show HandshakeFailure
    , show BadCertificate, show UnsupportedCertificate
    , show CertificateRevoked, show CertificateExpired
    , show CertificateUnknown, show IllegalParameter
    , show UnknownCA, show AccessDenied, show DecodeError
    , show DecryptError, show ProtocolVersion
    , show InsufficientSecurity, show InternalError
    , show InappropriateFallback, show MissingExtension
    , show UnsupportedExtension, show UnrecognizedName
    , show CertificateRequired, show NoApplicationProtocol ]
  putStrLn ""
  putStrLn $ "  tlsPort               = " ++ show tlsPort
  putStrLn $ "  minVersion            = " ++ show minVersion
  putStrLn $ "  maxCertChainDepth     = " ++ show maxCertChainDepth
  putStrLn $ "  sessionTicketLifetime = " ++ show sessionTicketLifetime
