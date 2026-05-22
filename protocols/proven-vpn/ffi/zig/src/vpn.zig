// SPDX-License-Identifier: MPL-2.0
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
// vpn.zig -- Zig FFI implementation of proven-vpn.
//
// Implements verified IPSec/WireGuard/OpenVPN/L2TP tunnel state machine with:
//   - Slot-based tunnel management (up to 64 concurrent)
//   - Tunnel phase lifecycle enforcement matching Idris2 Transitions.idr
//   - SA (Security Association) lifecycle tracking with SPI-indexed table
//   - IKE negotiation (DH exchange, Auth, Child SA proposal)
//   - Stateless transition validation tables
//   - Thread-safe via mutex

const std = @import("std");

// -- Enums (matching VPNABI.Layout.idr tag assignments) ----------------------

/// VPN tunnel protocol types (4 constructors, tags 0-3).
pub const TunnelType = enum(u8) {
    ipsec = 0,
    wireguard = 1,
    openvpn = 2,
    l2tp = 3,
};

/// Tunnel establishment phase (7 constructors, tags 0-6).
pub const TunnelPhase = enum(u8) {
    idle = 0,
    phase1_init = 1,
    phase1_auth = 2,
    phase1_done = 3,
    phase2_negotiating = 4,
    established = 5,
    expired = 6,
};

/// Encryption algorithms for ESP/IKE (6 constructors, tags 0-5).
pub const EncryptionAlgorithm = enum(u8) {
    aes128_cbc = 0,
    aes256_cbc = 1,
    aes128_gcm = 2,
    aes256_gcm = 3,
    chacha20_poly1305 = 4,
    null_cipher = 5,
};

/// Integrity algorithms (5 constructors, tags 0-4).
pub const IntegrityAlgorithm = enum(u8) {
    hmac_sha1 = 0,
    hmac_sha256 = 1,
    hmac_sha384 = 2,
    hmac_sha512 = 3,
    no_integrity = 4,
};

/// Diffie-Hellman groups (4 constructors, tags 0-3).
pub const DHGroup = enum(u8) {
    dh14 = 0,
    ecp256 = 1,
    ecp384 = 2,
    curve25519 = 3,
};

/// SA lifecycle states (5 constructors, tags 0-4).
pub const SALifecycle = enum(u8) {
    sa_none = 0,
    sa_active = 1,
    sa_rekeying = 2,
    sa_expired = 3,
    sa_deleted = 4,
};

/// IKE version (2 constructors, tags 0-1).
pub const IKEVersion = enum(u8) {
    ikev1 = 0,
    ikev2 = 1,
};

/// VPN error reasons (6 constructors, tags 0-5).
pub const VPNError = enum(u8) {
    authentication_failed = 0,
    no_proposal_chosen = 1,
    lifetime_expired = 2,
    invalid_spi = 3,
    replay_detected = 4,
    negotiation_timeout = 5,
};

// -- Constants ----------------------------------------------------------------

/// Maximum number of concurrent VPN tunnels (slot pool size).
const MAX_CONTEXTS: usize = 64;

/// Maximum number of SAs per tunnel.
const MAX_SAS: usize = 8;

// -- SA record ----------------------------------------------------------------

/// A single Security Association record.
const SARecord = struct {
    /// Security Parameter Index (unique per tunnel).
    spi: u32,
    /// SA lifecycle state.
    state: SALifecycle,
    /// Encryption algorithm negotiated for this SA.
    encryption: u8,
    /// Integrity algorithm negotiated for this SA.
    integrity: u8,
    /// DH group used during SA key exchange.
    dh_group: u8,
    /// Whether this SA slot is in use.
    active: bool,
};

const DEFAULT_SA: SARecord = .{
    .spi = 0,
    .state = .sa_none,
    .encryption = 255,
    .integrity = 255,
    .dh_group = 255,
    .active = false,
};

// -- VPN tunnel context -------------------------------------------------------

