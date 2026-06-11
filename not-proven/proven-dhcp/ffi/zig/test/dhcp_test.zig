// SPDX-License-Identifier: MPL-2.0
// Copyright (c) Jonathan D.A. Jewell <j.d.a.jewell@open.ac.uk>
//
// dhcp_test.zig -- Integration tests for proven-dhcp FFI.
//
// Covers:
//   - ABI version check
//   - Enum encoding seams (MessageType, OptionCode, HardwareType, DhcpState, LeaseState)
//   - Wire code mappings (option codes, hardware types, reverse lookup)
//   - Context lifecycle (create, destroy, invalid slots)
//   - Full DORA lifecycle (Discover -> Offer -> Request -> Ack)
//   - NAK path (Request -> Nak)
//   - Parse validation (short buffers, null pointers, wrong op code, wrong xid)
//   - State transition enforcement (cannot skip DORA steps)
//   - Context reset with lease preservation
//   - Lease pool operations (allocate, bind, release, decline)
//   - Full lease lifecycle (Available through Expired and back)
//   - Invalid lease transitions
//   - Pool available count tracking
//   - Stateless DORA transition table
//   - Stateless lease transition table
//   - State query safety on invalid slots
//   - Relay agent information (set, query, validation)
//   - Option TLV parsing (pad, end, standard options, edge cases)
//   - Lease duration bounds
//   - Multiple concurrent contexts

const std = @import("std");
const dhcp = @import("dhcp");

// =========================================================================
// 1. ABI version
// =========================================================================

test "abi version matches Idris2 Foreign.abiVersion" {
    try std.testing.expectEqual(@as(u32, 1), dhcp.dhcp_abi_version());
}

// =========================================================================
// 2. Enum encoding seams -- MessageType (8 tags)
// =========================================================================

test "MessageType encoding matches Layout.idr (8 tags)" {
    try std.testing.expectEqual(@as(u8, 0), @intFromEnum(dhcp.MessageType.discover));
    try std.testing.expectEqual(@as(u8, 1), @intFromEnum(dhcp.MessageType.offer));
    try std.testing.expectEqual(@as(u8, 2), @intFromEnum(dhcp.MessageType.request));
    try std.testing.expectEqual(@as(u8, 3), @intFromEnum(dhcp.MessageType.ack));
    try std.testing.expectEqual(@as(u8, 4), @intFromEnum(dhcp.MessageType.nak));
    try std.testing.expectEqual(@as(u8, 5), @intFromEnum(dhcp.MessageType.release));
    try std.testing.expectEqual(@as(u8, 6), @intFromEnum(dhcp.MessageType.inform));
    try std.testing.expectEqual(@as(u8, 7), @intFromEnum(dhcp.MessageType.decline));
}

// =========================================================================
// 3. Enum encoding seams -- OptionCode (8 tags)
// =========================================================================

test "OptionCode encoding matches Layout.idr (8 tags)" {
    try std.testing.expectEqual(@as(u8, 0), @intFromEnum(dhcp.OptionCode.subnet_mask));
    try std.testing.expectEqual(@as(u8, 1), @intFromEnum(dhcp.OptionCode.router));
    try std.testing.expectEqual(@as(u8, 2), @intFromEnum(dhcp.OptionCode.dns));
    try std.testing.expectEqual(@as(u8, 3), @intFromEnum(dhcp.OptionCode.domain_name));
    try std.testing.expectEqual(@as(u8, 4), @intFromEnum(dhcp.OptionCode.lease_time));
    try std.testing.expectEqual(@as(u8, 5), @intFromEnum(dhcp.OptionCode.server_id));
    try std.testing.expectEqual(@as(u8, 6), @intFromEnum(dhcp.OptionCode.requested_ip));
    try std.testing.expectEqual(@as(u8, 7), @intFromEnum(dhcp.OptionCode.msg_type));
}

// =========================================================================
// 4. Enum encoding seams -- HardwareType (4 tags)
// =========================================================================

test "HardwareType encoding matches Layout.idr (4 tags)" {
    try std.testing.expectEqual(@as(u8, 0), @intFromEnum(dhcp.HardwareType.ethernet));
    try std.testing.expectEqual(@as(u8, 1), @intFromEnum(dhcp.HardwareType.ieee802));
    try std.testing.expectEqual(@as(u8, 2), @intFromEnum(dhcp.HardwareType.arcnet));
    try std.testing.expectEqual(@as(u8, 3), @intFromEnum(dhcp.HardwareType.frame_relay));
}

// =========================================================================
// 5. Enum encoding seams -- DhcpState (6 tags)
// =========================================================================

test "DhcpState encoding matches Transitions.idr (6 tags)" {
    try std.testing.expectEqual(@as(u8, 0), @intFromEnum(dhcp.DhcpState.idle));
    try std.testing.expectEqual(@as(u8, 1), @intFromEnum(dhcp.DhcpState.discover_received));
    try std.testing.expectEqual(@as(u8, 2), @intFromEnum(dhcp.DhcpState.offer_sent));
    try std.testing.expectEqual(@as(u8, 3), @intFromEnum(dhcp.DhcpState.request_received));
    try std.testing.expectEqual(@as(u8, 4), @intFromEnum(dhcp.DhcpState.ack_sent));
    try std.testing.expectEqual(@as(u8, 5), @intFromEnum(dhcp.DhcpState.nak_sent));
}

// =========================================================================
// 6. Enum encoding seams -- LeaseState (6 tags)
// =========================================================================

