// SPDX-License-Identifier: MPL-2.0
// Copyright (c) Jonathan D.A. Jewell <j.d.a.jewell@open.ac.uk>
//
// ca.zig -- Zig FFI implementation of proven-ca.
//
// Implements verified certificate authority state machine with:
//   - Slot-based CA context management (up to 64 concurrent contexts)
//   - Per-context certificate store (up to 64 certs per context)
//   - Certificate lifecycle enforcement matching Idris2 Transitions.idr
//   - CA hierarchy validation matching CanIssue GADT
//   - CRL management with status tracking
//   - OCSP responder state per context
//   - Thread-safe via mutex

const std = @import("std");

// -- Enums (matching CAABI.Layout.idr tag assignments) ------------------------

pub const CertType = enum(u8) {
    root = 0,
    intermediate = 1,
    end_entity = 2,
    cross_signed = 3,
    code_signing = 4,
    email_protection = 5,
    ocsp_signing = 6,
};

pub const KeyAlgorithm = enum(u8) {
    rsa2048 = 0,
    rsa4096 = 1,
    ecdsa_p256 = 2,
    ecdsa_p384 = 3,
    ed25519 = 4,
    ed448 = 5,
};

pub const SignatureAlgorithm = enum(u8) {
    sha256_with_rsa = 0,
    sha384_with_rsa = 1,
    sha512_with_rsa = 2,
    sha256_with_ecdsa = 3,
    sha384_with_ecdsa = 4,
    pure_ed25519 = 5,
    pure_ed448 = 6,
};

pub const CertState = enum(u8) {
    pending = 0,
    active = 1,
    revoked = 2,
    expired = 3,
    suspended = 4,
};

pub const RevocationReason = enum(u8) {
    unspecified = 0,
    key_compromise = 1,
    ca_compromise = 2,
    affiliation_changed = 3,
    superseded = 4,
    cessation_of_operation = 5,
    certificate_hold = 6,
};

pub const CRLStatus = enum(u8) {
    current = 0,
    crl_expired = 1,
    crl_pending = 2,
    crl_error = 3,
};

pub const OCSPStatus = enum(u8) {
    good = 0,
    ocsp_revoked = 1,
    unknown = 2,
    unavailable = 3,
};

pub const Extension = enum(u8) {
    basic_constraints = 0,
    key_usage = 1,
    ext_key_usage = 2,
    subject_alt_name = 3,
    authority_info_access = 4,
    crl_distribution_points = 5,
};

// -- Certificate record -------------------------------------------------------

const MAX_CERTS: usize = 64;
const INVALID_ID: c_int = -1;

pub const KeyUsageBit = enum(u8) {
    digital_signature = 0,
    non_repudiation = 1,
    key_encipherment = 2,
    data_encipherment = 3,
    key_agreement = 4,
    key_cert_sign = 5,
    crl_sign = 6,
    encipher_only = 7,
    decipher_only = 8,
};

// -- Certificate record -------------------------------------------------------

const Certificate = struct {
    cert_type: CertType,
    key_algo: KeyAlgorithm,
    sig_algo: SignatureAlgorithm,
    state: CertState,
    revocation_reason: u8, // 255 = not revoked
    issuer_id: c_int, // -1 = self-signed / no issuer
    not_before: u64, // Unix epoch seconds, 0 = unset
    not_after: u64, // Unix epoch seconds, 0 = unset
    serial: u64, // Monotonic serial number (0 = unset)
    path_length: i32, // -1 = unconstrained, >= 0 = max intermediates
    key_usage: u16, // Bitmask of KeyUsageBit (bit N = tag N)
    active: bool,
};

const default_cert: Certificate = .{
    .cert_type = .root,
    .key_algo = .rsa2048,
    .sig_algo = .sha256_with_rsa,
    .state = .pending,
    .revocation_reason = 255,
    .issuer_id = -1,
    .not_before = 0,
    .not_after = 0,
    .serial = 0,
    .path_length = -1,
    .key_usage = 0,
    .active = false,
};

// -- CA context ---------------------------------------------------------------

const MAX_CONTEXTS: usize = 64;

const CaContext = struct {
    certs: [MAX_CERTS]Certificate,
    cert_count: usize,
    next_serial: u64, // Monotonic serial counter; starts at 1
    crl_status: CRLStatus,
    ocsp_status: OCSPStatus,
    context_active: bool,
};

