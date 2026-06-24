// SPDX-License-Identifier: MPL-2.0
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
// WebSocket protocol types for the proven-servers ABI.
//
// Mirrors the Idris2 modules:
// - WS.Opcode    -- frame opcodes (RFC 6455 Section 5.2)
// - WS.CloseCode -- close status codes (RFC 6455 Section 7.4)
// - WS.Frame     -- frame structure and validation
//
// All numeric encodings match the wire values from RFC 6455.

// ===========================================================================
// Opcode (WS.Opcode, RFC 6455 Section 5.2)
// ===========================================================================

/// WebSocket frame opcodes (RFC 6455 Section 11.8).
/// Matches the Opcode type in WS.Opcode.
/// Discriminant values are the 4-bit wire values from the spec.
type opcode =
  | @as(0x0) Continuation
  | @as(0x1) Text
  | @as(0x2) Binary
  | @as(0x8) Close
  | @as(0x9) Ping
  | @as(0xA) Pong

/// Parse a 4-bit nibble to an opcode.
/// Returns None for reserved opcodes (0x3-0x7, 0xB-0xF),
/// matching opcodeFromNibble in WS.Opcode.
let opcodeFromNibble = (nibble: int): option<opcode> =>
  switch nibble {
  | 0x0 => Some(Continuation)
  | 0x1 => Some(Text)
  | 0x2 => Some(Binary)
  | 0x8 => Some(Close)
  | 0x9 => Some(Ping)
  | 0xA => Some(Pong)
  | _ => None
  }

/// Convert to the 4-bit wire value.
/// Matches opcodeToNibble in WS.Opcode.
let opcodeToNibble = (op: opcode): int =>
  switch op {
  | Continuation => 0x0
  | Text => 0x1
  | Binary => 0x2
  | Close => 0x8
  | Ping => 0x9
  | Pong => 0xA
  }

/// Whether this is a data opcode (Continuation, Text, Binary).
/// Matches isData in WS.Opcode.
let opcodeIsData = (op: opcode): bool =>
  switch op {
  | Continuation | Text | Binary => true
  | Close | Ping | Pong => false
  }

/// Whether this is a control opcode (Close, Ping, Pong).
/// Control frames MUST NOT be fragmented and MUST have payload <= 125 bytes.
/// Matches isControl in WS.Opcode.
let opcodeIsControl = (op: opcode): bool => !opcodeIsData(op)

/// Whether this opcode begins a new message (Text or Binary).
/// Matches isMessageStart in WS.Opcode.
let opcodeIsMessageStart = (op: opcode): bool =>
  switch op {
  | Text | Binary => true
  | Continuation | Close | Ping | Pong => false
  }

/// Whether this opcode requires a mandatory response.
/// Ping -> Pong, Close -> Close.
/// Matches requiresResponse in WS.Opcode.
let opcodeRequiresResponse = (op: opcode): bool =>
  switch op {
  | Ping | Close => true
  | Continuation | Text | Binary | Pong => false
  }

/// Human-readable name for the opcode.
/// Matches opcodeName in WS.Opcode.
let opcodeName = (op: opcode): string =>
  switch op {
  | Continuation => "continuation"
  | Text => "text"
  | Binary => "binary"
  | Close => "close"
  | Ping => "ping"
  | Pong => "pong"
  }

// ===========================================================================
// Close Code (WS.CloseCode, RFC 6455 Section 7.4)
// ===========================================================================

/// WebSocket close status codes (RFC 6455 Section 7.4.1).
/// Matches the CloseCode type in WS.CloseCode.
/// Discriminant values are the 16-bit wire values.
type closeCode =
  | @as(1000) Normal
  | @as(1001) GoingAway
  | @as(1002) ProtocolError
  | @as(1003) UnsupportedData
  | @as(1005) NoStatus
  | @as(1006) Abnormal
  | @as(1007) InvalidPayload
  | @as(1008) PolicyViolation
  | @as(1009) MessageTooBig
  | @as(1010) MandatoryExtension
  | @as(1011) InternalError

/// Parse a 16-bit wire value to a close code.
/// Returns None for unrecognised codes, matching closeCodeFromWord in WS.CloseCode.
let closeCodeFromWire = (code: int): option<closeCode> =>
  switch code {
  | 1000 => Some(Normal)
  | 1001 => Some(GoingAway)
  | 1002 => Some(ProtocolError)
  | 1003 => Some(UnsupportedData)
  | 1005 => Some(NoStatus)
  | 1006 => Some(Abnormal)
  | 1007 => Some(InvalidPayload)
  | 1008 => Some(PolicyViolation)
  | 1009 => Some(MessageTooBig)
  | 1010 => Some(MandatoryExtension)
  | 1011 => Some(InternalError)
  | _ => None
  }

/// Convert to the 16-bit wire value.
/// Matches closeCodeToWord in WS.CloseCode.
let closeCodeToWire = (cc: closeCode): int =>
  switch cc {
  | Normal => 1000
  | GoingAway => 1001
  | ProtocolError => 1002
  | UnsupportedData => 1003
  | NoStatus => 1005
  | Abnormal => 1006
  | InvalidPayload => 1007
  | PolicyViolation => 1008
  | MessageTooBig => 1009
  | MandatoryExtension => 1010
  | InternalError => 1011
  }

/// Whether this represents a normal (clean) closure.
/// Matches isNormalClose in WS.CloseCode.
let closeCodeIsNormal = (cc: closeCode): bool =>
  switch cc {
  | Normal | GoingAway => true
  | ProtocolError | UnsupportedData | NoStatus | Abnormal | InvalidPayload | PolicyViolation
  | MessageTooBig | MandatoryExtension | InternalError => false
  }

