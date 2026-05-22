// SPDX-License-Identifier: MPL-2.0
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
// kms.zig — Zig FFI implementation of proven-kms.
//
// Implements the Key Management Server primitive with:
//   - Slot-based key context management (up to 64 concurrent keys)
//   - KMIP-style key lifecycle state machine (PreActive -> Active ->
//     Deactivated -> Destroyed, with Compromised branches)
//   - Operation tracking (create, encrypt, decrypt, sign, verify, etc.)
//   - Algorithm and object type metadata
//   - Thread-safe via mutex on global state
//
// Tag values MUST match:
//   - Idris2 ABI (src/KMSABI/Layout.idr)
//   - C header   (generated/abi/kms.h)

const std = @import("std");

// ── Enums (matching Idris2 Layout.idr tag assignments exactly) ──────────

/// ObjectType — matches objectTypeToTag
pub const ObjectType = enum(u8) {
    symmetric_key = 0,
    public_key = 1,
    private_key = 2,
    secret_data = 3,
    certificate = 4,
    opaque_data = 5,
};

/// Operation — matches operationToTag
pub const Operation = enum(u8) {
    create = 0,
    get = 1,
    activate = 2,
    revoke = 3,
    destroy = 4,
    locate = 5,
    register = 6,
    rekey = 7,
    encrypt = 8,
    decrypt = 9,
    sign = 10,
    verify = 11,
    wrap = 12,
    unwrap = 13,
    mac = 14,
};

/// KeyState — matches keyStateToTag
pub const KeyState = enum(u8) {
    pre_active = 0,
    active = 1,
    deactivated = 2,
    compromised = 3,
    destroyed = 4,
    destroyed_compromised = 5,
};

/// Algorithm — matches algorithmToTag
pub const Algorithm = enum(u8) {
    aes128 = 0,
    aes256 = 1,
    rsa2048 = 2,
    rsa4096 = 3,
    ecdsa_p256 = 4,
    ecdsa_p384 = 5,
    ed25519 = 6,
    chacha20_poly1305 = 7,
    hmac_sha256 = 8,
};

/// KMSError — matches kmsErrorToTag
pub const KMSError = enum(u8) {
    ok = 0,
    invalid_slot = 1,
    not_active = 2,
    invalid_transition = 3,
    operation_denied = 4,
    capacity_exhausted = 5,
    unsupported_alg = 6,
    key_destroyed = 7,
};

// ── Key Context instance ────────────────────────────────────────────────

const KeyCtx = struct {
    /// Whether this slot is in use.
    active: bool,
    /// Current lifecycle state.
    state: KeyState,
    /// Type of cryptographic object stored in this slot.
    obj_type: ObjectType,
    /// Cryptographic algorithm associated with the key.
    algorithm: Algorithm,
    /// Last error code (255 = no error).
    last_error: u8,
    /// Number of operations performed on this key.
    operation_count: u32,
};

// ── Global state (slot-based, mutex-protected) ──────────────────────────

const MAX_CONTEXTS: usize = 64;

const empty_ctx: KeyCtx = .{
    .active = false,
    .state = .pre_active,
    .obj_type = .symmetric_key,
    .algorithm = .aes128,
    .last_error = 255,
    .operation_count = 0,
};

var contexts: [MAX_CONTEXTS]KeyCtx = [_]KeyCtx{empty_ctx} ** MAX_CONTEXTS;
var mutex: std.Thread.Mutex = .{};

// ── Helpers ─────────────────────────────────────────────────────────────

/// Validate and return a pointer to an active context, or null.
fn getActive(slot: c_int) ?*KeyCtx {
    if (slot < 0 or slot >= MAX_CONTEXTS) return null;
    const idx: usize = @intCast(slot);
    if (!contexts[idx].active) return null;
    return &contexts[idx];
}

// ── ABI version ─────────────────────────────────────────────────────────

/// ABI version — must match KMSABI.Foreign.abiVersion (currently 1).
pub export fn kms_abi_version() callconv(.c) u32 {
    return 1;
}

// ── Lifecycle ───────────────────────────────────────────────────────────

/// Create a new key context.
/// Returns slot index (0-63) or -1 if no slots available or invalid params.
pub export fn kms_create(obj_type: u8, algorithm: u8) callconv(.c) c_int {
    mutex.lock();
    defer mutex.unlock();

    // Validate obj_type (0-5)
    if (obj_type > 5) return -1;
    // Validate algorithm (0-8)
    if (algorithm > 8) return -1;

    for (&contexts, 0..) |*ctx, i| {
        if (!ctx.active) {
            ctx.* = empty_ctx;
            ctx.active = true;
            ctx.obj_type = @enumFromInt(obj_type);
            ctx.algorithm = @enumFromInt(algorithm);
            return @intCast(i);
        }
    }
    return -1; // all slots occupied
}

/// Destroy a key context, freeing its slot.
/// Safe to call with any slot index (invalid slots are no-ops).
pub export fn kms_destroy(slot: c_int) callconv(.c) void {
    mutex.lock();
    defer mutex.unlock();

    if (slot < 0 or slot >= MAX_CONTEXTS) return;
    const idx: usize = @intCast(slot);
    contexts[idx].active = false;
}

