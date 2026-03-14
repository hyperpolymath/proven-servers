-- SPDX-License-Identifier: PMPL-1.0-or-later
-- Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
--
-- TLSABI.Layout: C-ABI-compatible numeric representations of TLS types.
--
-- Maps every constructor of the six core sum types (TLSVersion, CipherSuite,
-- HandshakeState, CertValidation, AlertLevel, AlertDescription) to fixed
-- Bits8 values for C interop.  Each type gets a total encoder, partial
-- decoder, and roundtrip proof.
--
-- Tag values here MUST match the C header (generated/abi/tls.h) and the
-- Zig FFI enums (ffi/zig/src/tls.zig) exactly.

module TLSABI.Layout

import TLS.Types

%default total

---------------------------------------------------------------------------
-- TLSVersion (2 constructors, tags 0-1)
---------------------------------------------------------------------------

public export
tlsVersionSize : Nat
tlsVersionSize = 1

public export
tlsVersionToTag : TLSVersion -> Bits8
tlsVersionToTag TLS12 = 0
tlsVersionToTag TLS13 = 1

public export
tagToTlsVersion : Bits8 -> Maybe TLSVersion
tagToTlsVersion 0 = Just TLS12
tagToTlsVersion 1 = Just TLS13
tagToTlsVersion _ = Nothing

public export
tlsVersionRoundtrip : (v : TLSVersion) -> tagToTlsVersion (tlsVersionToTag v) = Just v
tlsVersionRoundtrip TLS12 = Refl
tlsVersionRoundtrip TLS13 = Refl

---------------------------------------------------------------------------
-- CipherSuite (3 constructors, tags 0-2)
---------------------------------------------------------------------------

public export
cipherSuiteSize : Nat
cipherSuiteSize = 1

public export
cipherSuiteToTag : CipherSuite -> Bits8
cipherSuiteToTag TLS_AES_128_GCM_SHA256       = 0
cipherSuiteToTag TLS_AES_256_GCM_SHA384       = 1
cipherSuiteToTag TLS_CHACHA20_POLY1305_SHA256 = 2

public export
tagToCipherSuite : Bits8 -> Maybe CipherSuite
tagToCipherSuite 0 = Just TLS_AES_128_GCM_SHA256
tagToCipherSuite 1 = Just TLS_AES_256_GCM_SHA384
tagToCipherSuite 2 = Just TLS_CHACHA20_POLY1305_SHA256
tagToCipherSuite _ = Nothing

public export
cipherSuiteRoundtrip : (c : CipherSuite) -> tagToCipherSuite (cipherSuiteToTag c) = Just c
cipherSuiteRoundtrip TLS_AES_128_GCM_SHA256       = Refl
cipherSuiteRoundtrip TLS_AES_256_GCM_SHA384       = Refl
cipherSuiteRoundtrip TLS_CHACHA20_POLY1305_SHA256 = Refl

---------------------------------------------------------------------------
-- HandshakeState (8 constructors, tags 0-7)
---------------------------------------------------------------------------

public export
handshakeStateSize : Nat
handshakeStateSize = 1

public export
handshakeStateToTag : HandshakeState -> Bits8
handshakeStateToTag ClientHello         = 0
handshakeStateToTag ServerHello         = 1
handshakeStateToTag EncryptedExtensions = 2
handshakeStateToTag Certificate         = 3
handshakeStateToTag CertificateVerify   = 4
handshakeStateToTag Finished            = 5
handshakeStateToTag Established         = 6
handshakeStateToTag Closed              = 7

public export
tagToHandshakeState : Bits8 -> Maybe HandshakeState
tagToHandshakeState 0 = Just ClientHello
tagToHandshakeState 1 = Just ServerHello
tagToHandshakeState 2 = Just EncryptedExtensions
tagToHandshakeState 3 = Just Certificate
tagToHandshakeState 4 = Just CertificateVerify
tagToHandshakeState 5 = Just Finished
tagToHandshakeState 6 = Just Established
tagToHandshakeState 7 = Just Closed
tagToHandshakeState _ = Nothing