test "LeaseState encoding matches Layout.idr (6 tags)" {
    try std.testing.expectEqual(@as(u8, 0), @intFromEnum(dhcp.LeaseState.available));
    try std.testing.expectEqual(@as(u8, 1), @intFromEnum(dhcp.LeaseState.offered));
    try std.testing.expectEqual(@as(u8, 2), @intFromEnum(dhcp.LeaseState.bound));
    try std.testing.expectEqual(@as(u8, 3), @intFromEnum(dhcp.LeaseState.renewing));
    try std.testing.expectEqual(@as(u8, 4), @intFromEnum(dhcp.LeaseState.rebinding));
    try std.testing.expectEqual(@as(u8, 5), @intFromEnum(dhcp.LeaseState.expired));
}

// =========================================================================
// 7. Wire code mapping -- option codes
// =========================================================================

test "optionCodeToWire maps all 8 codes correctly" {
    try std.testing.expectEqual(@as(u8, 1), dhcp.optionCodeToWire(0)); // SubnetMask
    try std.testing.expectEqual(@as(u8, 3), dhcp.optionCodeToWire(1)); // Router
    try std.testing.expectEqual(@as(u8, 6), dhcp.optionCodeToWire(2)); // DNS
    try std.testing.expectEqual(@as(u8, 15), dhcp.optionCodeToWire(3)); // DomainName
    try std.testing.expectEqual(@as(u8, 51), dhcp.optionCodeToWire(4)); // LeaseTime
    try std.testing.expectEqual(@as(u8, 54), dhcp.optionCodeToWire(5)); // ServerID
    try std.testing.expectEqual(@as(u8, 50), dhcp.optionCodeToWire(6)); // RequestedIP
    try std.testing.expectEqual(@as(u8, 53), dhcp.optionCodeToWire(7)); // MsgType
    try std.testing.expectEqual(@as(u8, 0), dhcp.optionCodeToWire(255)); // invalid
}

// =========================================================================
// 8. Wire code mapping -- hardware types
// =========================================================================

test "hardwareTypeToWire maps all 4 types correctly" {
    try std.testing.expectEqual(@as(u8, 1), dhcp.hardwareTypeToWire(0)); // Ethernet
    try std.testing.expectEqual(@as(u8, 6), dhcp.hardwareTypeToWire(1)); // IEEE802
    try std.testing.expectEqual(@as(u8, 7), dhcp.hardwareTypeToWire(2)); // Arcnet
    try std.testing.expectEqual(@as(u8, 15), dhcp.hardwareTypeToWire(3)); // FrameRelay
    try std.testing.expectEqual(@as(u8, 0), dhcp.hardwareTypeToWire(99)); // invalid
}

// =========================================================================
// 9. Wire code mapping -- reverse option code lookup
// =========================================================================

test "wireToOptionCode roundtrips with optionCodeToWire" {
    try std.testing.expectEqual(@as(u8, 0), dhcp.wireToOptionCode(1)); // SubnetMask
    try std.testing.expectEqual(@as(u8, 1), dhcp.wireToOptionCode(3)); // Router
    try std.testing.expectEqual(@as(u8, 2), dhcp.wireToOptionCode(6)); // DNS
    try std.testing.expectEqual(@as(u8, 3), dhcp.wireToOptionCode(15)); // DomainName
    try std.testing.expectEqual(@as(u8, 4), dhcp.wireToOptionCode(51)); // LeaseTime
    try std.testing.expectEqual(@as(u8, 5), dhcp.wireToOptionCode(54)); // ServerID
    try std.testing.expectEqual(@as(u8, 6), dhcp.wireToOptionCode(50)); // RequestedIP
    try std.testing.expectEqual(@as(u8, 7), dhcp.wireToOptionCode(53)); // MsgType
    try std.testing.expectEqual(@as(u8, 255), dhcp.wireToOptionCode(99)); // unknown
}

// =========================================================================
// 10. Lifecycle -- create and destroy
// =========================================================================

test "create returns valid slot" {
    const slot = dhcp.dhcp_create_context();
    try std.testing.expect(slot >= 0);
    defer dhcp.dhcp_destroy_context(slot);
    try std.testing.expectEqual(@as(u8, 0), dhcp.dhcp_state(slot)); // idle
}

// =========================================================================
// 11. Destroy safety
// =========================================================================

test "destroy is safe with invalid slot" {
    dhcp.dhcp_destroy_context(-1);
    dhcp.dhcp_destroy_context(999);
}

// =========================================================================
// Helpers for building DHCP messages
// =========================================================================

/// Build a minimal DHCP DISCOVER message (240+ bytes).
fn buildDiscover(xid: u32, mac: [6]u8) [244]u8 {
    var buf: [244]u8 = [_]u8{0} ** 244;
    buf[0] = 1; // op: BOOTREQUEST
    buf[1] = 1; // htype: Ethernet
    buf[2] = 6; // hlen: 6 bytes
    // xid (network byte order)
    buf[4] = @truncate(xid >> 24);
    buf[5] = @truncate(xid >> 16);
    buf[6] = @truncate(xid >> 8);
    buf[7] = @truncate(xid);
    // chaddr at offset 28
    @memcpy(buf[28..34], &mac);
    // Magic cookie at offset 236
    buf[236] = 99;
    buf[237] = 130;
    buf[238] = 83;
    buf[239] = 99;
    // Option 53 (Message Type) = 1 (DISCOVER)
    buf[240] = 53;
    buf[241] = 1;
    buf[242] = 1;
    // End option
    buf[243] = 255;
    return buf;
}

