// SPDX-License-Identifier: MPL-2.0
// Copyright (c) Jonathan D.A. Jewell <j.d.a.jewell@open.ac.uk>
//
// pqc.zig -- Zig FFI implementation of proven-pqc.
//
// Implements verified Post-Quantum Cryptography key lifecycle with:
//   - Slot-based context management (up to 64 concurrent)
//   - Key lifecycle state machine matching Idris2 Transitions.idr
//   - Hybrid negotiation state machine (classical + PQC selection)
//   - Algorithm/NIST-level validation per Layout.idr tables
//   - Category-aware operation validation (KEM vs Signature)
//   - Thread-safe via mutex

const std = @import("std");

// -- Enums (matching PQCABI.Layout.idr tag assignments) ----------------------

/// PQC algorithm families (8 constructors, tags 0-7).
pub const PQCAlgorithm = enum(u8) {
    crystals_kyber = 0,
    crystals_dilithium = 1,
    falcon = 2,
    sphincs_plus = 3,
    classic_mceliece = 4,
    bike = 5,
    hqc = 6,
    frodokem = 7,
};

/// NIST security levels (5 constructors, tags 0-4).
pub const NISTLevel = enum(u8) {
    nist_1 = 0,
    nist_2 = 1,
    nist_3 = 2,
    nist_4 = 3,
    nist_5 = 4,
};

/// Cryptographic operations (5 constructors, tags 0-4).
pub const Operation = enum(u8) {
    keygen = 0,
    encapsulate = 1,
    decapsulate = 2,
    sign = 3,
    verify = 4,
};

/// Hybrid operation modes (3 constructors, tags 0-2).
pub const HybridMode = enum(u8) {
    classical_only = 0,
    pqc_only = 1,
    hybrid = 2,
};

/// Algorithm categories (2 constructors, tags 0-1).
pub const AlgorithmCategory = enum(u8) {
    kem = 0,
    signature = 1,
};

/// Key lifecycle states (6 constructors, tags 0-5).
pub const KeyState = enum(u8) {
    empty = 0,
    generating = 1,
    generated = 2,
    active = 3,
    expired = 4,
    compromised = 5,
};

/// Hybrid negotiation states (5 constructors, tags 0-4).
pub const HybridState = enum(u8) {
    idle = 0,
    classical_selected = 1,
    pqc_selected = 2,
    negotiated = 3,
    complete = 4,
};

// -- Constants ----------------------------------------------------------------

/// Maximum number of concurrent PQC contexts (slot pool size).
const MAX_CONTEXTS: usize = 64;

/// Maximum key material buffer size (bytes).
const MAX_KEY_LEN: usize = 4096;

// -- PQC context --------------------------------------------------------------

/// A single PQC key lifecycle context.
const Context = struct {
    /// Current key lifecycle state.
    key_state: KeyState,
    /// Current hybrid negotiation state.
    hybrid_state: HybridState,
    /// PQC algorithm selected.
    algorithm: u8,
    /// NIST security level.
    nist_level: u8,
    /// Hybrid mode.
    hybrid_mode: u8,
    /// Public key buffer and length.
    pk_buf: [MAX_KEY_LEN]u8,
    pk_len: u32,
    /// Secret key buffer and length.
    sk_buf: [MAX_KEY_LEN]u8,
    sk_len: u32,
    /// Whether this slot is in use.
    active: bool,
};

const DEFAULT_CONTEXT: Context = .{
    .key_state = .empty,
    .hybrid_state = .idle,
    .algorithm = 0,
    .nist_level = 0,
    .hybrid_mode = 1, // PQCOnly default
    .pk_buf = [_]u8{0} ** MAX_KEY_LEN,
    .pk_len = 0,
    .sk_buf = [_]u8{0} ** MAX_KEY_LEN,
    .sk_len = 0,
    .active = false,
};

/// Pool of PQC contexts.
var contexts: [MAX_CONTEXTS]Context = [_]Context{DEFAULT_CONTEXT} ** MAX_CONTEXTS;

/// Mutex protecting the context pool.
var mutex: std.Thread.Mutex = .{};

/// Validate a slot index and return it as usize if active.
fn validSlot(slot: c_int) ?usize {
    if (slot < 0 or slot >= MAX_CONTEXTS) return null;
    const idx: usize = @intCast(slot);
    if (!contexts[idx].active) return null;
    return idx;
}

