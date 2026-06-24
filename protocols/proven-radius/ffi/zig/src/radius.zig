// SPDX-License-Identifier: MPL-2.0
// Copyright (c) Jonathan D.A. Jewell <j.d.a.jewell@open.ac.uk>
//
// radius.zig -- Zig FFI implementation of proven-radius.
//
// Implements the RADIUS AAA session lifecycle with:
//   - 64-slot session pool (mutex-protected)
//   - State transition enforcement matching Idris2 Transitions.idr proofs
//   - Shared secret storage per session
//   - Attribute TLV encoding/storage
//   - Thread-safe via mutex on global state
//
// Tag values are pinned to the proven Idris ABI by the comptime guard below:
// they are generated from RADIUSABI.{Layout,Transitions,Foreign} into
// radius_abi_gen.zig (tools/gen-abi.sh), and any drift fails the build.

const std = @import("std");

// Generated from the proven Idris ABI encoders by tools/gen-abi.sh. The
// comptime guard below pins every enum tag + layout constant to these, so
// drift from the proofs is a COMPILE error, not a runtime surprise.
const gen = @import("radius_abi_gen.zig");

/// ABI version (guarded against gen.ABI_VERSION below).
const ABI_VERSION: u32 = 1;

// ── Enums (matching Layout.idr tag assignments exactly) ──────────────────

/// PacketType -- matches packetTypeToTag (RFC 2865 Code field values)
pub const PacketType = enum(u8) {
    access_request = 1,
    access_accept = 2,
    access_reject = 3,
    accounting_request = 4,
    accounting_response = 5,
    access_challenge = 11,
};

/// AttributeType -- matches attributeTypeToTag (RFC 2865 Type field values)
pub const AttributeType = enum(u8) {
    user_name = 1,
    user_password = 2,
    nas_ip_address = 4,
    nas_port = 5,
    service_type = 6,
    framed_protocol = 7,
    framed_ip_address = 8,
    reply_message = 18,
    session_timeout = 27,
};

/// ServiceType -- matches serviceTypeToTag (RFC 2865 Section 5.6)
pub const ServiceType = enum(u8) {
    login = 1,
    framed = 2,
    callback_login = 3,
    callback_framed = 4,
    outbound = 5,
    administrative = 6,
};

/// AuthMethod -- matches authMethodToTag
pub const AuthMethod = enum(u8) {
    pap = 0,
    chap = 1,
    mschap = 2,
    mschapv2 = 3,
    eap = 4,
};

/// SessionState -- matches sessionStateToTag in Transitions.idr
pub const SessionState = enum(u8) {
    idle = 0,
    authenticating = 1,
    authorized = 2,
    rejected = 3,
    challenged = 4,
    accounting = 5,
    complete = 6,
};

/// RadiusResult -- matches radiusResultToTag
pub const RadiusResult = enum(u8) {
    ok = 0,
    err = 1,
    invalid_param = 2,
    pool_exhausted = 3,
    bad_secret = 4,
};

// ── Constants (matching Layout.idr) ──────────────────────────────────────

/// RADIUS packet header size (RFC 2865 Section 3): 20 bytes.
pub const PACKET_HEADER_SIZE: usize = 20;

/// Maximum RADIUS packet size (RFC 2865): 4096 bytes.
pub const MAX_PACKET_SIZE: usize = 4096;

/// Attribute header size: Type (1 byte) + Length (1 byte).
pub const ATTRIBUTE_HEADER_SIZE: usize = 2;

/// Maximum attribute value length: 255 - 2 = 253 bytes.
pub const MAX_ATTRIBUTE_VALUE_LEN: usize = 253;

