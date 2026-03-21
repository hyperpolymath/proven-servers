// SPDX-License-Identifier: PMPL-1.0-or-later
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
// TLS protocol types for the proven-servers ABI.
//
// Models TLS 1.2 and 1.3 protocol types based on RFC 8446 (TLS 1.3)
// and RFC 5246 (TLS 1.2).  No dedicated proven-tls Idris2 module exists
// yet; these types anticipate the ABI that will be defined when the
// protocol is formalised.  Tag values are provisional and will be
// updated to match the Idris2 definitions once created.
//
// Types covered:
// - TLS versions
// - Handshake message types
// - Cipher suites (TLS 1.3 only, recommended set)
// - Alert levels and descriptions
// - Handshake state machine

// ===========================================================================
// TLS Version (provisional tags 0-3)
// ===========================================================================

/// TLS protocol versions.
/// Tag values are provisional pending Idris2 ABI definition.
type tlsVersion =
  | @as(0) Tls10
  | @as(1) Tls11
  | @as(2) Tls12
  | @as(3) Tls13

/// Decode from C-ABI tag value.
let tlsVersionFromTag = (tag: int): option<tlsVersion> =>
  switch tag {
  | 0 => Some(Tls10)
  | 1 => Some(Tls11)
  | 2 => Some(Tls12)
  | 3 => Some(Tls13)
  | _ => None
  }

/// Encode to C-ABI tag value.
let tlsVersionToTag = (v: tlsVersion): int =>
  switch v {
  | Tls10 => 0
  | Tls11 => 1
  | Tls12 => 2
  | Tls13 => 3
  }

/// TLS wire protocol version bytes (major.minor).
let tlsVersionWireValue = (v: tlsVersion): int =>
  switch v {
  | Tls10 => 0x0301
  | Tls11 => 0x0302
  | Tls12 => 0x0303
  | Tls13 => 0x0304
  }

/// Human-readable version string.
let tlsVersionAsStr = (v: tlsVersion): string =>
  switch v {
  | Tls10 => "TLS 1.0"
  | Tls11 => "TLS 1.1"
  | Tls12 => "TLS 1.2"
  | Tls13 => "TLS 1.3"
  }

/// Whether this version is considered secure (only TLS 1.2+ per
/// RFC 8996 which deprecates TLS 1.0 and 1.1).
let tlsVersionIsSecure = (v: tlsVersion): bool =>
  switch v {
  | Tls12 | Tls13 => true
  | Tls10 | Tls11 => false
  }

// ===========================================================================
// Handshake Type (RFC 8446 Section 4, provisional tags 0-10)
// ===========================================================================

/// TLS handshake message types (RFC 8446 Section 4).
type handshakeType =
  | @as(0) ClientHello
  | @as(1) ServerHello
  | @as(2) NewSessionTicket
  | @as(3) EndOfEarlyData
  | @as(4) EncryptedExtensions
  | @as(5) Certificate
  | @as(6) CertificateRequest
  | @as(7) CertificateVerify
  | @as(8) Finished
  | @as(9) KeyUpdate
  | @as(10) MessageHash

/// Decode from C-ABI tag value.
let handshakeTypeFromTag = (tag: int): option<handshakeType> =>
  switch tag {
  | 0 => Some(ClientHello)
  | 1 => Some(ServerHello)
  | 2 => Some(NewSessionTicket)
  | 3 => Some(EndOfEarlyData)
  | 4 => Some(EncryptedExtensions)
  | 5 => Some(Certificate)
  | 6 => Some(CertificateRequest)
  | 7 => Some(CertificateVerify)
  | 8 => Some(Finished)
  | 9 => Some(KeyUpdate)
  | 10 => Some(MessageHash)
  | _ => None
  }

/// Encode to C-ABI tag value.
let handshakeTypeToTag = (ht: handshakeType): int =>
  switch ht {
  | ClientHello => 0
  | ServerHello => 1
  | NewSessionTicket => 2
  | EndOfEarlyData => 3
  | EncryptedExtensions => 4
  | Certificate => 5
  | CertificateRequest => 6
  | CertificateVerify => 7
  | Finished => 8
  | KeyUpdate => 9
  | MessageHash => 10
  }

/// RFC wire value for the handshake type.
let handshakeTypeWireValue = (ht: handshakeType): int =>
  switch ht {
  | ClientHello => 1
  | ServerHello => 2
  | NewSessionTicket => 4
  | EndOfEarlyData => 5
  | EncryptedExtensions => 8
  | Certificate => 11
  | CertificateRequest => 13
  | CertificateVerify => 15
  | Finished => 20
  | KeyUpdate => 24
  | MessageHash => 254
  }

/// Human-readable name.
let handshakeTypeName = (ht: handshakeType): string =>
  switch ht {
  | ClientHello => "ClientHello"
  | ServerHello => "ServerHello"
  | NewSessionTicket => "NewSessionTicket"
  | EndOfEarlyData => "EndOfEarlyData"
  | EncryptedExtensions => "EncryptedExtensions"
  | Certificate => "Certificate"
  | CertificateRequest => "CertificateRequest"
  | CertificateVerify => "CertificateVerify"
  | Finished => "Finished"
  | KeyUpdate => "KeyUpdate"
  | MessageHash => "MessageHash"
  }