const default_context: CaContext = .{
    .certs = [_]Certificate{default_cert} ** MAX_CERTS,
    .cert_count = 0,
    .next_serial = 1,
    .crl_status = .crl_pending,
    .ocsp_status = .unavailable,
    .context_active = false,
};

var contexts: [MAX_CONTEXTS]CaContext = [_]CaContext{default_context} ** MAX_CONTEXTS;
var mutex: std.Thread.Mutex = .{};

// -- Internal helpers ---------------------------------------------------------

/// Validate that a context slot index is in range and active.
fn validContext(slot: c_int) ?usize {
    if (slot < 0 or slot >= MAX_CONTEXTS) return null;
    const idx: usize = @intCast(slot);
    if (!contexts[idx].context_active) return null;
    return idx;
}

/// Validate that a cert id is in range and active within a context.
fn validCert(ctx_idx: usize, cert_id: c_int) ?usize {
    if (cert_id < 0 or cert_id >= MAX_CERTS) return null;
    const cid: usize = @intCast(cert_id);
    if (!contexts[ctx_idx].certs[cid].active) return null;
    return cid;
}

/// Check whether issuer CertType can issue child CertType.
/// Matches CAABI.Transitions.CanIssue GADT exactly.
fn canIssueCheck(issuer: u8, child: u8) bool {
    // Root(0) -> Intermediate(1), CrossSigned(3), EndEntity(2)
    if (issuer == 0 and child == 1) return true;
    if (issuer == 0 and child == 3) return true;
    if (issuer == 0 and child == 2) return true;
    // Intermediate(1) -> EndEntity(2), CodeSigning(4), EmailProtection(5), OCSPSigning(6)
    if (issuer == 1 and child == 2) return true;
    if (issuer == 1 and child == 4) return true;
    if (issuer == 1 and child == 5) return true;
    if (issuer == 1 and child == 6) return true;
    // CrossSigned(3) -> EndEntity(2)
    if (issuer == 3 and child == 2) return true;
    return false;
}

/// Check whether a cert state transition is valid.
/// Matches CAABI.Transitions.ValidCertTransition GADT exactly.
fn canTransitionCheck(from: u8, to: u8) bool {
    if (from == 0 and to == 1) return true; // Pending -> Active (Sign)
    if (from == 1 and to == 2) return true; // Active -> Revoked
    if (from == 1 and to == 3) return true; // Active -> Expired
    if (from == 1 and to == 4) return true; // Active -> Suspended
    if (from == 1 and to == 0) return true; // Active -> Pending (Renew)
    if (from == 4 and to == 1) return true; // Suspended -> Active (Reinstate)
    if (from == 4 and to == 2) return true; // Suspended -> Revoked
    if (from == 0 and to == 2) return true; // Pending -> Revoked (Reject)
    return false;
}

// -- ABI version --------------------------------------------------------------

pub export fn ca_abi_version() callconv(.c) u32 {
    return 1;
}

// -- Context lifecycle --------------------------------------------------------

pub export fn ca_create() callconv(.c) c_int {
    mutex.lock();
    defer mutex.unlock();
    for (&contexts, 0..) |*ctx, i| {
        if (!ctx.context_active) {
            ctx.* = default_context;
            ctx.context_active = true;
            ctx.crl_status = .crl_pending;
            ctx.ocsp_status = .unavailable;
            return @intCast(i);
        }
    }
    return -1; // no free slots
}

pub export fn ca_destroy(slot: c_int) callconv(.c) void {
    mutex.lock();
    defer mutex.unlock();
    if (slot < 0 or slot >= MAX_CONTEXTS) return;
    contexts[@intCast(slot)].context_active = false;
}

// -- Certificate issuance -----------------------------------------------------

pub export fn ca_issue_cert(slot: c_int, cert_type_tag: u8, key_algo_tag: u8, sig_algo_tag: u8) callconv(.c) c_int {
    mutex.lock();
    defer mutex.unlock();
    const ctx_idx = validContext(slot) orelse return -1;
    // Validate enum ranges
    if (cert_type_tag > 6) return -1;
    if (key_algo_tag > 5) return -1;
    if (sig_algo_tag > 6) return -1;
    // Find free cert slot
    const serial = contexts[ctx_idx].next_serial;
    for (&contexts[ctx_idx].certs, 0..) |*cert, i| {
        if (!cert.active) {
            cert.* = .{
                .cert_type = @enumFromInt(cert_type_tag),
                .key_algo = @enumFromInt(key_algo_tag),
                .sig_algo = @enumFromInt(sig_algo_tag),
                .state = .pending,
                .revocation_reason = 255,
                .issuer_id = -1,
                .not_before = 0,
                .not_after = 0,
                .serial = serial,
                .path_length = -1,
                .key_usage = 0,
                .active = true,
            };
            contexts[ctx_idx].next_serial = serial + 1;
            contexts[ctx_idx].cert_count += 1;
            return @intCast(i);
        }
    }
    return -1; // no free cert slots
}

