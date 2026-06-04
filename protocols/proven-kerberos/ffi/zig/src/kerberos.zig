// SPDX-License-Identifier: MPL-2.0
// Copyright (c) Jonathan D.A. Jewell <j.d.a.jewell@open.ac.uk>
//
// kerberos.zig -- Zig FFI implementation of proven-kerberos.
//
// Implements verified Kerberos V5 authentication state machine with:
//   - Slot-based session management (up to 64 concurrent)
//   - Authentication lifecycle enforcement matching Idris2 Transitions.idr
//   - Encryption type negotiation (strongest-common-cipher selection)
//   - Principal name storage and validation
//   - Ticket flag management
//   - Thread-safe via mutex

const std = @import("std");

// -- Enums (matching KerberosABI.Layout.idr tag assignments) ------------------

/// Kerberos message types per RFC 4120 (10 constructors, tags 0-9).
pub const MessageType = enum(u8) {
    as_req = 0,
    as_rep = 1,
    tgs_req = 2,
    tgs_rep = 3,
    ap_req = 4,
    ap_rep = 5,
    krb_error = 6,
    krb_safe = 7,
    krb_priv = 8,
    krb_cred = 9,
};

/// Kerberos encryption types per RFC 3962 / RFC 8009 (5 constructors, tags 0-4).
pub const EncryptionType = enum(u8) {
    aes256_cts_hmac_sha1 = 0,
    aes128_cts_hmac_sha1 = 1,
    aes256_cts_hmac_sha384 = 2,
    rc4_hmac = 3,
    des3_cbc_sha1 = 4,
};

/// Kerberos principal name types per RFC 4120 Section 6.2 (7 constructors, tags 0-6).
pub const PrincipalType = enum(u8) {
    nt_unknown = 0,
    nt_principal = 1,
    nt_srv_inst = 2,
    nt_srv_hst = 3,
    nt_uid = 4,
    nt_x500 = 5,
    nt_enterprise = 6,
};

/// Kerberos ticket flags per RFC 4120 Section 5.3 (7 constructors, tags 0-6).
pub const TicketFlag = enum(u8) {
    forwardable = 0,
    forwarded = 1,
    proxiable = 2,
    proxy = 3,
    renewable = 4,
    pre_authent = 5,
    hw_authent = 6,
};

/// Kerberos error codes per RFC 4120 Section 7.5.9 (10 constructors, tags 0-9).
pub const ErrorCode = enum(u8) {
    kdc_err_none = 0,
    kdc_err_name_exp = 1,
    kdc_err_service_exp = 2,
    kdc_err_bad_pvno = 3,
    kdc_err_c_old_mast_kvno = 4,
    kdc_err_s_old_mast_kvno = 5,
    kdc_err_c_principal_unknown = 6,
    kdc_err_s_principal_unknown = 7,
    kdc_err_preauth_failed = 8,
    kdc_err_preauth_required = 9,
};

/// Authentication lifecycle states (5 constructors, tags 0-4).
pub const AuthState = enum(u8) {
    initial = 0,
    tgt_obtained = 1,
    service_ticket_obtained = 2,
    authenticated = 3,
    auth_failed = 4,
};

/// Encryption strength classification (3 constructors, tags 0-2).
pub const EncStrength = enum(u8) {
    strong = 0,
    medium = 1,
    weak = 2,
};

/// Pre-authentication method types per RFC 4120 / RFC 6113 (4 constructors, tags 0-3).
pub const PreAuthType = enum(u8) {
    pa_enc_timestamp = 0,
    pa_etype_info2 = 1,
    pa_fx_fast = 2,
    pa_fx_cookie = 3,
};

/// Encryption negotiation states (4 constructors, tags 0-3).
pub const NegotiationState = enum(u8) {
    neg_idle = 0,
    proposed = 1,
    selected = 2,
    neg_failed = 3,
};

// -- Constants ----------------------------------------------------------------

/// Maximum length for principal names (realm, client, service).
const MAX_PRINCIPAL_LEN: usize = 256;

/// Maximum number of proposed encryption types per session.
const MAX_PROPOSED_ENCTYPES: usize = 5;

/// Maximum number of ticket flags per session.
const MAX_TICKET_FLAGS: usize = 7;