// ===========================================================================
// Cipher Suite (TLS 1.3 only, provisional tags 0-4)
// ===========================================================================

/// TLS 1.3 cipher suites (RFC 8446 Section 9.1).
type cipherSuite =
  | @as(0) Aes128GcmSha256
  | @as(1) Aes256GcmSha384
  | @as(2) ChaCha20Poly1305Sha256
  | @as(3) Aes128CcmSha256
  | @as(4) Aes128Ccm8Sha256

/// Decode from C-ABI tag value.
let cipherSuiteFromTag = (tag: int): option<cipherSuite> =>
  switch tag {
  | 0 => Some(Aes128GcmSha256)
  | 1 => Some(Aes256GcmSha384)
  | 2 => Some(ChaCha20Poly1305Sha256)
  | 3 => Some(Aes128CcmSha256)
  | 4 => Some(Aes128Ccm8Sha256)
  | _ => None
  }

/// Encode to C-ABI tag value.
let cipherSuiteToTag = (cs: cipherSuite): int =>
  switch cs {
  | Aes128GcmSha256 => 0
  | Aes256GcmSha384 => 1
  | ChaCha20Poly1305Sha256 => 2
  | Aes128CcmSha256 => 3
  | Aes128Ccm8Sha256 => 4
  }

/// IANA cipher suite value (RFC 8446 Appendix B.4).
let cipherSuiteIanaValue = (cs: cipherSuite): int =>
  switch cs {
  | Aes128GcmSha256 => 0x1301
  | Aes256GcmSha384 => 0x1302
  | ChaCha20Poly1305Sha256 => 0x1303
  | Aes128CcmSha256 => 0x1304
  | Aes128Ccm8Sha256 => 0x1305
  }

/// OpenSSL-style cipher suite name.
let cipherSuiteName = (cs: cipherSuite): string =>
  switch cs {
  | Aes128GcmSha256 => "TLS_AES_128_GCM_SHA256"
  | Aes256GcmSha384 => "TLS_AES_256_GCM_SHA384"
  | ChaCha20Poly1305Sha256 => "TLS_CHACHA20_POLY1305_SHA256"
  | Aes128CcmSha256 => "TLS_AES_128_CCM_SHA256"
  | Aes128Ccm8Sha256 => "TLS_AES_128_CCM_8_SHA256"
  }

// ===========================================================================
// Alert Level (RFC 8446 Section 6, provisional tags 0-1)
// ===========================================================================

/// TLS alert levels (RFC 8446 Section 6.1).
type alertLevel =
  | @as(0) Warning
  | @as(1) Fatal

/// Decode from C-ABI tag value.
let alertLevelFromTag = (tag: int): option<alertLevel> =>
  switch tag {
  | 0 => Some(Warning)
  | 1 => Some(Fatal)
  | _ => None
  }

/// Encode to C-ABI tag value.
let alertLevelToTag = (l: alertLevel): int =>
  switch l {
  | Warning => 0
  | Fatal => 1
  }

/// TLS wire value.
let alertLevelWireValue = (l: alertLevel): int =>
  switch l {
  | Warning => 1
  | Fatal => 2
  }

// ===========================================================================
// Alert Description (RFC 8446 Section 6.2, provisional tags 0-13)
// ===========================================================================

/// TLS alert descriptions (RFC 8446 Section 6.2, subset).
type alertDescription =
  | @as(0) CloseNotify
  | @as(1) UnexpectedMessage
  | @as(2) BadRecordMac
  | @as(3) RecordOverflow
  | @as(4) HandshakeFailure
  | @as(5) BadCertificate
  | @as(6) UnsupportedCertificate
  | @as(7) CertificateRevoked
  | @as(8) CertificateExpired
  | @as(9) CertificateUnknown
  | @as(10) IllegalParameter
  | @as(11) DecodeError
  | @as(12) DecryptError
  | @as(13) ProtocolVersion

/// Decode from C-ABI tag value.
let alertDescriptionFromTag = (tag: int): option<alertDescription> =>
  switch tag {
  | 0 => Some(CloseNotify)
  | 1 => Some(UnexpectedMessage)
  | 2 => Some(BadRecordMac)
  | 3 => Some(RecordOverflow)
  | 4 => Some(HandshakeFailure)
  | 5 => Some(BadCertificate)
  | 6 => Some(UnsupportedCertificate)
  | 7 => Some(CertificateRevoked)
  | 8 => Some(CertificateExpired)
  | 9 => Some(CertificateUnknown)
  | 10 => Some(IllegalParameter)
  | 11 => Some(DecodeError)
  | 12 => Some(DecryptError)
  | 13 => Some(ProtocolVersion)
  | _ => None
  }

