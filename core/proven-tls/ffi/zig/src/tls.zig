// SPDX-License-Identifier: PMPL-1.0-or-later
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
// tls.zig -- Zig FFI implementation of proven-tls.
//
// Implements verified TLS handshake state machine with:
//   - Slot-based session management (up to 64 concurrent)
//   - State machine enforcement matching Idris2 Transitions.idr
//   - Thread-safe via mutex
//   - Certificate validation tracking
//   - Alert description recording

const std = @import("std");

// -- Enums (matching TLSABI.Layout.idr tag assignments) ---------------------

pub const TlsVersion = enum(u8) {
    tls12 = 0,
    tls13 = 1,
};

pub const CipherSuite = enum(u8) {
    aes_128_gcm_sha256 = 0,
    aes_256_gcm_sha384 = 1,
    chacha20_poly1305_sha256 = 2,
};

pub const HandshakeState = enum(u8) {
    client_hello = 0,
    server_hello = 1,
    encrypted_extensions = 2,
    certificate = 3,
    certificate_verify = 4,
    finished = 5,
    established = 6,
    closed = 7,
};

pub const CertValidation = enum(u8) {
    valid = 0,
    expired = 1,
    not_yet_valid = 2,
    revoked = 3,
    self_signed = 4,
    unknown_ca = 5,
    hostname_mismatch = 6,
    weak_key = 7,
    weak_signature = 8,
};

pub const AlertLevel = enum(u8) {
    warning = 0,
    fatal = 1,
};

pub const AlertDescription = enum(u8) {
    close_notify = 0,
    unexpected_message = 1,
    bad_record_mac = 2,
    decryption_failed = 3,
    record_overflow = 4,
    handshake_failure = 5,
    bad_certificate = 6,
    unsupported_certificate = 7,
    certificate_revoked = 8,
    certificate_expired = 9,
    certificate_unknown = 10,
    illegal_parameter = 11,
    unknown_ca = 12,
    access_denied = 13,
    decode_error = 14,
    decrypt_error = 15,
    protocol_version = 16,
    insufficient_security = 17,
    internal_error = 18,
    inappropriate_fallback = 19,
    missing_extension = 20,
    unsupported_extension = 21,
    unrecognized_name = 22,
    certificate_required = 23,
    no_application_protocol = 24,
};

// -- TLS session ------------------------------------------------------------

const Session = struct {
    state: HandshakeState,
    version: TlsVersion,
    cipher: CipherSuite,
    cert_status: u8, // 255 = not yet validated
    last_alert: u8, // 255 = no alert
    active: bool,
};

const MAX_SESSIONS: usize = 64;
var sessions: [MAX_SESSIONS]Session = [_]Session{.{
    .state = .client_hello, .version = .tls13, .cipher = .aes_128_gcm_sha256,
    .cert_status = 255, .last_alert = 255, .active = false,
}} ** MAX_SESSIONS;

var mutex: std.Thread.Mutex = .{};

fn validSlot(slot: c_int) ?usize {
    if (slot < 0 or slot >= MAX_SESSIONS) return null;
    const idx: usize = @intCast(slot);
    if (!sessions[idx].active) return null;
    return idx;
}

// -- Next state in the handshake sequence -----------------------------------

fn nextState(s: HandshakeState) ?HandshakeState {
    return switch (s) {
        .client_hello => .server_hello,
        .server_hello => .encrypted_extensions,
        .encrypted_extensions => .certificate,
        .certificate => .certificate_verify,
        .certificate_verify => .finished,
        .finished => .established,
        .established, .closed => null,
    };
}

// -- ABI version ------------------------------------------------------------

pub export fn tls_abi_version() callconv(.c) u32 {
    return 1;
}

// -- Lifecycle --------------------------------------------------------------

pub export fn tls_create(version: u8, cipher: u8) callconv(.c) c_int {
    mutex.lock();
    defer mutex.unlock();
    if (version > 1) return -1;
    if (cipher > 2) return -1;
    for (&sessions, 0..) |*s, i| {
        if (!s.active) {
            s.* = .{
                .state = .client_hello,
                .version = @enumFromInt(version),
                .cipher = @enumFromInt(cipher),
                .cert_status = 255,
                .last_alert = 255,
                .active = true,
            };
            return @intCast(i);
        }
    }
    return -1; // no free slots
}

pub export fn tls_destroy(slot: c_int) callconv(.c) void {
    mutex.lock();
    defer mutex.unlock();
    if (slot < 0 or slot >= MAX_SESSIONS) return;
    sessions[@intCast(slot)].active = false;
}

// -- State queries ----------------------------------------------------------

