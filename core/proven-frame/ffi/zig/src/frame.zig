// SPDX-License-Identifier: PMPL-1.0-or-later
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
// proven-frame FFI -- Zig implementation of the frame parser ABI.
//
// This module enforces at runtime the state machine transitions that
// the Idris2 ABI proves at compile time.  Together they guarantee that:
//   - Data can only be fed when the parser is in an active state
//   - Frames can only be emitted when parsing is complete
//   - Resets are only valid from Complete or Failed states
//   - Frame size limits are enforced
//
// This is a SKELETON implementation -- it enforces the state machine
// and type contracts but uses a simplified parsing model.  Real
// implementations would contain full protocol-specific frame parsers
// (HTTP/1.1, WebSocket, gRPC length-prefixed, etc.).
//
// Enum tag values MUST match:
//   - Idris2 Layout.idr  (src/FrameABI/Layout.idr)
//   - C header            (generated/abi/frame.h)

const std = @import("std");

// ========================================================================
// ABI constants
// ========================================================================

/// ABI version.  Must match PROVEN_FRAME_ABI_VERSION in the C header
/// and abiVersion in FrameABI.Foreign.
pub const ABI_VERSION: u32 = 1;

/// Maximum frame size in bytes (16 MiB).  Matches Frame.maxFrameSize.
pub const MAX_FRAME_SIZE: u32 = 16777216;

/// Default read buffer size in bytes (8 KiB).  Matches Frame.defaultBufferSize.
pub const DEFAULT_BUFFER_SIZE: u32 = 8192;

// ========================================================================
// Enum types -- tag values match C header and Idris2 Layout.idr exactly
// ========================================================================

/// Framing strategy.
/// Tags: LineDelimited=0, LengthPrefixed=1, HTTPFrame=2, FixedSize=3,
///       ChunkEncoded=4, RawBytes=5, TLVFrame=6.
pub const FrameStrategy = enum(u8) {
    line_delimited = 0,
    length_prefixed = 1,
    http_frame = 2,
    fixed_size = 3,
    chunk_encoded = 4,
    raw_bytes = 5,
    tlv_frame = 6,
};

/// Line delimiter type.
/// Tags: CRLF=0, LF=1, Null=2, Custom=3.
pub const Delimiter = enum(u8) {
    crlf = 0,
    lf = 1,
    null_ = 2,
    custom = 3,
};

/// Length-prefix encoding format.
/// Tags: BigEndian16=0, BigEndian32=1, LittleEndian16=2,
///       LittleEndian32=3, Varint=4.
pub const LengthEncoding = enum(u8) {
    big_endian_16 = 0,
    big_endian_32 = 1,
    little_endian_16 = 2,
    little_endian_32 = 3,
    varint = 4,
};

/// Frame parsing error category.
/// Tags: None=0, Incomplete=1, Oversized=2, InvalidDelimiter=3,
///       InvalidLength=4, MalformedHeader=5, EncodingError=6.
/// Tag 0 (none) has no Idris2 constructor -- it represents success.
pub const FrameError = enum(u8) {
    none = 0,
    incomplete = 1,
    oversized = 2,
    invalid_delimiter = 3,
    invalid_length = 4,
    malformed_header = 5,
    encoding_error = 6,
};

/// Frame parser lifecycle state.
/// Tags: AwaitingHeader=0, AwaitingPayload=1, Complete=2, Failed=3.
pub const FrameState = enum(u8) {
    awaiting_header = 0,
    awaiting_payload = 1,
    complete = 2,
    failed = 3,
};

// ========================================================================
// Opaque handle type
// ========================================================================

/// Frame parser handle.
/// Tracks parser configuration, state, and accumulated data.
/// Backend-specific parsing logic would extend this struct;
/// the skeleton tracks state and validates transitions only.
pub const FrameParser = struct {
    /// Current lifecycle state of this parser.
    state: FrameState,
    /// Framing strategy in use.
    strategy: FrameStrategy,
    /// Delimiter type (for line-delimited strategy).
    delimiter: Delimiter,
    /// Length encoding (for length-prefixed strategy).
    length_enc: LengthEncoding,
    /// Maximum allowed frame size.
    max_size: u32,
    /// Number of bytes fed so far in the current frame.
    bytes_fed: u32,
    /// Whether the header has been received (for two-phase strategies).
    header_received: bool,
};

// ========================================================================
// Allocator
// ========================================================================

var gpa = std.heap.GeneralPurposeAllocator(.{}){};
const allocator = gpa.allocator();

// ========================================================================
// Exported C ABI functions
// ========================================================================

/// Return ABI version for compatibility checking.
pub export fn frame_abi_version() callconv(.c) u32 {
    return ABI_VERSION;
}

