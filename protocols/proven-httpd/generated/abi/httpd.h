/* SPDX-License-Identifier: PMPL-1.0-or-later
 * Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
 *
 * httpd.h -- C-ABI header for proven-httpd.
 * Generated from HTTPABI.Layout.idr tag assignments.
 */

#ifndef PROVEN_HTTPD_H
#define PROVEN_HTTPD_H

#include <stdint.h>

#ifdef __cplusplus
extern "C" {
#endif

/* -- HttpMethod (9 constructors, tags 0-8) -------------------------------- */
#define HTTP_METHOD_GET     0
#define HTTP_METHOD_POST    1
#define HTTP_METHOD_PUT     2
#define HTTP_METHOD_DELETE  3
#define HTTP_METHOD_PATCH   4
#define HTTP_METHOD_HEAD    5
#define HTTP_METHOD_OPTIONS 6
#define HTTP_METHOD_TRACE   7
#define HTTP_METHOD_CONNECT 8

/* -- HttpVersion (4 constructors, tags 0-3) ------------------------------- */
#define HTTP_VERSION_10  0
#define HTTP_VERSION_11  1
#define HTTP_VERSION_20  2
#define HTTP_VERSION_30  3

/* -- StatusCategory (5 constructors, tags 0-4) ---------------------------- */
#define HTTP_STATUS_CAT_INFORMATIONAL 0
#define HTTP_STATUS_CAT_SUCCESS       1
#define HTTP_STATUS_CAT_REDIRECT      2
#define HTTP_STATUS_CAT_CLIENT_ERROR  3
#define HTTP_STATUS_CAT_SERVER_ERROR  4

/* -- AbiStatusCode (29 constructors, tags 0-28) --------------------------- */
/* 1xx Informational (tags 0-1) */
#define HTTP_SC_CONTINUE            0
#define HTTP_SC_SWITCHING_PROTOCOLS 1
/* 2xx Success (tags 2-5) */
#define HTTP_SC_OK                  2
#define HTTP_SC_CREATED             3
#define HTTP_SC_ACCEPTED            4
#define HTTP_SC_NO_CONTENT          5
/* 3xx Redirection (tags 6-10) */
#define HTTP_SC_MOVED_PERMANENTLY   6
#define HTTP_SC_FOUND               7
#define HTTP_SC_NOT_MODIFIED        8
#define HTTP_SC_TEMPORARY_REDIRECT  9
#define HTTP_SC_PERMANENT_REDIRECT  10
/* 4xx Client Error (tags 11-23) */
#define HTTP_SC_BAD_REQUEST         11
#define HTTP_SC_UNAUTHORIZED        12
#define HTTP_SC_FORBIDDEN           13
#define HTTP_SC_NOT_FOUND           14
#define HTTP_SC_METHOD_NOT_ALLOWED  15
#define HTTP_SC_REQUEST_TIMEOUT     16
#define HTTP_SC_CONFLICT            17
#define HTTP_SC_GONE                18
#define HTTP_SC_LENGTH_REQUIRED     19
#define HTTP_SC_PAYLOAD_TOO_LARGE   20
#define HTTP_SC_URI_TOO_LONG        21
#define HTTP_SC_UNSUPPORTED_MEDIA   22
#define HTTP_SC_TOO_MANY_REQUESTS   23
/* 5xx Server Error (tags 24-28) */
#define HTTP_SC_INTERNAL_ERROR      24
#define HTTP_SC_NOT_IMPLEMENTED     25
#define HTTP_SC_BAD_GATEWAY         26
#define HTTP_SC_SERVICE_UNAVAILABLE 27
#define HTTP_SC_GATEWAY_TIMEOUT     28

/* -- ContentType (8 constructors, tags 0-7) ------------------------------- */
#define HTTP_CT_TEXT_PLAIN       0
#define HTTP_CT_TEXT_HTML        1
#define HTTP_CT_APPLICATION_JSON 2
#define HTTP_CT_APPLICATION_XML  3
#define HTTP_CT_APPLICATION_FORM 4
#define HTTP_CT_MULTIPART_FORM   5
#define HTTP_CT_OCTET_STREAM     6
#define HTTP_CT_TEXT_CSS         7

/* -- HeaderType (10 constructors, tags 0-9) ------------------------------- */
#define HTTP_HDR_CONTENT_TYPE   0
#define HTTP_HDR_CONTENT_LENGTH 1
#define HTTP_HDR_HOST           2
#define HTTP_HDR_CONNECTION     3
#define HTTP_HDR_ACCEPT         4
#define HTTP_HDR_USER_AGENT     5
#define HTTP_HDR_SERVER         6
#define HTTP_HDR_LOCATION       7
#define HTTP_HDR_CACHE_CONTROL  8
#define HTTP_HDR_CUSTOM         9

/* -- RequestPhase (7 constructors, tags 0-6) ------------------------------ */
#define HTTP_PHASE_IDLE           0
#define HTTP_PHASE_RECEIVING      1
#define HTTP_PHASE_HEADERS_PARSED 2
#define HTTP_PHASE_BODY_RECEIVING 3
#define HTTP_PHASE_COMPLETE       4
#define HTTP_PHASE_RESPONDING     5
#define HTTP_PHASE_SENT           6

/* -- Sentinel values ------------------------------------------------------ */
#define HTTP_INVALID 255

/* -- ABI ------------------------------------------------------------------ */
uint32_t http_abi_version(void);

/* -- Lifecycle ------------------------------------------------------------ */
int      http_create_context(void);
void     http_destroy_context(int slot);

/* -- Request parsing ------------------------------------------------------ */
uint8_t  http_parse_request(int slot, const uint8_t *data, uint32_t len);

/* -- Request queries ------------------------------------------------------ */
uint8_t  http_get_method(int slot);
uint32_t http_get_path(int slot, uint8_t *buf, uint32_t len);
uint32_t http_get_header(int slot, const uint8_t *key, uint32_t klen,
                         uint8_t *buf, uint32_t blen);
uint32_t http_get_body(int slot, uint8_t *buf, uint32_t len);

/* -- Response construction ------------------------------------------------ */
uint8_t  http_set_status(int slot, uint8_t status_tag);
uint8_t  http_set_header(int slot, const uint8_t *key, uint32_t klen,
                         const uint8_t *val, uint32_t vlen);
uint8_t  http_set_body(int slot, const uint8_t *data, uint32_t len);
uint8_t  http_send_response(int slot);

/* -- Keep-alive and phase queries ----------------------------------------- */
uint8_t  http_keep_alive_check(int slot);
uint8_t  http_get_phase(int slot);
uint8_t  http_get_version(int slot);
uint8_t  http_reset_context(int slot);

/* -- Stateless transition checks ------------------------------------------ */
uint8_t  http_can_transition(uint8_t from, uint8_t to);

#ifdef __cplusplus
}
#endif

#endif /* PROVEN_HTTPD_H */
