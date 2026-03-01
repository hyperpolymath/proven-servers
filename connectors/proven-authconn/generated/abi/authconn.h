/* SPDX-License-Identifier: PMPL-1.0-or-later */
/* Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk> */
/*
 * authconn.h — C ABI header for proven-authconn.
 *
 * AUTO-GENERATED from Idris2 ABI definitions.  DO NOT EDIT.
 *
 * Tag values MUST match:
 *   - Idris2:  src/AuthConnABI/Layout.idr
 *   - Zig:     ffi/zig/src/authconn.zig
 *
 * ABI version: 1
 */

#ifndef PROVEN_AUTHCONN_H
#define PROVEN_AUTHCONN_H

#include <stdint.h>

#ifdef __cplusplus
extern "C" {
#endif

/* -----------------------------------------------------------------------
 * AuthMethod — authentication mechanism (7 variants, tags 0-6)
 * ----------------------------------------------------------------------- */

typedef uint8_t authconn_method_t;

#define AUTHCONN_METHOD_PASSWORD_HASH  0
#define AUTHCONN_METHOD_CERTIFICATE    1
#define AUTHCONN_METHOD_TOKEN          2
#define AUTHCONN_METHOD_MFA            3
#define AUTHCONN_METHOD_KERBEROS       4
#define AUTHCONN_METHOD_SAML           5
#define AUTHCONN_METHOD_OIDC           6

/* -----------------------------------------------------------------------
 * AuthState — session lifecycle (6 variants, tags 0-5)
 * ----------------------------------------------------------------------- */

typedef uint8_t authconn_state_t;

#define AUTHCONN_STATE_UNAUTHENTICATED  0
#define AUTHCONN_STATE_CHALLENGING      1
#define AUTHCONN_STATE_AUTHENTICATED    2
#define AUTHCONN_STATE_EXPIRED          3
#define AUTHCONN_STATE_REVOKED          4
#define AUTHCONN_STATE_LOCKED           5

/* -----------------------------------------------------------------------
 * TokenState — token lifecycle (4 variants, tags 0-3)
 * ----------------------------------------------------------------------- */

typedef uint8_t authconn_token_state_t;

#define AUTHCONN_TOKEN_VALID       0
#define AUTHCONN_TOKEN_EXPIRED     1
#define AUTHCONN_TOKEN_REVOKED     2
#define AUTHCONN_TOKEN_REFRESHING  3

/* -----------------------------------------------------------------------
 * CredentialType — credential handling classification (4 variants, tags 0-3)
 * ----------------------------------------------------------------------- */

typedef uint8_t authconn_credential_t;

#define AUTHCONN_CRED_OPAQUE     0
#define AUTHCONN_CRED_HASHED     1
#define AUTHCONN_CRED_ENCRYPTED  2
#define AUTHCONN_CRED_DELEGATED  3

/* -----------------------------------------------------------------------
 * AuthError — error categories (7 variants, tags 1-7; 0 = no error)
 * ----------------------------------------------------------------------- */

typedef uint8_t authconn_error_t;

#define AUTHCONN_ERR_NONE                  0
#define AUTHCONN_ERR_INVALID_CREDENTIALS   1
#define AUTHCONN_ERR_ACCOUNT_LOCKED        2
#define AUTHCONN_ERR_TOKEN_EXPIRED         3
#define AUTHCONN_ERR_MFA_REQUIRED          4
#define AUTHCONN_ERR_PROVIDER_UNAVAILABLE  5
#define AUTHCONN_ERR_INSUFFICIENT_SCOPE    6
#define AUTHCONN_ERR_SESSION_EXPIRED       7

/* -----------------------------------------------------------------------
 * Opaque handle types
 * ----------------------------------------------------------------------- */

typedef struct authconn_session  authconn_session_t;
typedef struct authconn_token    authconn_token_t;

/* -----------------------------------------------------------------------
 * Constants (must match Idris2 AuthConn module)
 * ----------------------------------------------------------------------- */

#define AUTHCONN_MAX_TOKEN_LIFETIME   3600   /* seconds (1 hour) */
#define AUTHCONN_MAX_REFRESH_LIFETIME 86400  /* seconds (24 hours) */
#define AUTHCONN_MAX_LOGIN_ATTEMPTS   5
#define AUTHCONN_LOCKOUT_DURATION     900    /* seconds (15 minutes) */

/* -----------------------------------------------------------------------
 * Function declarations
 * ----------------------------------------------------------------------- */

/* ABI version check — must return 1. */
uint32_t authconn_abi_version(void);

/* Session lifecycle */
authconn_session_t *authconn_create_session(authconn_method_t method, authconn_error_t *err);
void authconn_destroy_session(authconn_session_t *h);
authconn_state_t authconn_session_state(const authconn_session_t *h);

/* Authentication operations */
authconn_error_t authconn_authenticate(authconn_session_t *h,
                                       const void *cred, uint32_t cred_len,
                                       authconn_credential_t cred_type);
authconn_error_t authconn_challenge_respond(authconn_session_t *h,
                                            const void *response, uint32_t resp_len);
authconn_error_t authconn_revoke(authconn_session_t *h);
authconn_error_t authconn_reset(authconn_session_t *h);

/* Token lifecycle */
authconn_token_t *authconn_issue_token(authconn_session_t *h, authconn_error_t *err);
authconn_token_state_t authconn_token_state(const authconn_token_t *t);
authconn_token_t *authconn_refresh_token(authconn_token_t *t, authconn_error_t *err);
void authconn_revoke_token(authconn_token_t *t);

#ifdef __cplusplus
}
#endif

#endif /* PROVEN_AUTHCONN_H */
