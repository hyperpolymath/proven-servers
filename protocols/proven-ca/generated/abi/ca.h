/* SPDX-License-Identifier: MPL-2.0
 * Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
 *
 * ca.h -- C-ABI header for proven-ca.
 * Generated from CAABI.Layout.idr tag assignments.
 *
 * This header declares all 24 FFI functions exposed by the Zig
 * implementation (ffi/zig/src/ca.zig).  Tag values match the
 * Idris2 Layout.idr encoders/decoders exactly.
 */

#ifndef PROVEN_CA_H
#define PROVEN_CA_H

#include <stdint.h>

#ifdef __cplusplus
extern "C" {
#endif

/* -- CertType (7 constructors, tags 0-6) ---------------------------------- */
#define CA_CERT_TYPE_ROOT             0
#define CA_CERT_TYPE_INTERMEDIATE     1
#define CA_CERT_TYPE_END_ENTITY       2
#define CA_CERT_TYPE_CROSS_SIGNED     3
#define CA_CERT_TYPE_CODE_SIGNING     4
#define CA_CERT_TYPE_EMAIL_PROTECTION 5
#define CA_CERT_TYPE_OCSP_SIGNING     6

/* -- KeyAlgorithm (6 constructors, tags 0-5) ------------------------------ */
#define CA_KEY_ALGO_RSA2048    0
#define CA_KEY_ALGO_RSA4096    1
#define CA_KEY_ALGO_ECDSA_P256 2
#define CA_KEY_ALGO_ECDSA_P384 3
#define CA_KEY_ALGO_ED25519    4
#define CA_KEY_ALGO_ED448      5

/* -- SignatureAlgorithm (7 constructors, tags 0-6) ------------------------ */
#define CA_SIG_ALGO_SHA256_WITH_RSA   0
#define CA_SIG_ALGO_SHA384_WITH_RSA   1
#define CA_SIG_ALGO_SHA512_WITH_RSA   2
#define CA_SIG_ALGO_SHA256_WITH_ECDSA 3
#define CA_SIG_ALGO_SHA384_WITH_ECDSA 4
#define CA_SIG_ALGO_PURE_ED25519      5
#define CA_SIG_ALGO_PURE_ED448        6

/* -- CertState (5 constructors, tags 0-4) --------------------------------- */
#define CA_STATE_PENDING   0
#define CA_STATE_ACTIVE    1
#define CA_STATE_REVOKED   2
#define CA_STATE_EXPIRED   3
#define CA_STATE_SUSPENDED 4

/* -- RevocationReason (7 constructors, tags 0-6) -------------------------- */
#define CA_REVOKE_UNSPECIFIED            0
#define CA_REVOKE_KEY_COMPROMISE         1
#define CA_REVOKE_CA_COMPROMISE          2
#define CA_REVOKE_AFFILIATION_CHANGED    3
#define CA_REVOKE_SUPERSEDED             4
#define CA_REVOKE_CESSATION_OF_OPERATION 5
#define CA_REVOKE_CERTIFICATE_HOLD       6

/* -- CRLStatus (4 constructors, tags 0-3) --------------------------------- */
#define CA_CRL_CURRENT 0
#define CA_CRL_EXPIRED 1
#define CA_CRL_PENDING 2
#define CA_CRL_ERROR   3

/* -- OCSPStatus (4 constructors, tags 0-3) -------------------------------- */
#define CA_OCSP_GOOD        0
#define CA_OCSP_REVOKED     1
#define CA_OCSP_UNKNOWN     2
#define CA_OCSP_UNAVAILABLE 3

/* -- Extension (6 constructors, tags 0-5) --------------------------------- */
#define CA_EXT_BASIC_CONSTRAINTS        0
#define CA_EXT_KEY_USAGE                1
#define CA_EXT_EXT_KEY_USAGE            2
#define CA_EXT_SUBJECT_ALT_NAME         3
#define CA_EXT_AUTHORITY_INFO_ACCESS    4
#define CA_EXT_CRL_DISTRIBUTION_POINTS  5

/* -- KeyUsageBit (9 bits, as defined by RFC 5280 Section 4.2.1.3) --------- */
#define CA_KU_DIGITAL_SIGNATURE 0
#define CA_KU_NON_REPUDIATION   1
#define CA_KU_KEY_ENCIPHERMENT  2
#define CA_KU_DATA_ENCIPHERMENT 3
#define CA_KU_KEY_AGREEMENT     4
#define CA_KU_KEY_CERT_SIGN     5
#define CA_KU_CRL_SIGN          6
#define CA_KU_ENCIPHER_ONLY     7
#define CA_KU_DECIPHER_ONLY     8

/* -- Sentinel value for invalid queries ----------------------------------- */
#define CA_INVALID 255

/* -- ABI ------------------------------------------------------------------ */
uint32_t ca_abi_version(void);

/* -- Context lifecycle ---------------------------------------------------- */
int      ca_create(void);
void     ca_destroy(int slot);

/* -- Certificate issuance ------------------------------------------------- */
int      ca_issue_cert(int slot, uint8_t cert_type, uint8_t key_algo,
                       uint8_t sig_algo);

/* -- Certificate state transitions ---------------------------------------- */
uint8_t  ca_sign_cert(int slot, int cert_id);
uint8_t  ca_revoke_cert(int slot, int cert_id, uint8_t reason);
uint8_t  ca_suspend_cert(int slot, int cert_id);
uint8_t  ca_reinstate_cert(int slot, int cert_id);
uint8_t  ca_expire_cert(int slot, int cert_id);
int      ca_renew_cert(int slot, int cert_id);

/* -- Certificate queries -------------------------------------------------- */
uint8_t  ca_cert_state(int slot, int cert_id);
uint8_t  ca_cert_type(int slot, int cert_id);
uint8_t  ca_cert_key_algo(int slot, int cert_id);
uint8_t  ca_cert_sig_algo(int slot, int cert_id);
int      ca_cert_count(int slot);

/* -- Chain and hierarchy -------------------------------------------------- */
uint8_t  ca_validate_chain(int slot, int cert_id);
uint8_t  ca_set_issuer(int slot, int cert_id, int issuer_id);
int      ca_cert_issuer(int slot, int cert_id);

/* -- Stateless queries ---------------------------------------------------- */
uint8_t  ca_can_issue(uint8_t issuer_tag, uint8_t child_tag);
uint8_t  ca_can_transition(uint8_t from_tag, uint8_t to_tag);

/* -- CRL management ------------------------------------------------------- */
uint8_t  ca_crl_status(int slot);
uint8_t  ca_update_crl(int slot);

/* -- OCSP responder ------------------------------------------------------- */
uint8_t  ca_ocsp_status(int slot);
uint8_t  ca_ocsp_query(int slot, int cert_id);

/* -- Validity period ------------------------------------------------------ */
uint8_t  ca_set_validity(int slot, int cert_id,
                         uint64_t not_before, uint64_t not_after);
uint64_t ca_cert_not_before(int slot, int cert_id);
uint64_t ca_cert_not_after(int slot, int cert_id);

/* -- Serial numbers ------------------------------------------------------- */
uint64_t ca_cert_serial(int slot, int cert_id);
uint64_t ca_next_serial(int slot);

/* -- Path length constraints ---------------------------------------------- */
uint8_t  ca_set_path_length(int slot, int cert_id, int32_t max_path_len);
int32_t  ca_cert_path_length(int slot, int cert_id);
uint8_t  ca_validate_path_length(int slot, int cert_id);

/* -- Key usage ------------------------------------------------------------ */
uint8_t  ca_set_key_usage(int slot, int cert_id, uint16_t key_usage_bits);
uint16_t ca_cert_key_usage(int slot, int cert_id);
uint8_t  ca_validate_key_usage(int slot, int cert_id);

#ifdef __cplusplus
}
#endif

#endif /* PROVEN_CA_H */
