//// SPDX-License-Identifier: MPL-2.0
//// (PMPL-1.0-or-later preferred; MPL-2.0 required for Gleam ecosystem)
//// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
////
//// TLS protocol types for the proven-servers ABI.
////
//// Models TLS 1.2 and 1.3 protocol types based on RFC 8446 (TLS 1.3)
//// and RFC 5246 (TLS 1.2). Tag values are provisional pending Idris2
//// ABI formalisation.
////
//// Types covered:
//// - TLS versions
//// - Handshake message types
//// - Cipher suites (TLS 1.3 only)
//// - Alert levels and descriptions
//// - Handshake state machine

import gleam/option.{type Option, None, Some}

// ===========================================================================
// TLS Constants
// ===========================================================================

/// Standard HTTPS port.
pub const https_port = 443

/// Maximum TLS record size in bytes (RFC 8446 Section 5.1).
pub const max_record_size = 16_384

/// Maximum TLS record size with padding (RFC 8446 Section 5.4).
pub const max_record_size_with_padding = 16_640

// ===========================================================================
// TlsVersion (provisional tags 0-3)
// ===========================================================================

/// TLS protocol versions.
pub type TlsVersion {
  Tls10
  Tls11
  Tls12
  Tls13
}

/// Convert a `TlsVersion` to its C-ABI tag value.
pub fn version_to_int(version: TlsVersion) -> Int {
  case version {
    Tls10 -> 0
    Tls11 -> 1
    Tls12 -> 2
    Tls13 -> 3
  }
}

/// Decode from a C-ABI tag value.
pub fn version_from_int(tag: Int) -> Result(TlsVersion, Nil) {
  case tag {
    0 -> Ok(Tls10)
    1 -> Ok(Tls11)
    2 -> Ok(Tls12)
    3 -> Ok(Tls13)
    _ -> Error(Nil)
  }
}

/// TLS wire protocol version bytes (major.minor as u16).
pub fn version_wire_value(version: TlsVersion) -> Int {
  case version {
    Tls10 -> 0x0301
    Tls11 -> 0x0302
    Tls12 -> 0x0303
    Tls13 -> 0x0304
  }
}

/// Human-readable version string.
pub fn version_to_string(version: TlsVersion) -> String {
  case version {
    Tls10 -> "TLS 1.0"
    Tls11 -> "TLS 1.1"
    Tls12 -> "TLS 1.2"
    Tls13 -> "TLS 1.3"
  }
}

/// Whether this version is considered secure (TLS 1.2+ per RFC 8996).
pub fn version_is_secure(version: TlsVersion) -> Bool {
  case version {
    Tls12 | Tls13 -> True
    _ -> False
  }
}

// ===========================================================================
// HandshakeType (RFC 8446 Section 4, provisional tags 0-10)
// ===========================================================================

/// TLS handshake message types (RFC 8446 Section 4).
pub type HandshakeType {
  ClientHello
  ServerHello
  NewSessionTicket
  EndOfEarlyData
  EncryptedExtensions
  TlsCertificate
  CertificateRequest
  CertificateVerify
  Finished
  KeyUpdate
  MessageHash
}

/// Convert a `HandshakeType` to its C-ABI tag value.
pub fn handshake_type_to_int(ht: HandshakeType) -> Int {
  case ht {
    ClientHello -> 0
    ServerHello -> 1
    NewSessionTicket -> 2
    EndOfEarlyData -> 3
    EncryptedExtensions -> 4
    TlsCertificate -> 5
    CertificateRequest -> 6
    CertificateVerify -> 7
    Finished -> 8
    KeyUpdate -> 9
    MessageHash -> 10
  }
}

/// Decode from a C-ABI tag value.
pub fn handshake_type_from_int(tag: Int) -> Result(HandshakeType, Nil) {
  case tag {
    0 -> Ok(ClientHello)
    1 -> Ok(ServerHello)
    2 -> Ok(NewSessionTicket)
    3 -> Ok(EndOfEarlyData)
    4 -> Ok(EncryptedExtensions)
    5 -> Ok(TlsCertificate)
    6 -> Ok(CertificateRequest)
    7 -> Ok(CertificateVerify)
    8 -> Ok(Finished)
    9 -> Ok(KeyUpdate)
    10 -> Ok(MessageHash)
    _ -> Error(Nil)
  }
}

/// RFC wire value for the handshake type.
pub fn handshake_type_wire_value(ht: HandshakeType) -> Int {
  case ht {
    ClientHello -> 1
    ServerHello -> 2
    NewSessionTicket -> 4
    EndOfEarlyData -> 5
    EncryptedExtensions -> 8
    TlsCertificate -> 11
    CertificateRequest -> 13
    CertificateVerify -> 15
    Finished -> 20
    KeyUpdate -> 24
    MessageHash -> 254
  }
}

