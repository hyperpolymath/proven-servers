/* SPDX-License-Identifier: PMPL-1.0-or-later
 * Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
 *
 * firewall.h -- C-ABI header for proven-firewall.
 * Generated from FirewallABI.Layout.idr tag assignments.
 */

#ifndef PROVEN_FIREWALL_H
#define PROVEN_FIREWALL_H

#include <stdint.h>

#ifdef __cplusplus
extern "C" {
#endif

/* -- Action (8 constructors, tags 0-7) ------------------------------------ */
#define FW_ACTION_ACCEPT      0
#define FW_ACTION_DROP        1
#define FW_ACTION_REJECT      2
#define FW_ACTION_LOG         3
#define FW_ACTION_REDIRECT    4
#define FW_ACTION_DNAT        5
#define FW_ACTION_SNAT        6
#define FW_ACTION_MASQUERADE  7

/* -- Protocol (8 constructors, tags 0-7) ---------------------------------- */
#define FW_PROTO_TCP     0
#define FW_PROTO_UDP     1
#define FW_PROTO_ICMP    2
#define FW_PROTO_ICMPV6  3
#define FW_PROTO_GRE     4
#define FW_PROTO_ESP     5
#define FW_PROTO_AH      6
#define FW_PROTO_ANY     7

/* -- ChainType (5 constructors, tags 0-4) --------------------------------- */
#define FW_CHAIN_INPUT        0
#define FW_CHAIN_OUTPUT       1
#define FW_CHAIN_FORWARD      2
#define FW_CHAIN_PRE_ROUTING  3
#define FW_CHAIN_POST_ROUTING 4

/* -- RuleMatch (8 constructors, tags 0-7) --------------------------------- */
#define FW_MATCH_SOURCE_IP    0
#define FW_MATCH_DEST_IP      1
#define FW_MATCH_SOURCE_PORT  2
#define FW_MATCH_DEST_PORT    3
#define FW_MATCH_PROTOCOL     4
#define FW_MATCH_INTERFACE    5
#define FW_MATCH_STATE        6
#define FW_MATCH_MARK         7

/* -- ConnState (4 constructors, tags 0-3) --------------------------------- */
#define FW_CONN_NEW          0
#define FW_CONN_ESTABLISHED  1
#define FW_CONN_RELATED      2
#define FW_CONN_INVALID      3

/* -- PacketState (5 constructors, tags 0-4) ------------------------------- */
#define FW_STATE_ARRIVED         0
#define FW_STATE_CLASSIFIED      1
#define FW_STATE_CHAIN_TRAVERSAL 2
#define FW_STATE_DECIDED         3
#define FW_STATE_COMMITTED       4

/* -- ConnTrackState (4 constructors, tags 0-3) ---------------------------- */
#define FW_CONNTRACK_UNTRACKED  0
#define FW_CONNTRACK_TRACKING   1
#define FW_CONNTRACK_TRACKED    2
#define FW_CONNTRACK_EXPIRED    3

/* -- Sentinel values ------------------------------------------------------ */
#define FW_INVALID 255

/* -- ABI ------------------------------------------------------------------ */
uint32_t fw_abi_version(void);

/* -- Lifecycle ------------------------------------------------------------ */
int      fw_create_context(void);
void     fw_destroy_context(int slot);

/* -- State queries -------------------------------------------------------- */
uint8_t  fw_packet_state(int slot);
uint8_t  fw_conntrack_state(int slot);
uint8_t  fw_get_decision(int slot);
uint16_t fw_rule_count(int slot);
uint8_t  fw_packet_proto(int slot);
uint8_t  fw_packet_chain(int slot);
uint32_t fw_packet_src_ip(int slot);
uint32_t fw_packet_dst_ip(int slot);
uint16_t fw_packet_src_port(int slot);
uint16_t fw_packet_dst_port(int slot);
uint8_t  fw_conn_state(int slot);

/* -- Packet lifecycle transitions ----------------------------------------- */
uint8_t fw_classify_packet(int slot, uint8_t proto, uint8_t chain,
                           uint32_t src_ip, uint32_t dst_ip,
                           uint16_t src_port, uint16_t dst_port);
uint8_t fw_begin_chain(int slot);
uint8_t fw_add_rule(int slot, uint8_t match_type, uint32_t match_value,
                    uint8_t action, uint16_t priority);
uint8_t fw_evaluate_rules(int slot);
uint8_t fw_set_default_action(int slot, uint8_t action);
uint8_t fw_commit(int slot);

/* -- Connection tracking operations --------------------------------------- */
uint8_t fw_begin_tracking(int slot);
uint8_t fw_complete_tracking(int slot, uint8_t conn_state);
uint8_t fw_expire_conn(int slot);

/* -- Stateless transition checks ------------------------------------------ */
uint8_t fw_can_transition(uint8_t from, uint8_t to);
uint8_t fw_can_conntrack_transition(uint8_t from, uint8_t to);

#ifdef __cplusplus
}
#endif

#endif /* PROVEN_FIREWALL_H */