public export
handshakeStateRoundtrip : (s : HandshakeState) -> tagToHandshakeState (handshakeStateToTag s) = Just s
handshakeStateRoundtrip ClientHello         = Refl
handshakeStateRoundtrip ServerHello         = Refl
handshakeStateRoundtrip EncryptedExtensions = Refl
handshakeStateRoundtrip Certificate         = Refl
handshakeStateRoundtrip CertificateVerify   = Refl
handshakeStateRoundtrip Finished            = Refl
handshakeStateRoundtrip Established         = Refl
handshakeStateRoundtrip Closed              = Refl

---------------------------------------------------------------------------
-- CertValidation (9 constructors, tags 0-8)
---------------------------------------------------------------------------

public export
certValidationSize : Nat
certValidationSize = 1

public export
certValidationToTag : CertValidation -> Bits8
certValidationToTag Valid            = 0
certValidationToTag Expired          = 1
certValidationToTag NotYetValid      = 2
certValidationToTag Revoked          = 3
certValidationToTag SelfSigned       = 4
certValidationToTag UnknownCA        = 5
certValidationToTag HostnameMismatch = 6
certValidationToTag WeakKey          = 7
certValidationToTag WeakSignature    = 8

public export
tagToCertValidation : Bits8 -> Maybe CertValidation
tagToCertValidation 0 = Just Valid
tagToCertValidation 1 = Just Expired
tagToCertValidation 2 = Just NotYetValid
tagToCertValidation 3 = Just Revoked
tagToCertValidation 4 = Just SelfSigned
tagToCertValidation 5 = Just UnknownCA
tagToCertValidation 6 = Just HostnameMismatch
tagToCertValidation 7 = Just WeakKey
tagToCertValidation 8 = Just WeakSignature
tagToCertValidation _ = Nothing

public export
certValidationRoundtrip : (v : CertValidation) -> tagToCertValidation (certValidationToTag v) = Just v
certValidationRoundtrip Valid            = Refl
certValidationRoundtrip Expired          = Refl
certValidationRoundtrip NotYetValid      = Refl
certValidationRoundtrip Revoked          = Refl
certValidationRoundtrip SelfSigned       = Refl
certValidationRoundtrip UnknownCA        = Refl
certValidationRoundtrip HostnameMismatch = Refl
certValidationRoundtrip WeakKey          = Refl
certValidationRoundtrip WeakSignature    = Refl

---------------------------------------------------------------------------
-- AlertLevel (2 constructors, tags 0-1)
---------------------------------------------------------------------------

public export
alertLevelSize : Nat
alertLevelSize = 1

public export
alertLevelToTag : AlertLevel -> Bits8
alertLevelToTag Warning = 0
alertLevelToTag Fatal   = 1

public export
tagToAlertLevel : Bits8 -> Maybe AlertLevel
tagToAlertLevel 0 = Just Warning
tagToAlertLevel 1 = Just Fatal
tagToAlertLevel _ = Nothing

public export
alertLevelRoundtrip : (l : AlertLevel) -> tagToAlertLevel (alertLevelToTag l) = Just l
alertLevelRoundtrip Warning = Refl
alertLevelRoundtrip Fatal   = Refl

---------------------------------------------------------------------------
-- AlertDescription (24 constructors, tags 0-23)
---------------------------------------------------------------------------

public export
alertDescriptionSize : Nat
alertDescriptionSize = 1

public export
alertDescriptionToTag : AlertDescription -> Bits8
alertDescriptionToTag CloseNotify            = 0
alertDescriptionToTag UnexpectedMessage      = 1
alertDescriptionToTag BadRecordMAC           = 2
alertDescriptionToTag DecryptionFailed       = 3
alertDescriptionToTag RecordOverflow         = 4
alertDescriptionToTag HandshakeFailure       = 5
alertDescriptionToTag BadCertificate         = 6
alertDescriptionToTag UnsupportedCertificate = 7
alertDescriptionToTag CertificateRevoked     = 8
alertDescriptionToTag CertificateExpired     = 9
alertDescriptionToTag CertificateUnknown     = 10
alertDescriptionToTag IllegalParameter       = 11
alertDescriptionToTag UnknownCA              = 12
alertDescriptionToTag AccessDenied           = 13
alertDescriptionToTag DecodeError            = 14
alertDescriptionToTag DecryptError           = 15
alertDescriptionToTag ProtocolVersion        = 16
alertDescriptionToTag InsufficientSecurity   = 17
alertDescriptionToTag InternalError          = 18
alertDescriptionToTag InappropriateFallback  = 19
alertDescriptionToTag MissingExtension       = 20
alertDescriptionToTag UnsupportedExtension   = 21
alertDescriptionToTag UnrecognizedName       = 22
alertDescriptionToTag CertificateRequired    = 23
alertDescriptionToTag NoApplicationProtocol  = 24