// ── ABI conformance guard ────────────────────────────────────────────────
// "Type safety through Zig's particularity": every enum tag and layout
// constant MUST equal the generated (= proven Idris) value. A mismatch fails
// `zig build` with the named symbol, before any test runs. Regenerate with
// `bash tools/gen-abi.sh` if the proofs intentionally change.
comptime {
    if (ABI_VERSION != gen.ABI_VERSION) @compileError("ABI drift: abi_version (regenerate: tools/gen-abi.sh)");

    if (@intFromEnum(PacketType.access_request) != gen.PACKET_ACCESS_REQUEST) @compileError("ABI drift: PacketType.access_request");
    if (@intFromEnum(PacketType.access_accept) != gen.PACKET_ACCESS_ACCEPT) @compileError("ABI drift: PacketType.access_accept");
    if (@intFromEnum(PacketType.access_reject) != gen.PACKET_ACCESS_REJECT) @compileError("ABI drift: PacketType.access_reject");
    if (@intFromEnum(PacketType.accounting_request) != gen.PACKET_ACCOUNTING_REQUEST) @compileError("ABI drift: PacketType.accounting_request");
    if (@intFromEnum(PacketType.accounting_response) != gen.PACKET_ACCOUNTING_RESPONSE) @compileError("ABI drift: PacketType.accounting_response");
    if (@intFromEnum(PacketType.access_challenge) != gen.PACKET_ACCESS_CHALLENGE) @compileError("ABI drift: PacketType.access_challenge");

    if (@intFromEnum(AttributeType.user_name) != gen.ATTR_USER_NAME) @compileError("ABI drift: AttributeType.user_name");
    if (@intFromEnum(AttributeType.user_password) != gen.ATTR_USER_PASSWORD) @compileError("ABI drift: AttributeType.user_password");
    if (@intFromEnum(AttributeType.nas_ip_address) != gen.ATTR_NAS_IP_ADDRESS) @compileError("ABI drift: AttributeType.nas_ip_address");
    if (@intFromEnum(AttributeType.nas_port) != gen.ATTR_NAS_PORT) @compileError("ABI drift: AttributeType.nas_port");
    if (@intFromEnum(AttributeType.service_type) != gen.ATTR_SERVICE_TYPE) @compileError("ABI drift: AttributeType.service_type");
    if (@intFromEnum(AttributeType.framed_protocol) != gen.ATTR_FRAMED_PROTOCOL) @compileError("ABI drift: AttributeType.framed_protocol");
    if (@intFromEnum(AttributeType.framed_ip_address) != gen.ATTR_FRAMED_IP_ADDRESS) @compileError("ABI drift: AttributeType.framed_ip_address");
    if (@intFromEnum(AttributeType.reply_message) != gen.ATTR_REPLY_MESSAGE) @compileError("ABI drift: AttributeType.reply_message");
    if (@intFromEnum(AttributeType.session_timeout) != gen.ATTR_SESSION_TIMEOUT) @compileError("ABI drift: AttributeType.session_timeout");

    if (@intFromEnum(ServiceType.login) != gen.SVC_LOGIN) @compileError("ABI drift: ServiceType.login");
    if (@intFromEnum(ServiceType.framed) != gen.SVC_FRAMED) @compileError("ABI drift: ServiceType.framed");
    if (@intFromEnum(ServiceType.callback_login) != gen.SVC_CALLBACK_LOGIN) @compileError("ABI drift: ServiceType.callback_login");
    if (@intFromEnum(ServiceType.callback_framed) != gen.SVC_CALLBACK_FRAMED) @compileError("ABI drift: ServiceType.callback_framed");
    if (@intFromEnum(ServiceType.outbound) != gen.SVC_OUTBOUND) @compileError("ABI drift: ServiceType.outbound");
    if (@intFromEnum(ServiceType.administrative) != gen.SVC_ADMINISTRATIVE) @compileError("ABI drift: ServiceType.administrative");

    if (@intFromEnum(AuthMethod.pap) != gen.AUTH_PAP) @compileError("ABI drift: AuthMethod.pap");
    if (@intFromEnum(AuthMethod.chap) != gen.AUTH_CHAP) @compileError("ABI drift: AuthMethod.chap");
    if (@intFromEnum(AuthMethod.mschap) != gen.AUTH_MSCHAP) @compileError("ABI drift: AuthMethod.mschap");
    if (@intFromEnum(AuthMethod.mschapv2) != gen.AUTH_MSCHAPV2) @compileError("ABI drift: AuthMethod.mschapv2");
    if (@intFromEnum(AuthMethod.eap) != gen.AUTH_EAP) @compileError("ABI drift: AuthMethod.eap");

    if (@intFromEnum(SessionState.idle) != gen.STATE_IDLE) @compileError("ABI drift: SessionState.idle");
    if (@intFromEnum(SessionState.authenticating) != gen.STATE_AUTHENTICATING) @compileError("ABI drift: SessionState.authenticating");
    if (@intFromEnum(SessionState.authorized) != gen.STATE_AUTHORIZED) @compileError("ABI drift: SessionState.authorized");
    if (@intFromEnum(SessionState.rejected) != gen.STATE_REJECTED) @compileError("ABI drift: SessionState.rejected");
    if (@intFromEnum(SessionState.challenged) != gen.STATE_CHALLENGED) @compileError("ABI drift: SessionState.challenged");
    if (@intFromEnum(SessionState.accounting) != gen.STATE_ACCOUNTING) @compileError("ABI drift: SessionState.accounting");
    if (@intFromEnum(SessionState.complete) != gen.STATE_COMPLETE) @compileError("ABI drift: SessionState.complete");

    if (@intFromEnum(RadiusResult.ok) != gen.RESULT_OK) @compileError("ABI drift: RadiusResult.ok");
    if (@intFromEnum(RadiusResult.err) != gen.RESULT_ERR) @compileError("ABI drift: RadiusResult.err");
    if (@intFromEnum(RadiusResult.invalid_param) != gen.RESULT_INVALID_PARAM) @compileError("ABI drift: RadiusResult.invalid_param");
    if (@intFromEnum(RadiusResult.pool_exhausted) != gen.RESULT_POOL_EXHAUSTED) @compileError("ABI drift: RadiusResult.pool_exhausted");
    if (@intFromEnum(RadiusResult.bad_secret) != gen.RESULT_BAD_SECRET) @compileError("ABI drift: RadiusResult.bad_secret");

    if (PACKET_HEADER_SIZE != gen.PACKET_HEADER_SIZE) @compileError("ABI drift: PACKET_HEADER_SIZE");
    if (MAX_PACKET_SIZE != gen.MAX_PACKET_SIZE) @compileError("ABI drift: MAX_PACKET_SIZE");
    if (ATTRIBUTE_HEADER_SIZE != gen.ATTRIBUTE_HEADER_SIZE) @compileError("ABI drift: ATTRIBUTE_HEADER_SIZE");
    if (MAX_ATTRIBUTE_VALUE_LEN != gen.MAX_ATTRIBUTE_VALUE_LEN) @compileError("ABI drift: MAX_ATTRIBUTE_VALUE_LEN");
}