// ── State queries ───────────────────────────────────────────────────────

/// Get the current KeyState tag for a slot.
/// Returns PreActive (0) for invalid/inactive slots.
pub export fn kms_get_state(slot: c_int) callconv(.c) u8 {
    mutex.lock();
    defer mutex.unlock();

    const ctx = getActive(slot) orelse return 0;
    return @intFromEnum(ctx.state);
}

/// Get the ObjectType tag for a slot.
/// Returns SymmetricKey (0) for invalid/inactive slots.
pub export fn kms_get_object_type(slot: c_int) callconv(.c) u8 {
    mutex.lock();
    defer mutex.unlock();

    const ctx = getActive(slot) orelse return 0;
    return @intFromEnum(ctx.obj_type);
}

/// Get the Algorithm tag for a slot.
/// Returns AES128 (0) for invalid/inactive slots.
pub export fn kms_get_algorithm(slot: c_int) callconv(.c) u8 {
    mutex.lock();
    defer mutex.unlock();

    const ctx = getActive(slot) orelse return 0;
    return @intFromEnum(ctx.algorithm);
}

/// Get the number of operations performed on this key.
pub export fn kms_get_operation_count(slot: c_int) callconv(.c) u32 {
    mutex.lock();
    defer mutex.unlock();

    const ctx = getActive(slot) orelse return 0;
    return ctx.operation_count;
}

/// Get the last KMSError tag, or 255 if no error.
pub export fn kms_get_last_error(slot: c_int) callconv(.c) u8 {
    mutex.lock();
    defer mutex.unlock();

    const ctx = getActive(slot) orelse return 255;
    return ctx.last_error;
}

// ── State transitions ───────────────────────────────────────────────────

/// Advance a key to a new state, validating the transition.
/// Returns KMSError tag.
pub export fn kms_transition(slot: c_int, new_state: u8) callconv(.c) u8 {
    mutex.lock();
    defer mutex.unlock();

    const ctx = getActive(slot) orelse return @intFromEnum(KMSError.invalid_slot);

    const from = @intFromEnum(ctx.state);
    if (kms_can_transition(from, new_state) == 0) {
        ctx.last_error = @intFromEnum(KMSError.invalid_transition);
        return @intFromEnum(KMSError.invalid_transition);
    }

    ctx.state = @enumFromInt(new_state);
    ctx.last_error = 255;
    return @intFromEnum(KMSError.ok);
}

/// Record an operation on the key.
/// Key must be in Active state for cryptographic operations.
/// Create (0), Get (1), Locate (5), Register (6) are allowed in any non-destroyed state.
/// Returns KMSError tag.
pub export fn kms_perform_operation(slot: c_int, operation: u8) callconv(.c) u8 {
    mutex.lock();
    defer mutex.unlock();

    const ctx = getActive(slot) orelse return @intFromEnum(KMSError.invalid_slot);

    // Validate operation (0-14)
    if (operation > 14) {
        ctx.last_error = @intFromEnum(KMSError.invalid_transition);
        return @intFromEnum(KMSError.invalid_transition);
    }

    // Destroyed keys cannot have any operations performed
    if (ctx.state == .destroyed or ctx.state == .destroyed_compromised) {
        ctx.last_error = @intFromEnum(KMSError.key_destroyed);
        return @intFromEnum(KMSError.key_destroyed);
    }

    // Cryptographic operations (encrypt, decrypt, sign, verify, wrap,
    // unwrap, mac) require Active state
    if (operation >= 8 and operation <= 14) {
        if (ctx.state != .active) {
            ctx.last_error = @intFromEnum(KMSError.operation_denied);
            return @intFromEnum(KMSError.operation_denied);
        }
    }

    ctx.operation_count += 1;
    ctx.last_error = 255;
    return @intFromEnum(KMSError.ok);
}

// ── Stateless transition validation ─────────────────────────────────────

/// Check whether a key state transition is valid.
/// Returns 1 if valid, 0 if not.
/// Models KMIP key lifecycle per SP 800-57.
pub export fn kms_can_transition(from: u8, to: u8) callconv(.c) u8 {
    // PreActive (0) -> Active (1)
    if (from == 0 and to == 1) return 1;
    // PreActive (0) -> Destroyed (4) (never activated, discard)
    if (from == 0 and to == 4) return 1;
    // Active (1) -> Deactivated (2)
    if (from == 1 and to == 2) return 1;
    // Active (1) -> Compromised (3)
    if (from == 1 and to == 3) return 1;
    // Active (1) -> Destroyed (4)
    if (from == 1 and to == 4) return 1;
    // Deactivated (2) -> Destroyed (4)
    if (from == 2 and to == 4) return 1;
    // Deactivated (2) -> Compromised (3)
    if (from == 2 and to == 3) return 1;
    // Compromised (3) -> DestroyedCompromised (5)
    if (from == 3 and to == 5) return 1;
    // PreActive (0) -> Compromised (3) (key compromised before activation)
    if (from == 0 and to == 3) return 1;
    return 0;
}
