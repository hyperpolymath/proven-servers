-- SPDX-License-Identifier: PMPL-1.0-or-later
-- Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
--
-- TLS.Types: Core type definitions for TLS in the verified core.
-- Closed sum types representing TLS versions, cipher suites, handshake
-- states, certificate validation results, alert levels, and alert
-- descriptions per RFC 8446 (TLS 1.3) and RFC 5246 (TLS 1.2).

module TLS.Types

%default total

---------------------------------------------------------------------------
-- TLS version — the protocol version.
---------------------------------------------------------------------------

||| Supported TLS protocol versions.
public export
data TLSVersion : Type where
  ||| TLS 1.2 (RFC 5246).
  TLS12 : TLSVersion
  ||| TLS 1.3 (RFC 8446).
  TLS13 : TLSVersion

public export
Show TLSVersion where
  show TLS12 = "TLS12"
  show TLS13 = "TLS13"

---------------------------------------------------------------------------
-- Cipher suite — the cryptographic algorithm combination.
---------------------------------------------------------------------------

||| TLS 1.3 cipher suites (RFC 8446 appendix B.4).
public export
data CipherSuite : Type where
  ||| AES-128 in GCM mode with SHA-256 key derivation.
  TLS_AES_128_GCM_SHA256       : CipherSuite
  ||| AES-256 in GCM mode with SHA-384 key derivation.
  TLS_AES_256_GCM_SHA384       : CipherSuite
  ||| ChaCha20-Poly1305 with SHA-256 key derivation.
  TLS_CHACHA20_POLY1305_SHA256 : CipherSuite

public export
Show CipherSuite where
  show TLS_AES_128_GCM_SHA256       = "TLS_AES_128_GCM_SHA256"
  show TLS_AES_256_GCM_SHA384       = "TLS_AES_256_GCM_SHA384"
  show TLS_CHACHA20_POLY1305_SHA256 = "TLS_CHACHA20_POLY1305_SHA256"

---------------------------------------------------------------------------
-- Handshake state — the TLS handshake state machine.
---------------------------------------------------------------------------

||| States in the TLS handshake protocol.
public export
data HandshakeState : Type where
  ||| Client has sent its hello message.
  ClientHello          : HandshakeState
  ||| Server has sent its hello message.
  ServerHello          : HandshakeState
  ||| Server has sent encrypted extensions.
  EncryptedExtensions  : HandshakeState
  ||| Certificate message received/sent.
  Certificate          : HandshakeState
  ||| Certificate verification received/sent.
  CertificateVerify    : HandshakeState
  ||| Finished message received/sent.
  Finished             : HandshakeState
  ||| Handshake complete, application data may flow.
  Established          : HandshakeState
  ||| Connection has been closed.
  Closed               : HandshakeState

public export
Show HandshakeState where
  show ClientHello         = "ClientHello"
  show ServerHello         = "ServerHello"
  show EncryptedExtensions = "EncryptedExtensions"
  show Certificate         = "Certificate"
  show CertificateVerify   = "CertificateVerify"
  show Finished            = "Finished"
  show Established         = "Established"
  show Closed              = "Closed"

---------------------------------------------------------------------------
-- Certificate validation — the result of validating a certificate.
---------------------------------------------------------------------------

||| The result of validating a TLS certificate.
public export
data CertValidation : Type where
  ||| The certificate is valid and trusted.
  Valid            : CertValidation
  ||| The certificate has expired.
  Expired          : CertValidation
  ||| The certificate is not yet valid (future notBefore date).
  NotYetValid      : CertValidation
  ||| The certificate has been revoked.
  Revoked          : CertValidation
  ||| The certificate is self-signed and not in the trust store.
  SelfSigned       : CertValidation
  ||| The issuing CA is not known / trusted.
  UnknownCA        : CertValidation
  ||| The certificate hostname does not match the expected host.
  HostnameMismatch : CertValidation
  ||| The certificate key is too weak.
  WeakKey          : CertValidation
  ||| The certificate signature algorithm is too weak.
  WeakSignature    : CertValidation

public export
Show CertValidation where
  show Valid            = "Valid"
  show Expired          = "Expired"
  show NotYetValid      = "NotYetValid"
  show Revoked          = "Revoked"
  show SelfSigned       = "SelfSigned"
  show UnknownCA        = "UnknownCA"
  show HostnameMismatch = "HostnameMismatch"
  show WeakKey          = "WeakKey"
  show WeakSignature    = "WeakSignature"