/// Maximum number of attributes per session.
const MAX_ATTRIBUTES: usize = 32;

/// Maximum shared secret length (RFC 2865 recommends up to 128 bytes).
const MAX_SECRET_LEN: usize = 128;

// ── Attribute storage ────────────────────────────────────────────────────

/// A single RADIUS attribute (TLV without the T/L header bytes, just
/// the logical type and value).
const Attribute = struct {
    attr_type: u8,
    value_len: u8,
    value: [MAX_ATTRIBUTE_VALUE_LEN]u8,
};

// ── Session instance ─────────────────────────────────────────────────────

const Session = struct {
    state: SessionState,
    auth_method: AuthMethod,
    packet_id: u8,
    secret_len: u8,
    secret: [MAX_SECRET_LEN]u8,
    attr_count: u8,
    attrs: [MAX_ATTRIBUTES]Attribute,
    active: bool,
};

const EMPTY_ATTR: Attribute = .{
    .attr_type = 0,
    .value_len = 0,
    .value = [_]u8{0} ** MAX_ATTRIBUTE_VALUE_LEN,
};

const EMPTY_SESSION: Session = .{
    .state = .idle,
    .auth_method = .pap,
    .packet_id = 0,
    .secret_len = 0,
    .secret = [_]u8{0} ** MAX_SECRET_LEN,
    .attr_count = 0,
    .attrs = [_]Attribute{EMPTY_ATTR} ** MAX_ATTRIBUTES,
    .active = false,
};

// ── Global state (64-slot pool, mutex-protected) ─────────────────────────