/// Human-readable name.
pub fn handshake_type_name(ht: HandshakeType) -> String {
  case ht {
    ClientHello -> "ClientHello"
    ServerHello -> "ServerHello"
    NewSessionTicket -> "NewSessionTicket"
    EndOfEarlyData -> "EndOfEarlyData"
    EncryptedExtensions -> "EncryptedExtensions"
    TlsCertificate -> "Certificate"
    CertificateRequest -> "CertificateRequest"
    CertificateVerify -> "CertificateVerify"
    Finished -> "Finished"
    KeyUpdate -> "KeyUpdate"
    MessageHash -> "MessageHash"
  }
}

// ===========================================================================
// CipherSuite (TLS 1.3, provisional tags 0-4)
// ===========================================================================

/// TLS 1.3 cipher suites (RFC 8446 Section 9.1).
pub type CipherSuite {
  Aes128GcmSha256
  Aes256GcmSha384
  ChaCha20Poly1305Sha256
  Aes128CcmSha256
  Aes128Ccm8Sha256
}

/// Convert a `CipherSuite` to its C-ABI tag value.
pub fn cipher_suite_to_int(cs: CipherSuite) -> Int {
  case cs {
    Aes128GcmSha256 -> 0
    Aes256GcmSha384 -> 1
    ChaCha20Poly1305Sha256 -> 2
    Aes128CcmSha256 -> 3
    Aes128Ccm8Sha256 -> 4
  }
}

/// Decode from a C-ABI tag value.
pub fn cipher_suite_from_int(tag: Int) -> Result(CipherSuite, Nil) {
  case tag {
    0 -> Ok(Aes128GcmSha256)
    1 -> Ok(Aes256GcmSha384)
    2 -> Ok(ChaCha20Poly1305Sha256)
    3 -> Ok(Aes128CcmSha256)
    4 -> Ok(Aes128Ccm8Sha256)
    _ -> Error(Nil)
  }
}

/// IANA cipher suite value (RFC 8446 Appendix B.4).
pub fn cipher_suite_iana_value(cs: CipherSuite) -> Int {
  case cs {
    Aes128GcmSha256 -> 0x1301
    Aes256GcmSha384 -> 0x1302
    ChaCha20Poly1305Sha256 -> 0x1303
    Aes128CcmSha256 -> 0x1304
    Aes128Ccm8Sha256 -> 0x1305
  }
}

/// OpenSSL-style cipher suite name.
pub fn cipher_suite_name(cs: CipherSuite) -> String {
  case cs {
    Aes128GcmSha256 -> "TLS_AES_128_GCM_SHA256"
    Aes256GcmSha384 -> "TLS_AES_256_GCM_SHA384"
    ChaCha20Poly1305Sha256 -> "TLS_CHACHA20_POLY1305_SHA256"
    Aes128CcmSha256 -> "TLS_AES_128_CCM_SHA256"
    Aes128Ccm8Sha256 -> "TLS_AES_128_CCM_8_SHA256"
  }
}

// ===========================================================================
// AlertLevel (RFC 8446 Section 6, provisional tags 0-1)
// ===========================================================================

/// TLS alert levels (RFC 8446 Section 6.1).
pub type AlertLevel {
  Warning
  Fatal
}

/// Convert an `AlertLevel` to its C-ABI tag value.
pub fn alert_level_to_int(level: AlertLevel) -> Int {
  case level {
    Warning -> 0
    Fatal -> 1
  }
}

/// Decode from a C-ABI tag value.
pub fn alert_level_from_int(tag: Int) -> Result(AlertLevel, Nil) {
  case tag {
    0 -> Ok(Warning)
    1 -> Ok(Fatal)
    _ -> Error(Nil)
  }
}

/// TLS wire value.
pub fn alert_level_wire_value(level: AlertLevel) -> Int {
  case level {
    Warning -> 1
    Fatal -> 2
  }
}

// ===========================================================================
// AlertDescription (RFC 8446 Section 6.2, provisional tags 0-13)
// ===========================================================================

/// TLS alert descriptions (RFC 8446 Section 6.2, subset).
pub type AlertDescription {
  CloseNotify
  UnexpectedMessage
  BadRecordMac
  RecordOverflow
  HandshakeFailure
  BadCertificate
  UnsupportedCertificate
  CertificateRevoked
  CertificateExpired
  CertificateUnknown
  IllegalParameter
  DecodeAlertError
  DecryptError
  ProtocolVersion
}

