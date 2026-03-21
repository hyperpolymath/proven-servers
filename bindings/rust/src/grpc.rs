// SPDX-License-Identifier: PMPL-1.0-or-later
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
//! gRPC protocol types for the proven-servers ABI.
//!
//! Mirrors the Idris2 modules:
//! - `GRPC.Types`           — status codes, stream types, compression, content types
//! - `GRPCABI.Layout`       — C-ABI tag values for stream states
//! - `GRPCABI.Transitions`  — HTTP/2 stream state machine (RFC 7540 Section 5.1)
//!
//! The HTTP/2 stream lifecycle is modelled via [`StreamState`] and
//! [`validate_stream_transition`], matching the formal proofs in
//! `GRPCABI.Transitions` (including impossibility proofs like
//! `closedIsTerminal`).

use std::fmt;

// ===========================================================================
// gRPC Status Code (GRPC.Types.StatusCode)
// ===========================================================================

/// gRPC status codes per the gRPC specification.
///
/// Matches the `StatusCode` type in `GRPC.Types`.
/// Discriminant values are the standard gRPC numeric codes.
#[derive(Debug, Clone, Copy, PartialEq, Eq, Hash)]
#[repr(u8)]
pub enum StatusCode {
    /// The operation completed successfully.
    Ok = 0,
    /// The operation was cancelled.
    Cancelled = 1,
    /// Unknown error.
    Unknown = 2,
    /// The client specified an invalid argument.
    InvalidArgument = 3,
    /// The deadline expired before the operation completed.
    DeadlineExceeded = 4,
    /// The requested entity was not found.
    NotFound = 5,
    /// The entity that the client attempted to create already exists.
    AlreadyExists = 6,
    /// The caller does not have permission.
    PermissionDenied = 7,
    /// Some resource has been exhausted (e.g. per-user quota).
    ResourceExhausted = 8,
    /// The system is not in a state required for the operation.
    FailedPrecondition = 9,
    /// The operation was aborted (e.g. concurrency conflict).
    Aborted = 10,
    /// The operation was attempted past the valid range.
    OutOfRange = 11,
    /// The operation is not implemented or supported.
    Unimplemented = 12,
    /// Internal error.
    Internal = 13,
    /// The service is currently unavailable (transient).
    Unavailable = 14,
    /// Unrecoverable data loss or corruption.
    DataLoss = 15,
    /// The request does not have valid authentication credentials.
    Unauthenticated = 16,
}

impl StatusCode {
    /// Decode from a numeric gRPC status code.
    pub fn from_code(code: u8) -> Option<Self> {
        match code {
            0 => Some(Self::Ok),
            1 => Some(Self::Cancelled),
            2 => Some(Self::Unknown),
            3 => Some(Self::InvalidArgument),
            4 => Some(Self::DeadlineExceeded),
            5 => Some(Self::NotFound),
            6 => Some(Self::AlreadyExists),
            7 => Some(Self::PermissionDenied),
            8 => Some(Self::ResourceExhausted),
            9 => Some(Self::FailedPrecondition),
            10 => Some(Self::Aborted),
            11 => Some(Self::OutOfRange),
            12 => Some(Self::Unimplemented),
            13 => Some(Self::Internal),
            14 => Some(Self::Unavailable),
            15 => Some(Self::DataLoss),
            16 => Some(Self::Unauthenticated),
            _ => None,
        }
    }

    /// Encode to a numeric gRPC status code.
    pub fn to_code(self) -> u8 {
        self as u8
    }

    /// Whether this status represents success.
    pub fn is_ok(self) -> bool {
        matches!(self, Self::Ok)
    }
}

impl fmt::Display for StatusCode {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        fmt::Debug::fmt(self, f)
    }
}

// ===========================================================================
// Stream Type (GRPC.Types.StreamType)
// ===========================================================================