/// Determine algorithm category from algorithm tag.
fn algorithmCategoryFromTag(algo: u8) u8 {
    return switch (algo) {
        0 => 0, // Kyber -> KEM
        4 => 0, // Classic McEliece -> KEM
        5 => 0, // BIKE -> KEM
        6 => 0, // HQC -> KEM
        7 => 0, // FrodoKEM -> KEM
        1 => 1, // Dilithium -> Signature
        2 => 1, // FALCON -> Signature
        3 => 1, // SPHINCS+ -> Signature
        else => 255,
    };
}

// -- ABI version --------------------------------------------------------------

/// Returns the ABI version number. Must match PQCABI.Foreign.abiVersion.
pub export fn pqc_abi_version() callconv(.c) u32 {
    return 1;
}

// -- Lifecycle ----------------------------------------------------------------

/// Create a new PQC context with the given algorithm and NIST level.
/// Returns a non-negative slot index on success, or -1 on failure.
pub export fn pqc_create_context(algo: u8, level: u8) callconv(.c) c_int {
    mutex.lock();
    defer mutex.unlock();

    if (algo > 7) return -1;
    if (level > 4) return -1;
    // Validate algorithm+level combination.
    if (pqc_valid_algorithm_level(algo, level) == 0) return -1;

    for (&contexts, 0..) |*ctx, i| {
        if (!ctx.active) {
            ctx.* = DEFAULT_CONTEXT;
            ctx.active = true;
            ctx.key_state = .empty;
            ctx.hybrid_state = .idle;
            ctx.algorithm = algo;
            ctx.nist_level = level;
            return @intCast(i);
        }
    }
    return -1;
}

/// Destroy a PQC context, freeing its slot for reuse.
pub export fn pqc_destroy_context(slot: c_int) callconv(.c) void {
    mutex.lock();
    defer mutex.unlock();
    if (slot < 0 or slot >= MAX_CONTEXTS) return;
    contexts[@intCast(slot)] = DEFAULT_CONTEXT;
}

// -- State queries ------------------------------------------------------------

/// Returns the current key state tag. Returns 4 (Expired) for invalid slots.
pub export fn pqc_key_state(slot: c_int) callconv(.c) u8 {
    mutex.lock();
    defer mutex.unlock();
    const idx = validSlot(slot) orelse return 4;
    return @intFromEnum(contexts[idx].key_state);
}

/// Returns the current hybrid state tag. Returns 4 (Complete) for invalid slots.
pub export fn pqc_hybrid_state(slot: c_int) callconv(.c) u8 {
    mutex.lock();
    defer mutex.unlock();
    const idx = validSlot(slot) orelse return 4;
    return @intFromEnum(contexts[idx].hybrid_state);
}

/// Returns the PQC algorithm tag. Returns 255 for invalid slots.
pub export fn pqc_algorithm(slot: c_int) callconv(.c) u8 {
    mutex.lock();
    defer mutex.unlock();
    const idx = validSlot(slot) orelse return 255;
    return contexts[idx].algorithm;
}

/// Returns the NIST level tag. Returns 255 for invalid slots.
pub export fn pqc_nist_level(slot: c_int) callconv(.c) u8 {
    mutex.lock();
    defer mutex.unlock();
    const idx = validSlot(slot) orelse return 255;
    return contexts[idx].nist_level;
}

/// Returns the hybrid mode tag. Returns 255 for invalid slots.
pub export fn pqc_hybrid_mode(slot: c_int) callconv(.c) u8 {
    mutex.lock();
    defer mutex.unlock();
    const idx = validSlot(slot) orelse return 255;
    return contexts[idx].hybrid_mode;
}

/// Returns the algorithm category tag. Returns 255 for invalid slots.
pub export fn pqc_category(slot: c_int) callconv(.c) u8 {
    mutex.lock();
    defer mutex.unlock();
    const idx = validSlot(slot) orelse return 255;
    return algorithmCategoryFromTag(contexts[idx].algorithm);
}

// -- Key lifecycle transitions ------------------------------------------------

