//// SPDX-License-Identifier: MPL-2.0
//// (PMPL-1.0-or-later preferred; MPL-2.0 required for Gleam ecosystem)
//// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
////
//// WebSocket protocol types for the proven-servers ABI.
////
//// Mirrors the Idris2 modules:
//// - `WS.Opcode`    -- frame opcodes (RFC 6455 Section 5.2)
//// - `WS.CloseCode` -- close status codes (RFC 6455 Section 7.4)
//// - `WS.Frame`     -- frame structure and validation

// ===========================================================================
// Opcode (WS.Opcode, RFC 6455 Section 5.2)
// ===========================================================================

/// WebSocket frame opcodes (RFC 6455 Section 11.8).
///
/// Discriminant values are the 4-bit wire values from the spec.
pub type Opcode {
  /// 0x0 -- Continuation frame.
  Continuation
  /// 0x1 -- Text frame (UTF-8 payload).
  Text
  /// 0x2 -- Binary frame.
  Binary
  /// 0x8 -- Close frame.
  Close
  /// 0x9 -- Ping frame.
  Ping
  /// 0xA -- Pong frame.
  Pong
}

/// Convert an `Opcode` to its 4-bit wire value.
pub fn opcode_to_int(opcode: Opcode) -> Int {
  case opcode {
    Continuation -> 0x0
    Text -> 0x1
    Binary -> 0x2
    Close -> 0x8
    Ping -> 0x9
    Pong -> 0xA
  }
}

/// Parse a 4-bit nibble to an opcode.
///
/// Returns `Error(Nil)` for reserved opcodes (0x3-0x7, 0xB-0xF).
pub fn opcode_from_int(nibble: Int) -> Result(Opcode, Nil) {
  case nibble {
    0x0 -> Ok(Continuation)
    0x1 -> Ok(Text)
    0x2 -> Ok(Binary)
    0x8 -> Ok(Close)
    0x9 -> Ok(Ping)
    0xA -> Ok(Pong)
    _ -> Error(Nil)
  }
}

/// Whether this is a data opcode (Continuation, Text, Binary).
pub fn opcode_is_data(opcode: Opcode) -> Bool {
  case opcode {
    Continuation | Text | Binary -> True
    _ -> False
  }
}

/// Whether this is a control opcode (Close, Ping, Pong).
///
/// Control frames MUST NOT be fragmented and MUST have payload <= 125 bytes.
pub fn opcode_is_control(opcode: Opcode) -> Bool {
  !opcode_is_data(opcode)
}

/// Whether this opcode begins a new message (Text or Binary).
pub fn opcode_is_message_start(opcode: Opcode) -> Bool {
  case opcode {
    Text | Binary -> True
    _ -> False
  }
}

/// Whether this opcode requires a mandatory response.
///
/// Ping -> must respond with Pong. Close -> must respond with Close.
pub fn opcode_requires_response(opcode: Opcode) -> Bool {
  case opcode {
    Ping | Close -> True
    _ -> False
  }
}

/// Human-readable name for the opcode.
pub fn opcode_name(opcode: Opcode) -> String {
  case opcode {
    Continuation -> "continuation"
    Text -> "text"
    Binary -> "binary"
    Close -> "close"
    Ping -> "ping"
    Pong -> "pong"
  }
}

// ===========================================================================
// Close Code (WS.CloseCode, RFC 6455 Section 7.4)
// ===========================================================================

/// WebSocket close status codes (RFC 6455 Section 7.4.1).
pub type CloseCode {
  /// 1000 -- Normal closure.
  Normal
  /// 1001 -- Endpoint is going away.
  GoingAway
  /// 1002 -- Protocol error.
  ProtocolError
  /// 1003 -- Unsupported data type received.
  UnsupportedData
  /// 1005 -- No status code present (internal only, MUST NOT be sent).
  NoStatus
  /// 1006 -- Abnormal closure (internal only, MUST NOT be sent).
  Abnormal
  /// 1007 -- Invalid payload data.
  InvalidPayload
  /// 1008 -- Policy violation.
  PolicyViolation
  /// 1009 -- Message too big.
  MessageTooBig
  /// 1010 -- Mandatory extension missing.
  MandatoryExtension
  /// 1011 -- Internal server error.
  InternalError
}

/// Convert a `CloseCode` to its 16-bit wire value.
pub fn close_code_to_int(code: CloseCode) -> Int {
  case code {
    Normal -> 1000
    GoingAway -> 1001
    ProtocolError -> 1002
    UnsupportedData -> 1003
    NoStatus -> 1005
    Abnormal -> 1006
    InvalidPayload -> 1007
    PolicyViolation -> 1008
    MessageTooBig -> 1009
    MandatoryExtension -> 1010
    InternalError -> 1011
  }
}

