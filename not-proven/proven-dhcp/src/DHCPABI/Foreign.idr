-- SPDX-License-Identifier: PMPL-1.0-or-later
-- Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
--
-- DHCPABI.Foreign: Foreign function declarations for the C bridge.
--
-- Declares the opaque handle type and documents the complete FFI contract
-- that the Zig implementation must provide.

module DHCPABI.Foreign

import DHCPABI.Layout
import DHCPABI.Transitions

%default total

---------------------------------------------------------------------------
-- Opaque handle type
---------------------------------------------------------------------------

||| Opaque handle to a DHCP context.
||| Created by dhcp_create_context(), destroyed by dhcp_destroy_context().
export
data DhcpHandle : Type where [external]

---------------------------------------------------------------------------
-- ABI version
---------------------------------------------------------------------------

||| ABI version — must match dhcp_abi_version() return value.
public export
abiVersion : Bits32
abiVersion = 1

---------------------------------------------------------------------------
-- FFI function contract
---------------------------------------------------------------------------

-- +-----------------------------------------------------------------------+
-- | Function                  | Signature                                 |
-- +---------------------------+-------------------------------------------+
-- | dhcp_abi_version          | () -> Bits32                              |
-- +---------------------------+-------------------------------------------+
-- | dhcp_create_context       | () -> c_int (slot)                        |
-- |                           | Creates context in Idle state with lease   |
-- |                           | pool initialised to Available.             |
-- +---------------------------+-------------------------------------------+
-- | dhcp_destroy_context      | (slot: c_int) -> ()                       |
-- +---------------------------+-------------------------------------------+
-- | dhcp_state                | (slot: c_int) -> u8 (DhcpState tag)       |
-- |                           | 0=Idle, 1=DiscoverReceived, 2=OfferSent,  |
-- |                           | 3=RequestReceived, 4=AckSent, 5=NakSent   |
-- +---------------------------+-------------------------------------------+
-- | dhcp_lease_state          | (slot: c_int, lease_idx: u16) -> u8       |
-- |                           | Returns LeaseState tag for a lease entry.  |
-- |                           | 0=Available, 1=Offered, 2=Bound,          |
-- |                           | 3=Renewing, 4=Rebinding, 5=Expired        |
-- +---------------------------+-------------------------------------------+
-- | dhcp_parse_discover       | (slot: c_int, buf: *const u8,             |
-- |                           |  len: u16) -> u8 (0=ok, 1=error)          |
-- |                           | Idle -> DiscoverReceived.                  |
-- |                           | Parses DHCP DISCOVER message (RFC 2131).   |
-- +---------------------------+-------------------------------------------+
-- | dhcp_send_offer           | (slot: c_int, offered_ip: u32,            |
-- |                           |  subnet: u32, router: u32, dns: u32,      |
-- |                           |  lease_secs: u32) -> u8 (0=ok, 1=error)   |
-- |                           | DiscoverReceived -> OfferSent.             |
-- +---------------------------+-------------------------------------------+
-- | dhcp_parse_request        | (slot: c_int, buf: *const u8,             |
-- |                           |  len: u16) -> u8 (0=ok, 1=error)          |
-- |                           | OfferSent -> RequestReceived.              |
-- +---------------------------+-------------------------------------------+
-- | dhcp_send_ack             | (slot: c_int) -> u8 (0=ok, 1=error)       |
-- |                           | RequestReceived -> AckSent.                |
-- |                           | Binds the offered lease.                   |
-- +---------------------------+-------------------------------------------+
-- | dhcp_send_nak             | (slot: c_int) -> u8 (0=ok, 1=error)       |
-- |                           | RequestReceived -> NakSent.                |
-- +---------------------------+-------------------------------------------+
-- | dhcp_reset                | (slot: c_int) -> u8 (0=ok, 1=error)       |
-- |                           | Any non-terminal -> Idle.                  |
-- |                           | Resets the DORA cycle for reuse.           |
-- +---------------------------+-------------------------------------------+
-- | dhcp_pool_allocate        | (slot: c_int) -> i32                      |
-- |                           | Allocate a lease from the pool.  Returns   |
-- |                           | lease index (0-255) or -1 if full.         |
-- |                           | Transitions: Available -> Offered.         |
-- +---------------------------+-------------------------------------------+
-- | dhcp_pool_bind            | (slot: c_int, lease_idx: u16) -> u8       |
-- |                           | Offered -> Bound.                          |
-- +---------------------------+-------------------------------------------+
-- | dhcp_pool_release         | (slot: c_int, lease_idx: u16) -> u8       |
-- |                           | Bound -> Available.                        |
-- +---------------------------+-------------------------------------------+
-- | dhcp_pool_renew           | (slot: c_int, lease_idx: u16) -> u8       |
-- |                           | Bound -> Renewing -> Bound (on success).   |
-- +---------------------------+-------------------------------------------+
-- | dhcp_pool_expire          | (slot: c_int, lease_idx: u16) -> u8       |
-- |                           | Rebinding -> Expired.                      |
-- +---------------------------+-------------------------------------------+
-- | dhcp_pool_reclaim         | (slot: c_int, lease_idx: u16) -> u8       |
-- |                           | Expired -> Available.                      |
-- +---------------------------+-------------------------------------------+
-- | dhcp_pool_decline         | (slot: c_int, lease_idx: u16) -> u8       |
-- |                           | Offered -> Available.                      |
-- +---------------------------+-------------------------------------------+
-- | dhcp_pool_count           | (slot: c_int) -> u16                      |
-- |                           | Number of leases in pool.                  |
-- +---------------------------+-------------------------------------------+
-- | dhcp_pool_available_count | (slot: c_int) -> u16                      |
-- |                           | Number of Available leases.                |
-- +---------------------------+-------------------------------------------+
-- | dhcp_lease_ip             | (slot: c_int, lease_idx: u16) -> u32      |
-- |                           | IP address of a lease entry (network order)|
-- +---------------------------+-------------------------------------------+
-- | dhcp_lease_expiry         | (slot: c_int, lease_idx: u16) -> u32      |
-- |                           | Lease expiry timestamp.                    |
-- +---------------------------+-------------------------------------------+
-- | dhcp_client_mac           | (slot: c_int, out: *u8) -> u8             |
-- |                           | Copy client MAC address (6 bytes) to out.  |
-- +---------------------------+-------------------------------------------+
-- | dhcp_client_xid           | (slot: c_int) -> u32                      |
-- |                           | Client transaction ID.                     |
-- +---------------------------+-------------------------------------------+
-- | dhcp_can_transition       | (from: u8, to: u8) -> u8 (1=yes, 0=no)   |
-- |                           | Stateless DORA transition check.           |
-- +---------------------------+-------------------------------------------+
-- | dhcp_can_lease_transition | (from: u8, to: u8) -> u8 (1=yes, 0=no)   |
-- |                           | Stateless lease transition check.          |
-- +---------------------------+-------------------------------------------+