/// Build a minimal DHCP REQUEST message (240+ bytes).
fn buildRequest(xid: u32) [244]u8 {
    var buf: [244]u8 = [_]u8{0} ** 244;
    buf[0] = 1; // op: BOOTREQUEST
    buf[1] = 1; // htype: Ethernet
    buf[2] = 6; // hlen: 6 bytes
    // xid (network byte order)
    buf[4] = @truncate(xid >> 24);
    buf[5] = @truncate(xid >> 16);
    buf[6] = @truncate(xid >> 8);
    buf[7] = @truncate(xid);
    // Magic cookie at offset 236
    buf[236] = 99;
    buf[237] = 130;
    buf[238] = 83;
    buf[239] = 99;
    // Option 53 (Message Type) = 3 (REQUEST)
    buf[240] = 53;
    buf[241] = 1;
    buf[242] = 3;
    // End option
    buf[243] = 255;
    return buf;
}

// =========================================================================
// 12. Full DORA lifecycle
// =========================================================================

test "full DORA lifecycle: Idle -> DiscoverReceived -> OfferSent -> RequestReceived -> AckSent" {
    const slot = dhcp.dhcp_create_context();
    defer dhcp.dhcp_destroy_context(slot);

    const mac = [_]u8{ 0xAA, 0xBB, 0xCC, 0xDD, 0xEE, 0xFF };
    var discover = buildDiscover(0x12345678, mac);

    // Idle -> DiscoverReceived
    try std.testing.expectEqual(@as(u8, 0), dhcp.dhcp_parse_discover(slot, &discover, 244));
    try std.testing.expectEqual(@as(u8, 1), dhcp.dhcp_state(slot)); // discover_received
    try std.testing.expectEqual(@as(u32, 0x12345678), dhcp.dhcp_client_xid(slot));

    // Verify client MAC was parsed
    var mac_out: [6]u8 = undefined;
    try std.testing.expectEqual(@as(u8, 0), dhcp.dhcp_client_mac(slot, &mac_out));
    try std.testing.expectEqualSlices(u8, &mac, &mac_out);

    // DiscoverReceived -> OfferSent
    const offered_ip: u32 = 0xC0A80164; // 192.168.1.100
    const subnet: u32 = 0xFFFFFF00;
    const router_ip: u32 = 0xC0A80101; // 192.168.1.1
    const dns_ip: u32 = 0x08080808; // 8.8.8.8
    try std.testing.expectEqual(@as(u8, 0), dhcp.dhcp_send_offer(slot, offered_ip, subnet, router_ip, dns_ip, 3600));
    try std.testing.expectEqual(@as(u8, 2), dhcp.dhcp_state(slot)); // offer_sent

    // Verify lease was created in Offered state
    try std.testing.expectEqual(@as(u16, 1), dhcp.dhcp_pool_count(slot));
    try std.testing.expectEqual(@as(u8, 1), dhcp.dhcp_lease_state(slot, 0)); // offered
    try std.testing.expectEqual(offered_ip, dhcp.dhcp_lease_ip(slot, 0));

    // OfferSent -> RequestReceived
    var request = buildRequest(0x12345678);
    try std.testing.expectEqual(@as(u8, 0), dhcp.dhcp_parse_request(slot, &request, 244));
    try std.testing.expectEqual(@as(u8, 3), dhcp.dhcp_state(slot)); // request_received

    // RequestReceived -> AckSent
    try std.testing.expectEqual(@as(u8, 0), dhcp.dhcp_send_ack(slot));
    try std.testing.expectEqual(@as(u8, 4), dhcp.dhcp_state(slot)); // ack_sent

    // Verify lease is now Bound
    try std.testing.expectEqual(@as(u8, 2), dhcp.dhcp_lease_state(slot, 0)); // bound
    try std.testing.expectEqual(@as(u32, 3600), dhcp.dhcp_lease_expiry(slot, 0));
}

// =========================================================================
// 13. NAK path
// =========================================================================

test "DORA with NAK: Idle -> Discover -> Offer -> Request -> Nak" {
    const slot = dhcp.dhcp_create_context();
    defer dhcp.dhcp_destroy_context(slot);

    const mac = [_]u8{ 0x01, 0x02, 0x03, 0x04, 0x05, 0x06 };
    var discover = buildDiscover(0xAABBCCDD, mac);
    _ = dhcp.dhcp_parse_discover(slot, &discover, 244);
    _ = dhcp.dhcp_send_offer(slot, 0x0A000001, 0xFF000000, 0x0A000001, 0x08080808, 1800);

    var request = buildRequest(0xAABBCCDD);
    _ = dhcp.dhcp_parse_request(slot, &request, 244);

    // Send NAK
    try std.testing.expectEqual(@as(u8, 0), dhcp.dhcp_send_nak(slot));
    try std.testing.expectEqual(@as(u8, 5), dhcp.dhcp_state(slot)); // nak_sent

    // Verify lease was released back to Available
    try std.testing.expectEqual(@as(u8, 0), dhcp.dhcp_lease_state(slot, 0)); // available
}

// =========================================================================
// 14. Parse discover rejects short buffer
// =========================================================================

test "parse_discover rejects short buffer" {
    const slot = dhcp.dhcp_create_context();
    defer dhcp.dhcp_destroy_context(slot);
    var short_buf: [100]u8 = [_]u8{0} ** 100;
    try std.testing.expectEqual(@as(u8, 1), dhcp.dhcp_parse_discover(slot, &short_buf, 100));
    try std.testing.expectEqual(@as(u8, 0), dhcp.dhcp_state(slot)); // still idle
}

// =========================================================================
// 15. Parse discover rejects null buffer
// =========================================================================