---------------------------------------------------------------------------
-- Alert level — the severity of a TLS alert.
---------------------------------------------------------------------------

||| The severity level of a TLS alert.
public export
data AlertLevel : Type where
  ||| A warning alert (connection may continue).
  Warning : AlertLevel
  ||| A fatal alert (connection must be terminated).
  Fatal   : AlertLevel

public export
Show AlertLevel where
  show Warning = "Warning"
  show Fatal   = "Fatal"

---------------------------------------------------------------------------
-- Alert description — the specific TLS alert type.
---------------------------------------------------------------------------

||| TLS alert descriptions per RFC 8446 section 6.2.
public export
data AlertDescription : Type where
  ||| The connection is being closed normally.
  CloseNotify            : AlertDescription
  ||| An unexpected message was received.
  UnexpectedMessage      : AlertDescription
  ||| A bad record MAC was detected.
  BadRecordMAC           : AlertDescription
  ||| Decryption of a record failed.
  DecryptionFailed       : AlertDescription
  ||| A record exceeded the maximum allowed length.
  RecordOverflow         : AlertDescription
  ||| The handshake negotiation failed.
  HandshakeFailure       : AlertDescription
  ||| The certificate is bad or corrupt.
  BadCertificate         : AlertDescription
  ||| The certificate type is not supported.
  UnsupportedCertificate : AlertDescription
  ||| The certificate has been revoked.
  CertificateRevoked     : AlertDescription
  ||| The certificate has expired.
  CertificateExpired     : AlertDescription
  ||| An unspecified certificate error.
  CertificateUnknown     : AlertDescription
  ||| An illegal parameter in a handshake message.
  IllegalParameter       : AlertDescription
  ||| The issuing CA is unknown.
  UnknownCA              : AlertDescription
  ||| Access was denied by policy.
  AccessDenied           : AlertDescription
  ||| A message could not be decoded.
  DecodeError            : AlertDescription
  ||| A message could not be decrypted.
  DecryptError           : AlertDescription
  ||| The protocol version is not supported.
  ProtocolVersion        : AlertDescription
  ||| The server requires stronger security.
  InsufficientSecurity   : AlertDescription
  ||| An internal error occurred.
  InternalError          : AlertDescription
  ||| An inappropriate fallback was detected.
  InappropriateFallback  : AlertDescription
  ||| A required extension is missing.
  MissingExtension       : AlertDescription
  ||| An unsupported extension was received.
  UnsupportedExtension   : AlertDescription
  ||| The server name was not recognised.
  UnrecognizedName       : AlertDescription
  ||| A client certificate is required.
  CertificateRequired    : AlertDescription
  ||| No application protocol could be negotiated.
  NoApplicationProtocol  : AlertDescription

public export
Show AlertDescription where
  show CloseNotify            = "CloseNotify"
  show UnexpectedMessage      = "UnexpectedMessage"
  show BadRecordMAC           = "BadRecordMAC"
  show DecryptionFailed       = "DecryptionFailed"
  show RecordOverflow         = "RecordOverflow"
  show HandshakeFailure       = "HandshakeFailure"
  show BadCertificate         = "BadCertificate"
  show UnsupportedCertificate = "UnsupportedCertificate"
  show CertificateRevoked     = "CertificateRevoked"
  show CertificateExpired     = "CertificateExpired"
  show CertificateUnknown     = "CertificateUnknown"
  show IllegalParameter       = "IllegalParameter"
  show UnknownCA              = "UnknownCA"
  show AccessDenied           = "AccessDenied"
  show DecodeError            = "DecodeError"
  show DecryptError           = "DecryptError"
  show ProtocolVersion        = "ProtocolVersion"
  show InsufficientSecurity   = "InsufficientSecurity"
  show InternalError          = "InternalError"
  show InappropriateFallback  = "InappropriateFallback"
  show MissingExtension       = "MissingExtension"
  show UnsupportedExtension   = "UnsupportedExtension"
  show UnrecognizedName       = "UnrecognizedName"
  show CertificateRequired    = "CertificateRequired"
  show NoApplicationProtocol  = "NoApplicationProtocol"
