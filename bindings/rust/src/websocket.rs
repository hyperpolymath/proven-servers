// SPDX-License-Identifier: MPL-2.0
// Copyright (c) Jonathan D.A. Jewell <j.d.a.jewell@open.ac.uk>
//
//! WebSocket protocol types for the proven-servers ABI.
//!
//! Mirrors the Idris2 modules:
//! - `WS.Opcode`    — frame opcodes (RFC 6455 Section 5.2)
//! - `WS.CloseCode` — close status codes (RFC 6455 Section 7.4)
//! - `WS.Frame`     — frame structure and validation
//!
//! All numeric encodings match the wire values from RFC 6455.

use std::fmt;

// ===========================================================================
// Opcode (WS.Opcode, RFC 6455 Section 5.2)
// ===========================================================================

/// WebSocket frame opcodes (RFC 6455 Section 11.8).
///
/// Matches the `Opcode` type in `WS.Opcode`.
/// Discriminant values are the 4-bit wire values from the spec.
#[derive(Debug, Clone, Copy, PartialEq, Eq, Hash)]
#[repr(u8)]
pub enum Opcode {
    /// 0x0 -- Continuation frame (follows a fragmented message).
    Continuation = 0x0,
    /// 0x1 -- Text frame (payload is UTF-8 encoded text).
    Text = 0x1,
    /// 0x2 -- Binary frame (payload is arbitrary binary data).
    Binary = 0x2,
    /// 0x8 -- Close frame (initiates or acknowledges connection close).
    Close = 0x8,
    /// 0x9 -- Ping frame (heartbeat request).
    Ping = 0x9,
    /// 0xA -- Pong frame (heartbeat response).
    Pong = 0xA,
}

impl Opcode {
    /// Parse a 4-bit nibble to an opcode.
    ///
    /// Returns `None` for reserved opcodes (0x3-0x7, 0xB-0xF),
    /// matching `opcodeFromNibble` in `WS.Opcode`.
    pub fn from_nibble(nibble: u8) -> Option<Self> {
        match nibble {
            0x0 => Some(Self::Continuation),
            0x1 => Some(Self::Text),
            0x2 => Some(Self::Binary),
            0x8 => Some(Self::Close),
            0x9 => Some(Self::Ping),
            0xA => Some(Self::Pong),
            _ => None,
        }
    }

    /// Convert to the 4-bit wire value.
    ///
    /// Matches `opcodeToNibble` in `WS.Opcode`.
    pub fn to_nibble(self) -> u8 {
        self as u8
    }

    /// Whether this is a data opcode (Continuation, Text, Binary).
    ///
    /// Data opcodes carry application payload and can be fragmented.
    /// Matches `isData` in `WS.Opcode`.
    pub fn is_data(self) -> bool {
        matches!(self, Self::Continuation | Self::Text | Self::Binary)
    }

    /// Whether this is a control opcode (Close, Ping, Pong).
    ///
    /// Control frames MUST NOT be fragmented and MUST have a payload
    /// length of 125 bytes or less (RFC 6455 Section 5.5).
    /// Matches `isControl` in `WS.Opcode`.
    pub fn is_control(self) -> bool {
        !self.is_data()
    }

    /// Whether this opcode begins a new message (Text or Binary).
    ///
    /// Matches `isMessageStart` in `WS.Opcode`.
    pub fn is_message_start(self) -> bool {
        matches!(self, Self::Text | Self::Binary)
    }

    /// Whether this opcode requires a mandatory response.
    ///
    /// Ping frames MUST be responded to with Pong.
    /// Close frames MUST be responded to with Close.
    /// Matches `requiresResponse` in `WS.Opcode`.
    pub fn requires_response(self) -> bool {
        matches!(self, Self::Ping | Self::Close)
    }

    /// Human-readable name for the opcode.
    ///
    /// Matches `opcodeName` in `WS.Opcode`.
    pub fn name(self) -> &'static str {
        match self {
            Self::Continuation => "continuation",
            Self::Text => "text",
            Self::Binary => "binary",
            Self::Close => "close",
            Self::Ping => "ping",
            Self::Pong => "pong",
        }
    }
}

impl fmt::Display for Opcode {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        write!(f, "{}(0x{:X})", self.name(), self.to_nibble())
    }
}

// ===========================================================================
// Close Code (WS.CloseCode, RFC 6455 Section 7.4)
// ===========================================================================