/// Create a new frame parser.
///
/// State machine: creates a new parser in AwaitingHeader state.
///
/// Parameters:
///   strategy   -- FrameStrategy tag (0-6)
///   delimiter  -- Delimiter tag (0-3), used for line_delimited strategy
///   length_enc -- LengthEncoding tag (0-4), used for length_prefixed
///   max_size   -- maximum frame size (capped at MAX_FRAME_SIZE)
///   err        -- pointer to receive the error code
///
/// Returns: non-null parser on success, null on failure.
pub export fn frame_parser_create(
    strategy: FrameStrategy,
    delimiter: Delimiter,
    length_enc: LengthEncoding,
    max_size: u32,
    err: *FrameError,
) callconv(.c) ?*FrameParser {
    const capped = if (max_size > MAX_FRAME_SIZE) MAX_FRAME_SIZE else max_size;

    const parser = allocator.create(FrameParser) catch {
        err.* = FrameError.encoding_error;
        return null;
    };

    parser.* = FrameParser{
        .state = FrameState.awaiting_header,
        .strategy = strategy,
        .delimiter = delimiter,
        .length_enc = length_enc,
        .max_size = capped,
        .bytes_fed = 0,
        .header_received = false,
    };

    err.* = FrameError.none;
    return parser;
}

/// Get the current parser state.
///
/// Returns FrameState.failed if p is null.
pub export fn frame_parser_state(p: ?*const FrameParser) callconv(.c) FrameState {
    const parser = p orelse return FrameState.failed;
    return parser.state;
}

/// Feed data into the parser.
///
/// State machine: requires AwaitingHeader or AwaitingPayload (CanDecode).
/// The skeleton uses a simplified model:
///   - First feed while AwaitingHeader transitions to AwaitingPayload
///     (for two-phase strategies) or directly to Complete (for
///     line-delimited/raw strategies).
///   - Second feed while AwaitingPayload transitions to Complete.
///   - Feeding data exceeding max_size transitions to Failed.
///
/// Parameters:
///   p   -- parser handle
///   buf -- data buffer (unused in skeleton)
///   len -- number of bytes
///
/// Returns: FrameError.none on success, or an error code.
pub export fn frame_feed(
    p: ?*FrameParser,
    buf: ?*const anyopaque,
    len: u32,
) callconv(.c) FrameError {
    const parser = p orelse return FrameError.malformed_header;
    _ = buf;

    switch (parser.state) {
        .awaiting_header => {
            parser.bytes_fed += len;

            // Check size limit.
            if (parser.bytes_fed > parser.max_size) {
                parser.state = FrameState.failed;
                return FrameError.oversized;
            }

            // Skeleton: line_delimited and raw_bytes complete on first feed.
            // All others transition to awaiting_payload.
            switch (parser.strategy) {
                .line_delimited, .raw_bytes => {
                    parser.state = FrameState.complete;
                },
                else => {
                    parser.state = FrameState.awaiting_payload;
                    parser.header_received = true;
                },
            }

            return FrameError.none;
        },
        .awaiting_payload => {
            parser.bytes_fed += len;

            // Check size limit.
            if (parser.bytes_fed > parser.max_size) {
                parser.state = FrameState.failed;
                return FrameError.oversized;
            }

            // Skeleton: payload complete on any feed.
            parser.state = FrameState.complete;
            return FrameError.none;
        },
        .complete => return FrameError.encoding_error,
        .failed => return FrameError.encoding_error,
    }
}

/// Emit the assembled frame.
///
/// State machine: requires Complete state (CanEmit).
/// The skeleton sets *out_len to bytes_fed (the total data fed).
///
/// Parameters:
///   p       -- parser handle
///   out_buf -- output buffer (unused in skeleton)
///   out_len -- pointer to receive frame size
///
/// Returns: FrameError.none on success, or an error code.
pub export fn frame_emit(
    p: ?*FrameParser,
    out_buf: ?*anyopaque,
    out_len: *u32,
) callconv(.c) FrameError {
    const parser = p orelse return FrameError.malformed_header;
    _ = out_buf;

    switch (parser.state) {
        .complete => {
            out_len.* = parser.bytes_fed;
            return FrameError.none;
        },
        else => return FrameError.incomplete,
    }
}

/// Reset the parser to AwaitingHeader state.
///
/// State machine: Complete|Failed -> AwaitingHeader (CanReset).
/// Clears accumulated data.
///
/// Returns: FrameError.none on success, or an error code.
pub export fn frame_reset(p: ?*FrameParser) callconv(.c) FrameError {
    const parser = p orelse return FrameError.malformed_header;

    switch (parser.state) {
        .complete, .failed => {
            parser.state = FrameState.awaiting_header;
            parser.bytes_fed = 0;
            parser.header_received = false;
            return FrameError.none;
        },
        else => return FrameError.encoding_error,
    }
}

/// Destroy a frame parser and free its memory.
/// Safe to call with null (no-op).
pub export fn frame_parser_destroy(p: ?*FrameParser) callconv(.c) void {
    const parser = p orelse return;
    allocator.destroy(parser);
}
