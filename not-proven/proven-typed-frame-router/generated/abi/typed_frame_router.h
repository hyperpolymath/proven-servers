// SPDX-License-Identifier: MPL-2.0
// Copyright (c) Jonathan D.A. Jewell <j.d.a.jewell@open.ac.uk>
/* SPDX-License-Identifier: MPL-2.0
 * Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath)
 *
 * typed_frame_router.h — C ABI header for the Typed Frame Router.
 *
 * General-purpose frame-level proxy/router with formal proofs.
 * Supports any frame family translation (IPv4, IPv6, FibreChannel,
 * iSCSI, InfiniBand, BLE, Raw).
 *
 * AUTO-GENERATED from Idris2 ABI definitions.
 * DO NOT EDIT — regenerate via `just generate-headers`.
 *
 * Tag values match TypedFrameRouterABI.Layout exactly.
 */

#ifndef TYPED_FRAME_ROUTER_H
#define TYPED_FRAME_ROUTER_H

#include <stdint.h>

#ifdef __cplusplus
extern "C" {
#endif

/* -----------------------------------------------------------------------
 * Enumerations (match Layout.idr tag assignments)
 * ----------------------------------------------------------------------- */

typedef enum {
    TFR_FRAME_IPV4          = 0,
    TFR_FRAME_IPV6          = 1,
    TFR_FRAME_FIBRE_CHANNEL = 2,
    TFR_FRAME_ISCSI         = 3,
    TFR_FRAME_INFINIBAND    = 4,
    TFR_FRAME_BLE           = 5,
    TFR_FRAME_RAW           = 6
} tfr_frame_family_t;

typedef enum {
    TFR_SPLICE_KERNEL   = 0,  /* Linux splice(2): zero-copy */
    TFR_SPLICE_USERSPACE = 1  /* Fallback: 4KB buffer */
} tfr_splice_mode_t;

typedef enum {
    TFR_STATE_IDLE      = 0,
    TFR_STATE_ACCEPTED  = 1,
    TFR_STATE_CONNECTED = 2,
    TFR_STATE_SPLICING  = 3,
    TFR_STATE_DRAINING  = 4,
    TFR_STATE_CLOSED    = 5
} tfr_router_state_t;

/* -----------------------------------------------------------------------
 * Constants
 * ----------------------------------------------------------------------- */

#define TFR_MAX_BUFFER_SIZE 4096

/* -----------------------------------------------------------------------
 * Opaque handle types
 * ----------------------------------------------------------------------- */

typedef int64_t tfr_router_handle_t;

/* -----------------------------------------------------------------------
 * FFI function declarations (match Foreign.idr)
 * ----------------------------------------------------------------------- */

/**
 * Start the frame router.
 *
 * @param source_addr  Source bind address (e.g. "127.0.0.1" for IPv4)
 * @param source_port  Source listen port
 * @param target_addr  Target address (e.g. "::1" for IPv6)
 * @param target_port  Target port
 * @return             Positive handle on success, negative error code on failure
 */
tfr_router_handle_t typed_frame_router_start(
    const char *source_addr,
    uint16_t    source_port,
    const char *target_addr,
    uint16_t    target_port
);

/**
 * Stop the frame router and release all resources.
 *
 * @param handle  The router handle
 */
void typed_frame_router_stop(tfr_router_handle_t handle);

/**
 * Get current router statistics as a JSON string.
 *
 * @param handle  The router handle
 * @return        JSON-encoded stats (static lifetime, do not free)
 */
const char *typed_frame_router_stats(tfr_router_handle_t handle);

/**
 * Check if kernel splice(2) is available on this platform.
 *
 * @return  1 if splice is available (Linux), 0 if fallback
 */
uint8_t typed_frame_router_has_splice(void);

/**
 * Get the number of active routed connections.
 *
 * @param handle  The router handle
 * @return        Number of currently active connections
 */
uint32_t typed_frame_router_active_count(tfr_router_handle_t handle);

#ifdef __cplusplus
}
#endif

#endif /* TYPED_FRAME_ROUTER_H */