/// gRPC stream cardinality types.
///
/// Matches `StreamType` in `GRPC.Types`.
#[derive(Debug, Clone, Copy, PartialEq, Eq, Hash)]
#[repr(u8)]
pub enum StreamType {
    /// Single request, single response.
    Unary = 0,
    /// Single request, stream of responses.
    ServerStreaming = 1,
    /// Stream of requests, single response.
    ClientStreaming = 2,
    /// Bidirectional streaming.
    BidiStreaming = 3,
}

impl StreamType {
    /// Whether the client sends a stream of messages.
    pub fn is_client_streaming(self) -> bool {
        matches!(self, Self::ClientStreaming | Self::BidiStreaming)
    }

    /// Whether the server sends a stream of messages.
    pub fn is_server_streaming(self) -> bool {
        matches!(self, Self::ServerStreaming | Self::BidiStreaming)
    }
}

impl fmt::Display for StreamType {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        let name = match self {
            Self::Unary => "Unary",
            Self::ServerStreaming => "ServerStreaming",
            Self::ClientStreaming => "ClientStreaming",
            Self::BidiStreaming => "BidiStreaming",
        };
        f.write_str(name)
    }
}

// ===========================================================================
// Compression (GRPC.Types.Compression)
// ===========================================================================

/// gRPC message compression algorithms.
///
/// Matches `Compression` in `GRPC.Types`.
#[derive(Debug, Clone, Copy, PartialEq, Eq, Hash)]
#[repr(u8)]
pub enum Compression {
    /// No compression (identity encoding).
    Identity = 0,
    /// gzip compression.
    Gzip = 1,
    /// DEFLATE compression.
    Deflate = 2,
    /// Snappy compression.
    Snappy = 3,
    /// Zstandard compression.
    Zstd = 4,
}

impl fmt::Display for Compression {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        let name = match self {
            Self::Identity => "identity",
            Self::Gzip => "gzip",
            Self::Deflate => "deflate",
            Self::Snappy => "snappy",
            Self::Zstd => "zstd",
        };
        f.write_str(name)
    }
}

// ===========================================================================
// Content Type (GRPC.Types.ContentType)
// ===========================================================================

/// gRPC content type encodings.
///
/// Matches `ContentType` in `GRPC.Types`.
#[derive(Debug, Clone, Copy, PartialEq, Eq, Hash)]
#[repr(u8)]
pub enum GrpcContentType {
    /// Protocol Buffers (default).
    Protobuf = 0,
    /// JSON encoding.
    Json = 1,
}

impl GrpcContentType {
    /// The gRPC content-type header value.
    pub fn content_type_header(self) -> &'static str {
        match self {
            Self::Protobuf => "application/grpc+proto",
            Self::Json => "application/grpc+json",
        }
    }
}

impl fmt::Display for GrpcContentType {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        f.write_str(self.content_type_header())
    }
}

// ===========================================================================
// HTTP/2 Stream State (GRPCABI.Layout.StreamState)
// ===========================================================================

/// HTTP/2 stream states (RFC 7540 Section 5.1).
///
/// Used as the state index for the gRPC stream lifecycle state machine
/// in `GRPCABI.Transitions`.
#[derive(Debug, Clone, Copy, PartialEq, Eq, Hash)]
#[repr(u8)]
pub enum StreamState {
    /// Stream has not been opened.
    Idle = 0,
    /// Stream is open in both directions.
    Open = 1,
    /// Local side has sent END_STREAM; remote can still send.
    HalfClosedLocal = 2,
    /// Remote side has sent END_STREAM; local can still send.
    HalfClosedRemote = 3,
    /// Reserved via PUSH_PROMISE.
    Reserved = 4,
    /// Stream is closed (terminal state).
    Closed = 5,
}

impl StreamState {
    /// Decode from a C-ABI tag value.
    pub fn from_tag(tag: u8) -> Option<Self> {
        match tag {
            0 => Some(Self::Idle),
            1 => Some(Self::Open),
            2 => Some(Self::HalfClosedLocal),
            3 => Some(Self::HalfClosedRemote),
            4 => Some(Self::Reserved),
            5 => Some(Self::Closed),
            _ => None,
        }
    }