/// Whether this represents an error condition.
/// Matches isErrorClose in WS.CloseCode.
let closeCodeIsError = (cc: closeCode): bool =>
  switch cc {
  | Normal | GoingAway | NoStatus => false
  | ProtocolError | UnsupportedData | Abnormal | InvalidPayload | PolicyViolation
  | MessageTooBig | MandatoryExtension | InternalError => true
  }

/// Whether this code may be sent in a Close frame.
/// Codes 1005 (NoStatus) and 1006 (Abnormal) are internal-only
/// and MUST NOT appear on the wire.
/// Matches isSendable in WS.CloseCode.
let closeCodeIsSendable = (cc: closeCode): bool =>
  switch cc {
  | NoStatus | Abnormal => false
  | Normal | GoingAway | ProtocolError | UnsupportedData | InvalidPayload | PolicyViolation
  | MessageTooBig | MandatoryExtension | InternalError => true
  }

/// Human-readable description.
/// Matches closeReason in WS.CloseCode.
let closeCodeReason = (cc: closeCode): string =>
  switch cc {
  | Normal => "Normal closure"
  | GoingAway => "Endpoint going away"
  | ProtocolError => "Protocol error"
  | UnsupportedData => "Unsupported data type"
  | NoStatus => "No status code present"
  | Abnormal => "Abnormal closure (no close frame)"
  | InvalidPayload => "Invalid payload data"
  | PolicyViolation => "Policy violation"
  | MessageTooBig => "Message too big"
  | MandatoryExtension => "Mandatory extension missing"
  | InternalError => "Internal server error"
  }

/// Check if a raw 16-bit value is in the application-use range
/// (4000-4999, RFC 6455 Section 7.4.2).
/// Matches isApplicationCode in WS.CloseCode.
let isApplicationCode = (code: int): bool => code >= 4000 && code <= 4999

/// Check if a raw 16-bit value is in the private-use range
/// (3000-3999, reserved for libraries/frameworks).
/// Matches isPrivateCode in WS.CloseCode.
let isPrivateCode = (code: int): bool => code >= 3000 && code <= 3999

// ===========================================================================
// Frame Validation (WS.Frame)
// ===========================================================================

/// Maximum payload size for control frames (RFC 6455 Section 5.5).
/// Matches maxControlPayload in WS.Frame.
let maxControlPayload = 125

/// A parsed WebSocket frame with all header fields and payload.
/// Mirrors the Frame record in WS.Frame.
type frame = {
  /// FIN bit -- true if this is the final fragment of a message.
  fin: bool,
  /// Opcode identifying the frame type.
  opcode: opcode,
  /// MASK bit -- true if payload is XOR-masked (required from clients).
  masked: bool,
  /// Payload length in bytes.
  payloadLength: int,
  /// 4-byte masking key (present only if masked is true).
  maskingKey: option<array<int>>,
  /// Payload data (unmasked).
  payload: array<int>,
}

/// Errors detected during frame validation.
/// Matches the FrameError type in WS.Frame.
type frameError =
  | ControlFrameTooLarge({opcode: opcode, size: int})
  | ControlFrameFragmented({opcode: opcode})
  | ClientFrameNotMasked
  | ServerFrameMasked
  | PayloadTooLarge({size: int, maxSize: int})
  | ReservedOpcode({nibble: int})
  | PayloadLengthMismatch({declared: int, actual: int})

// validateFrameCommon removed: unproven reimplementation. The verified check lives in the
// Idris2/Zig core; calling it needs @module FFI wiring not yet present for this
// protocol. Do not reimplement here. See docs/decisions/0003-keep-bindings-thin-abi-wrappers.md

// validateClientFrame removed: unproven reimplementation. The verified check lives in the
// Idris2/Zig core; calling it needs @module FFI wiring not yet present for this
// protocol. Do not reimplement here. See docs/decisions/0003-keep-bindings-thin-abi-wrappers.md

// validateServerFrame removed: unproven reimplementation. The verified check lives in the
// Idris2/Zig core; calling it needs @module FFI wiring not yet present for this
// protocol. Do not reimplement here. See docs/decisions/0003-keep-bindings-thin-abi-wrappers.md

/// Build a server-to-client text frame (unmasked, FIN set).
/// Matches makeTextFrame in WS.Frame.
let makeTextFrame = (payload: array<int>): frame => {
  fin: true,
  opcode: Text,
  masked: false,
  payloadLength: Array.length(payload),
  maskingKey: None,
  payload,
}

/// Build a server-to-client binary frame (unmasked, FIN set).
/// Matches makeBinaryFrame in WS.Frame.
let makeBinaryFrame = (payload: array<int>): frame => {
  fin: true,
  opcode: Binary,
  masked: false,
  payloadLength: Array.length(payload),
  maskingKey: None,
  payload,
}

/// Build a Pong frame echoing a Ping's payload.
/// Matches makePongFrame in WS.Frame.
let makePongFrame = (pingPayload: array<int>): frame => {
  fin: true,
  opcode: Pong,
  masked: false,
  payloadLength: Array.length(pingPayload),
  maskingKey: None,
  payload: pingPayload,
}

/// Build a Ping frame with optional payload.
/// Matches makePingFrame in WS.Frame.
let makePingFrame = (payload: array<int>): frame => {
  fin: true,
  opcode: Ping,
  masked: false,
  payloadLength: Array.length(payload),
  maskingKey: None,
  payload,
}