test "parse_discover rejects null buffer" {
    const slot = dhcp.dhcp_create_context();
    defer dhcp.dhcp_destroy_context(slot);
    try std.testing.expectEqual(@as(u8, 1), dhcp.dhcp_parse_discover(slot, null, 240));
}

// =========================================================================
// 16. Parse discover rejects BOOTREPLY
// =========================================================================

test "parse_discover rejects BOOTREPLY (op=2)" {
    const slot = dhcp.dhcp_create_context();
    defer dhcp.dhcp_destroy_context(slot);
    var buf: [244]u8 = [_]u8{0} ** 244;
    buf[0] = 2; // op: BOOTREPLY (invalid for DISCOVER)
    try std.testing.expectEqual(@as(u8, 1), dhcp.dhcp_parse_discover(slot, &buf, 244));
}

// =========================================================================
// 17. Parse request rejects wrong xid
// =========================================================================

test "parse_request rejects mismatched xid" {
    const slot = dhcp.dhcp_create_context();
    defer dhcp.dhcp_destroy_context(slot);

    const mac = [_]u8{ 0xDE, 0xAD, 0xBE, 0xEF, 0x00, 0x01 };
    var discover = buildDiscover(0x11111111, mac);
    _ = dhcp.dhcp_parse_discover(slot, &discover, 244);
    _ = dhcp.dhcp_send_offer(slot, 0xC0A80102, 0xFFFFFF00, 0xC0A80101, 0x08080808, 7200);

    // REQUEST with different xid
    var request = buildRequest(0x22222222);
    try std.testing.expectEqual(@as(u8, 1), dhcp.dhcp_parse_request(slot, &request, 244));
    try std.testing.expectEqual(@as(u8, 2), dhcp.dhcp_state(slot)); // still offer_sent
}

// =========================================================================
// 18-21. State transition enforcement
// =========================================================================

test "cannot send offer from Idle" {
    const slot = dhcp.dhcp_create_context();
    defer dhcp.dhcp_destroy_context(slot);
    try std.testing.expectEqual(@as(u8, 1), dhcp.dhcp_send_offer(slot, 0, 0, 0, 0, 0));
}

test "cannot send ack from Idle" {
    const slot = dhcp.dhcp_create_context();
    defer dhcp.dhcp_destroy_context(slot);
    try std.testing.expectEqual(@as(u8, 1), dhcp.dhcp_send_ack(slot));
}

test "cannot send nak from Idle" {
    const slot = dhcp.dhcp_create_context();
    defer dhcp.dhcp_destroy_context(slot);
    try std.testing.expectEqual(@as(u8, 1), dhcp.dhcp_send_nak(slot));
}

test "cannot parse request from Idle (skip DiscoverReceived and OfferSent)" {
    const slot = dhcp.dhcp_create_context();
    defer dhcp.dhcp_destroy_context(slot);
    var request = buildRequest(0);
    try std.testing.expectEqual(@as(u8, 1), dhcp.dhcp_parse_request(slot, &request, 244));
}

// =========================================================================
// 22. Reset
// =========================================================================

test "reset returns context to Idle preserving leases" {
    const slot = dhcp.dhcp_create_context();
    defer dhcp.dhcp_destroy_context(slot);

    const mac = [_]u8{ 0x11, 0x22, 0x33, 0x44, 0x55, 0x66 };
    var discover = buildDiscover(0xDEADBEEF, mac);
    _ = dhcp.dhcp_parse_discover(slot, &discover, 244);
    _ = dhcp.dhcp_send_offer(slot, 0xC0A80164, 0xFFFFFF00, 0xC0A80101, 0x08080808, 3600);

    var request = buildRequest(0xDEADBEEF);
    _ = dhcp.dhcp_parse_request(slot, &request, 244);
    _ = dhcp.dhcp_send_ack(slot);

    // Now in AckSent with a bound lease
    try std.testing.expectEqual(@as(u8, 4), dhcp.dhcp_state(slot));
    try std.testing.expectEqual(@as(u8, 2), dhcp.dhcp_lease_state(slot, 0)); // bound

    // Reset back to Idle
    try std.testing.expectEqual(@as(u8, 0), dhcp.dhcp_reset(slot));
    try std.testing.expectEqual(@as(u8, 0), dhcp.dhcp_state(slot)); // idle

    // Lease table preserved
    try std.testing.expectEqual(@as(u16, 1), dhcp.dhcp_pool_count(slot));
    try std.testing.expectEqual(@as(u8, 2), dhcp.dhcp_lease_state(slot, 0)); // still bound
}

// =========================================================================
// 23-26. Lease pool operations
// =========================================================================

test "pool_allocate returns lease index and transitions to Offered" {
    const slot = dhcp.dhcp_create_context();
    defer dhcp.dhcp_destroy_context(slot);

    const li = dhcp.dhcp_pool_allocate(slot);
    try std.testing.expect(li >= 0);
    try std.testing.expectEqual(@as(u8, 1), dhcp.dhcp_lease_state(slot, @intCast(li))); // offered
    try std.testing.expectEqual(@as(u16, 1), dhcp.dhcp_pool_count(slot));
}

test "pool_bind transitions Offered -> Bound" {
    const slot = dhcp.dhcp_create_context();
    defer dhcp.dhcp_destroy_context(slot);

    const li: u16 = @intCast(dhcp.dhcp_pool_allocate(slot));
    try std.testing.expectEqual(@as(u8, 0), dhcp.dhcp_pool_bind(slot, li));
    try std.testing.expectEqual(@as(u8, 2), dhcp.dhcp_lease_state(slot, li)); // bound
}