public export
tagToAlertDescription : Bits8 -> Maybe AlertDescription
tagToAlertDescription 0  = Just CloseNotify
tagToAlertDescription 1  = Just UnexpectedMessage
tagToAlertDescription 2  = Just BadRecordMAC
tagToAlertDescription 3  = Just DecryptionFailed
tagToAlertDescription 4  = Just RecordOverflow
tagToAlertDescription 5  = Just HandshakeFailure
tagToAlertDescription 6  = Just BadCertificate
tagToAlertDescription 7  = Just UnsupportedCertificate
tagToAlertDescription 8  = Just CertificateRevoked
tagToAlertDescription 9  = Just CertificateExpired
tagToAlertDescription 10 = Just CertificateUnknown
tagToAlertDescription 11 = Just IllegalParameter
tagToAlertDescription 12 = Just UnknownCA
tagToAlertDescription 13 = Just AccessDenied
tagToAlertDescription 14 = Just DecodeError
tagToAlertDescription 15 = Just DecryptError
tagToAlertDescription 16 = Just ProtocolVersion
tagToAlertDescription 17 = Just InsufficientSecurity
tagToAlertDescription 18 = Just InternalError
tagToAlertDescription 19 = Just InappropriateFallback
tagToAlertDescription 20 = Just MissingExtension
tagToAlertDescription 21 = Just UnsupportedExtension
tagToAlertDescription 22 = Just UnrecognizedName
tagToAlertDescription 23 = Just CertificateRequired
tagToAlertDescription 24 = Just NoApplicationProtocol
tagToAlertDescription _  = Nothing

public export
alertDescriptionRoundtrip : (d : AlertDescription) -> tagToAlertDescription (alertDescriptionToTag d) = Just d
alertDescriptionRoundtrip CloseNotify            = Refl
alertDescriptionRoundtrip UnexpectedMessage      = Refl
alertDescriptionRoundtrip BadRecordMAC           = Refl
alertDescriptionRoundtrip DecryptionFailed       = Refl
alertDescriptionRoundtrip RecordOverflow         = Refl
alertDescriptionRoundtrip HandshakeFailure       = Refl
alertDescriptionRoundtrip BadCertificate         = Refl
alertDescriptionRoundtrip UnsupportedCertificate = Refl
alertDescriptionRoundtrip CertificateRevoked     = Refl
alertDescriptionRoundtrip CertificateExpired     = Refl
alertDescriptionRoundtrip CertificateUnknown     = Refl
alertDescriptionRoundtrip IllegalParameter       = Refl
alertDescriptionRoundtrip UnknownCA              = Refl
alertDescriptionRoundtrip AccessDenied           = Refl
alertDescriptionRoundtrip DecodeError            = Refl
alertDescriptionRoundtrip DecryptError           = Refl
alertDescriptionRoundtrip ProtocolVersion        = Refl
alertDescriptionRoundtrip InsufficientSecurity   = Refl
alertDescriptionRoundtrip InternalError          = Refl
alertDescriptionRoundtrip InappropriateFallback  = Refl
alertDescriptionRoundtrip MissingExtension       = Refl
alertDescriptionRoundtrip UnsupportedExtension   = Refl
alertDescriptionRoundtrip UnrecognizedName       = Refl
alertDescriptionRoundtrip CertificateRequired    = Refl
alertDescriptionRoundtrip NoApplicationProtocol  = Refl
