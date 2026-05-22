// SPDX-License-Identifier: MPL-2.0
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
// proven-nesy-solver-api — Zig FFI implementation (E2 skeleton).
//
// E2 provides the C-ABI surface and type definitions that mirror the
// Idris2 ABI in src/NesySolverAPIABI/Layout.idr.  The dispatch functions
// return typed stubs; E3 replaces them with real echidna HTTP calls and
// verisim-api persistence.
//
// Tag values here MUST match generated/abi/nesy_solver_api.h and the
// Idris2 Layout.idr encodings exactly.

const std = @import("std");

// ─── Typed tag enums (match C header + Idris2 Layout.idr) ───────────────

pub const ProverTag = enum(u8) {
    z3 = 0,
    cvc5 = 1,
    coq = 2,
    lean = 3,
    idris2 = 4,
    agda = 5,
    isabelle = 6,
    dafny = 7,
    fstar = 8,
};

pub const LanguageTag = enum(u8) {
    smtlib = 0,
    lean = 1,
    coq = 2,
    idris2 = 3,
    agda = 4,
};

pub const ClassTag = enum(u8) {
    safety = 0,
    linearity = 1,
    termination = 2,
    equiv = 3,
    correctness = 4,
    confluence = 5,
    totality = 6,
    invariant = 7,
    refinement = 8,
    model_check = 9,
    other = 10,
};

pub const OutcomeTag = enum(u8) {
    success = 0,
    failure = 1,
    timeout = 2,
    unknown = 3,
};

pub const SessionStateTag = enum(u8) {
    idle = 0,
    dispatching = 1,
    recording = 2,
    failed = 3,
};

pub const SurfaceTag = enum(u8) {
    rest = 0,
    graphql = 1,
    websocket = 2,
    sse = 3,
    grpc = 4,
    jsonrpc = 5,
    msgpack_rpc = 6,
    cbor = 7,
    flatbuffers = 8,
    capnproto = 9,
    bebop = 10,
    trpc = 11,
    mqtt = 12,
    amqp = 13,
    soap = 14,
    verisimdb = 15,
};

// ─── Opaque handles (allocated on heap, returned as *anyopaque in C) ────

pub const Session = struct {
    state: SessionStateTag,
    allocator: std.mem.Allocator,
};

pub const Dispatch = struct {
    outcome: OutcomeTag,
    duration_ms: u64,
    prover: ProverTag,
    allocator: std.mem.Allocator,
};

// ─── Global allocator for FFI-owned handles ─────────────────────────────

var gpa = std.heap.GeneralPurposeAllocator(.{}){};

// ─── Session lifecycle ──────────────────────────────────────────────────

pub export fn nesy_session_open() callconv(.c) ?*Session {
    const allocator = gpa.allocator();
    const s = allocator.create(Session) catch return null;
    s.* = .{ .state = .idle, .allocator = allocator };
    return s;
}

pub export fn nesy_session_close(s: ?*Session) callconv(.c) void {
    if (s) |session| {
        session.allocator.destroy(session);
    }
}

pub export fn nesy_session_state(s: ?*const Session) callconv(.c) u8 {
    if (s) |session| {
        return @intFromEnum(session.state);
    }
    return @intFromEnum(SessionStateTag.failed);
}

// ─── Dispatch ───────────────────────────────────────────────────────────

pub export fn nesy_dispatch_begin(
    s: ?*Session,
    prover: u8,
    language: u8,
    obligation_class: u8,
    content: [*]const u8,
    content_len: usize,
) callconv(.c) ?*Dispatch {
    _ = language;
    _ = obligation_class;
    _ = content;
    _ = content_len;

    const session = s orelse return null;
    const prover_tag: ProverTag = std.meta.intToEnum(ProverTag, prover) catch return null;

    session.state = .dispatching;

    const allocator = gpa.allocator();
    const d = allocator.create(Dispatch) catch return null;
    d.* = .{
        .outcome = .unknown, // E3: real dispatch fills this in
        .duration_ms = 0,
        .prover = prover_tag,
        .allocator = allocator,
    };
    return d;
}

pub export fn nesy_dispatch_poll(d: ?*const Dispatch) callconv(.c) u8 {
    if (d) |dispatch| {
        return @intFromEnum(dispatch.outcome);
    }
    return @intFromEnum(OutcomeTag.unknown);
}

pub export fn nesy_dispatch_duration_ms(d: ?*const Dispatch) callconv(.c) u64 {
    if (d) |dispatch| {
        return dispatch.duration_ms;
    }
    return 0;
}

pub export fn nesy_dispatch_end(d: ?*Dispatch) callconv(.c) void {
    if (d) |dispatch| {
        dispatch.allocator.destroy(dispatch);
    }
}

// ─── Utilities ──────────────────────────────────────────────────────────