/// Begin key generation. Empty -> Generating. Returns 0=ok, 1=rejected.
pub export fn pqc_begin_keygen(slot: c_int) callconv(.c) u8 {
    mutex.lock();
    defer mutex.unlock();
    const idx = validSlot(slot) orelse return 1;
    if (contexts[idx].key_state != .empty) return 1;

    contexts[idx].key_state = .generating;
    return 0;
}

/// Finish key generation. Generating -> Generated.
/// Stores public and secret key material. Returns 0=ok, 1=rejected.
pub export fn pqc_finish_keygen(slot: c_int, pk: ?[*]const u8, pk_len: u32, sk: ?[*]const u8, sk_len: u32) callconv(.c) u8 {
    mutex.lock();
    defer mutex.unlock();
    const idx = validSlot(slot) orelse return 1;
    if (contexts[idx].key_state != .generating) return 1;
    const pk_ptr = pk orelse return 1;
    const sk_ptr = sk orelse return 1;
    if (pk_len == 0 or pk_len > MAX_KEY_LEN) return 1;
    if (sk_len == 0 or sk_len > MAX_KEY_LEN) return 1;

    const pk_l: usize = @intCast(pk_len);
    const sk_l: usize = @intCast(sk_len);
    @memcpy(contexts[idx].pk_buf[0..pk_l], pk_ptr[0..pk_l]);
    @memcpy(contexts[idx].sk_buf[0..sk_l], sk_ptr[0..sk_l]);
    contexts[idx].pk_len = pk_len;
    contexts[idx].sk_len = sk_len;
    contexts[idx].key_state = .generated;
    return 0;
}

/// Activate key. Generated -> Active. Returns 0=ok, 1=rejected.
pub export fn pqc_activate_key(slot: c_int) callconv(.c) u8 {
    mutex.lock();
    defer mutex.unlock();
    const idx = validSlot(slot) orelse return 1;
    if (contexts[idx].key_state != .generated) return 1;

    contexts[idx].key_state = .active;
    return 0;
}

/// Expire key. Active -> Expired or Generated -> Expired.
/// Returns 0=ok, 1=rejected.
pub export fn pqc_expire_key(slot: c_int) callconv(.c) u8 {
    mutex.lock();
    defer mutex.unlock();
    const idx = validSlot(slot) orelse return 1;
    const state = contexts[idx].key_state;
    if (state != .active and state != .generated and state != .empty and state != .generating) return 1;

    contexts[idx].key_state = .expired;
    return 0;
}

/// Mark key as compromised. Active -> Compromised.
/// Returns 0=ok, 1=rejected.
pub export fn pqc_compromise_key(slot: c_int) callconv(.c) u8 {
    mutex.lock();
    defer mutex.unlock();
    const idx = validSlot(slot) orelse return 1;
    if (contexts[idx].key_state != .active) return 1;

    contexts[idx].key_state = .compromised;
    return 0;
}

// -- Crypto operations (simulated) --------------------------------------------

/// Encapsulate. Requires Active key state and KEM algorithm.
/// Returns 0=ok, 1=rejected.
pub export fn pqc_encapsulate(slot: c_int, ct: ?[*]u8, ct_len: ?*u32, ss: ?[*]u8, ss_len: ?*u32) callconv(.c) u8 {
    mutex.lock();
    defer mutex.unlock();
    const idx = validSlot(slot) orelse return 1;
    if (contexts[idx].key_state != .active) return 1;
    if (algorithmCategoryFromTag(contexts[idx].algorithm) != 0) return 1; // Not KEM
    _ = ct;
    _ = ss;
    // Simulated: write placeholder lengths.
    if (ct_len) |p| p.* = 32;
    if (ss_len) |p| p.* = 32;
    return 0;
}

/// Decapsulate. Requires Active key state and KEM algorithm.
/// Returns 0=ok, 1=rejected.
pub export fn pqc_decapsulate(slot: c_int, ct: ?[*]const u8, ct_len: u32, ss: ?[*]u8, ss_len: ?*u32) callconv(.c) u8 {
    mutex.lock();
    defer mutex.unlock();
    const idx = validSlot(slot) orelse return 1;
    if (contexts[idx].key_state != .active) return 1;
    if (algorithmCategoryFromTag(contexts[idx].algorithm) != 0) return 1;
    _ = ct;
    _ = ct_len;
    _ = ss;
    if (ss_len) |p| p.* = 32;
    return 0;
}

