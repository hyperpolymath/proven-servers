// SPDX-License-Identifier: PMPL-1.0-or-later
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
// dhcp.zig -- Zig FFI implementation of proven-dhcp.
//
// Implements the verified DHCP DORA lifecycle state machine with:
//   - 64-slot mutex-protected context pool
//   - DORA state machine enforcement matching Idris2 DHCPABI.Transitions.idr
//   - Lease state machine (Available/Offered/Bound/Renewing/Rebinding/Expired)
//   - IP address pool with lease tracking (256 leases per context)
//   - DHCP message parsing (RFC 2131 fixed header + options)
//   - DHCP option encoding (SubnetMask, Router, DNS, LeaseTime, etc.)
//   - Thread-safe via per-slot mutex pool

const std = @import("std");

// -- Enums (matching DHCPABI.Layout.idr tag assignments) ----------------------

/// DHCP message types (ABI tags 0-7, matching Layout.idr).
pub const MessageType = enum(u8) {
    discover = 0,
    offer = 1,
    request = 2,
    ack = 3,
    nak = 4,
    release = 5,
    inform = 6,
    decline = 7,
};

/// DHCP option codes (ABI tags 0-7, matching Layout.idr).
pub const OptionCode = enum(u8) {
    subnet_mask = 0,
    router = 1,
    dns = 2,
    domain_name = 3,
    lease_time = 4,
    server_id = 5,
    requested_ip = 6,
    msg_type = 7,
};

/// Hardware types (ABI tags 0-3, matching Layout.idr).
pub const HardwareType = enum(u8) {
    ethernet = 0,
    ieee802 = 1,
    arcnet = 2,
    frame_relay = 3,
};

/// DHCP DORA lifecycle states (matching DHCPABI.Transitions.idr).
pub const DhcpState = enum(u8) {
    idle = 0,
    discover_received = 1,
    offer_sent = 2,
    request_received = 3,
    ack_sent = 4,
    nak_sent = 5,
};

/// DHCP lease lifecycle states (matching DHCPABI.Layout.idr).
pub const LeaseState = enum(u8) {
    available = 0,
    offered = 1,
    bound = 2,
    renewing = 3,
    rebinding = 4,
    expired = 5,
};

// -- Option code <-> RFC 2132 wire code mapping --------------------------------

/// Map ABI option code tag to RFC 2132 wire code.
pub fn optionCodeToWire(tag: u8) u8 {
    return switch (tag) {
        0 => 1, // SubnetMask
        1 => 3, // Router
        2 => 6, // DNS
        3 => 15, // DomainName
        4 => 51, // LeaseTime
        5 => 54, // ServerID
        6 => 50, // RequestedIP
        7 => 53, // MsgType
        else => 0, // invalid
    };
}

/// Map RFC 2132 wire code to ABI option code tag.
pub fn wireToOptionCode(wire: u8) u8 {
    return switch (wire) {
        1 => 0, // SubnetMask
        3 => 1, // Router
        6 => 2, // DNS
        15 => 3, // DomainName
        51 => 4, // LeaseTime
        54 => 5, // ServerID
        50 => 6, // RequestedIP
        53 => 7, // MsgType
        else => 255, // unknown
    };
}

/// Map ABI hardware type tag to IANA wire code.
pub fn hardwareTypeToWire(tag: u8) u8 {
    return switch (tag) {
        0 => 1, // Ethernet
        1 => 6, // IEEE802
        2 => 7, // Arcnet
        3 => 15, // FrameRelay
        else => 0, // invalid
    };
}

// -- Lease entry ---------------------------------------------------------------

/// A single lease entry in the IP address pool.
const LeaseEntry = struct {
    /// Current lease lifecycle state.
    state: LeaseState,
    /// IP address assigned to this lease (network byte order).
    ip_addr: u32,
    /// Lease expiry time (seconds since epoch, 0 = not set).
    expiry: u32,
    /// Client MAC address (6 bytes for Ethernet).
    client_mac: [6]u8,
};

/// Maximum number of leases per context.
const MAX_LEASES: u16 = 256;

/// The default (empty) lease entry used for array initialisation.
const empty_lease: LeaseEntry = .{
    .state = .available,
    .ip_addr = 0,
    .expiry = 0,
    .client_mac = [_]u8{0} ** 6,
};

// -- DHCP context --------------------------------------------------------------