/// Maximum number of concurrent Kerberos sessions (slot pool size).
const MAX_CONTEXTS: usize = 64;

// -- Kerberos session context -------------------------------------------------

/// A single Kerberos authentication session.
const Context = struct {
    /// Current authentication lifecycle state.
    auth_state: AuthState,
    /// Realm name (null-terminated slice into realm_buf).
    realm_buf: [MAX_PRINCIPAL_LEN]u8,
    realm_len: u32,
    /// Client principal name.
    client_name_buf: [MAX_PRINCIPAL_LEN]u8,
    client_name_len: u32,
    client_ptype: u8,
    client_set: bool,
    /// Service principal name.
    service_name_buf: [MAX_PRINCIPAL_LEN]u8,
    service_name_len: u32,
    service_ptype: u8,
    service_set: bool,
    /// Encryption negotiation state.
    neg_state: NegotiationState,
    /// Client-proposed encryption types.
    proposed_enctypes: [MAX_PROPOSED_ENCTYPES]u8,
    proposed_count: u32,
    /// Selected encryption type after negotiation (255 = none).
    selected_enctype: u8,
    /// Whether the session holds a TGT.
    has_tgt: bool,
    /// Whether the session holds a service ticket.
    has_service_ticket: bool,
    /// Last error code (tag value).
    last_error: u8,
    /// Ticket flags (bitset via array).
    ticket_flags: [MAX_TICKET_FLAGS]bool,
    /// Whether this slot is in use.
    active: bool,
};

/// Default (inactive) context value.
const DEFAULT_CONTEXT: Context = .{
    .auth_state = .initial,
    .realm_buf = [_]u8{0} ** MAX_PRINCIPAL_LEN,
    .realm_len = 0,
    .client_name_buf = [_]u8{0} ** MAX_PRINCIPAL_LEN,
    .client_name_len = 0,
    .client_ptype = 0,
    .client_set = false,
    .service_name_buf = [_]u8{0} ** MAX_PRINCIPAL_LEN,
    .service_name_len = 0,
    .service_ptype = 0,
    .service_set = false,
    .neg_state = .neg_idle,
    .proposed_enctypes = [_]u8{0} ** MAX_PROPOSED_ENCTYPES,
    .proposed_count = 0,
    .selected_enctype = 255,
    .has_tgt = false,
    .has_service_ticket = false,
    .last_error = 0,
    .ticket_flags = [_]bool{false} ** MAX_TICKET_FLAGS,
    .active = false,
};

/// Pool of Kerberos session contexts, indexed by slot number.
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

/// Classify an encryption type tag by its security strength.
/// Returns the EncStrength tag, or 255 for invalid encryption type tags.
fn classifyStrength(enc_tag: u8) u8 {
    return switch (enc_tag) {
        0 => 0, // AES256_CTS_HMAC_SHA1 -> Strong
        2 => 0, // AES256_CTS_HMAC_SHA384 -> Strong
        1 => 1, // AES128_CTS_HMAC_SHA1 -> Medium
        3 => 2, // RC4_HMAC -> Weak
        4 => 2, // DES3_CBC_SHA1 -> Weak
        else => 255,
    };
}

/// Strength ordering: lower value = stronger cipher.
/// Used for negotiation to select the strongest common cipher.
fn strengthOrd(enc_tag: u8) u8 {
    return switch (enc_tag) {
        0 => 0, // AES256_CTS_HMAC_SHA1: best
        2 => 1, // AES256_CTS_HMAC_SHA384: second
        1 => 2, // AES128_CTS_HMAC_SHA1: third
        3 => 3, // RC4_HMAC: fourth
        4 => 4, // DES3_CBC_SHA1: worst
        else => 255,
    };
}

// -- ABI version --------------------------------------------------------------

/// Returns the ABI version number.  Must match KerberosABI.Foreign.abiVersion.
pub export fn krb_abi_version() callconv(.c) u32 {
    return 1;
}

// -- Lifecycle ----------------------------------------------------------------

