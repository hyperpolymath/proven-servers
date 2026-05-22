/* SPDX-License-Identifier: MPL-2.0
 * Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
 *
 * radius.h -- C-ABI header for proven-radius.
 * Generated from RADIUSABI.Layout.idr and RADIUSABI.Transitions.idr tag assignments.
 *
 * Tag values MUST match:
 *   - Idris2 ABI  (src/abi/Layout.idr)
 *   - Idris2 Transitions (src/abi/Transitions.idr)
 *   - Zig FFI     (ffi/zig/src/radius.zig)
 */

#ifndef PROVEN_RADIUS_H
#define PROVEN_RADIUS_H

#include <stdint.h>

#ifdef __cplusplus
extern "C" {
#endif

/* -- PacketType (6 constructors, RFC 2865 Code field values) -------------- */
#define RADIUS_PKT_ACCESS_REQUEST      1
#define RADIUS_PKT_ACCESS_ACCEPT       2
#define RADIUS_PKT_ACCESS_REJECT       3
#define RADIUS_PKT_ACCOUNTING_REQUEST  4
#define RADIUS_PKT_ACCOUNTING_RESPONSE 5
#define RADIUS_PKT_ACCESS_CHALLENGE    11

/* -- AttributeType (9 constructors, RFC 2865 Type field values) ----------- */
#define RADIUS_ATTR_USER_NAME       1
#define RADIUS_ATTR_USER_PASSWORD   2
#define RADIUS_ATTR_NAS_IP_ADDRESS  4
#define RADIUS_ATTR_NAS_PORT        5
#define RADIUS_ATTR_SERVICE_TYPE    6
#define RADIUS_ATTR_FRAMED_PROTOCOL 7
#define RADIUS_ATTR_FRAMED_IP_ADDR  8
#define RADIUS_ATTR_REPLY_MESSAGE   18
#define RADIUS_ATTR_SESSION_TIMEOUT 27

/* -- ServiceType (6 constructors, RFC 2865 Section 5.6 values) ------------ */
#define RADIUS_SVC_LOGIN           1
#define RADIUS_SVC_FRAMED          2
#define RADIUS_SVC_CALLBACK_LOGIN  3
#define RADIUS_SVC_CALLBACK_FRAMED 4
#define RADIUS_SVC_OUTBOUND        5
#define RADIUS_SVC_ADMINISTRATIVE  6

/* -- AuthMethod (5 constructors, tags 0-4) -------------------------------- */
#define RADIUS_AUTH_PAP      0
#define RADIUS_AUTH_CHAP     1
#define RADIUS_AUTH_MSCHAP   2
#define RADIUS_AUTH_MSCHAPV2 3
#define RADIUS_AUTH_EAP      4

/* -- SessionState (7 constructors, tags 0-6) ------------------------------ */
#define RADIUS_STATE_IDLE           0
#define RADIUS_STATE_AUTHENTICATING 1
#define RADIUS_STATE_AUTHORIZED     2
#define RADIUS_STATE_REJECTED       3
#define RADIUS_STATE_CHALLENGED     4
#define RADIUS_STATE_ACCOUNTING     5
#define RADIUS_STATE_COMPLETE       6

/* -- RadiusResult (5 constructors, tags 0-4) ------------------------------ */
#define RADIUS_RESULT_OK             0
#define RADIUS_RESULT_ERR            1
#define RADIUS_RESULT_INVALID_PARAM  2
#define RADIUS_RESULT_POOL_EXHAUSTED 3
#define RADIUS_RESULT_BAD_SECRET     4

/* -- Layout constants (RFC 2865 Section 3 / Section 5) -------------------- */
#define RADIUS_PACKET_HEADER_SIZE    20
#define RADIUS_MAX_PACKET_SIZE       4096
#define RADIUS_MIN_PACKET_SIZE       20
#define RADIUS_ATTRIBUTE_HEADER_SIZE 2
#define RADIUS_MAX_ATTR_VALUE_LEN    253

/* -- ABI ------------------------------------------------------------------ */
uint32_t radius_abi_version(void);

/* -- Lifecycle ------------------------------------------------------------ */
int      radius_session_create(uint8_t auth_method);
void     radius_session_destroy(int slot);

/* -- State queries -------------------------------------------------------- */
uint8_t  radius_session_state(int slot);
uint8_t  radius_get_auth_method(int slot);
uint8_t  radius_get_packet_id(int slot);
uint8_t  radius_get_attribute_count(int slot);

/* -- AAA transitions ------------------------------------------------------ */
uint8_t  radius_begin_auth(int slot, uint8_t pkt_id);
uint8_t  radius_accept_auth(int slot);
uint8_t  radius_reject_auth(int slot);
uint8_t  radius_challenge_auth(int slot);
uint8_t  radius_respond_challenge(int slot);
uint8_t  radius_begin_accounting(int slot);
uint8_t  radius_end_accounting(int slot);
uint8_t  radius_end_session(int slot);

/* -- Stateless validation ------------------------------------------------- */
uint8_t  radius_can_transition(uint8_t from, uint8_t to);

/* -- Shared secret -------------------------------------------------------- */
uint8_t  radius_set_secret(int slot, const uint8_t *secret_ptr, uint32_t secret_len);

/* -- Attribute encoding --------------------------------------------------- */
uint8_t  radius_add_attribute(int slot, uint8_t attr_type,
                              const uint8_t *value_ptr, uint8_t value_len);

#ifdef __cplusplus
}
#endif

#endif /* PROVEN_RADIUS_H */