const MAX_SESSIONS: usize = 64;

var sessions: [MAX_SESSIONS]Session = [_]Session{EMPTY_SESSION} ** MAX_SESSIONS;

var mutex: std.Thread.Mutex = .{};

// ── ABI version ──────────────────────────────────────────────────────────

/// ABI version -- must match RADIUSABI.Foreign.abiVersion (guarded above).
pub export fn radius_abi_version() callconv(.c) u32 {
    return ABI_VERSION;
}

// ── Session lifecycle ────────────────────────────────────────────────────

/// Create a new RADIUS session in Idle state.
/// auth_method is an AuthMethod tag (0-4).
/// Returns slot index (0-63) or -1 if no slots available or invalid param.
pub export fn radius_session_create(auth_method: u8) callconv(.c) c_int {
    mutex.lock();
    defer mutex.unlock();

    // Validate auth_method tag
    if (auth_method > 4) return -1;

    for (&sessions, 0..) |*s, i| {
        if (!s.active) {
            s.* = EMPTY_SESSION;
            s.auth_method = @enumFromInt(auth_method);
            s.active = true;
            return @intCast(i);
        }
    }
    return -1; // pool exhausted
}

/// Destroy a session, freeing its slot.
/// Safe to call with any slot index (invalid slots are no-ops).
pub export fn radius_session_destroy(slot: c_int) callconv(.c) void {
    mutex.lock();
    defer mutex.unlock();

    if (slot < 0 or slot >= MAX_SESSIONS) return;
    const idx: usize = @intCast(slot);
    // Zero-wipe secret before deactivation (defense in depth)
    @memset(&sessions[idx].secret, 0);
    sessions[idx].active = false;
}

// ── State queries ────────────────────────────────────────────────────────

/// Get the current SessionState tag for a slot.
/// Returns Idle (0) for invalid/inactive slots.
pub export fn radius_session_state(slot: c_int) callconv(.c) u8 {
    mutex.lock();
    defer mutex.unlock();

    if (slot < 0 or slot >= MAX_SESSIONS) return 0;
    const idx: usize = @intCast(slot);
    if (!sessions[idx].active) return 0;
    return @intFromEnum(sessions[idx].state);
}

/// Get the AuthMethod tag for a session.
/// Returns PAP (0) for invalid/inactive slots.
pub export fn radius_get_auth_method(slot: c_int) callconv(.c) u8 {
    mutex.lock();
    defer mutex.unlock();

    if (slot < 0 or slot >= MAX_SESSIONS) return 0;
    const idx: usize = @intCast(slot);
    if (!sessions[idx].active) return 0;
    return @intFromEnum(sessions[idx].auth_method);
}

/// Get the RADIUS Identifier field for a session.
/// Returns 0 for invalid/inactive slots.
pub export fn radius_get_packet_id(slot: c_int) callconv(.c) u8 {
    mutex.lock();
    defer mutex.unlock();

    if (slot < 0 or slot >= MAX_SESSIONS) return 0;
    const idx: usize = @intCast(slot);
    if (!sessions[idx].active) return 0;
    return sessions[idx].packet_id;
}

/// Get the number of attributes stored for a session.
/// Returns 0 for invalid/inactive slots.
pub export fn radius_get_attribute_count(slot: c_int) callconv(.c) u8 {
    mutex.lock();
    defer mutex.unlock();

    if (slot < 0 or slot >= MAX_SESSIONS) return 0;
    const idx: usize = @intCast(slot);
    if (!sessions[idx].active) return 0;
    return sessions[idx].attr_count;
}

// ── AAA transitions (matching Transitions.idr ValidRadiusTransition) ─────

/// Helper: perform a guarded state transition.
/// Returns RadiusResult tag.
fn doTransition(slot: c_int, expected: SessionState, next: SessionState) u8 {
    if (slot < 0 or slot >= MAX_SESSIONS) return @intFromEnum(RadiusResult.invalid_param);
    const idx: usize = @intCast(slot);
    if (!sessions[idx].active) return @intFromEnum(RadiusResult.invalid_param);

    if (sessions[idx].state == expected) {
        sessions[idx].state = next;
        return @intFromEnum(RadiusResult.ok);
    }
    return @intFromEnum(RadiusResult.err);
}