/// WebSocket close status codes (RFC 6455 Section 7.4.1).
///
/// Matches the `CloseCode` type in `WS.CloseCode`.
/// Discriminant values are the 16-bit wire values.
#[derive(Debug, Clone, Copy, PartialEq, Eq, Hash)]
#[repr(u16)]
pub enum CloseCode {
    /// 1000 -- Normal closure.
    Normal = 1000,
    /// 1001 -- Endpoint is going away.
    GoingAway = 1001,
    /// 1002 -- Protocol error.
    ProtocolError = 1002,
    /// 1003 -- Unsupported data type received.
    UnsupportedData = 1003,
    /// 1005 -- No status code present (internal only, MUST NOT be sent).
    NoStatus = 1005,
    /// 1006 -- Abnormal closure (internal only, MUST NOT be sent).
    Abnormal = 1006,
    /// 1007 -- Invalid payload data (e.g. non-UTF-8 in text message).
    InvalidPayload = 1007,
    /// 1008 -- Policy violation.
    PolicyViolation = 1008,
    /// 1009 -- Message too big.
    MessageTooBig = 1009,
    /// 1010 -- Mandatory extension missing.
    MandatoryExtension = 1010,
    /// 1011 -- Internal server error.
    InternalError = 1011,
}

impl CloseCode {
    /// Parse a 16-bit wire value to a close code.
    ///
    /// Returns `None` for unrecognised codes, matching
    /// `closeCodeFromWord` in `WS.CloseCode`.
    pub fn from_wire(code: u16) -> Option<Self> {
        match code {
            1000 => Some(Self::Normal),
            1001 => Some(Self::GoingAway),
            1002 => Some(Self::ProtocolError),
            1003 => Some(Self::UnsupportedData),
            1005 => Some(Self::NoStatus),
            1006 => Some(Self::Abnormal),
            1007 => Some(Self::InvalidPayload),
            1008 => Some(Self::PolicyViolation),
            1009 => Some(Self::MessageTooBig),
            1010 => Some(Self::MandatoryExtension),
            1011 => Some(Self::InternalError),
            _ => None,
        }
    }

    /// Convert to the 16-bit wire value.
    ///
    /// Matches `closeCodeToWord` in `WS.CloseCode`.
    pub fn to_wire(self) -> u16 {
        self as u16
    }

    /// Whether this represents a normal (clean) closure.
    ///
    /// Matches `isNormalClose` in `WS.CloseCode`.
    pub fn is_normal(self) -> bool {
        matches!(self, Self::Normal | Self::GoingAway)
    }

    /// Whether this represents an error condition.
    ///
    /// Matches `isErrorClose` in `WS.CloseCode`.
    pub fn is_error(self) -> bool {
        !self.is_normal() && self != Self::NoStatus
    }

    /// Whether this code may be sent in a Close frame.
    ///
    /// Codes 1005 (NoStatus) and 1006 (Abnormal) are internal-only
    /// and MUST NOT appear on the wire.
    /// Matches `isSendable` in `WS.CloseCode`.
    pub fn is_sendable(self) -> bool {
        !matches!(self, Self::NoStatus | Self::Abnormal)
    }

    /// Human-readable description.
    ///
    /// Matches `closeReason` in `WS.CloseCode`.
    pub fn reason(self) -> &'static str {
        match self {
            Self::Normal => "Normal closure",
            Self::GoingAway => "Endpoint going away",
            Self::ProtocolError => "Protocol error",
            Self::UnsupportedData => "Unsupported data type",
            Self::NoStatus => "No status code present",
            Self::Abnormal => "Abnormal closure (no close frame)",
            Self::InvalidPayload => "Invalid payload data",
            Self::PolicyViolation => "Policy violation",
            Self::MessageTooBig => "Message too big",
            Self::MandatoryExtension => "Mandatory extension missing",
            Self::InternalError => "Internal server error",
        }
    }

    /// Check if a raw 16-bit value is in the application-use range
    /// (4000-4999, RFC 6455 Section 7.4.2).
    ///
    /// Matches `isApplicationCode` in `WS.CloseCode`.
    pub fn is_application_code(code: u16) -> bool {
        (4000..=4999).contains(&code)
    }

    /// Check if a raw 16-bit value is in the private-use range
    /// (3000-3999, reserved for libraries/frameworks).
    ///
    /// Matches `isPrivateCode` in `WS.CloseCode`.
    pub fn is_private_code(code: u16) -> bool {
        (3000..=3999).contains(&code)
    }
}