/// Encode to C-ABI tag value.
let alertDescriptionToTag = (d: alertDescription): int =>
  switch d {
  | CloseNotify => 0
  | UnexpectedMessage => 1
  | BadRecordMac => 2
  | RecordOverflow => 3
  | HandshakeFailure => 4
  | BadCertificate => 5
  | UnsupportedCertificate => 6
  | CertificateRevoked => 7
  | CertificateExpired => 8
  | CertificateUnknown => 9
  | IllegalParameter => 10
  | DecodeError => 11
  | DecryptError => 12
  | ProtocolVersion => 13
  }

/// RFC wire value for the alert description.
let alertDescriptionWireValue = (d: alertDescription): int =>
  switch d {
  | CloseNotify => 0
  | UnexpectedMessage => 10
  | BadRecordMac => 20
  | RecordOverflow => 22
  | HandshakeFailure => 40
  | BadCertificate => 42
  | UnsupportedCertificate => 43
  | CertificateRevoked => 44
  | CertificateExpired => 45
  | CertificateUnknown => 46
  | IllegalParameter => 47
  | DecodeError => 50
  | DecryptError => 51
  | ProtocolVersion => 70
  }

/// Human-readable alert description.
let alertDescriptionAsStr = (d: alertDescription): string =>
  switch d {
  | CloseNotify => "close_notify"
  | UnexpectedMessage => "unexpected_message"
  | BadRecordMac => "bad_record_mac"
  | RecordOverflow => "record_overflow"
  | HandshakeFailure => "handshake_failure"
  | BadCertificate => "bad_certificate"
  | UnsupportedCertificate => "unsupported_certificate"
  | CertificateRevoked => "certificate_revoked"
  | CertificateExpired => "certificate_expired"
  | CertificateUnknown => "certificate_unknown"
  | IllegalParameter => "illegal_parameter"
  | DecodeError => "decode_error"
  | DecryptError => "decrypt_error"
  | ProtocolVersion => "protocol_version"
  }

/// Whether this alert is fatal.
let alertDescriptionIsFatal = (d: alertDescription): bool =>
  switch d {
  | CloseNotify => false
  | _ => true
  }

// ===========================================================================
// Handshake State (provisional tags 0-6)
// ===========================================================================

/// TLS handshake lifecycle states.
/// Models the TLS 1.3 full handshake flow (RFC 8446 Section 2).
type handshakeState =
  | @as(0) Start
  | @as(1) WaitServerHello
  | @as(2) WaitEncryptedExtensions
  | @as(3) WaitCertRequest
  | @as(4) WaitCert
  | @as(5) WaitFinished
  | @as(6) Connected

/// Decode from C-ABI tag value.
let handshakeStateFromTag = (tag: int): option<handshakeState> =>
  switch tag {
  | 0 => Some(Start)
  | 1 => Some(WaitServerHello)
  | 2 => Some(WaitEncryptedExtensions)
  | 3 => Some(WaitCertRequest)
  | 4 => Some(WaitCert)
  | 5 => Some(WaitFinished)
  | 6 => Some(Connected)
  | _ => None
  }

/// Encode to C-ABI tag value.
let handshakeStateToTag = (s: handshakeState): int =>
  switch s {
  | Start => 0
  | WaitServerHello => 1
  | WaitEncryptedExtensions => 2
  | WaitCertRequest => 3
  | WaitCert => 4
  | WaitFinished => 5
  | Connected => 6
  }

/// Whether application data can be sent in this state.
let handshakeStateCanSendData = (s: handshakeState): bool =>
  switch s {
  | Connected => true
  | _ => false
  }

/// Named TLS handshake transitions.
type handshakeTransition =
  | SendClientHello
  | ReceiveServerHello
  | ReceiveEncryptedExtensions
  | ReceiveCertRequest
  | ReceiveCert
  | ReceiveFinished
  | SkipCertRequest
  | SkipCert

/// Validate a TLS handshake state transition.
let validateHandshakeTransition = (
  from: handshakeState,
  to: handshakeState,
): option<handshakeTransition> =>
  switch (from, to) {
  | (Start, WaitServerHello) => Some(SendClientHello)
  | (WaitServerHello, WaitEncryptedExtensions) => Some(ReceiveServerHello)
  | (WaitEncryptedExtensions, WaitCertRequest) => Some(ReceiveEncryptedExtensions)
  | (WaitCertRequest, WaitCert) => Some(ReceiveCertRequest)
  | (WaitCertRequest, WaitFinished) => Some(SkipCert)
  | (WaitCert, WaitFinished) => Some(ReceiveCert)
  | (WaitFinished, Connected) => Some(ReceiveFinished)
  | (WaitEncryptedExtensions, WaitFinished) => Some(SkipCertRequest)
  | _ => None
  }

// ===========================================================================
// Constants
// ===========================================================================

/// Standard HTTPS port.
let httpsPort = 443

/// Maximum TLS record size in bytes (RFC 8446 Section 5.1).
let maxRecordSize = 16384

/// Maximum TLS record size with padding (RFC 8446 Section 5.4).
let maxRecordSizeWithPadding = 16640