/// Offered address configuration (filled during send_offer).
const OfferConfig = struct {
    /// Offered IP address (network byte order).
    offered_ip: u32,
    /// Subnet mask (network byte order).
    subnet_mask: u32,
    /// Router/gateway (network byte order).
    router: u32,
    /// DNS server (network byte order).
    dns_server: u32,
    /// Lease duration in seconds.
    lease_secs: u32,
    /// Index into the lease pool for the offered address.
    lease_idx: u16,
};

const empty_offer: OfferConfig = .{
    .offered_ip = 0,
    .subnet_mask = 0,
    .router = 0,
    .dns_server = 0,
    .lease_secs = 0,
    .lease_idx = 0,
};

/// A DHCP server processing context (one DORA cycle).
const Context = struct {
    /// Current DORA lifecycle state.
    state: DhcpState,
    /// Whether this slot is in use.
    active: bool,
    /// Client transaction ID (xid from DHCP header).
    xid: u32,
    /// Client hardware address (from chaddr field, 6 bytes for Ethernet).
    client_mac: [6]u8,
    /// Client hardware type (ABI tag).
    htype: u8,
    /// Client hardware address length.
    hlen: u8,
    /// IP address pool (lease table).
    leases: [MAX_LEASES]LeaseEntry,
    /// Number of leases configured in the pool.
    lease_count: u16,
    /// Current offer configuration.
    offer: OfferConfig,
};

const MAX_CONTEXTS: usize = 64;

/// The default (empty) context used for array initialisation.
const empty_context: Context = .{
    .state = .idle,
    .active = false,
    .xid = 0,
    .client_mac = [_]u8{0} ** 6,
    .htype = 0,
    .hlen = 6,
    .leases = [_]LeaseEntry{empty_lease} ** MAX_LEASES,
    .lease_count = 0,
    .offer = empty_offer,
};

var contexts: [MAX_CONTEXTS]Context = [_]Context{empty_context} ** MAX_CONTEXTS;

/// Per-slot mutex pool for thread safety.
var mutexes: [MAX_CONTEXTS]std.Thread.Mutex = [_]std.Thread.Mutex{.{}} ** MAX_CONTEXTS;

/// Global mutex for slot allocation/deallocation.
var global_mutex: std.Thread.Mutex = .{};

/// Validate and return the slot index, or null if invalid/inactive.
fn validSlot(slot: c_int) ?usize {
    if (slot < 0 or slot >= MAX_CONTEXTS) return null;
    const idx: usize = @intCast(slot);
    if (!contexts[idx].active) return null;
    return idx;
}

// -- ABI version ---------------------------------------------------------------

pub export fn dhcp_abi_version() callconv(.c) u32 {
    return 1;
}

// -- Lifecycle -----------------------------------------------------------------

pub export fn dhcp_create_context() callconv(.c) c_int {
    global_mutex.lock();
    defer global_mutex.unlock();
    for (&contexts, 0..) |*ctx, i| {
        if (!ctx.active) {
            ctx.* = empty_context;
            ctx.active = true;
            return @intCast(i);
        }
    }
    return -1; // no free slots
}

pub export fn dhcp_destroy_context(slot: c_int) callconv(.c) void {
    global_mutex.lock();
    defer global_mutex.unlock();
    if (slot < 0 or slot >= MAX_CONTEXTS) return;
    const idx: usize = @intCast(slot);
    contexts[idx].active = false;
}

// -- State queries -------------------------------------------------------------

pub export fn dhcp_state(slot: c_int) callconv(.c) u8 {
    const idx = validSlot(slot) orelse return 4; // ack_sent as fallback
    mutexes[idx].lock();
    defer mutexes[idx].unlock();
    return @intFromEnum(contexts[idx].state);
}

pub export fn dhcp_lease_state(slot: c_int, lease_idx: u16) callconv(.c) u8 {
    const idx = validSlot(slot) orelse return 5; // expired fallback
    mutexes[idx].lock();
    defer mutexes[idx].unlock();
    if (lease_idx >= contexts[idx].lease_count) return 5; // expired fallback
    return @intFromEnum(contexts[idx].leases[lease_idx].state);
}

pub export fn dhcp_client_xid(slot: c_int) callconv(.c) u32 {
    const idx = validSlot(slot) orelse return 0;
    mutexes[idx].lock();
    defer mutexes[idx].unlock();
    return contexts[idx].xid;
}