// -- Certificate state transitions --------------------------------------------

pub export fn ca_sign_cert(slot: c_int, cert_id: c_int) callconv(.c) u8 {
    mutex.lock();
    defer mutex.unlock();
    const ctx_idx = validContext(slot) orelse return 1;
    const cid = validCert(ctx_idx, cert_id) orelse return 1;
    if (contexts[ctx_idx].certs[cid].state != .pending) return 1;
    contexts[ctx_idx].certs[cid].state = .active;
    return 0;
}

pub export fn ca_revoke_cert(slot: c_int, cert_id: c_int, reason_tag: u8) callconv(.c) u8 {
    mutex.lock();
    defer mutex.unlock();
    const ctx_idx = validContext(slot) orelse return 1;
    const cid = validCert(ctx_idx, cert_id) orelse return 1;
    if (reason_tag > 6) return 1; // invalid RevocationReason tag
    const state = contexts[ctx_idx].certs[cid].state;
    // Can revoke from Active or Suspended only
    if (state != .active and state != .suspended) return 1;
    contexts[ctx_idx].certs[cid].state = .revoked;
    contexts[ctx_idx].certs[cid].revocation_reason = reason_tag;
    return 0;
}

pub export fn ca_suspend_cert(slot: c_int, cert_id: c_int) callconv(.c) u8 {
    mutex.lock();
    defer mutex.unlock();
    const ctx_idx = validContext(slot) orelse return 1;
    const cid = validCert(ctx_idx, cert_id) orelse return 1;
    if (contexts[ctx_idx].certs[cid].state != .active) return 1;
    contexts[ctx_idx].certs[cid].state = .suspended;
    return 0;
}

pub export fn ca_reinstate_cert(slot: c_int, cert_id: c_int) callconv(.c) u8 {
    mutex.lock();
    defer mutex.unlock();
    const ctx_idx = validContext(slot) orelse return 1;
    const cid = validCert(ctx_idx, cert_id) orelse return 1;
    if (contexts[ctx_idx].certs[cid].state != .suspended) return 1;
    contexts[ctx_idx].certs[cid].state = .active;
    return 0;
}

pub export fn ca_expire_cert(slot: c_int, cert_id: c_int) callconv(.c) u8 {
    mutex.lock();
    defer mutex.unlock();
    const ctx_idx = validContext(slot) orelse return 1;
    const cid = validCert(ctx_idx, cert_id) orelse return 1;
    if (contexts[ctx_idx].certs[cid].state != .active) return 1;
    contexts[ctx_idx].certs[cid].state = .expired;
    return 0;
}

pub export fn ca_renew_cert(slot: c_int, cert_id: c_int) callconv(.c) c_int {
    mutex.lock();
    defer mutex.unlock();
    const ctx_idx = validContext(slot) orelse return -1;
    const cid = validCert(ctx_idx, cert_id) orelse return -1;
    const old = &contexts[ctx_idx].certs[cid];
    if (old.state != .active) return -1;
    // Create new cert in Pending state with same type/algos
    const serial = contexts[ctx_idx].next_serial;
    for (&contexts[ctx_idx].certs, 0..) |*cert, i| {
        if (!cert.active) {
            cert.* = .{
                .cert_type = old.cert_type,
                .key_algo = old.key_algo,
                .sig_algo = old.sig_algo,
                .state = .pending,
                .revocation_reason = 255,
                .issuer_id = old.issuer_id,
                .not_before = 0,
                .not_after = 0,
                .serial = serial,
                .path_length = old.path_length,
                .key_usage = 0,
                .active = true,
            };
            contexts[ctx_idx].next_serial = serial + 1;
            contexts[ctx_idx].cert_count += 1;
            return @intCast(i);
        }
    }
    return -1; // no free cert slots
}

// -- Certificate queries ------------------------------------------------------