/// Convert an `AlertDescription` to its C-ABI tag value.
pub fn alert_description_to_int(desc: AlertDescription) -> Int {
  case desc {
    CloseNotify -> 0
    UnexpectedMessage -> 1
    BadRecordMac -> 2
    RecordOverflow -> 3
    HandshakeFailure -> 4
    BadCertificate -> 5
    UnsupportedCertificate -> 6
    CertificateRevoked -> 7
    CertificateExpired -> 8
    CertificateUnknown -> 9
    IllegalParameter -> 10
    DecodeAlertError -> 11
    DecryptError -> 12
    ProtocolVersion -> 13
  }
}

/// Decode from a C-ABI tag value.
pub fn alert_description_from_int(tag: Int) -> Result(AlertDescription, Nil) {
  case tag {
    0 -> Ok(CloseNotify)
    1 -> Ok(UnexpectedMessage)
    2 -> Ok(BadRecordMac)
    3 -> Ok(RecordOverflow)
    4 -> Ok(HandshakeFailure)
    5 -> Ok(BadCertificate)
    6 -> Ok(UnsupportedCertificate)
    7 -> Ok(CertificateRevoked)
    8 -> Ok(CertificateExpired)
    9 -> Ok(CertificateUnknown)
    10 -> Ok(IllegalParameter)
    11 -> Ok(DecodeAlertError)
    12 -> Ok(DecryptError)
    13 -> Ok(ProtocolVersion)
    _ -> Error(Nil)
  }
}

/// Whether this alert is always fatal.
pub fn alert_description_is_fatal(desc: AlertDescription) -> Bool {
  case desc {
    CloseNotify -> False
    _ -> True
  }
}

/// Human-readable alert description.
pub fn alert_description_to_string(desc: AlertDescription) -> String {
  case desc {
    CloseNotify -> "close_notify"
    UnexpectedMessage -> "unexpected_message"
    BadRecordMac -> "bad_record_mac"
    RecordOverflow -> "record_overflow"
    HandshakeFailure -> "handshake_failure"
    BadCertificate -> "bad_certificate"
    UnsupportedCertificate -> "unsupported_certificate"
    CertificateRevoked -> "certificate_revoked"
    CertificateExpired -> "certificate_expired"
    CertificateUnknown -> "certificate_unknown"
    IllegalParameter -> "illegal_parameter"
    DecodeAlertError -> "decode_error"
    DecryptError -> "decrypt_error"
    ProtocolVersion -> "protocol_version"
  }
}

// ===========================================================================
// HandshakeState (provisional tags 0-6)
// ===========================================================================

/// TLS handshake lifecycle states (TLS 1.3 full handshake, RFC 8446 Section 2).
pub type HandshakeState {
  HsStart
  WaitServerHello
  WaitEncryptedExtensions
  WaitCertRequest
  WaitCert
  WaitFinished
  TlsConnected
}

/// Convert a `HandshakeState` to its C-ABI tag value.
pub fn handshake_state_to_int(state: HandshakeState) -> Int {
  case state {
    HsStart -> 0
    WaitServerHello -> 1
    WaitEncryptedExtensions -> 2
    WaitCertRequest -> 3
    WaitCert -> 4
    WaitFinished -> 5
    TlsConnected -> 6
  }
}

/// Decode from a C-ABI tag value.
pub fn handshake_state_from_int(tag: Int) -> Result(HandshakeState, Nil) {
  case tag {
    0 -> Ok(HsStart)
    1 -> Ok(WaitServerHello)
    2 -> Ok(WaitEncryptedExtensions)
    3 -> Ok(WaitCertRequest)
    4 -> Ok(WaitCert)
    5 -> Ok(WaitFinished)
    6 -> Ok(TlsConnected)
    _ -> Error(Nil)
  }
}

/// Whether application data can be sent in this state.
pub fn handshake_state_can_send_data(state: HandshakeState) -> Bool {
  state == TlsConnected
}

/// Named TLS handshake transitions.
pub type HandshakeTransition {
  SendClientHello
  ReceiveServerHello
  ReceiveEncryptedExtensions
  ReceiveCertRequest
  ReceiveCert
  ReceiveFinished
  SkipCertRequest
  SkipCert
}

/// Validate a TLS handshake state transition.
pub fn validate_handshake_transition(
  from: HandshakeState,
  to: HandshakeState,
) -> Option(HandshakeTransition) {
  case from, to {
    HsStart, WaitServerHello -> Some(SendClientHello)
    WaitServerHello, WaitEncryptedExtensions -> Some(ReceiveServerHello)
    WaitEncryptedExtensions, WaitCertRequest ->
      Some(ReceiveEncryptedExtensions)
    WaitCertRequest, WaitCert -> Some(ReceiveCertRequest)
    WaitCertRequest, WaitFinished -> Some(SkipCert)
    WaitCert, WaitFinished -> Some(ReceiveCert)
    WaitFinished, TlsConnected -> Some(ReceiveFinished)
    WaitEncryptedExtensions, WaitFinished -> Some(SkipCertRequest)
    _, _ -> None
  }
}