pub export fn dhcp_client_mac(slot: c_int, out: ?[*]u8) callconv(.c) u8 {
    const idx = validSlot(slot) orelse return 1;
    mutexes[idx].lock();
    defer mutexes[idx].unlock();
    const buf = out orelse return 1;
    @memcpy(buf[0..6], &contexts[idx].client_mac);
    return 0;
}

pub export fn dhcp_lease_ip(slot: c_int, lease_idx: u16) callconv(.c) u32 {
    const idx = validSlot(slot) orelse return 0;
    mutexes[idx].lock();
    defer mutexes[idx].unlock();
    if (lease_idx >= contexts[idx].lease_count) return 0;
    return contexts[idx].leases[lease_idx].ip_addr;
}

pub export fn dhcp_lease_expiry(slot: c_int, lease_idx: u16) callconv(.c) u32 {
    const idx = validSlot(slot) orelse return 0;
    mutexes[idx].lock();
    defer mutexes[idx].unlock();
    if (lease_idx >= contexts[idx].lease_count) return 0;
    return contexts[idx].leases[lease_idx].expiry;
}

pub export fn dhcp_pool_count(slot: c_int) callconv(.c) u16 {
    const idx = validSlot(slot) orelse return 0;
    mutexes[idx].lock();
    defer mutexes[idx].unlock();
    return contexts[idx].lease_count;
}

pub export fn dhcp_pool_available_count(slot: c_int) callconv(.c) u16 {
    const idx = validSlot(slot) orelse return 0;
    mutexes[idx].lock();
    defer mutexes[idx].unlock();
    var count: u16 = 0;
    var i: u16 = 0;
    while (i < contexts[idx].lease_count) : (i += 1) {
        if (contexts[idx].leases[i].state == .available) {
            count += 1;
        }
    }
    return count;
}

// -- DORA lifecycle transitions ------------------------------------------------

/// Parse a DHCP DISCOVER message from a raw buffer.
/// Transitions: Idle -> DiscoverReceived.
/// The buffer must be a valid DHCP message (RFC 2131): at least 240 bytes
/// (fixed header) with op=1 (BOOTREQUEST).
pub export fn dhcp_parse_discover(slot: c_int, buf: ?[*]const u8, len: u16) callconv(.c) u8 {
    const idx = validSlot(slot) orelse return 1;
    mutexes[idx].lock();
    defer mutexes[idx].unlock();
    if (contexts[idx].state != .idle) return 1;

    // Minimum DHCP message: 240-byte fixed header
    if (len < 240) return 1;
    const data = buf orelse return 1;

    // Validate op field: must be 1 (BOOTREQUEST)
    if (data[0] != 1) return 1;

    // Parse hardware type and length
    contexts[idx].htype = data[1];
    contexts[idx].hlen = data[2];
    if (contexts[idx].hlen > 16) contexts[idx].hlen = 16;

    // Parse transaction ID (bytes 4-7, network byte order)
    contexts[idx].xid = (@as(u32, data[4]) << 24) |
        (@as(u32, data[5]) << 16) |
        (@as(u32, data[6]) << 8) |
        @as(u32, data[7]);

    // Parse client hardware address (chaddr at offset 28, up to 16 bytes)
    const mac_len: usize = @min(contexts[idx].hlen, 6);
    @memcpy(contexts[idx].client_mac[0..mac_len], data[28 .. 28 + mac_len]);

    // Scan options to verify message type = DISCOVER (option 53 = 1)
    // Options start at offset 240 (after magic cookie at 236-239)
    if (len >= 244) {
        // Check magic cookie: 99.130.83.99 (0x63825363)
        if (data[236] == 99 and data[237] == 130 and data[238] == 83 and data[239] == 99) {
            var offset: usize = 240;
            while (offset < len) {
                const opt_code = data[offset];
                if (opt_code == 255) break; // end option
                if (opt_code == 0) { // pad option
                    offset += 1;
                    continue;
                }
                if (offset + 1 >= len) break;
                const opt_len = data[offset + 1];
                if (opt_code == 53 and opt_len == 1 and offset + 2 < len) {
                    // Message type option: value must be 1 (DISCOVER)
                    if (data[offset + 2] != 1) return 1;
                }
                offset += 2 + @as(usize, opt_len);
            }
        }
    }

    contexts[idx].state = .discover_received;
    return 0;
}

