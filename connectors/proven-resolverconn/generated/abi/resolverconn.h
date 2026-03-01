/* SPDX-License-Identifier: PMPL-1.0-or-later */
/* Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk> */
/*
 * resolverconn.h — C ABI header for proven-resolverconn.
 * AUTO-GENERATED from Idris2 ABI definitions.  DO NOT EDIT.
 * ABI version: 1
 */

#ifndef PROVEN_RESOLVERCONN_H
#define PROVEN_RESOLVERCONN_H

#include <stdint.h>

#ifdef __cplusplus
extern "C" {
#endif

/* RecordType — DNS RR types (13 variants, tags 0-12) */
typedef uint8_t resolverconn_rtype_t;
#define RESOLVERCONN_RTYPE_A      0
#define RESOLVERCONN_RTYPE_AAAA   1
#define RESOLVERCONN_RTYPE_CNAME  2
#define RESOLVERCONN_RTYPE_MX     3
#define RESOLVERCONN_RTYPE_TXT    4
#define RESOLVERCONN_RTYPE_SRV    5
#define RESOLVERCONN_RTYPE_NS     6
#define RESOLVERCONN_RTYPE_SOA    7
#define RESOLVERCONN_RTYPE_PTR    8
#define RESOLVERCONN_RTYPE_CAA    9
#define RESOLVERCONN_RTYPE_TLSA   10
#define RESOLVERCONN_RTYPE_SVCB   11
#define RESOLVERCONN_RTYPE_HTTPS  12

/* ResolverState (4 variants, tags 0-3) */
typedef uint8_t resolverconn_state_t;
#define RESOLVERCONN_STATE_READY     0
#define RESOLVERCONN_STATE_QUERYING  1
#define RESOLVERCONN_STATE_CACHED    2
#define RESOLVERCONN_STATE_FAILED    3

/* DNSSECStatus (4 variants, tags 0-3) */
typedef uint8_t resolverconn_dnssec_t;
#define RESOLVERCONN_DNSSEC_SECURE         0
#define RESOLVERCONN_DNSSEC_INSECURE       1
#define RESOLVERCONN_DNSSEC_BOGUS          2
#define RESOLVERCONN_DNSSEC_INDETERMINATE  3

/* ResolverError (7 variants, tags 1-7; 0 = no error) */
typedef uint8_t resolverconn_error_t;
#define RESOLVERCONN_ERR_NONE                     0
#define RESOLVERCONN_ERR_NXDOMAIN                 1
#define RESOLVERCONN_ERR_SERVER_FAILURE            2
#define RESOLVERCONN_ERR_REFUSED                   3
#define RESOLVERCONN_ERR_TIMEOUT                   4
#define RESOLVERCONN_ERR_DNSSEC_VALIDATION_FAILED  5
#define RESOLVERCONN_ERR_NETWORK_UNREACHABLE       6
#define RESOLVERCONN_ERR_TRUNCATED_RESPONSE        7

/* CachePolicy (4 variants, tags 0-3) */
typedef uint8_t resolverconn_cache_policy_t;
#define RESOLVERCONN_CACHE_USE      0
#define RESOLVERCONN_CACHE_BYPASS   1
#define RESOLVERCONN_CACHE_ONLY     2
#define RESOLVERCONN_CACHE_REFRESH  3

/* Opaque handle type */
typedef struct resolverconn_handle  resolverconn_handle_t;

/* Constants */
#define RESOLVERCONN_DEFAULT_TIMEOUT   5      /* seconds */
#define RESOLVERCONN_MAX_RETRIES       3
#define RESOLVERCONN_MAX_CACHE_ENTRIES 10000
#define RESOLVERCONN_MIN_TTL           60     /* seconds */

/* Function declarations */
uint32_t resolverconn_abi_version(void);
resolverconn_handle_t *resolverconn_create(const char *upstream, uint16_t port,
                                           resolverconn_error_t *err);
void resolverconn_destroy(resolverconn_handle_t *h);
resolverconn_state_t resolverconn_state(const resolverconn_handle_t *h);
resolverconn_error_t resolverconn_resolve(resolverconn_handle_t *h,
                                          const char *name, uint32_t name_len,
                                          resolverconn_rtype_t rtype,
                                          resolverconn_cache_policy_t policy,
                                          void *buf, uint32_t buf_cap,
                                          uint32_t *buf_len,
                                          resolverconn_dnssec_t *dnssec);
resolverconn_error_t resolverconn_reset(resolverconn_handle_t *h);
resolverconn_error_t resolverconn_cache_flush(resolverconn_handle_t *h);

#ifdef __cplusplus
}
#endif

#endif /* PROVEN_RESOLVERCONN_H */