test "pool_release transitions Bound -> Available" {
    const slot = dhcp.dhcp_create_context();
    defer dhcp.dhcp_destroy_context(slot);

    const li: u16 = @intCast(dhcp.dhcp_pool_allocate(slot));
    _ = dhcp.dhcp_pool_bind(slot, li);
    try std.testing.expectEqual(@as(u8, 0), dhcp.dhcp_pool_release(slot, li));
    try std.testing.expectEqual(@as(u8, 0), dhcp.dhcp_lease_state(slot, li)); // available
}

test "pool_decline transitions Offered -> Available" {
    const slot = dhcp.dhcp_create_context();
    defer dhcp.dhcp_destroy_context(slot);

    const li: u16 = @intCast(dhcp.dhcp_pool_allocate(slot));
    try std.testing.expectEqual(@as(u8, 0), dhcp.dhcp_pool_decline(slot, li));
    try std.testing.expectEqual(@as(u8, 0), dhcp.dhcp_lease_state(slot, li)); // available
}

// =========================================================================
// 27. Full lease lifecycle
// =========================================================================

test "full lease lifecycle: Available -> Offered -> Bound -> Renewing -> Rebinding -> Expired -> Available" {
    const slot = dhcp.dhcp_create_context();
    defer dhcp.dhcp_destroy_context(slot);

    const li: u16 = @intCast(dhcp.dhcp_pool_allocate(slot));
    // Offered
    try std.testing.expectEqual(@as(u8, 1), dhcp.dhcp_lease_state(slot, li));
    // -> Bound
    try std.testing.expectEqual(@as(u8, 0), dhcp.dhcp_pool_bind(slot, li));
    try std.testing.expectEqual(@as(u8, 2), dhcp.dhcp_lease_state(slot, li));
    // -> Renewing
    try std.testing.expectEqual(@as(u8, 0), dhcp.dhcp_pool_begin_renew(slot, li));
    try std.testing.expectEqual(@as(u8, 3), dhcp.dhcp_lease_state(slot, li));
    // -> Rebinding
    try std.testing.expectEqual(@as(u8, 0), dhcp.dhcp_pool_begin_rebind(slot, li));
    try std.testing.expectEqual(@as(u8, 4), dhcp.dhcp_lease_state(slot, li));
    // -> Expired
    try std.testing.expectEqual(@as(u8, 0), dhcp.dhcp_pool_expire(slot, li));
    try std.testing.expectEqual(@as(u8, 5), dhcp.dhcp_lease_state(slot, li));
    // -> Available (reclaim)
    try std.testing.expectEqual(@as(u8, 0), dhcp.dhcp_pool_reclaim(slot, li));
    try std.testing.expectEqual(@as(u8, 0), dhcp.dhcp_lease_state(slot, li));
}

// =========================================================================
// 28-31. Lease pool invalid transitions
// =========================================================================

test "pool_bind rejects non-Offered lease" {
    const slot = dhcp.dhcp_create_context();
    defer dhcp.dhcp_destroy_context(slot);

    const li: u16 = @intCast(dhcp.dhcp_pool_allocate(slot));
    _ = dhcp.dhcp_pool_bind(slot, li); // now bound
    try std.testing.expectEqual(@as(u8, 1), dhcp.dhcp_pool_bind(slot, li)); // already bound
}

test "pool_release rejects non-Bound lease" {
    const slot = dhcp.dhcp_create_context();
    defer dhcp.dhcp_destroy_context(slot);

    const li: u16 = @intCast(dhcp.dhcp_pool_allocate(slot));
    // Still offered, not bound
    try std.testing.expectEqual(@as(u8, 1), dhcp.dhcp_pool_release(slot, li));
}

test "pool_expire rejects non-Rebinding lease" {
    const slot = dhcp.dhcp_create_context();
    defer dhcp.dhcp_destroy_context(slot);

    const li: u16 = @intCast(dhcp.dhcp_pool_allocate(slot));
    _ = dhcp.dhcp_pool_bind(slot, li);
    // Bound, not rebinding
    try std.testing.expectEqual(@as(u8, 1), dhcp.dhcp_pool_expire(slot, li));
}

test "pool_reclaim rejects non-Expired lease" {
    const slot = dhcp.dhcp_create_context();
    defer dhcp.dhcp_destroy_context(slot);

    const li: u16 = @intCast(dhcp.dhcp_pool_allocate(slot));
    _ = dhcp.dhcp_pool_bind(slot, li);
    // Bound, not expired
    try std.testing.expectEqual(@as(u8, 1), dhcp.dhcp_pool_reclaim(slot, li));
}

// =========================================================================
// 32. Pool available count tracking
// =========================================================================

test "pool_available_count tracks available leases" {
    const slot = dhcp.dhcp_create_context();
    defer dhcp.dhcp_destroy_context(slot);

    // Allocate 3 leases (all start as Offered)
    const l0: u16 = @intCast(dhcp.dhcp_pool_allocate(slot));
    const l1: u16 = @intCast(dhcp.dhcp_pool_allocate(slot));
    _ = dhcp.dhcp_pool_allocate(slot);

    try std.testing.expectEqual(@as(u16, 0), dhcp.dhcp_pool_available_count(slot)); // all offered

    // Decline one back to available
    _ = dhcp.dhcp_pool_decline(slot, l0);
    try std.testing.expectEqual(@as(u16, 1), dhcp.dhcp_pool_available_count(slot));

    // Bind and release another
    _ = dhcp.dhcp_pool_bind(slot, l1);
    _ = dhcp.dhcp_pool_release(slot, l1);
    try std.testing.expectEqual(@as(u16, 2), dhcp.dhcp_pool_available_count(slot));
}