/// Create a new Kerberos session with the given realm.
/// Returns a non-negative slot index on success, or -1 if the pool is full
/// or the realm is invalid (null pointer or zero/excessive length).
pub export fn krb_create(realm_ptr: ?[*]const u8, realm_len: u32) callconv(.c) c_int {
    mutex.lock();
    defer mutex.unlock();

    // Validate realm
    const ptr = realm_ptr orelse return -1;
    if (realm_len == 0 or realm_len > MAX_PRINCIPAL_LEN) return -1;

    for (&contexts, 0..) |*ctx, i| {
        if (!ctx.active) {
            ctx.* = DEFAULT_CONTEXT;
            ctx.active = true;
            ctx.auth_state = .initial;
            const len: usize = @intCast(realm_len);
            @memcpy(ctx.realm_buf[0..len], ptr[0..len]);
            ctx.realm_len = realm_len;
            return @intCast(i);
        }
    }
    return -1; // no free slots
}

/// Destroy a Kerberos session, freeing its slot for reuse.
/// Safe to call with invalid or already-destroyed slots.
pub export fn krb_destroy(slot: c_int) callconv(.c) void {
    mutex.lock();
    defer mutex.unlock();
    if (slot < 0 or slot >= MAX_CONTEXTS) return;
    contexts[@intCast(slot)] = DEFAULT_CONTEXT;
}

// -- State queries ------------------------------------------------------------

/// Returns the current authentication state tag for the given slot.
/// Returns 4 (AuthFailed) for invalid slots as a safe fallback.
pub export fn krb_auth_state(slot: c_int) callconv(.c) u8 {
    mutex.lock();
    defer mutex.unlock();
    const idx = validSlot(slot) orelse return 4; // AuthFailed fallback
    return @intFromEnum(contexts[idx].auth_state);
}

// -- Principal management -----------------------------------------------------

/// Sets the client principal name and type.
/// Returns 0 on success, 1 if rejected (invalid slot, invalid ptype,
/// empty/excessive name, or not in Initial state).
pub export fn krb_set_client_principal(slot: c_int, name_ptr: ?[*]const u8, name_len: u32, ptype: u8) callconv(.c) u8 {
    mutex.lock();
    defer mutex.unlock();
    const idx = validSlot(slot) orelse return 1;
    if (ptype > 6) return 1; // invalid PrincipalType tag
    const ptr = name_ptr orelse return 1;
    if (name_len == 0 or name_len > MAX_PRINCIPAL_LEN) return 1;
    if (contexts[idx].auth_state != .initial) return 1;

    const len: usize = @intCast(name_len);
    @memcpy(contexts[idx].client_name_buf[0..len], ptr[0..len]);
    contexts[idx].client_name_len = name_len;
    contexts[idx].client_ptype = ptype;
    contexts[idx].client_set = true;
    return 0;
}

/// Sets the service principal name and type.
/// Returns 0 on success, 1 if rejected (invalid slot, invalid ptype,
/// empty/excessive name, or session is in AuthFailed state).
pub export fn krb_set_service_principal(slot: c_int, name_ptr: ?[*]const u8, name_len: u32, ptype: u8) callconv(.c) u8 {
    mutex.lock();
    defer mutex.unlock();
    const idx = validSlot(slot) orelse return 1;
    if (ptype > 6) return 1; // invalid PrincipalType tag
    const ptr = name_ptr orelse return 1;
    if (name_len == 0 or name_len > MAX_PRINCIPAL_LEN) return 1;
    if (contexts[idx].auth_state == .auth_failed) return 1;

    const len: usize = @intCast(name_len);
    @memcpy(contexts[idx].service_name_buf[0..len], ptr[0..len]);
    contexts[idx].service_name_len = name_len;
    contexts[idx].service_ptype = ptype;
    contexts[idx].service_set = true;
    return 0;
}

// -- Encryption negotiation ---------------------------------------------------

/// Client proposes supported encryption types (array of u8 tags).
/// Returns 0 on success, 1 if rejected (invalid slot, empty list,
/// invalid enc tags, or negotiation already started).
pub export fn krb_propose_enctypes(slot: c_int, types_ptr: ?[*]const u8, count: u32) callconv(.c) u8 {
    mutex.lock();
    defer mutex.unlock();
    const idx = validSlot(slot) orelse return 1;
    if (contexts[idx].neg_state != .neg_idle) return 1;
    const ptr = types_ptr orelse return 1;
    if (count == 0 or count > MAX_PROPOSED_ENCTYPES) return 1;

    const cnt: usize = @intCast(count);
    // Validate all tags before accepting
    for (ptr[0..cnt]) |tag| {
        if (tag > 4) return 1; // invalid EncryptionType tag
    }
    @memcpy(contexts[idx].proposed_enctypes[0..cnt], ptr[0..cnt]);
    contexts[idx].proposed_count = count;
    contexts[idx].neg_state = .proposed;
    return 0;
}