    /// Encode to the C-ABI tag value.
    pub fn to_tag(self) -> u8 {
        self as u8
    }

    /// Whether DATA frames can be sent (local direction) from this state.
    ///
    /// Matches `CanSendData` witnesses in `GRPCABI.Transitions`.
    pub fn can_send_data(self) -> bool {
        matches!(self, Self::Open | Self::HalfClosedRemote)
    }

    /// Whether DATA frames can be received (remote direction) in this state.
    ///
    /// Matches `CanReceiveData` witnesses in `GRPCABI.Transitions`.
    pub fn can_receive_data(self) -> bool {
        matches!(self, Self::Open | Self::HalfClosedLocal)
    }

    /// Whether WINDOW_UPDATE frames can be processed in this state.
    ///
    /// Matches `CanUpdateWindow` witnesses in `GRPCABI.Transitions`.
    pub fn can_update_window(self) -> bool {
        matches!(
            self,
            Self::Open | Self::HalfClosedLocal | Self::HalfClosedRemote
        )
    }

    /// Whether this is the terminal state (Closed).
    ///
    /// Relates to the `closedIsTerminal` impossibility proof in
    /// `GRPCABI.Transitions`.
    pub fn is_terminal(self) -> bool {
        matches!(self, Self::Closed)
    }
}

/// Named HTTP/2 stream state transitions.
///
/// Each variant corresponds to a constructor of `ValidStreamTransition`
/// in `GRPCABI.Transitions`.
#[derive(Debug, Clone, Copy, PartialEq, Eq, Hash)]
pub enum StreamTransition {
    /// Idle -> Open (sending or receiving HEADERS).
    SendHeaders,
    /// Open -> HalfClosedLocal (local sends END_STREAM).
    LocalEndStream,
    /// Open -> HalfClosedRemote (remote sends END_STREAM).
    RemoteEndStream,
    /// Open -> Closed (RST_STREAM from either side).
    ResetFromOpen,
    /// HalfClosedLocal -> Closed.
    CloseHalfLocal,
    /// HalfClosedRemote -> Closed.
    CloseHalfRemote,
    /// Idle -> Reserved (received PUSH_PROMISE).
    PushPromiseRecv,
    /// Reserved -> HalfClosedRemote (server sends HEADERS).
    ReservedToHalf,
    /// Reserved -> Closed (RST_STREAM cancels push).
    ReservedReset,
}

/// Validate whether a stream state transition is legal.
///
/// Mirrors `validateStreamTransition` in `GRPCABI.Transitions`.
/// Returns `Some(transition)` for valid transitions, `None` for invalid.
///
/// Key invariant: `Closed` is terminal -- no transitions originate from it.
pub fn validate_stream_transition(
    from: StreamState,
    to: StreamState,
) -> Option<StreamTransition> {
    match (from, to) {
        (StreamState::Idle, StreamState::Open) => Some(StreamTransition::SendHeaders),
        (StreamState::Open, StreamState::HalfClosedLocal) => {
            Some(StreamTransition::LocalEndStream)
        }
        (StreamState::Open, StreamState::HalfClosedRemote) => {
            Some(StreamTransition::RemoteEndStream)
        }
        (StreamState::Open, StreamState::Closed) => Some(StreamTransition::ResetFromOpen),
        (StreamState::HalfClosedLocal, StreamState::Closed) => {
            Some(StreamTransition::CloseHalfLocal)
        }
        (StreamState::HalfClosedRemote, StreamState::Closed) => {
            Some(StreamTransition::CloseHalfRemote)
        }
        (StreamState::Idle, StreamState::Reserved) => Some(StreamTransition::PushPromiseRecv),
        (StreamState::Reserved, StreamState::HalfClosedRemote) => {
            Some(StreamTransition::ReservedToHalf)
        }
        (StreamState::Reserved, StreamState::Closed) => Some(StreamTransition::ReservedReset),
        _ => None,
    }
}