/// Parse a 16-bit wire value to a close code.
pub fn close_code_from_int(code: Int) -> Result(CloseCode, Nil) {
  case code {
    1000 -> Ok(Normal)
    1001 -> Ok(GoingAway)
    1002 -> Ok(ProtocolError)
    1003 -> Ok(UnsupportedData)
    1005 -> Ok(NoStatus)
    1006 -> Ok(Abnormal)
    1007 -> Ok(InvalidPayload)
    1008 -> Ok(PolicyViolation)
    1009 -> Ok(MessageTooBig)
    1010 -> Ok(MandatoryExtension)
    1011 -> Ok(InternalError)
    _ -> Error(Nil)
  }
}

/// Whether this represents a normal (clean) closure.
pub fn close_code_is_normal(code: CloseCode) -> Bool {
  case code {
    Normal | GoingAway -> True
    _ -> False
  }
}

/// Whether this represents an error condition.
pub fn close_code_is_error(code: CloseCode) -> Bool {
  case code {
    Normal | GoingAway | NoStatus -> False
    _ -> True
  }
}

/// Whether this code may be sent in a Close frame.
///
/// Codes 1005 (NoStatus) and 1006 (Abnormal) are internal-only.
pub fn close_code_is_sendable(code: CloseCode) -> Bool {
  case code {
    NoStatus | Abnormal -> False
    _ -> True
  }
}

/// Human-readable description.
pub fn close_code_reason(code: CloseCode) -> String {
  case code {
    Normal -> "Normal closure"
    GoingAway -> "Endpoint going away"
    ProtocolError -> "Protocol error"
    UnsupportedData -> "Unsupported data type"
    NoStatus -> "No status code present"
    Abnormal -> "Abnormal closure (no close frame)"
    InvalidPayload -> "Invalid payload data"
    PolicyViolation -> "Policy violation"
    MessageTooBig -> "Message too big"
    MandatoryExtension -> "Mandatory extension missing"
    InternalError -> "Internal server error"
  }
}

/// Check if a raw 16-bit value is in the application-use range (4000-4999).
pub fn is_application_code(code: Int) -> Bool {
  code >= 4000 && code <= 4999
}

/// Check if a raw 16-bit value is in the private-use range (3000-3999).
pub fn is_private_code(code: Int) -> Bool {
  code >= 3000 && code <= 3999
}

// ===========================================================================
// Frame validation (WS.Frame)
// ===========================================================================

/// Maximum payload size for control frames (RFC 6455 Section 5.5).
pub const max_control_payload = 125

/// Errors detected during frame validation.
pub type FrameError {
  /// Control frame exceeds 125-byte payload limit.
  ControlFrameTooLarge(opcode: Opcode, size: Int)
  /// Control frame is fragmented (FIN bit not set).
  ControlFrameFragmented(opcode: Opcode)
  /// Client frame is not masked (RFC 6455 Section 5.1).
  ClientFrameNotMasked
  /// Server frame is masked (servers MUST NOT mask).
  ServerFrameMasked
  /// Payload exceeds maximum allowed frame size.
  PayloadTooLarge(size: Int, max_size: Int)
}

/// A parsed WebSocket frame with header fields.
pub type Frame {
  Frame(
    /// FIN bit -- True if this is the final fragment.
    fin: Bool,
    /// Opcode identifying the frame type.
    opcode: Opcode,
    /// MASK bit -- True if payload is XOR-masked.
    masked: Bool,
    /// Payload length in bytes.
    payload_length: Int,
  )
}

/// Validate a frame received from a client.
///
/// Checks: masking required, control frame size and fragmentation.
pub fn validate_client_frame(
  frame: Frame,
  max_frame_size: Int,
) -> Result(Nil, FrameError) {
  case frame.masked {
    False -> Error(ClientFrameNotMasked)
    True -> validate_common(frame, max_frame_size)
  }
}

/// Validate a frame received from a server.
///
/// Server frames MUST NOT be masked.
pub fn validate_server_frame(
  frame: Frame,
  max_frame_size: Int,
) -> Result(Nil, FrameError) {
  case frame.masked {
    True -> Error(ServerFrameMasked)
    False -> validate_common(frame, max_frame_size)
  }
}

/// Common validation shared between client and server frames.
fn validate_common(frame: Frame, max_frame_size: Int) -> Result(Nil, FrameError) {
  case opcode_is_control(frame.opcode), frame.payload_length > max_control_payload {
    True, True ->
      Error(ControlFrameTooLarge(
        opcode: frame.opcode,
        size: frame.payload_length,
      ))
    True, False ->
      case frame.fin {
        False -> Error(ControlFrameFragmented(opcode: frame.opcode))
        True ->
          case frame.payload_length > max_frame_size {
            True ->
              Error(PayloadTooLarge(
                size: frame.payload_length,
                max_size: max_frame_size,
              ))
            False -> Ok(Nil)
          }
      }
    False, _ ->
      case frame.payload_length > max_frame_size {
        True ->
          Error(PayloadTooLarge(
            size: frame.payload_length,
            max_size: max_frame_size,
          ))
        False -> Ok(Nil)
      }
  }
}