/// BeginAuth: Idle -> Authenticating (Access-Request received).
/// pkt_id = RADIUS Identifier field from the incoming packet.
/// Returns RadiusResult tag.
pub export fn radius_begin_auth(slot: c_int, pkt_id: u8) callconv(.c) u8 {
    mutex.lock();
    defer mutex.unlock();

    if (slot < 0 or slot >= MAX_SESSIONS) return @intFromEnum(RadiusResult.invalid_param);
    const idx: usize = @intCast(slot);
    if (!sessions[idx].active) return @intFromEnum(RadiusResult.invalid_param);

    if (sessions[idx].state == .idle) {
        sessions[idx].state = .authenticating;
        sessions[idx].packet_id = pkt_id;
        // Clear attributes for new auth round
        sessions[idx].attr_count = 0;
        return @intFromEnum(RadiusResult.ok);
    }
    return @intFromEnum(RadiusResult.err);
}

/// AcceptAuth: Authenticating -> Authorized (Access-Accept sent).
pub export fn radius_accept_auth(slot: c_int) callconv(.c) u8 {
    mutex.lock();
    defer mutex.unlock();
    return doTransition(slot, .authenticating, .authorized);
}

/// RejectAuth: Authenticating -> Rejected (Access-Reject sent).
pub export fn radius_reject_auth(slot: c_int) callconv(.c) u8 {
    mutex.lock();
    defer mutex.unlock();
    return doTransition(slot, .authenticating, .rejected);
}

/// ChallengeAuth: Authenticating -> Challenged (Access-Challenge sent).
pub export fn radius_challenge_auth(slot: c_int) callconv(.c) u8 {
    mutex.lock();
    defer mutex.unlock();
    return doTransition(slot, .authenticating, .challenged);
}

/// RespondChallenge: Challenged -> Authenticating (client responded).
pub export fn radius_respond_challenge(slot: c_int) callconv(.c) u8 {
    mutex.lock();
    defer mutex.unlock();
    return doTransition(slot, .challenged, .authenticating);
}

/// BeginAccounting: Authorized -> Accounting (Accounting-Request received).
pub export fn radius_begin_accounting(slot: c_int) callconv(.c) u8 {
    mutex.lock();
    defer mutex.unlock();
    return doTransition(slot, .authorized, .accounting);
}

/// EndAccounting: Accounting -> Complete (Accounting-Response sent).
pub export fn radius_end_accounting(slot: c_int) callconv(.c) u8 {
    mutex.lock();
    defer mutex.unlock();
    return doTransition(slot, .accounting, .complete);
}

/// EndSession: handles multiple terminal transitions:
///   Authorized -> Complete (session ended without accounting)
///   Complete -> Idle (session slot released)
///   Rejected -> Idle (rejection acknowledged)
///   Challenged -> Idle (challenge timed out)
pub export fn radius_end_session(slot: c_int) callconv(.c) u8 {
    mutex.lock();
    defer mutex.unlock();

    if (slot < 0 or slot >= MAX_SESSIONS) return @intFromEnum(RadiusResult.invalid_param);
    const idx: usize = @intCast(slot);
    if (!sessions[idx].active) return @intFromEnum(RadiusResult.invalid_param);

    switch (sessions[idx].state) {
        .authorized => {
            sessions[idx].state = .complete;
            return @intFromEnum(RadiusResult.ok);
        },
        .complete, .rejected, .challenged => {
            sessions[idx].state = .idle;
            sessions[idx].attr_count = 0;
            sessions[idx].packet_id = 0;
            return @intFromEnum(RadiusResult.ok);
        },
        else => return @intFromEnum(RadiusResult.err),
    }
}

// ── Stateless validation ─────────────────────────────────────────────────