/// Send a DHCPOFFER to the client.
/// Transitions: DiscoverReceived -> OfferSent.
/// The caller provides the offered configuration parameters.
pub export fn dhcp_send_offer(slot: c_int, offered_ip: u32, subnet: u32, router: u32, dns_server: u32, lease_secs: u32) callconv(.c) u8 {
    const idx = validSlot(slot) orelse return 1;
    mutexes[idx].lock();
    defer mutexes[idx].unlock();
    if (contexts[idx].state != .discover_received) return 1;

    // Find an available lease slot and allocate it
    var lease_idx: u16 = 0;
    var found = false;
    while (lease_idx < contexts[idx].lease_count) : (lease_idx += 1) {
        if (contexts[idx].leases[lease_idx].state == .available) {
            found = true;
            break;
        }
    }
    // If no existing available slot, try to add a new lease entry
    if (!found) {
        if (contexts[idx].lease_count >= MAX_LEASES) return 1;
        lease_idx = contexts[idx].lease_count;
        contexts[idx].lease_count += 1;
    }

    // Configure the lease
    contexts[idx].leases[lease_idx].state = .offered;
    contexts[idx].leases[lease_idx].ip_addr = offered_ip;
    @memcpy(&contexts[idx].leases[lease_idx].client_mac, &contexts[idx].client_mac);

    // Store offer configuration
    contexts[idx].offer = .{
        .offered_ip = offered_ip,
        .subnet_mask = subnet,
        .router = router,
        .dns_server = dns_server,
        .lease_secs = lease_secs,
        .lease_idx = lease_idx,
    };

    contexts[idx].state = .offer_sent;
    return 0;
}

/// Parse a DHCP REQUEST message from a raw buffer.
/// Transitions: OfferSent -> RequestReceived.
pub export fn dhcp_parse_request(slot: c_int, buf: ?[*]const u8, len: u16) callconv(.c) u8 {
    const idx = validSlot(slot) orelse return 1;
    mutexes[idx].lock();
    defer mutexes[idx].unlock();
    if (contexts[idx].state != .offer_sent) return 1;

    // Minimum DHCP message: 240-byte fixed header
    if (len < 240) return 1;
    const data = buf orelse return 1;

    // Validate op field: must be 1 (BOOTREQUEST)
    if (data[0] != 1) return 1;

    // Verify transaction ID matches
    const xid = (@as(u32, data[4]) << 24) |
        (@as(u32, data[5]) << 16) |
        (@as(u32, data[6]) << 8) |
        @as(u32, data[7]);
    if (xid != contexts[idx].xid) return 1;

    contexts[idx].state = .request_received;
    return 0;
}

/// Send a DHCPACK to the client.
/// Transitions: RequestReceived -> AckSent.
/// Binds the offered lease.
pub export fn dhcp_send_ack(slot: c_int) callconv(.c) u8 {
    const idx = validSlot(slot) orelse return 1;
    mutexes[idx].lock();
    defer mutexes[idx].unlock();
    if (contexts[idx].state != .request_received) return 1;

    // Bind the offered lease
    const li = contexts[idx].offer.lease_idx;
    if (li < contexts[idx].lease_count) {
        contexts[idx].leases[li].state = .bound;
        contexts[idx].leases[li].expiry = contexts[idx].offer.lease_secs;
    }

    contexts[idx].state = .ack_sent;
    return 0;
}

/// Send a DHCPNAK to the client.
/// Transitions: RequestReceived -> NakSent.
pub export fn dhcp_send_nak(slot: c_int) callconv(.c) u8 {
    const idx = validSlot(slot) orelse return 1;
    mutexes[idx].lock();
    defer mutexes[idx].unlock();
    if (contexts[idx].state != .request_received) return 1;

    // Release the offered lease back to available
    const li = contexts[idx].offer.lease_idx;
    if (li < contexts[idx].lease_count) {
        contexts[idx].leases[li].state = .available;
        contexts[idx].leases[li].ip_addr = 0;
        contexts[idx].leases[li].client_mac = [_]u8{0} ** 6;
    }

    contexts[idx].state = .nak_sent;
    return 0;
}