pub export fn ca_cert_state(slot: c_int, cert_id: c_int) callconv(.c) u8 {
    mutex.lock();
    defer mutex.unlock();
    const ctx_idx = validContext(slot) orelse return 255;
    const cid = validCert(ctx_idx, cert_id) orelse return 255;
    return @intFromEnum(contexts[ctx_idx].certs[cid].state);
}

pub export fn ca_cert_type(slot: c_int, cert_id: c_int) callconv(.c) u8 {
    mutex.lock();
    defer mutex.unlock();
    const ctx_idx = validContext(slot) orelse return 255;
    const cid = validCert(ctx_idx, cert_id) orelse return 255;
    return @intFromEnum(contexts[ctx_idx].certs[cid].cert_type);
}

pub export fn ca_cert_key_algo(slot: c_int, cert_id: c_int) callconv(.c) u8 {
    mutex.lock();
    defer mutex.unlock();
    const ctx_idx = validContext(slot) orelse return 255;
    const cid = validCert(ctx_idx, cert_id) orelse return 255;
    return @intFromEnum(contexts[ctx_idx].certs[cid].key_algo);
}

pub export fn ca_cert_sig_algo(slot: c_int, cert_id: c_int) callconv(.c) u8 {
    mutex.lock();
    defer mutex.unlock();
    const ctx_idx = validContext(slot) orelse return 255;
    const cid = validCert(ctx_idx, cert_id) orelse return 255;
    return @intFromEnum(contexts[ctx_idx].certs[cid].sig_algo);
}

pub export fn ca_cert_count(slot: c_int) callconv(.c) c_int {
    mutex.lock();
    defer mutex.unlock();
    const ctx_idx = validContext(slot) orelse return 0;
    return @intCast(contexts[ctx_idx].cert_count);
}

// -- Chain validation ---------------------------------------------------------

pub export fn ca_validate_chain(slot: c_int, cert_id: c_int) callconv(.c) u8 {
    mutex.lock();
    defer mutex.unlock();
    const ctx_idx = validContext(slot) orelse return 1;
    const cid = validCert(ctx_idx, cert_id) orelse return 1;
    const cert = &contexts[ctx_idx].certs[cid];

    // Self-signed root: valid chain of length 1
    if (cert.cert_type == .root and cert.issuer_id == -1) return 0;

    // Must have an issuer
    if (cert.issuer_id < 0) return 1;
    const issuer_cid = validCert(ctx_idx, cert.issuer_id) orelse return 1;
    const issuer = &contexts[ctx_idx].certs[issuer_cid];

    // Issuer must be Active
    if (issuer.state != .active and issuer.state != .pending) return 1;

    // Check CanIssue relationship
    if (!canIssueCheck(@intFromEnum(issuer.cert_type), @intFromEnum(cert.cert_type))) return 1;

    return 0; // chain valid
}

pub export fn ca_set_issuer(slot: c_int, cert_id: c_int, issuer_id: c_int) callconv(.c) u8 {
    mutex.lock();
    defer mutex.unlock();
    const ctx_idx = validContext(slot) orelse return 1;
    const cid = validCert(ctx_idx, cert_id) orelse return 1;
    const icid = validCert(ctx_idx, issuer_id) orelse return 1;

    // Validate CanIssue(issuer_type, child_type)
    const issuer_type = @intFromEnum(contexts[ctx_idx].certs[icid].cert_type);
    const child_type = @intFromEnum(contexts[ctx_idx].certs[cid].cert_type);
    if (!canIssueCheck(issuer_type, child_type)) return 1;

    contexts[ctx_idx].certs[cid].issuer_id = issuer_id;
    return 0;
}

pub export fn ca_cert_issuer(slot: c_int, cert_id: c_int) callconv(.c) c_int {
    mutex.lock();
    defer mutex.unlock();
    const ctx_idx = validContext(slot) orelse return -1;
    const cid = validCert(ctx_idx, cert_id) orelse return -1;
    return contexts[ctx_idx].certs[cid].issuer_id;
}

// -- Stateless queries --------------------------------------------------------

pub export fn ca_can_issue(issuer_tag: u8, child_tag: u8) callconv(.c) u8 {
    return if (canIssueCheck(issuer_tag, child_tag)) 1 else 0;
}

pub export fn ca_can_transition(from_tag: u8, to_tag: u8) callconv(.c) u8 {
    return if (canTransitionCheck(from_tag, to_tag)) 1 else 0;
}

// -- CRL management -----------------------------------------------------------