impl fmt::Display for CloseCode {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        write!(f, "{} ({})", self.reason(), self.to_wire())
    }
}

// ===========================================================================
// Frame (WS.Frame)
// ===========================================================================

/// Maximum payload size for control frames (RFC 6455 Section 5.5).
///
/// Matches `maxControlPayload` in `WS.Frame`.
pub const MAX_CONTROL_PAYLOAD: usize = 125;

/// A parsed WebSocket frame with all header fields and payload.
///
/// Mirrors the `Frame` record in `WS.Frame`.
#[derive(Debug, Clone, PartialEq, Eq)]
pub struct Frame {
    /// FIN bit -- true if this is the final fragment of a message.
    pub fin: bool,
    /// Opcode identifying the frame type.
    pub opcode: Opcode,
    /// MASK bit -- true if payload is XOR-masked (required from clients).
    pub masked: bool,
    /// Payload length in bytes.
    pub payload_length: usize,
    /// 4-byte masking key (present only if masked is true).
    pub masking_key: Option<[u8; 4]>,
    /// Payload data (unmasked).
    pub payload: Vec<u8>,
}

/// Errors detected during frame validation.
///
/// Matches the `FrameError` type in `WS.Frame`.
#[derive(Debug, Clone, PartialEq, Eq)]
pub enum FrameError {
    /// Control frame exceeds 125-byte payload limit.
    ControlFrameTooLarge { opcode: Opcode, size: usize },
    /// Control frame is fragmented (FIN bit not set).
    ControlFrameFragmented { opcode: Opcode },
    /// Client frame is not masked (RFC 6455 Section 5.1).
    ClientFrameNotMasked,
    /// Server frame is masked (servers MUST NOT mask).
    ServerFrameMasked,
    /// Payload exceeds maximum allowed frame size.
    PayloadTooLarge { size: usize, max_size: usize },
    /// Reserved opcode used.
    ReservedOpcode { nibble: u8 },
    /// Payload length and actual data mismatch.
    PayloadLengthMismatch { declared: usize, actual: usize },
}

impl fmt::Display for FrameError {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        match self {
            Self::ControlFrameTooLarge { opcode, size } => {
                write!(
                    f,
                    "Control frame {} payload too large: {} bytes (max {})",
                    opcode, size, MAX_CONTROL_PAYLOAD
                )
            }
            Self::ControlFrameFragmented { opcode } => {
                write!(f, "Control frame {} must not be fragmented", opcode)
            }
            Self::ClientFrameNotMasked => write!(f, "Client frame must be masked"),
            Self::ServerFrameMasked => write!(f, "Server frame must not be masked"),
            Self::PayloadTooLarge { size, max_size } => {
                write!(
                    f,
                    "Payload too large: {} bytes (max {})",
                    size, max_size
                )
            }
            Self::ReservedOpcode { nibble } => {
                write!(f, "Reserved opcode: 0x{:X}", nibble)
            }
            Self::PayloadLengthMismatch { declared, actual } => {
                write!(
                    f,
                    "Payload length mismatch: declared {}, actual {}",
                    declared, actual
                )
            }
        }
    }
}

impl std::error::Error for FrameError {}

impl Frame {
    /// Validate a frame received from a client.
    ///
    /// Checks: masking required, control frame size and fragmentation,
    /// payload length consistency.
    /// Matches `validateClientFrame` in `WS.Frame`.
    pub fn validate_client_frame(&self, max_frame_size: usize) -> Result<(), FrameError> {
        if !self.masked {
            return Err(FrameError::ClientFrameNotMasked);
        }
        self.validate_common(max_frame_size)
    }

    /// Validate a frame received from a server.
    ///
    /// Server frames MUST NOT be masked (RFC 6455 Section 5.1).
    /// Matches `validateServerFrame` in `WS.Frame`.
    pub fn validate_server_frame(&self, max_frame_size: usize) -> Result<(), FrameError> {
        if self.masked {
            return Err(FrameError::ServerFrameMasked);
        }
        self.validate_common(max_frame_size)
    }