/// Sign. Requires Active key state and Signature algorithm.
/// Returns 0=ok, 1=rejected.
pub export fn pqc_sign(slot: c_int, msg: ?[*]const u8, msg_len: u32, sig: ?[*]u8, sig_len: ?*u32) callconv(.c) u8 {
    mutex.lock();
    defer mutex.unlock();
    const idx = validSlot(slot) orelse return 1;
    if (contexts[idx].key_state != .active) return 1;
    if (algorithmCategoryFromTag(contexts[idx].algorithm) != 1) return 1; // Not Signature
    _ = msg;
    _ = msg_len;
    _ = sig;
    if (sig_len) |p| p.* = 64;
    return 0;
}

/// Verify. Requires Active key state and Signature algorithm.
/// Returns 0=ok, 1=rejected.
pub export fn pqc_verify(slot: c_int, msg: ?[*]const u8, msg_len: u32, sig: ?[*]const u8, sig_len: u32) callconv(.c) u8 {
    mutex.lock();
    defer mutex.unlock();
    const idx = validSlot(slot) orelse return 1;
    if (contexts[idx].key_state != .active) return 1;
    if (algorithmCategoryFromTag(contexts[idx].algorithm) != 1) return 1;
    _ = msg;
    _ = msg_len;
    _ = sig;
    _ = sig_len;
    return 0;
}

// -- Hybrid negotiation -------------------------------------------------------

/// Set the hybrid mode for this context. Returns 0=ok, 1=rejected.
pub export fn pqc_set_hybrid_mode(slot: c_int, mode: u8) callconv(.c) u8 {
    mutex.lock();
    defer mutex.unlock();
    const idx = validSlot(slot) orelse return 1;
    if (mode > 2) return 1;
    contexts[idx].hybrid_mode = mode;
    return 0;
}

/// Select classical algorithm. Idle -> ClassicalSelected.
/// Returns 0=ok, 1=rejected.
pub export fn pqc_select_classical(slot: c_int) callconv(.c) u8 {
    mutex.lock();
    defer mutex.unlock();
    const idx = validSlot(slot) orelse return 1;
    if (contexts[idx].hybrid_state != .idle) return 1;

    contexts[idx].hybrid_state = .classical_selected;
    return 0;
}

/// Select PQC algorithm.
/// Idle -> PQCSelected, or ClassicalSelected -> HybridNegotiated.
/// Returns 0=ok, 1=rejected.
pub export fn pqc_select_pqc(slot: c_int) callconv(.c) u8 {
    mutex.lock();
    defer mutex.unlock();
    const idx = validSlot(slot) orelse return 1;
    const state = contexts[idx].hybrid_state;
    if (state == .idle) {
        contexts[idx].hybrid_state = .pqc_selected;
        return 0;
    } else if (state == .classical_selected) {
        contexts[idx].hybrid_state = .negotiated;
        return 0;
    }
    return 1;
}

/// Complete hybrid negotiation.
/// HybridNegotiated -> HybridComplete, or Idle -> HybridComplete (direct).
/// Returns 0=ok, 1=rejected.
pub export fn pqc_complete_hybrid(slot: c_int) callconv(.c) u8 {
    mutex.lock();
    defer mutex.unlock();
    const idx = validSlot(slot) orelse return 1;
    const state = contexts[idx].hybrid_state;
    if (state == .negotiated or state == .idle) {
        contexts[idx].hybrid_state = .complete;
        return 0;
    }
    return 1;
}

// -- Key length queries -------------------------------------------------------

/// Returns the public key length. Returns 0 for invalid slots.
pub export fn pqc_public_key_len(slot: c_int) callconv(.c) u32 {
    mutex.lock();
    defer mutex.unlock();
    const idx = validSlot(slot) orelse return 0;
    return contexts[idx].pk_len;
}

/// Returns the secret key length. Returns 0 for invalid slots.
pub export fn pqc_secret_key_len(slot: c_int) callconv(.c) u32 {
    mutex.lock();
    defer mutex.unlock();
    const idx = validSlot(slot) orelse return 0;
    return contexts[idx].sk_len;
}

// -- Stateless validation -----------------------------------------------------