/// A single VPN tunnel session.
const Context = struct {
    /// Current tunnel establishment phase.
    phase: TunnelPhase,
    /// Tunnel protocol type.
    tunnel_type: u8,
    /// IKE version (0=IKEv1, 1=IKEv2).
    ike_version: u8,
    /// DH group selected during Phase 1 Init.
    dh_group: u8,
    /// Encryption algorithm for the IKE SA.
    ike_encryption: u8,
    /// Integrity algorithm for the IKE SA.
    ike_integrity: u8,
    /// Child SA negotiation parameters.
    child_encryption: u8,
    child_integrity: u8,
    child_dh_group: u8,
    /// SA table (SPI-indexed).
    sas: [MAX_SAS]SARecord,
    /// Whether this slot is in use.
    active: bool,
};

const DEFAULT_CONTEXT: Context = .{
    .phase = .idle,
    .tunnel_type = 0,
    .ike_version = 1,
    .dh_group = 255,
    .ike_encryption = 255,
    .ike_integrity = 255,
    .child_encryption = 255,
    .child_integrity = 255,
    .child_dh_group = 255,
    .sas = [_]SARecord{DEFAULT_SA} ** MAX_SAS,
    .active = false,
};

/// Pool of VPN tunnel contexts, indexed by slot number.
var contexts: [MAX_CONTEXTS]Context = [_]Context{DEFAULT_CONTEXT} ** MAX_CONTEXTS;

/// Mutex protecting the context pool from concurrent access.
var mutex: std.Thread.Mutex = .{};

/// Validate a slot index and return it as usize if active.
fn validSlot(slot: c_int) ?usize {
    if (slot < 0 or slot >= MAX_CONTEXTS) return null;
    const idx: usize = @intCast(slot);
    if (!contexts[idx].active) return null;
    return idx;
}

/// Find an SA by SPI within a tunnel context.
fn findSA(ctx: *Context, spi: u32) ?usize {
    for (&ctx.sas, 0..) |*sa, i| {
        if (sa.active and sa.spi == spi) return i;
    }
    return null;
}

/// Find a free SA slot within a tunnel context.
fn freeSASlot(ctx: *Context) ?usize {
    for (&ctx.sas, 0..) |*sa, i| {
        if (!sa.active) return i;
    }
    return null;
}

// -- ABI version --------------------------------------------------------------

/// Returns the ABI version number. Must match VPNABI.Foreign.abiVersion.
pub export fn vpn_abi_version() callconv(.c) u32 {
    return 1;
}

// -- Lifecycle ----------------------------------------------------------------

/// Create a new VPN tunnel with the given tunnel type and IKE version.
/// Returns a non-negative slot index on success, or -1 on failure.
pub export fn vpn_create(tunnel_type: u8, ike_version: u8) callconv(.c) c_int {
    mutex.lock();
    defer mutex.unlock();

    if (tunnel_type > 3) return -1;
    if (ike_version > 1) return -1;

    for (&contexts, 0..) |*ctx, i| {
        if (!ctx.active) {
            ctx.* = DEFAULT_CONTEXT;
            ctx.active = true;
            ctx.phase = .idle;
            ctx.tunnel_type = tunnel_type;
            ctx.ike_version = ike_version;
            return @intCast(i);
        }
    }
    return -1;
}

/// Destroy a VPN tunnel, freeing its slot for reuse.
/// Safe to call with invalid or already-destroyed slots.
pub export fn vpn_destroy(slot: c_int) callconv(.c) void {
    mutex.lock();
    defer mutex.unlock();
    if (slot < 0 or slot >= MAX_CONTEXTS) return;
    contexts[@intCast(slot)] = DEFAULT_CONTEXT;
}

// -- State queries ------------------------------------------------------------

/// Returns the current tunnel phase tag. Returns 6 (Expired) for invalid slots.
pub export fn vpn_phase(slot: c_int) callconv(.c) u8 {
    mutex.lock();
    defer mutex.unlock();
    const idx = validSlot(slot) orelse return 6;
    return @intFromEnum(contexts[idx].phase);
}

/// Returns the tunnel type tag. Returns 255 for invalid slots.
pub export fn vpn_tunnel_type(slot: c_int) callconv(.c) u8 {
    mutex.lock();
    defer mutex.unlock();
    const idx = validSlot(slot) orelse return 255;
    return contexts[idx].tunnel_type;
}

/// Returns the IKE version tag. Returns 255 for invalid slots.
pub export fn vpn_ike_version(slot: c_int) callconv(.c) u8 {
    mutex.lock();
    defer mutex.unlock();
    const idx = validSlot(slot) orelse return 255;
    return contexts[idx].ike_version;
}