pub export fn tls_state(slot: c_int) callconv(.c) u8 {
    mutex.lock();
    defer mutex.unlock();
    const idx = validSlot(slot) orelse return 7; // closed as fallback
    return @intFromEnum(sessions[idx].state);
}

pub export fn tls_version(slot: c_int) callconv(.c) u8 {
    mutex.lock();
    defer mutex.unlock();
    const idx = validSlot(slot) orelse return 255;
    return @intFromEnum(sessions[idx].version);
}

pub export fn tls_cipher(slot: c_int) callconv(.c) u8 {
    mutex.lock();
    defer mutex.unlock();
    const idx = validSlot(slot) orelse return 255;
    return @intFromEnum(sessions[idx].cipher);
}

pub export fn tls_can_send(slot: c_int) callconv(.c) u8 {
    mutex.lock();
    defer mutex.unlock();
    const idx = validSlot(slot) orelse return 0;
    return if (sessions[idx].state == .established) 1 else 0;
}

pub export fn tls_last_alert(slot: c_int) callconv(.c) u8 {
    mutex.lock();
    defer mutex.unlock();
    const idx = validSlot(slot) orelse return 255;
    return sessions[idx].last_alert;
}

pub export fn tls_cert_status(slot: c_int) callconv(.c) u8 {
    mutex.lock();
    defer mutex.unlock();
    const idx = validSlot(slot) orelse return 255;
    return sessions[idx].cert_status;
}

// -- Transitions ------------------------------------------------------------

pub export fn tls_advance(slot: c_int) callconv(.c) u8 {
    mutex.lock();
    defer mutex.unlock();
    const idx = validSlot(slot) orelse return 1;
    if (nextState(sessions[idx].state)) |ns| {
        sessions[idx].state = ns;
        return 0; // accepted
    }
    return 1; // rejected (closed or already established)
}

pub export fn tls_abort(slot: c_int, alert_tag: u8) callconv(.c) u8 {
    mutex.lock();
    defer mutex.unlock();
    const idx = validSlot(slot) orelse return 1;
    // Can abort from any state except Closed
    if (sessions[idx].state == .closed) return 1;
    sessions[idx].state = .closed;
    sessions[idx].last_alert = alert_tag;
    return 0;
}

pub export fn tls_key_update(slot: c_int) callconv(.c) u8 {
    mutex.lock();
    defer mutex.unlock();
    const idx = validSlot(slot) orelse return 1;
    if (sessions[idx].state == .established) {
        // Established -> Established (state unchanged, but rekey happened)
        return 0;
    }
    return 1;
}

pub export fn tls_close(slot: c_int) callconv(.c) u8 {
    mutex.lock();
    defer mutex.unlock();
    const idx = validSlot(slot) orelse return 1;
    if (sessions[idx].state == .established) {
        sessions[idx].state = .closed;
        sessions[idx].last_alert = 0; // close_notify
        return 0;
    }
    return 1;
}

// -- Certificate validation -------------------------------------------------

pub export fn tls_validate_cert(slot: c_int, cert_result: u8) callconv(.c) u8 {
    mutex.lock();
    defer mutex.unlock();
    const idx = validSlot(slot) orelse return 1;
    if (cert_result > 8) return 1; // invalid CertValidation tag
    sessions[idx].cert_status = cert_result;
    return 0;
}

// -- Stateless queries ------------------------------------------------------

pub export fn tls_can_transition(from: u8, to: u8) callconv(.c) u8 {
    // Matches Transitions.idr validateHandshakeTransition exactly
    if (from == 0 and to == 1) return 1; // ClientHello -> ServerHello
    if (from == 1 and to == 2) return 1; // ServerHello -> EncryptedExtensions
    if (from == 2 and to == 3) return 1; // EncryptedExtensions -> Certificate
    if (from == 3 and to == 4) return 1; // Certificate -> CertificateVerify
    if (from == 4 and to == 5) return 1; // CertificateVerify -> Finished
    if (from == 5 and to == 6) return 1; // Finished -> Established
    if (from == 6 and to == 6) return 1; // Established -> Established (KeyUpdate)
    if (from == 6 and to == 7) return 1; // Established -> Closed
    // Abort edges: any pre-Established state -> Closed
    if (from == 0 and to == 7) return 1; // ClientHello -> Closed
    if (from == 1 and to == 7) return 1; // ServerHello -> Closed
    if (from == 2 and to == 7) return 1; // EncryptedExtensions -> Closed
    if (from == 3 and to == 7) return 1; // Certificate -> Closed
    if (from == 4 and to == 7) return 1; // CertificateVerify -> Closed
    if (from == 5 and to == 7) return 1; // Finished -> Closed
    return 0;
}
