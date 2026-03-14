/* SPDX-License-Identifier: PMPL-1.0-or-later
 * Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
 *
 * ldap.h -- C-ABI header for proven-ldap.
 * Generated from LDAPABI.Layout.idr tag assignments.
 */

#ifndef PROVEN_LDAP_H
#define PROVEN_LDAP_H

#include <stdint.h>

#ifdef __cplusplus
extern "C" {
#endif

/* -- SessionState (4 constructors, tags 0-3) ------------------------------ */
#define LDAP_STATE_ANONYMOUS 0
#define LDAP_STATE_BOUND     1
#define LDAP_STATE_CLOSED    2
#define LDAP_STATE_BINDING   3

/* -- Operation (10 constructors, tags 0-9) -------------------------------- */
#define LDAP_OP_BIND     0
#define LDAP_OP_UNBIND   1
#define LDAP_OP_SEARCH   2
#define LDAP_OP_MODIFY   3
#define LDAP_OP_ADD      4
#define LDAP_OP_DELETE   5
#define LDAP_OP_MODDN    6
#define LDAP_OP_COMPARE  7
#define LDAP_OP_ABANDON  8
#define LDAP_OP_EXTENDED 9

/* -- SearchScope (3 constructors, tags 0-2) ------------------------------- */
#define LDAP_SCOPE_BASE_OBJECT   0
#define LDAP_SCOPE_SINGLE_LEVEL  1
#define LDAP_SCOPE_WHOLE_SUBTREE 2

/* -- ResultCode (11 constructors, tags 0-10) ------------------------------ */
#define LDAP_RESULT_SUCCESS                    0
#define LDAP_RESULT_OPERATIONS_ERROR           1
#define LDAP_RESULT_PROTOCOL_ERROR             2
#define LDAP_RESULT_TIME_LIMIT_EXCEEDED        3
#define LDAP_RESULT_SIZE_LIMIT_EXCEEDED        4
#define LDAP_RESULT_AUTH_METHOD_NOT_SUPPORTED   5
#define LDAP_RESULT_NO_SUCH_OBJECT             6
#define LDAP_RESULT_INVALID_CREDENTIALS        7
#define LDAP_RESULT_INSUFFICIENT_ACCESS_RIGHTS 8
#define LDAP_RESULT_BUSY                       9
#define LDAP_RESULT_UNAVAILABLE                10
#define LDAP_RESULT_NONE                       255

/* -- ABI ------------------------------------------------------------------ */
uint32_t ldap_abi_version(void);

/* -- Lifecycle ------------------------------------------------------------ */
int      ldap_create(void);
void     ldap_destroy(int slot);

/* -- State queries -------------------------------------------------------- */
uint8_t  ldap_state(int slot);
uint8_t  ldap_last_result(int slot);
uint32_t ldap_message_id(int slot);
uint32_t ldap_bind_dn(int slot, uint8_t *buf, uint32_t buf_len);

/* -- Commands ------------------------------------------------------------- */
uint8_t ldap_bind(int slot, const uint8_t *dn, uint32_t dn_len,
                  const uint8_t *pw, uint32_t pw_len);
uint8_t ldap_bind_complete(int slot, uint8_t result_tag);
uint8_t ldap_unbind(int slot);
uint8_t ldap_search(int slot, const uint8_t *base_dn, uint32_t base_len,
                    uint8_t scope);
uint8_t ldap_modify(int slot);
uint8_t ldap_add(int slot);
uint8_t ldap_delete(int slot);
uint8_t ldap_compare(int slot);
uint8_t ldap_abandon(int slot, uint32_t msg_id);

/* -- Stateless queries ---------------------------------------------------- */
uint8_t ldap_can_modify(uint8_t state_tag);
uint8_t ldap_can_search(uint8_t state_tag);
uint8_t ldap_can_transition(uint8_t from, uint8_t to);

#ifdef __cplusplus
}
#endif

#endif /* PROVEN_LDAP_H */