/// Reset a context back to Idle for reuse.
/// Only valid from non-terminal states (Idle, DiscoverReceived, OfferSent,
/// RequestReceived) or from terminal states (AckSent, NakSent) as a full reset.
pub export fn dhcp_reset(slot: c_int) callconv(.c) u8 {
    const idx = validSlot(slot) orelse return 1;
    mutexes[idx].lock();
    defer mutexes[idx].unlock();

    // Preserve lease table across resets
    const saved_leases = contexts[idx].leases;
    const saved_count = contexts[idx].lease_count;

    contexts[idx].state = .idle;
    contexts[idx].xid = 0;
    contexts[idx].client_mac = [_]u8{0} ** 6;
    contexts[idx].htype = 0;
    contexts[idx].hlen = 6;
    contexts[idx].offer = empty_offer;
    contexts[idx].leases = saved_leases;
    contexts[idx].lease_count = saved_count;

    return 0;
}

// -- Lease pool operations -----------------------------------------------------

/// Allocate a lease from the pool (Available -> Offered).
/// Returns the lease index (0-255) or -1 if no available leases.
pub export fn dhcp_pool_allocate(slot: c_int) callconv(.c) i32 {
    const idx = validSlot(slot) orelse return -1;
    mutexes[idx].lock();
    defer mutexes[idx].unlock();

    var i: u16 = 0;
    while (i < contexts[idx].lease_count) : (i += 1) {
        if (contexts[idx].leases[i].state == .available) {
            contexts[idx].leases[i].state = .offered;
            return @intCast(i);
        }
    }
    // Try adding a new entry if under limit
    if (contexts[idx].lease_count < MAX_LEASES) {
        const new_idx = contexts[idx].lease_count;
        contexts[idx].lease_count += 1;
        contexts[idx].leases[new_idx].state = .offered;
        return @intCast(new_idx);
    }
    return -1;
}

/// Bind a lease (Offered -> Bound).
pub export fn dhcp_pool_bind(slot: c_int, lease_idx: u16) callconv(.c) u8 {
    const idx = validSlot(slot) orelse return 1;
    mutexes[idx].lock();
    defer mutexes[idx].unlock();
    if (lease_idx >= contexts[idx].lease_count) return 1;
    if (contexts[idx].leases[lease_idx].state != .offered) return 1;
    contexts[idx].leases[lease_idx].state = .bound;
    return 0;
}

/// Release a lease (Bound -> Available).
pub export fn dhcp_pool_release(slot: c_int, lease_idx: u16) callconv(.c) u8 {
    const idx = validSlot(slot) orelse return 1;
    mutexes[idx].lock();
    defer mutexes[idx].unlock();
    if (lease_idx >= contexts[idx].lease_count) return 1;
    if (contexts[idx].leases[lease_idx].state != .bound) return 1;
    contexts[idx].leases[lease_idx].state = .available;
    contexts[idx].leases[lease_idx].expiry = 0;
    contexts[idx].leases[lease_idx].client_mac = [_]u8{0} ** 6;
    return 0;
}

/// Renew a lease (Bound -> Renewing -> Bound).
/// This is the combined T1 renewal: marks as renewing then immediately
/// succeeds (simulating ACK from server).
pub export fn dhcp_pool_renew(slot: c_int, lease_idx: u16) callconv(.c) u8 {
    const idx = validSlot(slot) orelse return 1;
    mutexes[idx].lock();
    defer mutexes[idx].unlock();
    if (lease_idx >= contexts[idx].lease_count) return 1;
    if (contexts[idx].leases[lease_idx].state != .bound) return 1;
    // Bound -> Renewing -> Bound (successful renewal)
    contexts[idx].leases[lease_idx].state = .bound;
    return 0;
}

/// Begin rebinding on a lease (Renewing -> Rebinding).
pub export fn dhcp_pool_begin_rebind(slot: c_int, lease_idx: u16) callconv(.c) u8 {
    const idx = validSlot(slot) orelse return 1;
    mutexes[idx].lock();
    defer mutexes[idx].unlock();
    if (lease_idx >= contexts[idx].lease_count) return 1;
    if (contexts[idx].leases[lease_idx].state != .renewing) return 1;
    contexts[idx].leases[lease_idx].state = .rebinding;
    return 0;
}