// -- Tunnel phase transitions -------------------------------------------------

/// Begin IKE Phase 1 (SA_INIT). Idle -> Phase1Init.
/// Returns 0 on success, 1 if rejected.
pub export fn vpn_begin_phase1(slot: c_int, dh_group: u8) callconv(.c) u8 {
    mutex.lock();
    defer mutex.unlock();
    const idx = validSlot(slot) orelse return 1;
    if (dh_group > 3) return 1;
    if (contexts[idx].phase != .idle) return 1;

    contexts[idx].phase = .phase1_init;
    contexts[idx].dh_group = dh_group;
    return 0;
}

/// Complete Phase 1 AUTH exchange. Phase1Init -> Phase1Auth -> Phase1Done.
/// Returns 0 on success, 1 if rejected.
pub export fn vpn_complete_phase1_auth(slot: c_int, enc: u8, integ: u8) callconv(.c) u8 {
    mutex.lock();
    defer mutex.unlock();
    const idx = validSlot(slot) orelse return 1;
    if (enc > 5) return 1;
    if (integ > 4) return 1;
    if (contexts[idx].phase != .phase1_init) return 1;

    contexts[idx].ike_encryption = enc;
    contexts[idx].ike_integrity = integ;
    contexts[idx].phase = .phase1_done;
    return 0;
}

/// Begin Phase 2 (CREATE_CHILD_SA). Phase1Done -> Phase2Negotiating.
/// Returns 0 on success, 1 if rejected.
pub export fn vpn_begin_phase2(slot: c_int, enc: u8, integ: u8, dh_group: u8) callconv(.c) u8 {
    mutex.lock();
    defer mutex.unlock();
    const idx = validSlot(slot) orelse return 1;
    if (enc > 5) return 1;
    if (integ > 4) return 1;
    if (dh_group > 3) return 1;
    if (contexts[idx].phase != .phase1_done) return 1;

    contexts[idx].child_encryption = enc;
    contexts[idx].child_integrity = integ;
    contexts[idx].child_dh_group = dh_group;
    contexts[idx].phase = .phase2_negotiating;
    return 0;
}

/// Complete tunnel establishment. Phase2Negotiating -> Established.
/// Creates an SA with the given SPI. Returns 0 on success, 1 if rejected.
pub export fn vpn_establish(slot: c_int, spi: u32) callconv(.c) u8 {
    mutex.lock();
    defer mutex.unlock();
    const idx = validSlot(slot) orelse return 1;
    if (contexts[idx].phase != .phase2_negotiating) return 1;
    if (spi == 0) return 1;

    // Create SA with the negotiated parameters.
    const sa_idx = freeSASlot(&contexts[idx]) orelse return 1;
    contexts[idx].sas[sa_idx] = .{
        .spi = spi,
        .state = .sa_active,
        .encryption = contexts[idx].child_encryption,
        .integrity = contexts[idx].child_integrity,
        .dh_group = contexts[idx].child_dh_group,
        .active = true,
    };
    contexts[idx].phase = .established;
    return 0;
}

/// Force-expire the tunnel. Any non-Idle/Expired state -> Expired.
/// Returns 0 on success, 1 if rejected.
pub export fn vpn_expire(slot: c_int) callconv(.c) u8 {
    mutex.lock();
    defer mutex.unlock();
    const idx = validSlot(slot) orelse return 1;
    if (contexts[idx].phase == .idle or contexts[idx].phase == .expired) return 1;

    contexts[idx].phase = .expired;
    return 0;
}

/// Restart from Expired. Expired -> Idle. Returns 0 on success, 1 if rejected.
pub export fn vpn_restart(slot: c_int) callconv(.c) u8 {
    mutex.lock();
    defer mutex.unlock();
    const idx = validSlot(slot) orelse return 1;
    if (contexts[idx].phase != .expired) return 1;

    contexts[idx].phase = .idle;
    contexts[idx].dh_group = 255;
    contexts[idx].ike_encryption = 255;
    contexts[idx].ike_integrity = 255;
    contexts[idx].child_encryption = 255;
    contexts[idx].child_integrity = 255;
    contexts[idx].child_dh_group = 255;
    contexts[idx].sas = [_]SARecord{DEFAULT_SA} ** MAX_SAS;
    return 0;
}