/// Check whether a transition from one SessionState to another is valid.
/// Returns 1 if valid, 0 if not.
/// Matches Transitions.idr validateTransition exactly.
pub export fn radius_can_transition(from: u8, to: u8) callconv(.c) u8 {
    // Idle(0) -> Authenticating(1)
    if (from == 0 and to == 1) return 1;
    // Authenticating(1) -> Authorized(2)
    if (from == 1 and to == 2) return 1;
    // Authenticating(1) -> Rejected(3)
    if (from == 1 and to == 3) return 1;
    // Authenticating(1) -> Challenged(4)
    if (from == 1 and to == 4) return 1;
    // Challenged(4) -> Authenticating(1)
    if (from == 4 and to == 1) return 1;
    // Authorized(2) -> Accounting(5)
    if (from == 2 and to == 5) return 1;
    // Accounting(5) -> Complete(6)
    if (from == 5 and to == 6) return 1;
    // Authorized(2) -> Complete(6)
    if (from == 2 and to == 6) return 1;
    // Complete(6) -> Idle(0)
    if (from == 6 and to == 0) return 1;
    // Rejected(3) -> Idle(0)
    if (from == 3 and to == 0) return 1;
    // Challenged(4) -> Idle(0)
    if (from == 4 and to == 0) return 1;
    return 0;
}

// ── Shared secret ────────────────────────────────────────────────────────

/// Set the shared secret for a session.
/// secret_ptr/secret_len must point to a valid buffer.
/// Returns RadiusResult tag.
pub export fn radius_set_secret(slot: c_int, secret_ptr: [*]const u8, secret_len: u32) callconv(.c) u8 {
    mutex.lock();
    defer mutex.unlock();

    if (slot < 0 or slot >= MAX_SESSIONS) return @intFromEnum(RadiusResult.invalid_param);
    const idx: usize = @intCast(slot);
    if (!sessions[idx].active) return @intFromEnum(RadiusResult.invalid_param);

    if (secret_len == 0 or secret_len > MAX_SECRET_LEN) return @intFromEnum(RadiusResult.bad_secret);

    const len: usize = @intCast(secret_len);
    @memset(&sessions[idx].secret, 0);
    @memcpy(sessions[idx].secret[0..len], secret_ptr[0..len]);
    sessions[idx].secret_len = @intCast(secret_len);
    return @intFromEnum(RadiusResult.ok);
}

// ── Attribute encoding ───────────────────────────────────────────────────

/// Add an attribute to the session's attribute list.
/// attr_type = AttributeType tag (RFC 2865 Type field value).
/// value_ptr/value_len = attribute value bytes.
/// Returns RadiusResult tag.
pub export fn radius_add_attribute(slot: c_int, attr_type: u8, value_ptr: [*]const u8, value_len: u8) callconv(.c) u8 {
    mutex.lock();
    defer mutex.unlock();

    if (slot < 0 or slot >= MAX_SESSIONS) return @intFromEnum(RadiusResult.invalid_param);
    const idx: usize = @intCast(slot);
    if (!sessions[idx].active) return @intFromEnum(RadiusResult.invalid_param);

    // Validate attribute value length (max 253 per RFC 2865)
    if (value_len > MAX_ATTRIBUTE_VALUE_LEN) return @intFromEnum(RadiusResult.invalid_param);
    if (value_len == 0) return @intFromEnum(RadiusResult.invalid_param);

    // Check for attribute pool capacity
    if (sessions[idx].attr_count >= MAX_ATTRIBUTES) return @intFromEnum(RadiusResult.pool_exhausted);

    const ai: usize = sessions[idx].attr_count;
    sessions[idx].attrs[ai].attr_type = attr_type;
    sessions[idx].attrs[ai].value_len = value_len;

    const vlen: usize = @intCast(value_len);
    @memset(&sessions[idx].attrs[ai].value, 0);
    @memcpy(sessions[idx].attrs[ai].value[0..vlen], value_ptr[0..vlen]);

    sessions[idx].attr_count += 1;
    return @intFromEnum(RadiusResult.ok);
}

// --- pool size guard (audit S5: prevent oversized-global stack overflow) ---
comptime {
    if (@sizeOf(@TypeOf(sessions)) > 16 * 1024 * 1024)
        @compileError("pool 'sessions' exceeds the 16 MiB budget; heap-allocate or shrink (see audits/proof-panic-attack-2026-06-23.md)");
}