/// Check whether a key lifecycle state transition is valid.
/// Returns 1 if valid, 0 if not.
pub export fn pqc_can_key_transition(from: u8, to: u8) callconv(.c) u8 {
    // Empty(0) -> Generating(1): BeginKeyGen
    if (from == 0 and to == 1) return 1;
    // Generating(1) -> Generated(2): FinishKeyGen
    if (from == 1 and to == 2) return 1;
    // Generated(2) -> Active(3): ActivateKey
    if (from == 2 and to == 3) return 1;
    // Active(3) -> Expired(4): ExpireKey
    if (from == 3 and to == 4) return 1;
    // Active(3) -> Compromised(5): CompromiseKey
    if (from == 3 and to == 5) return 1;
    // Generated(2) -> Expired(4): ExpireBeforeUse
    if (from == 2 and to == 4) return 1;
    // Empty(0) -> Expired(4): AbortEmpty
    if (from == 0 and to == 4) return 1;
    // Generating(1) -> Expired(4): AbortGenerating
    if (from == 1 and to == 4) return 1;
    return 0;
}

/// Check whether a hybrid negotiation state transition is valid.
/// Returns 1 if valid, 0 if not.
pub export fn pqc_can_hybrid_transition(from: u8, to: u8) callconv(.c) u8 {
    // Idle(0) -> ClassicalSelected(1): SelectClassical
    if (from == 0 and to == 1) return 1;
    // Idle(0) -> PQCSelected(2): SelectPQC
    if (from == 0 and to == 2) return 1;
    // ClassicalSelected(1) -> HybridNegotiated(3): AddPQCToClassical
    if (from == 1 and to == 3) return 1;
    // PQCSelected(2) -> HybridNegotiated(3): AddClassicalToPQC
    if (from == 2 and to == 3) return 1;
    // HybridNegotiated(3) -> HybridComplete(4): CompleteHybrid
    if (from == 3 and to == 4) return 1;
    // Idle(0) -> HybridComplete(4): DirectComplete
    if (from == 0 and to == 4) return 1;
    return 0;
}

/// Check if algorithm+level combination is valid.
/// Returns 1 if valid, 0 if not.
pub export fn pqc_valid_algorithm_level(algo: u8, level: u8) callconv(.c) u8 {
    if (algo > 7 or level > 4) return 0;
    // Kyber: Level 1, 3, 5 (tags 0, 2, 4)
    if (algo == 0 and (level == 0 or level == 2 or level == 4)) return 1;
    // Dilithium: Level 2, 3, 5 (tags 1, 2, 4)
    if (algo == 1 and (level == 1 or level == 2 or level == 4)) return 1;
    // FALCON: Level 1, 5 (tags 0, 4)
    if (algo == 2 and (level == 0 or level == 4)) return 1;
    // SPHINCS+: Level 1, 3, 5 (tags 0, 2, 4)
    if (algo == 3 and (level == 0 or level == 2 or level == 4)) return 1;
    // Classic McEliece: Level 1, 3, 5 (tags 0, 2, 4)
    if (algo == 4 and (level == 0 or level == 2 or level == 4)) return 1;
    // BIKE: Level 1, 3, 5 (tags 0, 2, 4)
    if (algo == 5 and (level == 0 or level == 2 or level == 4)) return 1;
    // HQC: Level 1, 3, 5 (tags 0, 2, 4)
    if (algo == 6 and (level == 0 or level == 2 or level == 4)) return 1;
    // FrodoKEM: Level 1, 3, 5 (tags 0, 2, 4)
    if (algo == 7 and (level == 0 or level == 2 or level == 4)) return 1;
    return 0;
}

/// Check if operation is valid for algorithm category.
/// Returns 1 if valid, 0 if not.
pub export fn pqc_valid_operation(category: u8, op: u8) callconv(.c) u8 {
    if (category > 1 or op > 4) return 0;
    // KEM (0): KeyGen(0), Encapsulate(1), Decapsulate(2)
    if (category == 0 and (op == 0 or op == 1 or op == 2)) return 1;
    // Signature (1): KeyGen(0), Sign(3), Verify(4)
    if (category == 1 and (op == 0 or op == 3 or op == 4)) return 1;
    return 0;
}