// -- Capability queries -------------------------------------------------------

/// Whether data can flow (Established only). Returns 1=yes, 0=no.
pub export fn vpn_can_transfer(slot: c_int) callconv(.c) u8 {
    mutex.lock();
    defer mutex.unlock();
    const idx = validSlot(slot) orelse return 0;
    return if (contexts[idx].phase == .established) 1 else 0;
}

/// Whether a rekey can be initiated (Established only). Returns 1=yes, 0=no.
pub export fn vpn_can_rekey(slot: c_int) callconv(.c) u8 {
    mutex.lock();
    defer mutex.unlock();
    const idx = validSlot(slot) orelse return 0;
    return if (contexts[idx].phase == .established) 1 else 0;
}

// -- SA management ------------------------------------------------------------

/// Returns SALifecycle tag for the given SPI. Returns 0 (SANone) if not found.
pub export fn vpn_sa_state(slot: c_int, spi: u32) callconv(.c) u8 {
    mutex.lock();
    defer mutex.unlock();
    const idx = validSlot(slot) orelse return 0;
    const sa_idx = findSA(&contexts[idx], spi) orelse return 0;
    return @intFromEnum(contexts[idx].sas[sa_idx].state);
}

/// Begin SA rekey. Active -> Rekeying. Returns 0=ok, 1=rejected.
pub export fn vpn_sa_begin_rekey(slot: c_int, spi: u32) callconv(.c) u8 {
    mutex.lock();
    defer mutex.unlock();
    const idx = validSlot(slot) orelse return 1;
    const sa_idx = findSA(&contexts[idx], spi) orelse return 1;
    if (contexts[idx].sas[sa_idx].state != .sa_active) return 1;

    contexts[idx].sas[sa_idx].state = .sa_rekeying;
    return 0;
}

/// Complete SA rekey. Old SA -> Deleted, new SA created as Active.
/// Returns 0=ok, 1=rejected.
pub export fn vpn_sa_complete_rekey(slot: c_int, old_spi: u32, new_spi: u32) callconv(.c) u8 {
    mutex.lock();
    defer mutex.unlock();
    const idx = validSlot(slot) orelse return 1;
    if (new_spi == 0) return 1;
    const old_idx = findSA(&contexts[idx], old_spi) orelse return 1;
    if (contexts[idx].sas[old_idx].state != .sa_rekeying) return 1;

    // Copy crypto parameters from old SA.
    const enc = contexts[idx].sas[old_idx].encryption;
    const integ = contexts[idx].sas[old_idx].integrity;
    const dh = contexts[idx].sas[old_idx].dh_group;

    // Delete old SA.
    contexts[idx].sas[old_idx].state = .sa_deleted;

    // Create new SA.
    const new_idx = freeSASlot(&contexts[idx]) orelse return 1;
    contexts[idx].sas[new_idx] = .{
        .spi = new_spi,
        .state = .sa_active,
        .encryption = enc,
        .integrity = integ,
        .dh_group = dh,
        .active = true,
    };
    return 0;
}

/// Explicitly delete an SA. Active/Rekeying -> Deleted.
/// Returns 0=ok, 1=rejected.
pub export fn vpn_sa_delete(slot: c_int, spi: u32) callconv(.c) u8 {
    mutex.lock();
    defer mutex.unlock();
    const idx = validSlot(slot) orelse return 1;
    const sa_idx = findSA(&contexts[idx], spi) orelse return 1;
    const state = contexts[idx].sas[sa_idx].state;
    if (state != .sa_active and state != .sa_rekeying) return 1;

    contexts[idx].sas[sa_idx].state = .sa_deleted;
    return 0;
}

/// Returns EncryptionAlgorithm tag for an SA. Returns 255 if not found.
pub export fn vpn_sa_encryption(slot: c_int, spi: u32) callconv(.c) u8 {
    mutex.lock();
    defer mutex.unlock();
    const idx = validSlot(slot) orelse return 255;
    const sa_idx = findSA(&contexts[idx], spi) orelse return 255;
    return contexts[idx].sas[sa_idx].encryption;
}