// =========================================================================
// 33. Stateless DORA transition table
// =========================================================================

test "dhcp_can_transition matches Transitions.idr" {
    // Forward DORA sequence
    try std.testing.expectEqual(@as(u8, 1), dhcp.dhcp_can_transition(0, 1)); // Idle -> DiscoverReceived
    try std.testing.expectEqual(@as(u8, 1), dhcp.dhcp_can_transition(1, 2)); // DiscoverReceived -> OfferSent
    try std.testing.expectEqual(@as(u8, 1), dhcp.dhcp_can_transition(2, 3)); // OfferSent -> RequestReceived
    try std.testing.expectEqual(@as(u8, 1), dhcp.dhcp_can_transition(3, 4)); // RequestReceived -> AckSent
    try std.testing.expectEqual(@as(u8, 1), dhcp.dhcp_can_transition(3, 5)); // RequestReceived -> NakSent

    // Abort edges (back to Idle)
    try std.testing.expectEqual(@as(u8, 1), dhcp.dhcp_can_transition(1, 0)); // DiscoverReceived -> Idle
    try std.testing.expectEqual(@as(u8, 1), dhcp.dhcp_can_transition(2, 0)); // OfferSent -> Idle
    try std.testing.expectEqual(@as(u8, 1), dhcp.dhcp_can_transition(3, 0)); // RequestReceived -> Idle

    // Invalid transitions
    try std.testing.expectEqual(@as(u8, 0), dhcp.dhcp_can_transition(4, 0)); // AckSent -> Idle (terminal!)
    try std.testing.expectEqual(@as(u8, 0), dhcp.dhcp_can_transition(5, 0)); // NakSent -> Idle (terminal!)
    try std.testing.expectEqual(@as(u8, 0), dhcp.dhcp_can_transition(0, 4)); // Idle -> AckSent (skip!)
    try std.testing.expectEqual(@as(u8, 0), dhcp.dhcp_can_transition(0, 2)); // Idle -> OfferSent (skip!)
}

// =========================================================================
// 34. Stateless lease transition table
// =========================================================================

test "dhcp_can_lease_transition matches Transitions.idr" {
    // Forward lease sequence
    try std.testing.expectEqual(@as(u8, 1), dhcp.dhcp_can_lease_transition(0, 1)); // Available -> Offered
    try std.testing.expectEqual(@as(u8, 1), dhcp.dhcp_can_lease_transition(1, 2)); // Offered -> Bound
    try std.testing.expectEqual(@as(u8, 1), dhcp.dhcp_can_lease_transition(2, 3)); // Bound -> Renewing
    try std.testing.expectEqual(@as(u8, 1), dhcp.dhcp_can_lease_transition(3, 2)); // Renewing -> Bound
    try std.testing.expectEqual(@as(u8, 1), dhcp.dhcp_can_lease_transition(3, 4)); // Renewing -> Rebinding
    try std.testing.expectEqual(@as(u8, 1), dhcp.dhcp_can_lease_transition(4, 2)); // Rebinding -> Bound
    try std.testing.expectEqual(@as(u8, 1), dhcp.dhcp_can_lease_transition(4, 5)); // Rebinding -> Expired
    try std.testing.expectEqual(@as(u8, 1), dhcp.dhcp_can_lease_transition(5, 0)); // Expired -> Available
    try std.testing.expectEqual(@as(u8, 1), dhcp.dhcp_can_lease_transition(2, 0)); // Bound -> Available
    try std.testing.expectEqual(@as(u8, 1), dhcp.dhcp_can_lease_transition(1, 0)); // Offered -> Available

    // Invalid transitions
    try std.testing.expectEqual(@as(u8, 0), dhcp.dhcp_can_lease_transition(0, 2)); // Available -> Bound (skip!)
    try std.testing.expectEqual(@as(u8, 0), dhcp.dhcp_can_lease_transition(0, 5)); // Available -> Expired (skip!)
    try std.testing.expectEqual(@as(u8, 0), dhcp.dhcp_can_lease_transition(5, 2)); // Expired -> Bound (skip!)
}

// =========================================================================
// 35. State queries on invalid slots
// =========================================================================

test "state queries safe on invalid slot" {
    try std.testing.expectEqual(@as(u8, 4), dhcp.dhcp_state(-1)); // ack_sent fallback
    try std.testing.expectEqual(@as(u8, 5), dhcp.dhcp_lease_state(-1, 0)); // expired fallback
    try std.testing.expectEqual(@as(u32, 0), dhcp.dhcp_client_xid(-1));
    try std.testing.expectEqual(@as(u16, 0), dhcp.dhcp_pool_count(-1));
    try std.testing.expectEqual(@as(u16, 0), dhcp.dhcp_pool_available_count(-1));
    try std.testing.expectEqual(@as(u32, 0), dhcp.dhcp_lease_ip(-1, 0));
    try std.testing.expectEqual(@as(u32, 0), dhcp.dhcp_lease_expiry(-1, 0));
}

// =========================================================================
// 36. Client MAC on invalid slot
// =========================================================================

test "client_mac returns error on invalid slot" {
    var mac_out: [6]u8 = undefined;
    try std.testing.expectEqual(@as(u8, 1), dhcp.dhcp_client_mac(-1, &mac_out));
}

// =========================================================================
// 37. Relay agent -- set and query
// =========================================================================