    /// Common validation shared between client and server frames.
    fn validate_common(&self, max_frame_size: usize) -> Result<(), FrameError> {
        if self.opcode.is_control() && self.payload_length > MAX_CONTROL_PAYLOAD {
            return Err(FrameError::ControlFrameTooLarge {
                opcode: self.opcode,
                size: self.payload_length,
            });
        }
        if self.opcode.is_control() && !self.fin {
            return Err(FrameError::ControlFrameFragmented {
                opcode: self.opcode,
            });
        }
        if self.payload_length > max_frame_size {
            return Err(FrameError::PayloadTooLarge {
                size: self.payload_length,
                max_size: max_frame_size,
            });
        }
        if self.payload_length != self.payload.len() {
            return Err(FrameError::PayloadLengthMismatch {
                declared: self.payload_length,
                actual: self.payload.len(),
            });
        }
        Ok(())
    }

    /// Build a server-to-client text frame (unmasked, FIN set).
    ///
    /// Matches `makeTextFrame` in `WS.Frame`.
    pub fn text(payload: Vec<u8>) -> Self {
        let len = payload.len();
        Self {
            fin: true,
            opcode: Opcode::Text,
            masked: false,
            payload_length: len,
            masking_key: None,
            payload,
        }
    }

    /// Build a server-to-client binary frame (unmasked, FIN set).
    ///
    /// Matches `makeBinaryFrame` in `WS.Frame`.
    pub fn binary(payload: Vec<u8>) -> Self {
        let len = payload.len();
        Self {
            fin: true,
            opcode: Opcode::Binary,
            masked: false,
            payload_length: len,
            masking_key: None,
            payload,
        }
    }

    /// Build a Pong frame echoing a Ping's payload.
    ///
    /// Matches `makePongFrame` in `WS.Frame`.
    pub fn pong(ping_payload: Vec<u8>) -> Self {
        let len = ping_payload.len();
        Self {
            fin: true,
            opcode: Opcode::Pong,
            masked: false,
            payload_length: len,
            masking_key: None,
            payload: ping_payload,
        }
    }

    /// Build a Ping frame with optional payload.
    ///
    /// Matches `makePingFrame` in `WS.Frame`.
    pub fn ping(payload: Vec<u8>) -> Self {
        let len = payload.len();
        Self {
            fin: true,
            opcode: Opcode::Ping,
            masked: false,
            payload_length: len,
            masking_key: None,
            payload,
        }
    }

    /// Build a Close frame with an optional status code and reason.
    ///
    /// Matches `makeCloseFrame` in `WS.Frame`.
    pub fn close(status_code: Option<u16>, reason: &[u8]) -> Self {
        let mut payload = Vec::new();
        if let Some(code) = status_code {
            payload.push((code >> 8) as u8);
            payload.push((code & 0xFF) as u8);
        }
        payload.extend_from_slice(reason);
        let len = payload.len();
        Self {
            fin: true,
            opcode: Opcode::Close,
            masked: false,
            payload_length: len,
            masking_key: None,
            payload,
        }
    }
}

impl fmt::Display for Frame {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        write!(
            f,
            "Frame({} {} {} len={})",
            if self.fin { "FIN" } else { "..." },
            self.opcode,
            if self.masked { "MASKED" } else { "UNMASKED" },
            self.payload_length
        )
    }
}