pub export fn nesy_obligation_hash(
    content: [*]const u8,
    content_len: usize,
    out: [*]u8,
    out_len: usize,
) callconv(.c) c_int {
    if (out_len < 65) return -1;
    const Sha256 = std.crypto.hash.sha2.Sha256;
    var digest: [32]u8 = undefined;
    Sha256.hash(content[0..content_len], &digest, .{});
    const hex = "0123456789abcdef";
    var i: usize = 0;
    while (i < 32) : (i += 1) {
        out[i * 2] = hex[digest[i] >> 4];
        out[i * 2 + 1] = hex[digest[i] & 0x0f];
    }
    out[64] = 0;
    return 0;
}

pub export fn nesy_strategy_lookup(obligation_class: u8) callconv(.c) u8 {
    // E2: static fallback table. E3: replaced by verisim-api /strategy call.
    return switch (std.meta.intToEnum(ClassTag, obligation_class) catch return 0xFF) {
        .safety => @intFromEnum(ProverTag.z3),
        .linearity => @intFromEnum(ProverTag.idris2),
        .termination => @intFromEnum(ProverTag.agda),
        .equiv => @intFromEnum(ProverTag.lean),
        .correctness => @intFromEnum(ProverTag.coq),
        .confluence => @intFromEnum(ProverTag.lean),
        .totality => @intFromEnum(ProverTag.agda),
        .invariant => @intFromEnum(ProverTag.z3),
        .refinement => @intFromEnum(ProverTag.fstar),
        .model_check => @intFromEnum(ProverTag.z3),
        .other => @intFromEnum(ProverTag.z3),
    };
}

pub export fn nesy_record_attempt(
    s: ?*Session,
    attempt_id: [*:0]const u8,
    obligation_id: [*:0]const u8,
    repo: [*:0]const u8,
    file: [*:0]const u8,
    claim: [*:0]const u8,
    obligation_class: u8,
    prover: u8,
    outcome: u8,
    duration_ms: u64,
    confidence: f64,
    strategy_tag: [*:0]const u8,
    started_at: [*:0]const u8,
    completed_at: [*:0]const u8,
) callconv(.c) bool {
    _ = attempt_id;
    _ = obligation_id;
    _ = repo;
    _ = file;
    _ = claim;
    _ = obligation_class;
    _ = prover;
    _ = outcome;
    _ = duration_ms;
    _ = confidence;
    _ = strategy_tag;
    _ = started_at;
    _ = completed_at;

    // E2 stub: accept all attempts, mark session as Recording.
    // E3: POST to verisim-api /api/v1/proof_attempts and return the real result.
    if (s) |session| {
        session.state = .recording;
        return true;
    }
    return false;
}

// ─── Unit tests ─────────────────────────────────────────────────────────

test "session open/close roundtrip" {
    const s = nesy_session_open() orelse return error.OutOfMemory;
    try std.testing.expectEqual(@intFromEnum(SessionStateTag.idle), nesy_session_state(s));
    nesy_session_close(s);
}

test "obligation hash produces 64 hex chars" {
    const input = "hello";
    var out: [65]u8 = undefined;
    const rc = nesy_obligation_hash(input.ptr, input.len, &out, out.len);
    try std.testing.expectEqual(@as(c_int, 0), rc);
    try std.testing.expectEqual(@as(u8, 0), out[64]);
    // SHA-256("hello") = 2cf24dba5fb0a30e26e83b2ac5b9e29e1b161e5c1fa7425e73043362938b9824
    const expected = "2cf24dba5fb0a30e26e83b2ac5b9e29e1b161e5c1fa7425e73043362938b9824";
    try std.testing.expectEqualSlices(u8, expected, out[0..64]);
}

test "strategy lookup returns sensible defaults" {
    try std.testing.expectEqual(
        @intFromEnum(ProverTag.z3),
        nesy_strategy_lookup(@intFromEnum(ClassTag.safety)),
    );
    try std.testing.expectEqual(
        @intFromEnum(ProverTag.idris2),
        nesy_strategy_lookup(@intFromEnum(ClassTag.linearity)),
    );
    try std.testing.expectEqual(
        @intFromEnum(ProverTag.coq),
        nesy_strategy_lookup(@intFromEnum(ClassTag.correctness)),
    );
    try std.testing.expectEqual(@as(u8, 0xFF), nesy_strategy_lookup(99));
}

test "dispatch lifecycle" {
    const s = nesy_session_open() orelse return error.OutOfMemory;
    defer nesy_session_close(s);
    const content = "(check-sat)";
    const d = nesy_dispatch_begin(
        s,
        @intFromEnum(ProverTag.z3),
        @intFromEnum(LanguageTag.smtlib),
        @intFromEnum(ClassTag.safety),
        content.ptr,
        content.len,
    ) orelse return error.OutOfMemory;
    try std.testing.expectEqual(@intFromEnum(SessionStateTag.dispatching), nesy_session_state(s));
    try std.testing.expectEqual(@intFromEnum(OutcomeTag.unknown), nesy_dispatch_poll(d));
    try std.testing.expectEqual(@as(u64, 0), nesy_dispatch_duration_ms(d));
    nesy_dispatch_end(d);
}
