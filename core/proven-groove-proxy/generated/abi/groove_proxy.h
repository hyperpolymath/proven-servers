/* SPDX-License-Identifier: PMPL-1.0-or-later
 * Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath)
 *
 * groove_proxy.h — C ABI header for the Groove frame-level proxy.
 *
 * AUTO-GENERATED from Idris2 ABI definitions.
 * DO NOT EDIT — regenerate via `just generate-headers`.
 *
 * Tag values match GrooveProxyABI.Layout exactly.
 */

#ifndef GROOVE_PROXY_H
#define GROOVE_PROXY_H

#include <stdint.h>

#ifdef __cplusplus
extern "C" {
#endif

/* -----------------------------------------------------------------------
 * Enumerations (match Layout.idr tag assignments)
 * ----------------------------------------------------------------------- */

typedef enum {
    GROOVE_ADDR_IPV4 = 0,
    GROOVE_ADDR_IPV6 = 1
} groove_addr_family_t;

typedef enum {
    GROOVE_SPLICE_KERNEL   = 0,  /* Linux splice(2): zero-copy */
    GROOVE_SPLICE_USERSPACE = 1  /* Fallback: 4KB buffer */
} groove_splice_mode_t;

typedef enum {
    GROOVE_STATE_IDLE      = 0,
    GROOVE_STATE_ACCEPTED  = 1,
    GROOVE_STATE_CONNECTED = 2,
    GROOVE_STATE_SPLICING  = 3,
    GROOVE_STATE_DRAINING  = 4,
    GROOVE_STATE_CLOSED    = 5
} groove_proxy_state_t;

/* -----------------------------------------------------------------------
 * Constants
 * ----------------------------------------------------------------------- */

#define GROOVE_PROXY_MAX_BUFFER_SIZE 4096

/* -----------------------------------------------------------------------
 * Opaque handle types
 * ----------------------------------------------------------------------- */

typedef int64_t groove_proxy_handle_t;

/* -----------------------------------------------------------------------
 * FFI function declarations (match Foreign.idr)
 * ----------------------------------------------------------------------- */

/**
 * Start the proxy server.
 *
 * @param ipv4_addr  IPv4 bind address (e.g. "127.0.0.1")
 * @param ipv4_port  IPv4 listen port
 * @param ipv6_addr  IPv6 target address (e.g. "::1")
 * @param ipv6_port  IPv6 target port
 * @return           Positive handle on success, negative error code on failure
 */
groove_proxy_handle_t groove_proxy_start(
    const char *ipv4_addr,
    uint16_t    ipv4_port,
    const char *ipv6_addr,
    uint16_t    ipv6_port
);

/**
 * Stop the proxy server and release all resources.
 *
 * @param handle  The server handle from groove_proxy_start
 */
void groove_proxy_stop(groove_proxy_handle_t handle);

/**
 * Get current proxy statistics as a JSON string.
 *
 * @param handle  The server handle
 * @return        JSON-encoded stats (static lifetime, do not free)
 */
const char *groove_proxy_stats(groove_proxy_handle_t handle);

/**
 * Check if kernel splice(2) is available on this platform.
 *
 * @return  1 if splice is available (Linux), 0 if fallback
 */
uint8_t groove_proxy_has_splice(void);

/**
 * Get the number of active proxied connections.
 *
 * @param handle  The server handle
 * @return        Number of currently active connections
 */
uint32_t groove_proxy_active_count(groove_proxy_handle_t handle);

#ifdef __cplusplus
}
#endif

#endif /* GROOVE_PROXY_H */