// ===========================================================================
// Tests
// ===========================================================================

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn opcode_roundtrip() {
        let opcodes = [
            (0x0, Opcode::Continuation),
            (0x1, Opcode::Text),
            (0x2, Opcode::Binary),
            (0x8, Opcode::Close),
            (0x9, Opcode::Ping),
            (0xA, Opcode::Pong),
        ];
        for (nibble, expected) in opcodes {
            let decoded = Opcode::from_nibble(nibble).expect("valid nibble");
            assert_eq!(decoded, expected);
            assert_eq!(decoded.to_nibble(), nibble);
        }
    }

    #[test]
    fn opcode_reserved_rejected() {
        // Reserved opcodes 0x3-0x7 and 0xB-0xF should return None.
        for nibble in [0x3, 0x4, 0x5, 0x6, 0x7, 0xB, 0xC, 0xD, 0xE, 0xF] {
            assert!(Opcode::from_nibble(nibble).is_none());
        }
    }

    #[test]
    fn opcode_classification() {
        assert!(Opcode::Text.is_data());
        assert!(Opcode::Binary.is_data());
        assert!(Opcode::Continuation.is_data());
        assert!(!Opcode::Close.is_data());

        assert!(Opcode::Close.is_control());
        assert!(Opcode::Ping.is_control());
        assert!(Opcode::Pong.is_control());
        assert!(!Opcode::Text.is_control());

        assert!(Opcode::Text.is_message_start());
        assert!(Opcode::Binary.is_message_start());
        assert!(!Opcode::Continuation.is_message_start());

        assert!(Opcode::Ping.requires_response());
        assert!(Opcode::Close.requires_response());
        assert!(!Opcode::Text.requires_response());
    }

    #[test]
    fn close_code_roundtrip() {
        let codes = [1000, 1001, 1002, 1003, 1005, 1006, 1007, 1008, 1009, 1010, 1011];
        for wire in codes {
            let code = CloseCode::from_wire(wire).expect("valid code");
            assert_eq!(code.to_wire(), wire);
        }
    }

    #[test]
    fn close_code_unknown_rejected() {
        assert!(CloseCode::from_wire(1004).is_none());
        assert!(CloseCode::from_wire(999).is_none());
        assert!(CloseCode::from_wire(1012).is_none());
    }

    #[test]
    fn close_code_classification() {
        assert!(CloseCode::Normal.is_normal());
        assert!(CloseCode::GoingAway.is_normal());
        assert!(!CloseCode::ProtocolError.is_normal());

        assert!(CloseCode::ProtocolError.is_error());
        assert!(CloseCode::InternalError.is_error());
        assert!(!CloseCode::Normal.is_error());
        assert!(!CloseCode::NoStatus.is_error()); // NoStatus is not "error"

        assert!(CloseCode::Normal.is_sendable());
        assert!(!CloseCode::NoStatus.is_sendable());
        assert!(!CloseCode::Abnormal.is_sendable());
    }

    #[test]
    fn close_code_ranges() {
        assert!(CloseCode::is_application_code(4000));
        assert!(CloseCode::is_application_code(4999));
        assert!(!CloseCode::is_application_code(3999));
        assert!(!CloseCode::is_application_code(5000));

        assert!(CloseCode::is_private_code(3000));
        assert!(CloseCode::is_private_code(3999));
        assert!(!CloseCode::is_private_code(2999));
        assert!(!CloseCode::is_private_code(4000));
    }

    #[test]
    fn frame_text_construction() {
        let frame = Frame::text(b"hello".to_vec());
        assert!(frame.fin);
        assert_eq!(frame.opcode, Opcode::Text);
        assert!(!frame.masked);
        assert_eq!(frame.payload_length, 5);
        assert_eq!(frame.payload, b"hello");
    }

    #[test]
    fn frame_close_with_code() {
        let frame = Frame::close(Some(1000), b"bye");
        assert_eq!(frame.opcode, Opcode::Close);
        assert_eq!(frame.payload_length, 5); // 2 bytes code + 3 bytes reason
        assert_eq!(frame.payload[0], 0x03); // 1000 >> 8
        assert_eq!(frame.payload[1], 0xE8); // 1000 & 0xFF
    }

    #[test]
    fn frame_validate_client_unmasked() {
        let frame = Frame::text(b"hello".to_vec()); // unmasked
        let result = frame.validate_client_frame(65536);
        assert_eq!(result, Err(FrameError::ClientFrameNotMasked));
    }

    #[test]
    fn frame_validate_server_masked() {
        let mut frame = Frame::text(b"hello".to_vec());
        frame.masked = true;
        frame.masking_key = Some([0, 0, 0, 0]);
        let result = frame.validate_server_frame(65536);
        assert_eq!(result, Err(FrameError::ServerFrameMasked));
    }

    #[test]
    fn frame_validate_control_too_large() {
        let payload = vec![0u8; 126]; // Exceeds 125 limit
        let frame = Frame::ping(payload);
        let result = frame.validate_server_frame(65536);
        assert!(matches!(result, Err(FrameError::ControlFrameTooLarge { .. })));
    }

    #[test]
    fn frame_validate_control_fragmented() {
        let mut frame = Frame::ping(vec![1, 2, 3]);
        frame.fin = false; // Fragmented control frame
        let result = frame.validate_server_frame(65536);
        assert!(matches!(
            result,
            Err(FrameError::ControlFrameFragmented { .. })
        ));
    }
}