/// Server selects the strongest common cipher from client proposal vs server list.
/// Returns the selected EncryptionType tag, or 255 if no common cipher found.
/// Transitions negotiation state: Proposed -> Selected or Proposed -> NegFailed.
pub export fn krb_negotiate_enctype(slot: c_int, server_types_ptr: ?[*]const u8, count: u32) callconv(.c) u8 {
    mutex.lock();
    defer mutex.unlock();
    const idx = validSlot(slot) orelse return 255;
    if (contexts[idx].neg_state != .proposed) return 255;
    const ptr = server_types_ptr orelse {
        contexts[idx].neg_state = .neg_failed;
        return 255;
    };
    if (count == 0) {
        contexts[idx].neg_state = .neg_failed;
        return 255;
    }

    const client_count: usize = @intCast(contexts[idx].proposed_count);
    const server_count: usize = @intCast(count);

    // Find strongest common cipher (lowest strengthOrd value wins).
    var best_tag: u8 = 255;
    var best_ord: u8 = 255;

    for (contexts[idx].proposed_enctypes[0..client_count]) |client_tag| {
        for (ptr[0..server_count]) |server_tag| {
            if (client_tag == server_tag) {
                const ord = strengthOrd(client_tag);
                if (ord < best_ord) {
                    best_ord = ord;
                    best_tag = client_tag;
                }
            }
        }
    }

    if (best_tag == 255) {
        contexts[idx].neg_state = .neg_failed;
        return 255;
    }

    contexts[idx].selected_enctype = best_tag;
    contexts[idx].neg_state = .selected;
    return best_tag;
}

/// Returns the current negotiation state tag.
/// Returns 3 (NegFailed) for invalid slots.
pub export fn krb_negotiation_state(slot: c_int) callconv(.c) u8 {
    mutex.lock();
    defer mutex.unlock();
    const idx = validSlot(slot) orelse return 3; // NegFailed fallback
    return @intFromEnum(contexts[idx].neg_state);
}

/// Returns the negotiated encryption type tag, or 255 if not yet selected.
pub export fn krb_selected_enctype(slot: c_int) callconv(.c) u8 {
    mutex.lock();
    defer mutex.unlock();
    const idx = validSlot(slot) orelse return 255;
    return contexts[idx].selected_enctype;
}

// -- Authentication state transitions -----------------------------------------

/// Simulates AS exchange: Initial -> TGTObtained.
/// Requires client principal and realm to be set.
/// Returns 0 on success, 1 if rejected.
pub export fn krb_obtain_tgt(slot: c_int) callconv(.c) u8 {
    mutex.lock();
    defer mutex.unlock();
    const idx = validSlot(slot) orelse return 1;
    if (contexts[idx].auth_state != .initial) return 1;
    if (!contexts[idx].client_set) return 1;
    if (contexts[idx].realm_len == 0) return 1;

    contexts[idx].auth_state = .tgt_obtained;
    contexts[idx].has_tgt = true;
    return 0;
}

/// Simulates TGS exchange: TGTObtained -> ServiceTicketObtained.
/// Requires service principal to be set.
/// Returns 0 on success, 1 if rejected.
pub export fn krb_obtain_service_ticket(slot: c_int) callconv(.c) u8 {
    mutex.lock();
    defer mutex.unlock();
    const idx = validSlot(slot) orelse return 1;
    if (contexts[idx].auth_state != .tgt_obtained) return 1;
    if (!contexts[idx].service_set) return 1;

    contexts[idx].auth_state = .service_ticket_obtained;
    contexts[idx].has_service_ticket = true;
    return 0;
}

