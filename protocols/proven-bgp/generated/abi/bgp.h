/* SPDX-License-Identifier: PMPL-1.0-or-later */
/* Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk> */
/*
 * bgp.h -- C header for proven-bgp FFI.
 *
 * Generated from BGPABI.Layout (Idris2).
 * Tag values MUST match Layout.idr and bgp.zig exactly.
 */

#ifndef PROVEN_BGP_ABI_H
#define PROVEN_BGP_ABI_H

#include <stdint.h>

#define PROVEN_BGP_ABI_VERSION 1

/* BGPState (6 values, tags 0-5) */
#define BGP_STATE_IDLE          0
#define BGP_STATE_CONNECT       1
#define BGP_STATE_ACTIVE        2
#define BGP_STATE_OPENSENT      3
#define BGP_STATE_OPENCONFIRM   4
#define BGP_STATE_ESTABLISHED   5

/* BGPEvent (19 values, tags 0-18) */
#define BGP_EVENT_MANUAL_START               0
#define BGP_EVENT_MANUAL_STOP                1
#define BGP_EVENT_AUTOMATIC_START            2
#define BGP_EVENT_CONNECT_RETRY_TIMER_EXPIRES 3
#define BGP_EVENT_HOLD_TIMER_EXPIRES         4
#define BGP_EVENT_KEEPALIVE_TIMER_EXPIRES    5
#define BGP_EVENT_DELAY_OPEN_TIMER_EXPIRES   6
#define BGP_EVENT_TCP_CONNECTION_VALID       7
#define BGP_EVENT_TCP_CR_ACKED              8
#define BGP_EVENT_TCP_CONNECTION_CONFIRMED   9
#define BGP_EVENT_TCP_CONNECTION_FAILS       10
#define BGP_EVENT_BGP_OPEN_RECEIVED          11
#define BGP_EVENT_BGP_HEADER_ERR             12
#define BGP_EVENT_BGP_OPEN_MSG_ERR           13
#define BGP_EVENT_NOTIF_MSG_VER_ERR          14
#define BGP_EVENT_NOTIF_MSG                  15
#define BGP_EVENT_KEEPALIVE_MSG              16
#define BGP_EVENT_UPDATE_MSG                 17
#define BGP_EVENT_UPDATE_MSG_ERR             18

/* MessageType (4 values, tags 0-3) */
#define BGP_MSG_OPEN         0
#define BGP_MSG_UPDATE       1
#define BGP_MSG_NOTIFICATION 2
#define BGP_MSG_KEEPALIVE    3

/* ErrorCode (6 values, tags 0-5) */
#define BGP_ERR_MESSAGE_HEADER 0
#define BGP_ERR_OPEN_MESSAGE   1
#define BGP_ERR_UPDATE_MESSAGE 2
#define BGP_ERR_HOLD_TIMER     3
#define BGP_ERR_FSM            4
#define BGP_ERR_CEASE          5

/* Origin (3 values, tags 0-2) */
#define BGP_ORIGIN_IGP        0
#define BGP_ORIGIN_EGP        1
#define BGP_ORIGIN_INCOMPLETE 2

/* ASPathSegmentType (2 values, tags 0-1) */
#define BGP_ASPATH_SET      0
#define BGP_ASPATH_SEQUENCE 1

/* PathAttrType (8 values, tags 0-7) */
#define BGP_ATTR_ORIGIN      0
#define BGP_ATTR_AS_PATH     1
#define BGP_ATTR_NEXT_HOP    2
#define BGP_ATTR_MED         3
#define BGP_ATTR_LOCAL_PREF  4
#define BGP_ATTR_ATOMIC_AGGR 5
#define BGP_ATTR_AGGREGATOR  6
#define BGP_ATTR_UNKNOWN     7

/* --- FFI function prototypes --- */

uint32_t bgp_abi_version(void);
int      bgp_create(uint32_t local_as, uint32_t peer_as, uint16_t hold_time);
void     bgp_destroy(int slot);
uint8_t  bgp_state(int slot);
uint8_t  bgp_apply_event(int slot, uint8_t event);
uint8_t  bgp_is_established(int slot);
uint32_t bgp_connect_retry_count(int slot);
uint32_t bgp_routes_received(int slot);
uint8_t  bgp_add_route(int slot);
uint8_t  bgp_withdraw_route(int slot);
uint8_t  bgp_can_exchange(int slot);
uint8_t  bgp_can_transition(uint8_t from, uint8_t to);
uint16_t bgp_hold_time(int slot);
uint32_t bgp_local_as(int slot);
uint32_t bgp_peer_as(int slot);

#endif /* PROVEN_BGP_ABI_H */
