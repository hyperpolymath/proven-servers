/* SPDX-License-Identifier: PMPL-1.0-or-later
 * Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
 *
 * tls.h -- C-ABI header for proven-tls.
 * Generated from TLSABI.Layout.idr tag assignments.
 */

#ifndef PROVEN_TLS_H
#define PROVEN_TLS_H

#include <stdint.h>

#ifdef __cplusplus
extern "C" {
#endif

/* -- TLSVersion (2 constructors, tags 0-1) -------------------------------- */
#define TLS_VERSION_TLS12 0
#define TLS_VERSION_TLS13 1

/* -- CipherSuite (3 constructors, tags 0-2) ------------------------------- */
#define TLS_CIPHER_AES_128_GCM_SHA256       0
#define TLS_CIPHER_AES_256_GCM_SHA384       1
#define TLS_CIPHER_CHACHA20_POLY1305_SHA256 2

/* -- HandshakeState (8 constructors, tags 0-7) ---------------------------- */
#define TLS_HS_CLIENT_HELLO          0
#define TLS_HS_SERVER_HELLO          1
#define TLS_HS_ENCRYPTED_EXTENSIONS  2
#define TLS_HS_CERTIFICATE           3
#define TLS_HS_CERTIFICATE_VERIFY    4
#define TLS_HS_FINISHED              5
#define TLS_HS_ESTABLISHED           6
#define TLS_HS_CLOSED                7

/* -- CertValidation (9 constructors, tags 0-8) ---------------------------- */
#define TLS_CERT_VALID             0
#define TLS_CERT_EXPIRED           1
#define TLS_CERT_NOT_YET_VALID     2
#define TLS_CERT_REVOKED           3
#define TLS_CERT_SELF_SIGNED       4
#define TLS_CERT_UNKNOWN_CA        5
#define TLS_CERT_HOSTNAME_MISMATCH 6
#define TLS_CERT_WEAK_KEY          7
#define TLS_CERT_WEAK_SIGNATURE    8
#define TLS_CERT_NONE              255

/* -- AlertLevel (2 constructors, tags 0-1) -------------------------------- */
#define TLS_ALERT_WARNING 0
#define TLS_ALERT_FATAL   1

/* -- AlertDescription (25 constructors, tags 0-24) ------------------------ */
#define TLS_ALERT_CLOSE_NOTIFY             0
#define TLS_ALERT_UNEXPECTED_MESSAGE       1
#define TLS_ALERT_BAD_RECORD_MAC           2
#define TLS_ALERT_DECRYPTION_FAILED        3
#define TLS_ALERT_RECORD_OVERFLOW          4
#define TLS_ALERT_HANDSHAKE_FAILURE        5
#define TLS_ALERT_BAD_CERTIFICATE          6
#define TLS_ALERT_UNSUPPORTED_CERTIFICATE  7
#define TLS_ALERT_CERTIFICATE_REVOKED      8
#define TLS_ALERT_CERTIFICATE_EXPIRED      9
#define TLS_ALERT_CERTIFICATE_UNKNOWN      10
#define TLS_ALERT_ILLEGAL_PARAMETER        11
#define TLS_ALERT_UNKNOWN_CA               12
#define TLS_ALERT_ACCESS_DENIED            13
#define TLS_ALERT_DECODE_ERROR             14
#define TLS_ALERT_DECRYPT_ERROR            15
#define TLS_ALERT_PROTOCOL_VERSION         16
#define TLS_ALERT_INSUFFICIENT_SECURITY    17
#define TLS_ALERT_INTERNAL_ERROR           18
#define TLS_ALERT_INAPPROPRIATE_FALLBACK   19
#define TLS_ALERT_MISSING_EXTENSION        20
#define TLS_ALERT_UNSUPPORTED_EXTENSION    21
#define TLS_ALERT_UNRECOGNIZED_NAME        22
#define TLS_ALERT_CERTIFICATE_REQUIRED     23
#define TLS_ALERT_NO_APPLICATION_PROTOCOL  24
#define TLS_ALERT_NONE                     255

/* -- ABI ------------------------------------------------------------------ */
uint32_t tls_abi_version(void);

/* -- Lifecycle ------------------------------------------------------------ */
int      tls_create(uint8_t version, uint8_t cipher);
void     tls_destroy(int slot);

/* -- State queries -------------------------------------------------------- */
uint8_t  tls_state(int slot);
uint8_t  tls_version(int slot);
uint8_t  tls_cipher(int slot);
uint8_t  tls_can_send(int slot);
uint8_t  tls_last_alert(int slot);
uint8_t  tls_cert_status(int slot);

/* -- Transitions ---------------------------------------------------------- */
uint8_t tls_advance(int slot);
uint8_t tls_abort(int slot, uint8_t alert_tag);
uint8_t tls_key_update(int slot);
uint8_t tls_close(int slot);

/* -- Certificate validation ----------------------------------------------- */
uint8_t tls_validate_cert(int slot, uint8_t cert_result);

/* -- Stateless queries ---------------------------------------------------- */
uint8_t tls_can_transition(uint8_t from, uint8_t to);

#ifdef __cplusplus
}
#endif

#endif /* PROVEN_TLS_H */