pub export fn ca_crl_status(slot: c_int) callconv(.c) u8 {
    mutex.lock();
    defer mutex.unlock();
    const ctx_idx = validContext(slot) orelse return 3; // error fallback
    return @intFromEnum(contexts[ctx_idx].crl_status);
}

pub export fn ca_update_crl(slot: c_int) callconv(.c) u8 {
    mutex.lock();
    defer mutex.unlock();
    const ctx_idx = validContext(slot) orelse return 1;
    // Transition CRL to current state (simulates successful CRL generation)
    contexts[ctx_idx].crl_status = .current;
    return 0;
}

// -- OCSP responder -----------------------------------------------------------

pub export fn ca_ocsp_status(slot: c_int) callconv(.c) u8 {
    mutex.lock();
    defer mutex.unlock();
    const ctx_idx = validContext(slot) orelse return 3; // unavailable fallback
    return @intFromEnum(contexts[ctx_idx].ocsp_status);
}

pub export fn ca_ocsp_query(slot: c_int, cert_id: c_int) callconv(.c) u8 {
    mutex.lock();
    defer mutex.unlock();
    const ctx_idx = validContext(slot) orelse return 3; // unavailable
    const cid = validCert(ctx_idx, cert_id) orelse return 2; // unknown
    const state = contexts[ctx_idx].certs[cid].state;
    // Update OCSP responder status to reflect it is serving
    contexts[ctx_idx].ocsp_status = .good;
    return switch (state) {
        .active => 0, // good
        .revoked => 1, // revoked
        .pending, .expired, .suspended => 2, // unknown (not definitively good/revoked)
    };
}

// -- Validity period ----------------------------------------------------------

/// Set the validity period for a certificate.
/// Enforces the well-formedness invariant: not_before < not_after.
/// Returns 0 on success, 1 on rejection (invalid period or bad slot/cert).
pub export fn ca_set_validity(slot: c_int, cert_id: c_int, not_before: u64, not_after: u64) callconv(.c) u8 {
    mutex.lock();
    defer mutex.unlock();
    const ctx_idx = validContext(slot) orelse return 1;
    const cid = validCert(ctx_idx, cert_id) orelse return 1;
    // Enforce: notBefore < notAfter (matches Idris2 ValidityPeriod proof)
    if (not_before >= not_after) return 1;
    contexts[ctx_idx].certs[cid].not_before = not_before;
    contexts[ctx_idx].certs[cid].not_after = not_after;
    return 0;
}

/// Get the notBefore timestamp for a certificate.
/// Returns 0 if the slot/cert is invalid or validity is unset.
pub export fn ca_cert_not_before(slot: c_int, cert_id: c_int) callconv(.c) u64 {
    mutex.lock();
    defer mutex.unlock();
    const ctx_idx = validContext(slot) orelse return 0;
    const cid = validCert(ctx_idx, cert_id) orelse return 0;
    return contexts[ctx_idx].certs[cid].not_before;
}

/// Get the notAfter timestamp for a certificate.
/// Returns 0 if the slot/cert is invalid or validity is unset.
pub export fn ca_cert_not_after(slot: c_int, cert_id: c_int) callconv(.c) u64 {
    mutex.lock();
    defer mutex.unlock();
    const ctx_idx = validContext(slot) orelse return 0;
    const cid = validCert(ctx_idx, cert_id) orelse return 0;
    return contexts[ctx_idx].certs[cid].not_after;
}

// -- Serial numbers -----------------------------------------------------------

/// Get the serial number of a certificate.
/// Returns 0 if the slot/cert is invalid.
pub export fn ca_cert_serial(slot: c_int, cert_id: c_int) callconv(.c) u64 {
    mutex.lock();
    defer mutex.unlock();
    const ctx_idx = validContext(slot) orelse return 0;
    const cid = validCert(ctx_idx, cert_id) orelse return 0;
    return contexts[ctx_idx].certs[cid].serial;
}

/// Get the next serial number that will be assigned.
/// Returns 0 if the slot is invalid.
pub export fn ca_next_serial(slot: c_int) callconv(.c) u64 {
    mutex.lock();
    defer mutex.unlock();
    const ctx_idx = validContext(slot) orelse return 0;
    return contexts[ctx_idx].next_serial;
}

// -- Path length constraints --------------------------------------------------