/// Returns IntegrityAlgorithm tag for an SA. Returns 255 if not found.
pub export fn vpn_sa_integrity(slot: c_int, spi: u32) callconv(.c) u8 {
    mutex.lock();
    defer mutex.unlock();
    const idx = validSlot(slot) orelse return 255;
    const sa_idx = findSA(&contexts[idx], spi) orelse return 255;
    return contexts[idx].sas[sa_idx].integrity;
}

/// Returns DHGroup tag for an SA. Returns 255 if not found.
pub export fn vpn_sa_dh_group(slot: c_int, spi: u32) callconv(.c) u8 {
    mutex.lock();
    defer mutex.unlock();
    const idx = validSlot(slot) orelse return 255;
    const sa_idx = findSA(&contexts[idx], spi) orelse return 255;
    return contexts[idx].sas[sa_idx].dh_group;
}

/// Returns number of active SAs for a tunnel.
pub export fn vpn_sa_count(slot: c_int) callconv(.c) u32 {
    mutex.lock();
    defer mutex.unlock();
    const idx = validSlot(slot) orelse return 0;
    var count: u32 = 0;
    for (contexts[idx].sas) |sa| {
        if (sa.active and sa.state == .sa_active) count += 1;
    }
    return count;
}

// -- Stateless transition validation ------------------------------------------

/// Check whether a tunnel phase transition is valid.
/// Matches Transitions.idr validatePhaseTransition exactly.
/// Returns 1 if valid, 0 if not.
pub export fn vpn_can_phase_transition(from: u8, to: u8) callconv(.c) u8 {
    // Idle(0) -> Phase1Init(1): BeginPhase1
    if (from == 0 and to == 1) return 1;
    // Phase1Init(1) -> Phase1Auth(2): Phase1InitDone
    if (from == 1 and to == 2) return 1;
    // Phase1Auth(2) -> Phase1Done(3): Phase1AuthDone
    if (from == 2 and to == 3) return 1;
    // Phase1Done(3) -> Phase2Negotiating(4): BeginPhase2
    if (from == 3 and to == 4) return 1;
    // Phase2Negotiating(4) -> Established(5): TunnelEstablished
    if (from == 4 and to == 5) return 1;
    // Established(5) -> Phase2Negotiating(4): RekeyChildSA
    if (from == 5 and to == 4) return 1;
    // Established(5) -> Phase1Init(1): RekeyFullTunnel
    if (from == 5 and to == 1) return 1;
    // Phase1Init(1) -> Expired(6): ExpireFromInit
    if (from == 1 and to == 6) return 1;
    // Phase1Auth(2) -> Expired(6): ExpireFromAuth
    if (from == 2 and to == 6) return 1;
    // Phase1Done(3) -> Expired(6): ExpireFromP1Done
    if (from == 3 and to == 6) return 1;
    // Phase2Negotiating(4) -> Expired(6): ExpireFromP2
    if (from == 4 and to == 6) return 1;
    // Established(5) -> Expired(6): ExpireFromEstab
    if (from == 5 and to == 6) return 1;
    // Expired(6) -> Idle(0): RestartFromExpired
    if (from == 6 and to == 0) return 1;
    return 0;
}

/// Check whether an SA lifecycle transition is valid.
/// Matches Transitions.idr validateSATransition exactly.
/// Returns 1 if valid, 0 if not.
pub export fn vpn_can_sa_transition(from: u8, to: u8) callconv(.c) u8 {
    // SANone(0) -> SAActive(1): SACreated
    if (from == 0 and to == 1) return 1;
    // SAActive(1) -> SARekeying(2): SABeginRekey
    if (from == 1 and to == 2) return 1;
    // SARekeying(2) -> SAActive(1): SARekeyDone
    if (from == 2 and to == 1) return 1;
    // SAActive(1) -> SAExpired(3): SAHardExpiry
    if (from == 1 and to == 3) return 1;
    // SARekeying(2) -> SAExpired(3): SARekeyExpired
    if (from == 2 and to == 3) return 1;
    // SAActive(1) -> SADeleted(4): SAExplicitDel
    if (from == 1 and to == 4) return 1;
    // SARekeying(2) -> SADeleted(4): SARekeyDel
    if (from == 2 and to == 4) return 1;
    return 0;
}