test "relay agent info: set and query giaddr/hops" {
    const slot = dhcp.dhcp_create_context();
    defer dhcp.dhcp_destroy_context(slot);

    // Initially no relay info
    try std.testing.expectEqual(@as(u8, 0), dhcp.dhcp_has_relay_info(slot));
    try std.testing.expectEqual(@as(u32, 0), dhcp.dhcp_relay_giaddr(slot));
    try std.testing.expectEqual(@as(u8, 0), dhcp.dhcp_relay_hops(slot));

    // Set relay info: giaddr=10.0.0.1 (0x0A000001), hops=1
    const circuit = [_]u8{ 0x00, 0x01, 0x02 }; // port identifier
    const remote = [_]u8{ 0xAA, 0xBB, 0xCC, 0xDD }; // device identifier
    try std.testing.expectEqual(@as(u8, 0), dhcp.dhcp_set_relay_info(
        slot,
        0x0A000001,
        1,
        &circuit,
        3,
        &remote,
        4,
    ));

    // Verify relay info is present
    try std.testing.expectEqual(@as(u8, 1), dhcp.dhcp_has_relay_info(slot));
    try std.testing.expectEqual(@as(u32, 0x0A000001), dhcp.dhcp_relay_giaddr(slot));
    try std.testing.expectEqual(@as(u8, 1), dhcp.dhcp_relay_hops(slot));
}

// =========================================================================
// 38. Relay agent -- giaddr must be non-zero
// =========================================================================

test "relay agent rejects zero giaddr" {
    const slot = dhcp.dhcp_create_context();
    defer dhcp.dhcp_destroy_context(slot);

    try std.testing.expectEqual(@as(u8, 1), dhcp.dhcp_set_relay_info(slot, 0, 1, null, 0, null, 0));
    try std.testing.expectEqual(@as(u8, 0), dhcp.dhcp_has_relay_info(slot)); // not set
}

// =========================================================================
// 39. Relay agent -- hop count limit
// =========================================================================

test "relay agent rejects excessive hops" {
    const slot = dhcp.dhcp_create_context();
    defer dhcp.dhcp_destroy_context(slot);

    // MAX_HOPS = 16, so hops=16 should be rejected
    try std.testing.expectEqual(@as(u8, 1), dhcp.dhcp_set_relay_info(slot, 0x0A000001, 16, null, 0, null, 0));
    try std.testing.expectEqual(@as(u8, 0), dhcp.dhcp_has_relay_info(slot)); // not set

    // hops=15 should be accepted
    try std.testing.expectEqual(@as(u8, 0), dhcp.dhcp_set_relay_info(slot, 0x0A000001, 15, null, 0, null, 0));
    try std.testing.expectEqual(@as(u8, 1), dhcp.dhcp_has_relay_info(slot));
}

// =========================================================================
// 40. Option TLV parsing -- standard option
// =========================================================================

test "parse_option: standard TLV option (subnet mask)" {
    // Option 1 (SubnetMask), length 4, data: 255.255.255.0
    const buf = [_]u8{ 1, 4, 255, 255, 255, 0, 255 };
    var code: u8 = undefined;
    var opt_len: u8 = undefined;
    var data_ptr: ?[*]const u8 = undefined;

    const result = dhcp.dhcp_parse_option(&buf, 7, 0, &code, &opt_len, &data_ptr);
    try std.testing.expectEqual(@as(u8, 0), result); // success
    try std.testing.expectEqual(@as(u8, 1), code); // SubnetMask wire code
    try std.testing.expectEqual(@as(u8, 4), opt_len);
    try std.testing.expect(data_ptr != null);
    const data = data_ptr.?;
    try std.testing.expectEqual(@as(u8, 255), data[0]);
    try std.testing.expectEqual(@as(u8, 255), data[1]);
    try std.testing.expectEqual(@as(u8, 255), data[2]);
    try std.testing.expectEqual(@as(u8, 0), data[3]);
}

// =========================================================================
// 41. Option TLV parsing -- pad option
// =========================================================================

test "parse_option: pad option (code 0)" {
    const buf = [_]u8{ 0, 53, 1, 1, 255 };
    var code: u8 = undefined;
    var opt_len: u8 = undefined;
    var data_ptr: ?[*]const u8 = undefined;

    const result = dhcp.dhcp_parse_option(&buf, 5, 0, &code, &opt_len, &data_ptr);
    try std.testing.expectEqual(@as(u8, 0), result); // success (pad is not an error)
    try std.testing.expectEqual(@as(u8, 0), code); // pad code
    try std.testing.expectEqual(@as(u8, 0), opt_len); // no data
}

// =========================================================================
// 42. Option TLV parsing -- end option
// =========================================================================

test "parse_option: end option (code 255)" {
    const buf = [_]u8{255};
    var code: u8 = undefined;
    var opt_len: u8 = undefined;
    var data_ptr: ?[*]const u8 = undefined;

    const result = dhcp.dhcp_parse_option(&buf, 1, 0, &code, &opt_len, &data_ptr);
    try std.testing.expectEqual(@as(u8, 1), result); // end-of-options signal
    try std.testing.expectEqual(@as(u8, 255), code);
}

// =========================================================================
// 43. Option TLV parsing -- null buffer
// =========================================================================

test "parse_option: null buffer returns error" {
    var code: u8 = undefined;
    var opt_len: u8 = undefined;
    var data_ptr: ?[*]const u8 = undefined;

    const result = dhcp.dhcp_parse_option(null, 10, 0, &code, &opt_len, &data_ptr);
    try std.testing.expectEqual(@as(u8, 1), result);
}

// =========================================================================
// 44. Option TLV parsing -- offset past end of buffer
// =========================================================================