/// Simulates AP exchange: ServiceTicketObtained -> Authenticated.
/// Returns 0 on success, 1 if rejected.
pub export fn krb_authenticate(slot: c_int) callconv(.c) u8 {
    mutex.lock();
    defer mutex.unlock();
    const idx = validSlot(slot) orelse return 1;
    if (contexts[idx].auth_state != .service_ticket_obtained) return 1;

    contexts[idx].auth_state = .authenticated;
    return 0;
}

/// Forces transition to AuthFailed with the given error code.
/// Valid from any non-terminal (non-AuthFailed) state.
/// Returns 0 on success, 1 if rejected.
pub export fn krb_fail(slot: c_int, error_code: u8) callconv(.c) u8 {
    mutex.lock();
    defer mutex.unlock();
    const idx = validSlot(slot) orelse return 1;
    if (error_code > 9) return 1; // invalid ErrorCode tag
    if (contexts[idx].auth_state == .auth_failed) return 1;

    contexts[idx].auth_state = .auth_failed;
    contexts[idx].last_error = error_code;
    return 0;
}

/// Resets from AuthFailed -> Initial.
/// Clears tickets, negotiation state, and flags.
/// Returns 0 on success, 1 if rejected.
pub export fn krb_retry(slot: c_int) callconv(.c) u8 {
    mutex.lock();
    defer mutex.unlock();
    const idx = validSlot(slot) orelse return 1;
    if (contexts[idx].auth_state != .auth_failed) return 1;

    contexts[idx].auth_state = .initial;
    contexts[idx].has_tgt = false;
    contexts[idx].has_service_ticket = false;
    contexts[idx].neg_state = .neg_idle;
    contexts[idx].proposed_count = 0;
    contexts[idx].selected_enctype = 255;
    contexts[idx].last_error = 0;
    contexts[idx].ticket_flags = [_]bool{false} ** MAX_TICKET_FLAGS;
    return 0;
}

/// Renews TGT: TGTObtained -> TGTObtained (self-transition).
/// Resets ticket lifetime. Returns 0 on success, 1 if rejected.
pub export fn krb_renew_tgt(slot: c_int) callconv(.c) u8 {
    mutex.lock();
    defer mutex.unlock();
    const idx = validSlot(slot) orelse return 1;
    if (contexts[idx].auth_state != .tgt_obtained) return 1;

    // Self-transition: TGT remains valid but lifetime is reset.
    // (In a real implementation this would reset expiry timestamps.)
    return 0;
}

/// Re-authenticate: Authenticated -> Initial.
/// Clears all tickets, negotiation, and flags.
/// Returns 0 on success, 1 if rejected.
pub export fn krb_reauth(slot: c_int) callconv(.c) u8 {
    mutex.lock();
    defer mutex.unlock();
    const idx = validSlot(slot) orelse return 1;
    if (contexts[idx].auth_state != .authenticated) return 1;

    contexts[idx].auth_state = .initial;
    contexts[idx].has_tgt = false;
    contexts[idx].has_service_ticket = false;
    contexts[idx].neg_state = .neg_idle;
    contexts[idx].proposed_count = 0;
    contexts[idx].selected_enctype = 255;
    contexts[idx].ticket_flags = [_]bool{false} ** MAX_TICKET_FLAGS;
    return 0;
}

// -- Ticket queries -----------------------------------------------------------

/// Whether the session holds a valid TGT.
/// Returns 1 if yes, 0 if no.
pub export fn krb_has_tgt(slot: c_int) callconv(.c) u8 {
    mutex.lock();
    defer mutex.unlock();
    const idx = validSlot(slot) orelse return 0;
    return if (contexts[idx].has_tgt) 1 else 0;
}

/// Whether the session holds a service ticket.
/// Returns 1 if yes, 0 if no.
pub export fn krb_has_service_ticket(slot: c_int) callconv(.c) u8 {
    mutex.lock();
    defer mutex.unlock();
    const idx = validSlot(slot) orelse return 0;
    return if (contexts[idx].has_service_ticket) 1 else 0;
}

/// Whether the session is fully authenticated.
/// Returns 1 if yes, 0 if no.
pub export fn krb_has_access(slot: c_int) callconv(.c) u8 {
    mutex.lock();
    defer mutex.unlock();
    const idx = validSlot(slot) orelse return 0;
    return if (contexts[idx].auth_state == .authenticated) 1 else 0;
}