/// Begin renewing on a lease (Bound -> Renewing).
pub export fn dhcp_pool_begin_renew(slot: c_int, lease_idx: u16) callconv(.c) u8 {
    const idx = validSlot(slot) orelse return 1;
    mutexes[idx].lock();
    defer mutexes[idx].unlock();
    if (lease_idx >= contexts[idx].lease_count) return 1;
    if (contexts[idx].leases[lease_idx].state != .bound) return 1;
    contexts[idx].leases[lease_idx].state = .renewing;
    return 0;
}

/// Expire a lease (Rebinding -> Expired).
pub export fn dhcp_pool_expire(slot: c_int, lease_idx: u16) callconv(.c) u8 {
    const idx = validSlot(slot) orelse return 1;
    mutexes[idx].lock();
    defer mutexes[idx].unlock();
    if (lease_idx >= contexts[idx].lease_count) return 1;
    if (contexts[idx].leases[lease_idx].state != .rebinding) return 1;
    contexts[idx].leases[lease_idx].state = .expired;
    return 0;
}

/// Reclaim an expired lease (Expired -> Available).
pub export fn dhcp_pool_reclaim(slot: c_int, lease_idx: u16) callconv(.c) u8 {
    const idx = validSlot(slot) orelse return 1;
    mutexes[idx].lock();
    defer mutexes[idx].unlock();
    if (lease_idx >= contexts[idx].lease_count) return 1;
    if (contexts[idx].leases[lease_idx].state != .expired) return 1;
    contexts[idx].leases[lease_idx].state = .available;
    contexts[idx].leases[lease_idx].ip_addr = 0;
    contexts[idx].leases[lease_idx].expiry = 0;
    contexts[idx].leases[lease_idx].client_mac = [_]u8{0} ** 6;
    return 0;
}

/// Decline an offered lease (Offered -> Available).
pub export fn dhcp_pool_decline(slot: c_int, lease_idx: u16) callconv(.c) u8 {
    const idx = validSlot(slot) orelse return 1;
    mutexes[idx].lock();
    defer mutexes[idx].unlock();
    if (lease_idx >= contexts[idx].lease_count) return 1;
    if (contexts[idx].leases[lease_idx].state != .offered) return 1;
    contexts[idx].leases[lease_idx].state = .available;
    contexts[idx].leases[lease_idx].ip_addr = 0;
    contexts[idx].leases[lease_idx].client_mac = [_]u8{0} ** 6;
    return 0;
}

// -- Stateless transition checks -----------------------------------------------

/// Check whether a DHCP DORA lifecycle transition is valid.
/// Matches DHCPABI.Transitions.validateDhcpTransition exactly.
pub export fn dhcp_can_transition(from: u8, to: u8) callconv(.c) u8 {
    if (from == 0 and to == 1) return 1; // Idle -> DiscoverReceived
    if (from == 1 and to == 2) return 1; // DiscoverReceived -> OfferSent
    if (from == 2 and to == 3) return 1; // OfferSent -> RequestReceived
    if (from == 3 and to == 4) return 1; // RequestReceived -> AckSent
    if (from == 3 and to == 5) return 1; // RequestReceived -> NakSent
    // Abort edges (back to Idle)
    if (from == 1 and to == 0) return 1; // DiscoverReceived -> Idle
    if (from == 2 and to == 0) return 1; // OfferSent -> Idle
    if (from == 3 and to == 0) return 1; // RequestReceived -> Idle
    return 0;
}

/// Check whether a lease state transition is valid.
/// Matches DHCPABI.Transitions.validateLeaseTransition exactly.
pub export fn dhcp_can_lease_transition(from: u8, to: u8) callconv(.c) u8 {
    if (from == 0 and to == 1) return 1; // Available -> Offered
    if (from == 1 and to == 2) return 1; // Offered -> Bound
    if (from == 2 and to == 3) return 1; // Bound -> Renewing
    if (from == 3 and to == 2) return 1; // Renewing -> Bound (RenewSuccess)
    if (from == 3 and to == 4) return 1; // Renewing -> Rebinding
    if (from == 4 and to == 2) return 1; // Rebinding -> Bound (RebindSuccess)
    if (from == 4 and to == 5) return 1; // Rebinding -> Expired
    if (from == 5 and to == 0) return 1; // Expired -> Available (reclaim)
    if (from == 2 and to == 0) return 1; // Bound -> Available (release)
    if (from == 1 and to == 0) return 1; // Offered -> Available (decline)
    return 0;
}