test "parse_option: offset past buffer returns error" {
    const buf = [_]u8{ 1, 4, 0, 0, 0, 0 };
    var code: u8 = undefined;
    var opt_len: u8 = undefined;
    var data_ptr: ?[*]const u8 = undefined;

    const result = dhcp.dhcp_parse_option(&buf, 6, 6, &code, &opt_len, &data_ptr);
    try std.testing.expectEqual(@as(u8, 1), result);
}

// =========================================================================
// 45. Option TLV parsing -- truncated option (length exceeds buffer)
// =========================================================================

test "parse_option: truncated option data returns error" {
    // Option 51 (LeaseTime), claims length 4, but only 2 bytes of data follow
    const buf = [_]u8{ 51, 4, 0, 0 };
    var code: u8 = undefined;
    var opt_len: u8 = undefined;
    var data_ptr: ?[*]const u8 = undefined;

    const result = dhcp.dhcp_parse_option(&buf, 4, 0, &code, &opt_len, &data_ptr);
    try std.testing.expectEqual(@as(u8, 1), result); // error: data exceeds buffer
}

// =========================================================================
// 46. Multiple concurrent contexts
// =========================================================================

test "multiple concurrent contexts are independent" {
    const slot_a = dhcp.dhcp_create_context();
    const slot_b = dhcp.dhcp_create_context();
    defer dhcp.dhcp_destroy_context(slot_a);
    defer dhcp.dhcp_destroy_context(slot_b);

    try std.testing.expect(slot_a >= 0);
    try std.testing.expect(slot_b >= 0);
    try std.testing.expect(slot_a != slot_b);

    // Advance slot_a through DISCOVER
    const mac_a = [_]u8{ 0xAA, 0x00, 0x00, 0x00, 0x00, 0x01 };
    var discover_a = buildDiscover(0x11111111, mac_a);
    _ = dhcp.dhcp_parse_discover(slot_a, &discover_a, 244);

    // slot_a is DiscoverReceived, slot_b is still Idle
    try std.testing.expectEqual(@as(u8, 1), dhcp.dhcp_state(slot_a));
    try std.testing.expectEqual(@as(u8, 0), dhcp.dhcp_state(slot_b));

    // Advance slot_b independently
    const mac_b = [_]u8{ 0xBB, 0x00, 0x00, 0x00, 0x00, 0x02 };
    var discover_b = buildDiscover(0x22222222, mac_b);
    _ = dhcp.dhcp_parse_discover(slot_b, &discover_b, 244);
    try std.testing.expectEqual(@as(u8, 1), dhcp.dhcp_state(slot_b));

    // Verify different xids
    try std.testing.expectEqual(@as(u32, 0x11111111), dhcp.dhcp_client_xid(slot_a));
    try std.testing.expectEqual(@as(u32, 0x22222222), dhcp.dhcp_client_xid(slot_b));
}

// =========================================================================
// 47. Relay agent on invalid slot
// =========================================================================

test "relay queries safe on invalid slot" {
    try std.testing.expectEqual(@as(u8, 0), dhcp.dhcp_has_relay_info(-1));
    try std.testing.expectEqual(@as(u32, 0), dhcp.dhcp_relay_giaddr(-1));
    try std.testing.expectEqual(@as(u8, 0), dhcp.dhcp_relay_hops(-1));
}

// =========================================================================
// 48. Lease duration constants match Idris2 Lease.idr
// =========================================================================

test "lease duration constants match Lease.idr" {
    try std.testing.expectEqual(@as(u32, 60), dhcp.MIN_LEASE_SECS);
    try std.testing.expectEqual(@as(u32, 31536000), dhcp.MAX_LEASE_SECS);
    try std.testing.expectEqual(@as(u8, 16), dhcp.MAX_HOPS);
}

// =========================================================================
// 49. Relay agent -- null circuit/remote IDs accepted
// =========================================================================

test "relay agent accepts null circuit and remote IDs" {
    const slot = dhcp.dhcp_create_context();
    defer dhcp.dhcp_destroy_context(slot);

    try std.testing.expectEqual(@as(u8, 0), dhcp.dhcp_set_relay_info(
        slot,
        0xC0A80101,
        3,
        null,
        0,
        null,
        0,
    ));
    try std.testing.expectEqual(@as(u8, 1), dhcp.dhcp_has_relay_info(slot));
    try std.testing.expectEqual(@as(u32, 0xC0A80101), dhcp.dhcp_relay_giaddr(slot));
    try std.testing.expectEqual(@as(u8, 3), dhcp.dhcp_relay_hops(slot));
}

// =========================================================================
// 50. Parse discover rejects wrong message type in options
// =========================================================================

test "parse_discover rejects non-DISCOVER message type" {
    const slot = dhcp.dhcp_create_context();
    defer dhcp.dhcp_destroy_context(slot);

    // Build a packet that claims to be a REQUEST (type 3) but is sent to parse_discover
    var buf: [244]u8 = [_]u8{0} ** 244;
    buf[0] = 1; // BOOTREQUEST
    buf[1] = 1; // Ethernet
    buf[2] = 6; // hlen
    // Magic cookie
    buf[236] = 99;
    buf[237] = 130;
    buf[238] = 83;
    buf[239] = 99;
    // Option 53, length 1, value 3 (REQUEST, not DISCOVER)
    buf[240] = 53;
    buf[241] = 1;
    buf[242] = 3;
    buf[243] = 255;

    try std.testing.expectEqual(@as(u8, 1), dhcp.dhcp_parse_discover(slot, &buf, 244));
    try std.testing.expectEqual(@as(u8, 0), dhcp.dhcp_state(slot)); // still idle
}