// ===========================================================================
// Tests
// ===========================================================================

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn status_code_roundtrip() {
        for code in 0u8..=16 {
            let sc = StatusCode::from_code(code).expect("valid code");
            assert_eq!(sc.to_code(), code);
        }
    }

    #[test]
    fn status_code_invalid() {
        assert!(StatusCode::from_code(17).is_none());
        assert!(StatusCode::from_code(255).is_none());
    }

    #[test]
    fn stream_type_classification() {
        assert!(!StreamType::Unary.is_client_streaming());
        assert!(!StreamType::Unary.is_server_streaming());
        assert!(StreamType::ServerStreaming.is_server_streaming());
        assert!(!StreamType::ServerStreaming.is_client_streaming());
        assert!(StreamType::ClientStreaming.is_client_streaming());
        assert!(!StreamType::ClientStreaming.is_server_streaming());
        assert!(StreamType::BidiStreaming.is_client_streaming());
        assert!(StreamType::BidiStreaming.is_server_streaming());
    }

    #[test]
    fn stream_state_data_capabilities() {
        // CanSendData: Open and HalfClosedRemote
        assert!(StreamState::Open.can_send_data());
        assert!(StreamState::HalfClosedRemote.can_send_data());
        assert!(!StreamState::HalfClosedLocal.can_send_data()); // cannotSendFromHalfLocal
        assert!(!StreamState::Idle.can_send_data());            // cannotSendFromIdle
        assert!(!StreamState::Closed.can_send_data());          // cannotSendFromClosed

        // CanReceiveData: Open and HalfClosedLocal
        assert!(StreamState::Open.can_receive_data());
        assert!(StreamState::HalfClosedLocal.can_receive_data());
        assert!(!StreamState::HalfClosedRemote.can_receive_data()); // cannotReceiveFromHalfRemote
        assert!(!StreamState::Closed.can_receive_data());           // cannotReceiveFromClosed
    }

    #[test]
    fn closed_is_terminal() {
        // The Idris2 proof `closedIsTerminal` shows no transition exists
        // from Closed to any other state.
        for to_tag in 0u8..=5 {
            let to = StreamState::from_tag(to_tag).unwrap();
            assert!(
                validate_stream_transition(StreamState::Closed, to).is_none(),
                "Closed -> {to:?} should be impossible"
            );
        }
    }

    #[test]
    fn valid_stream_transitions() {
        let valid_pairs = [
            (StreamState::Idle, StreamState::Open),
            (StreamState::Open, StreamState::HalfClosedLocal),
            (StreamState::Open, StreamState::HalfClosedRemote),
            (StreamState::Open, StreamState::Closed),
            (StreamState::HalfClosedLocal, StreamState::Closed),
            (StreamState::HalfClosedRemote, StreamState::Closed),
            (StreamState::Idle, StreamState::Reserved),
            (StreamState::Reserved, StreamState::HalfClosedRemote),
            (StreamState::Reserved, StreamState::Closed),
        ];
        for (from, to) in valid_pairs {
            assert!(
                validate_stream_transition(from, to).is_some(),
                "transition {from:?} -> {to:?} should be valid"
            );
        }
    }

    #[test]
    fn impossible_stream_transitions() {
        // From the impossibility proofs in GRPCABI.Transitions
        let impossible_pairs = [
            (StreamState::Idle, StreamState::HalfClosedLocal),   // cannotSkipToHalfClosed
            (StreamState::HalfClosedLocal, StreamState::Open),   // cannotReopenHalfClosed
            (StreamState::Reserved, StreamState::Open),          // cannotReservedToOpen
        ];
        for (from, to) in impossible_pairs {
            assert!(
                validate_stream_transition(from, to).is_none(),
                "transition {from:?} -> {to:?} should be impossible"
            );
        }
    }
}