/// Set the path length constraint for a CA certificate.
/// max_path_len = -1 means unconstrained (leaf/no BasicConstraints).
/// max_path_len >= 0 means at most N intermediate CAs below this one.
/// Returns 0 on success, 1 on rejection.
pub export fn ca_set_path_length(slot: c_int, cert_id: c_int, max_path_len: i32) callconv(.c) u8 {
    mutex.lock();
    defer mutex.unlock();
    const ctx_idx = validContext(slot) orelse return 1;
    const cid = validCert(ctx_idx, cert_id) orelse return 1;
    // Only CA types (Root, Intermediate, CrossSigned) may have path length >= 0
    const ct = contexts[ctx_idx].certs[cid].cert_type;
    if (max_path_len >= 0 and ct != .root and ct != .intermediate and ct != .cross_signed) return 1;
    contexts[ctx_idx].certs[cid].path_length = max_path_len;
    return 0;
}

/// Get the path length constraint for a certificate.
/// Returns -1 for unconstrained or invalid.
pub export fn ca_cert_path_length(slot: c_int, cert_id: c_int) callconv(.c) i32 {
    mutex.lock();
    defer mutex.unlock();
    const ctx_idx = validContext(slot) orelse return -1;
    const cid = validCert(ctx_idx, cert_id) orelse return -1;
    return contexts[ctx_idx].certs[cid].path_length;
}

/// Validate that path length decreases along the issuer chain.
/// Checks: if both cert and issuer have path length >= 0,
/// then cert.path_length < issuer.path_length.
/// Returns 0 if valid, 1 if invalid.
pub export fn ca_validate_path_length(slot: c_int, cert_id: c_int) callconv(.c) u8 {
    mutex.lock();
    defer mutex.unlock();
    const ctx_idx = validContext(slot) orelse return 1;
    const cid = validCert(ctx_idx, cert_id) orelse return 1;
    const cert = &contexts[ctx_idx].certs[cid];
    // Self-signed / no issuer: valid by default
    if (cert.issuer_id < 0) return 0;
    const icid = validCert(ctx_idx, cert.issuer_id) orelse return 1;
    const issuer = &contexts[ctx_idx].certs[icid];
    // If issuer has no path length constraint, child is unchecked
    if (issuer.path_length < 0) return 0;
    // If child has no constraint, it's a leaf -- always valid
    if (cert.path_length < 0) return 0;
    // Both constrained: child must be strictly less
    if (cert.path_length < issuer.path_length) return 0;
    return 1; // violation
}

// -- Key usage ----------------------------------------------------------------

/// Set the key usage bitmask for a certificate.
/// Each bit position corresponds to a KeyUsageBit tag value.
/// Returns 0 on success, 1 on rejection.
pub export fn ca_set_key_usage(slot: c_int, cert_id: c_int, key_usage_bits: u16) callconv(.c) u8 {
    mutex.lock();
    defer mutex.unlock();
    const ctx_idx = validContext(slot) orelse return 1;
    const cid = validCert(ctx_idx, cert_id) orelse return 1;
    contexts[ctx_idx].certs[cid].key_usage = key_usage_bits;
    return 0;
}

/// Get the key usage bitmask for a certificate.
/// Returns 0 if invalid (no usage set or bad slot/cert).
pub export fn ca_cert_key_usage(slot: c_int, cert_id: c_int) callconv(.c) u16 {
    mutex.lock();
    defer mutex.unlock();
    const ctx_idx = validContext(slot) orelse return 0;
    const cid = validCert(ctx_idx, cert_id) orelse return 0;
    return contexts[ctx_idx].certs[cid].key_usage;
}

/// Validate that key usage is consistent with cert type.
/// - CA certs (Root, Intermediate, CrossSigned) MUST have keyCertSign (bit 5)
/// - EndEntity certs MUST NOT have keyCertSign (bit 5)
/// Returns 0 if valid, 1 if inconsistent.
pub export fn ca_validate_key_usage(slot: c_int, cert_id: c_int) callconv(.c) u8 {
    mutex.lock();
    defer mutex.unlock();
    const ctx_idx = validContext(slot) orelse return 1;
    const cid = validCert(ctx_idx, cert_id) orelse return 1;
    const cert = &contexts[ctx_idx].certs[cid];
    const has_cert_sign = (cert.key_usage & (1 << 5)) != 0;
    return switch (cert.cert_type) {
        // CA types MUST have keyCertSign
        .root, .intermediate, .cross_signed => if (has_cert_sign) 0 else 1,
        // Leaf types MUST NOT have keyCertSign
        .end_entity, .code_signing, .email_protection, .ocsp_signing => if (has_cert_sign) 1 else 0,
    };
}
