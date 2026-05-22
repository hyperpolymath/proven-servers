/* SPDX-License-Identifier: MPL-2.0
 * Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
 *
 * dhcp.h -- C-ABI header for proven-dhcp.
 * Generated from DHCPABI.Layout.idr tag assignments.
 *
 * This header defines the complete C interface to the proven-dhcp FFI library.
 * All enum tags match the Idris2 ABI definitions in DHCPABI.Layout.idr exactly.
 * The Zig implementation (ffi/zig/src/dhcp.zig) is the canonical implementation.
 *
 * Protocol references:
 *   - RFC 2131: Dynamic Host Configuration Protocol
 *   - RFC 2132: DHCP Options and BOOTP Vendor Extensions
 *   - RFC 3046: DHCP Relay Agent Information Option (Option 82)
 *   - RFC 1700: Hardware Types (IANA)
 */

#ifndef PROVEN_DHCP_H
#define PROVEN_DHCP_H

#include <stdint.h>

#ifdef __cplusplus
extern "C" {
#endif

/* -- MessageType (8 constructors, tags 0-7) ------------------------------- */
/* RFC 2131 Section 3.1, option 53.                                          */
#define DHCP_MSG_DISCOVER  0
#define DHCP_MSG_OFFER     1
#define DHCP_MSG_REQUEST   2
#define DHCP_MSG_ACK       3
#define DHCP_MSG_NAK       4
#define DHCP_MSG_RELEASE   5
#define DHCP_MSG_INFORM    6
#define DHCP_MSG_DECLINE   7

/* -- OptionCode (8 constructors, tags 0-7) -------------------------------- */
/* ABI tags are sequential; wire codes differ (see optionCodeToWire).         */
#define DHCP_OPT_SUBNET_MASK   0   /* RFC 2132 option  1 */
#define DHCP_OPT_ROUTER        1   /* RFC 2132 option  3 */
#define DHCP_OPT_DNS           2   /* RFC 2132 option  6 */
#define DHCP_OPT_DOMAIN_NAME   3   /* RFC 2132 option 15 */
#define DHCP_OPT_LEASE_TIME    4   /* RFC 2132 option 51 */
#define DHCP_OPT_SERVER_ID     5   /* RFC 2132 option 54 */
#define DHCP_OPT_REQUESTED_IP  6   /* RFC 2132 option 50 */
#define DHCP_OPT_MSG_TYPE      7   /* RFC 2132 option 53 */

/* -- HardwareType (4 constructors, tags 0-3) ------------------------------ */
/* IANA hardware type identifiers (RFC 1700).                                */
#define DHCP_HW_ETHERNET     0   /* htype  1 */
#define DHCP_HW_IEEE802      1   /* htype  6 */
#define DHCP_HW_ARCNET       2   /* htype  7 */
#define DHCP_HW_FRAME_RELAY  3   /* htype 15 */

/* -- DhcpState (6 constructors, tags 0-5) --------------------------------- */
/* DORA lifecycle states (DHCPABI.Transitions.idr).                          */
#define DHCP_STATE_IDLE               0
#define DHCP_STATE_DISCOVER_RECEIVED  1
#define DHCP_STATE_OFFER_SENT         2
#define DHCP_STATE_REQUEST_RECEIVED   3
#define DHCP_STATE_ACK_SENT           4
#define DHCP_STATE_NAK_SENT           5

/* -- LeaseState (6 constructors, tags 0-5) -------------------------------- */
/* Lease lifecycle states (DHCPABI.Layout.idr).                              */
#define DHCP_LEASE_AVAILABLE   0
#define DHCP_LEASE_OFFERED     1
#define DHCP_LEASE_BOUND       2
#define DHCP_LEASE_RENEWING    3
#define DHCP_LEASE_REBINDING   4
#define DHCP_LEASE_EXPIRED     5

/* -- RelayField (4 constructors, tags 0-3) -------------------------------- */
/* Relay agent sub-option types (RFC 3046 option 82).                        */
#define DHCP_RELAY_CIRCUIT_ID   0   /* sub-option 1 */
#define DHCP_RELAY_REMOTE_ID    1   /* sub-option 2 */
#define DHCP_RELAY_GIADDR       2   /* giaddr from relay */
#define DHCP_RELAY_HOPS         3   /* hop count */

/* -- Sentinel values ------------------------------------------------------ */
#define DHCP_INVALID  255

/* -- Constants ------------------------------------------------------------ */
#define DHCP_SERVER_PORT       67
#define DHCP_CLIENT_PORT       68
#define DHCP_MAX_MESSAGE_SIZE  576
#define DHCP_MIN_LEASE_SECS    60
#define DHCP_MAX_LEASE_SECS    31536000   /* 365 days */
#define DHCP_MAGIC_COOKIE      0x63825363

/* -- ABI ------------------------------------------------------------------ */
uint32_t dhcp_abi_version(void);

/* -- Lifecycle ------------------------------------------------------------ */
int      dhcp_create_context(void);
void     dhcp_destroy_context(int slot);

/* -- State queries -------------------------------------------------------- */
uint8_t  dhcp_state(int slot);
uint8_t  dhcp_lease_state(int slot, uint16_t lease_idx);
uint32_t dhcp_client_xid(int slot);
uint8_t  dhcp_client_mac(int slot, uint8_t *out);
uint32_t dhcp_lease_ip(int slot, uint16_t lease_idx);
uint32_t dhcp_lease_expiry(int slot, uint16_t lease_idx);
uint16_t dhcp_pool_count(int slot);
uint16_t dhcp_pool_available_count(int slot);

/* -- DORA lifecycle transitions ------------------------------------------- */
uint8_t dhcp_parse_discover(int slot, const uint8_t *buf, uint16_t len);
uint8_t dhcp_send_offer(int slot, uint32_t offered_ip, uint32_t subnet,
                        uint32_t router, uint32_t dns, uint32_t lease_secs);
uint8_t dhcp_parse_request(int slot, const uint8_t *buf, uint16_t len);
uint8_t dhcp_send_ack(int slot);
uint8_t dhcp_send_nak(int slot);
uint8_t dhcp_reset(int slot);

/* -- Lease pool operations ------------------------------------------------ */
int32_t dhcp_pool_allocate(int slot);
uint8_t dhcp_pool_bind(int slot, uint16_t lease_idx);
uint8_t dhcp_pool_release(int slot, uint16_t lease_idx);
uint8_t dhcp_pool_renew(int slot, uint16_t lease_idx);
uint8_t dhcp_pool_begin_renew(int slot, uint16_t lease_idx);
uint8_t dhcp_pool_begin_rebind(int slot, uint16_t lease_idx);
uint8_t dhcp_pool_expire(int slot, uint16_t lease_idx);
uint8_t dhcp_pool_reclaim(int slot, uint16_t lease_idx);
uint8_t dhcp_pool_decline(int slot, uint16_t lease_idx);

/* -- Relay agent (RFC 3046 option 82) ------------------------------------- */
uint8_t dhcp_set_relay_info(int slot, uint32_t giaddr, uint8_t hops,
                            const uint8_t *circuit_id, uint8_t circuit_len,
                            const uint8_t *remote_id, uint8_t remote_len);
uint8_t dhcp_has_relay_info(int slot);
uint32_t dhcp_relay_giaddr(int slot);
uint8_t dhcp_relay_hops(int slot);

/* -- Option TLV parsing --------------------------------------------------- */
uint8_t dhcp_parse_option(const uint8_t *buf, uint16_t len,
                          uint16_t offset, uint8_t *out_code,
                          uint8_t *out_len, const uint8_t **out_data);

/* -- Stateless transition checks ------------------------------------------ */
uint8_t dhcp_can_transition(uint8_t from, uint8_t to);
uint8_t dhcp_can_lease_transition(uint8_t from, uint8_t to);

#ifdef __cplusplus
}
#endif

#endif /* PROVEN_DHCP_H */
