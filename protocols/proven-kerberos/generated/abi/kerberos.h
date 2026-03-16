/* SPDX-License-Identifier: PMPL-1.0-or-later
 * Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
 *
 * kerberos.h -- C-ABI header for proven-kerberos.
 * Generated from KerberosABI.Layout.idr tag assignments.
 */

#ifndef PROVEN_KERBEROS_H
#define PROVEN_KERBEROS_H

#include <stdint.h>

#ifdef __cplusplus
extern "C" {
#endif

/* -- MessageType (10 constructors, tags 0-9) ------------------------------ */
#define KRB_MSG_AS_REQ    0
#define KRB_MSG_AS_REP    1
#define KRB_MSG_TGS_REQ   2
#define KRB_MSG_TGS_REP   3
#define KRB_MSG_AP_REQ    4
#define KRB_MSG_AP_REP    5
#define KRB_MSG_KRB_ERROR 6
#define KRB_MSG_KRB_SAFE  7
#define KRB_MSG_KRB_PRIV  8
#define KRB_MSG_KRB_CRED  9

/* -- EncryptionType (5 constructors, tags 0-4) ---------------------------- */
#define KRB_ENC_AES256_CTS_HMAC_SHA1   0
#define KRB_ENC_AES128_CTS_HMAC_SHA1   1
#define KRB_ENC_AES256_CTS_HMAC_SHA384 2
#define KRB_ENC_RC4_HMAC               3
#define KRB_ENC_DES3_CBC_SHA1          4

/* -- PrincipalType (7 constructors, tags 0-6) ----------------------------- */
#define KRB_NT_UNKNOWN    0
#define KRB_NT_PRINCIPAL  1
#define KRB_NT_SRV_INST   2
#define KRB_NT_SRV_HST    3
#define KRB_NT_UID        4
#define KRB_NT_X500       5
#define KRB_NT_ENTERPRISE 6

/* -- TicketFlag (7 constructors, tags 0-6) -------------------------------- */
#define KRB_FLAG_FORWARDABLE 0
#define KRB_FLAG_FORWARDED   1
#define KRB_FLAG_PROXIABLE   2
#define KRB_FLAG_PROXY       3
#define KRB_FLAG_RENEWABLE   4
#define KRB_FLAG_PRE_AUTHENT 5
#define KRB_FLAG_HW_AUTHENT  6

/* -- ErrorCode (10 constructors, tags 0-9) -------------------------------- */
#define KRB_ERR_NONE                0
#define KRB_ERR_NAME_EXP            1
#define KRB_ERR_SERVICE_EXP         2
#define KRB_ERR_BAD_PVNO            3
#define KRB_ERR_C_OLD_MAST_KVNO     4
#define KRB_ERR_S_OLD_MAST_KVNO     5
#define KRB_ERR_C_PRINCIPAL_UNKNOWN 6
#define KRB_ERR_S_PRINCIPAL_UNKNOWN 7
#define KRB_ERR_PREAUTH_FAILED      8
#define KRB_ERR_PREAUTH_REQUIRED    9

/* -- AuthState (5 constructors, tags 0-4) --------------------------------- */
#define KRB_AUTH_INITIAL                0
#define KRB_AUTH_TGT_OBTAINED           1
#define KRB_AUTH_SERVICE_TICKET_OBTAINED 2
#define KRB_AUTH_AUTHENTICATED          3
#define KRB_AUTH_FAILED                 4

/* -- EncStrength (3 constructors, tags 0-2) ------------------------------- */
#define KRB_STRENGTH_STRONG 0
#define KRB_STRENGTH_MEDIUM 1
#define KRB_STRENGTH_WEAK   2

/* -- PreAuthType (4 constructors, tags 0-3) ------------------------------- */
#define KRB_PA_ENC_TIMESTAMP 0
#define KRB_PA_ETYPE_INFO2   1
#define KRB_PA_FX_FAST       2
#define KRB_PA_FX_COOKIE     3

/* -- NegotiationState (4 constructors, tags 0-3) -------------------------- */
#define KRB_NEG_IDLE   0
#define KRB_NEG_PROPOSED 1
#define KRB_NEG_SELECTED 2
#define KRB_NEG_FAILED   3

/* -- Sentinel values ------------------------------------------------------ */
#define KRB_NONE 255

/* -- ABI ------------------------------------------------------------------ */
uint32_t krb_abi_version(void);

/* -- Lifecycle ------------------------------------------------------------ */
int      krb_create(const uint8_t *realm_ptr, uint32_t realm_len);
void     krb_destroy(int slot);

/* -- State queries -------------------------------------------------------- */
uint8_t  krb_auth_state(int slot);

/* -- Principal management ------------------------------------------------- */
uint8_t  krb_set_client_principal(int slot, const uint8_t *name_ptr,
                                  uint32_t name_len, uint8_t ptype);
uint8_t  krb_set_service_principal(int slot, const uint8_t *name_ptr,
                                   uint32_t name_len, uint8_t ptype);

/* -- Encryption negotiation ----------------------------------------------- */
uint8_t  krb_propose_enctypes(int slot, const uint8_t *types_ptr,
                              uint32_t count);
uint8_t  krb_negotiate_enctype(int slot, const uint8_t *server_types_ptr,
                               uint32_t count);
uint8_t  krb_negotiation_state(int slot);
uint8_t  krb_selected_enctype(int slot);

/* -- Authentication state transitions ------------------------------------- */
uint8_t  krb_obtain_tgt(int slot);
uint8_t  krb_obtain_service_ticket(int slot);
uint8_t  krb_authenticate(int slot);
uint8_t  krb_fail(int slot, uint8_t error_code);
uint8_t  krb_retry(int slot);
uint8_t  krb_renew_tgt(int slot);
uint8_t  krb_reauth(int slot);

/* -- Ticket queries ------------------------------------------------------- */
uint8_t  krb_has_tgt(int slot);
uint8_t  krb_has_service_ticket(int slot);
uint8_t  krb_has_access(int slot);
uint8_t  krb_last_error(int slot);

/* -- Ticket flag management ----------------------------------------------- */
uint32_t krb_ticket_flags_count(int slot);
uint8_t  krb_add_ticket_flag(int slot, uint8_t flag);
uint8_t  krb_has_ticket_flag(int slot, uint8_t flag);

/* -- Stateless queries ---------------------------------------------------- */
uint8_t  krb_can_transition(uint8_t from, uint8_t to);
uint8_t  krb_neg_can_transition(uint8_t from, uint8_t to);
uint8_t  krb_enc_strength(uint8_t enc_type);

#ifdef __cplusplus
}
#endif

#endif /* PROVEN_KERBEROS_H */