/// Returns the last error code set by krb_fail(), or 0 (KDC_ERR_NONE).
pub export fn krb_last_error(slot: c_int) callconv(.c) u8 {
    mutex.lock();
    defer mutex.unlock();
    const idx = validSlot(slot) orelse return 0;
    return contexts[idx].last_error;
}

// -- Ticket flag management ---------------------------------------------------

/// Returns the number of flags set on the TGT.
pub export fn krb_ticket_flags_count(slot: c_int) callconv(.c) u32 {
    mutex.lock();
    defer mutex.unlock();
    const idx = validSlot(slot) orelse return 0;
    var count: u32 = 0;
    for (contexts[idx].ticket_flags) |f| {
        if (f) count += 1;
    }
    return count;
}

/// Adds a flag to the TGT. Requires TGTObtained state.
/// Returns 0 on success, 1 if rejected (invalid slot, invalid flag tag,
/// or not in TGTObtained state).
pub export fn krb_add_ticket_flag(slot: c_int, flag: u8) callconv(.c) u8 {
    mutex.lock();
    defer mutex.unlock();
    const idx = validSlot(slot) orelse return 1;
    if (flag > 6) return 1; // invalid TicketFlag tag
    if (contexts[idx].auth_state != .tgt_obtained) return 1;

    contexts[idx].ticket_flags[@intCast(flag)] = true;
    return 0;
}

/// Whether the TGT has a specific flag.
/// Returns 1 if yes, 0 if no.
pub export fn krb_has_ticket_flag(slot: c_int, flag: u8) callconv(.c) u8 {
    mutex.lock();
    defer mutex.unlock();
    const idx = validSlot(slot) orelse return 0;
    if (flag > 6) return 0; // invalid TicketFlag tag
    return if (contexts[idx].ticket_flags[@intCast(flag)]) 1 else 0;
}

// -- Stateless queries --------------------------------------------------------

/// Check whether an authentication state transition is valid.
/// Matches Transitions.idr validateAuthTransition exactly.
/// Returns 1 if valid, 0 if not.
pub export fn krb_can_transition(from: u8, to: u8) callconv(.c) u8 {
    // Initial(0) -> TGTObtained(1): ObtainTGT
    if (from == 0 and to == 1) return 1;
    // TGTObtained(1) -> ServiceTicketObtained(2): ObtainServiceTicket
    if (from == 1 and to == 2) return 1;
    // ServiceTicketObtained(2) -> Authenticated(3): Authenticate
    if (from == 2 and to == 3) return 1;
    // Initial(0) -> AuthFailed(4): FailFromInitial
    if (from == 0 and to == 4) return 1;
    // TGTObtained(1) -> AuthFailed(4): FailFromTGT
    if (from == 1 and to == 4) return 1;
    // ServiceTicketObtained(2) -> AuthFailed(4): FailFromServiceTicket
    if (from == 2 and to == 4) return 1;
    // Authenticated(3) -> AuthFailed(4): FailFromAuthenticated
    if (from == 3 and to == 4) return 1;
    // Authenticated(3) -> Initial(0): ReauthFromAuthenticated
    if (from == 3 and to == 0) return 1;
    // AuthFailed(4) -> Initial(0): RetryFromFailed
    if (from == 4 and to == 0) return 1;
    // TGTObtained(1) -> TGTObtained(1): RenewTGT
    if (from == 1 and to == 1) return 1;
    return 0;
}

/// Check whether a negotiation state transition is valid.
/// Matches Transitions.idr validateNegotiation exactly.
/// Returns 1 if valid, 0 if not.
pub export fn krb_neg_can_transition(from: u8, to: u8) callconv(.c) u8 {
    // NegIdle(0) -> Proposed(1): ProposeEncTypes
    if (from == 0 and to == 1) return 1;
    // Proposed(1) -> Selected(2): SelectEncType
    if (from == 1 and to == 2) return 1;
    // Proposed(1) -> NegFailed(3): NegotiationFail
    if (from == 1 and to == 3) return 1;
    return 0;
}

/// Returns the strength classification of an encryption type.
/// Returns EncStrength tag (0=Strong, 1=Medium, 2=Weak), or 255 for invalid tags.
pub export fn krb_enc_strength(enc_type: u8) callconv(.c) u8 {
    return classifyStrength(enc_type);
}
