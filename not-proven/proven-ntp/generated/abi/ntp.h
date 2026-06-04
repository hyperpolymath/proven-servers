// SPDX-License-Identifier: MPL-2.0
// Copyright (c) Jonathan D.A. Jewell <j.d.a.jewell@open.ac.uk>
/* SPDX-License-Identifier: MPL-2.0
 * Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
 *
 * ntp.h -- C-ABI header for proven-ntp.
 *
 * Generated from NTPABI.Layout.idr tag assignments.
 * Tag values MUST match:
 *   - Idris2 ABI (src/NTPABI/Layout.idr)
 *   - Zig FFI   (ffi/zig/src/ntp.zig)
 *
 * NTP protocol definitions per RFC 5905.
 */

#ifndef PROVEN_NTP_H
#define PROVEN_NTP_H

#include <stdint.h>

#ifdef __cplusplus
extern "C" {
#endif

/* -- LeapIndicator (4 constructors, tags 0-3) ----------------------------- */
/* RFC 5905 Section 7.3: bits 7-6 of the first packet octet.               */
#define NTP_LEAP_NO_WARNING      0
#define NTP_LEAP_LAST_MINUTE_61  1
#define NTP_LEAP_LAST_MINUTE_59  2
#define NTP_LEAP_UNSYNCHRONISED  3

/* -- NTPMode (8 constructors, tags 0-7) ----------------------------------- */
/* RFC 5905 Section 3: bits 2-0 of the first packet octet.                 */
#define NTP_MODE_RESERVED          0
#define NTP_MODE_SYMMETRIC_ACTIVE  1
#define NTP_MODE_SYMMETRIC_PASSIVE 2
#define NTP_MODE_CLIENT            3
#define NTP_MODE_SERVER            4
#define NTP_MODE_BROADCAST         5
#define NTP_MODE_CONTROL_MESSAGE   6
#define NTP_MODE_PRIVATE           7

/* -- Stratum (tags 0-16) -------------------------------------------------- */
/* RFC 5905 Section 7.3: 0 = unspecified/KoD, 1 = primary, 2-15 secondary, */
/* 16 = unsynchronised, 17-255 reserved.                                    */
#define NTP_STRATUM_UNSPECIFIED  0
#define NTP_STRATUM_PRIMARY      1
/* 2-15: secondary reference (distance from primary) */
#define NTP_STRATUM_UNSYNCHRONISED 16

/* -- NTPVersion (tags 3-4) ------------------------------------------------ */
#define NTP_VERSION_3  3
#define NTP_VERSION_4  4

/* -- ExchangeState (4 constructors, tags 0-3) ----------------------------- */
/* NTP exchange lifecycle: Idle -> RequestReceived -> TimestampCalculated    */
/*   -> ResponseSent -> Idle                                                */
#define NTP_EXCHANGE_IDLE                  0
#define NTP_EXCHANGE_REQUEST_RECEIVED      1
#define NTP_EXCHANGE_TIMESTAMP_CALCULATED  2
#define NTP_EXCHANGE_RESPONSE_SENT         3

/* -- ClockDisciplineState (5 constructors, tags 0-4) ---------------------- */
/* RFC 5905 Section 12: clock discipline algorithm states.                  */
#define NTP_DISCIPLINE_UNSET  0
#define NTP_DISCIPLINE_SPIKE  1
#define NTP_DISCIPLINE_FREQ   2
#define NTP_DISCIPLINE_SYNC   3
#define NTP_DISCIPLINE_PANIC  4

/* -- KissCodeABI (4 constructors, tags 0-3) ------------------------------- */
/* RFC 5905 Section 7.4: Kiss-o'-Death codes in reference ID field.         */
#define NTP_KISS_DENY   0
#define NTP_KISS_RSTR   1
#define NTP_KISS_RATE   2
#define NTP_KISS_OTHER  3

/* -- NtpError (6 constructors, tags 0-5) ---------------------------------- */
/* Error codes returned by NTP FFI operations.                              */
#define NTP_ERR_OK              0
#define NTP_ERR_INVALID_SLOT    1
#define NTP_ERR_NOT_ACTIVE      2
#define NTP_ERR_INVALID_PACKET  3
#define NTP_ERR_KISS_OF_DEATH   4
#define NTP_ERR_STRATUM_TOO_HIGH 5

/* -- Sentinel values ------------------------------------------------------ */
#define NTP_NO_ERROR  255
#define NTP_NO_KISS   255
#define NTP_INVALID   255

/* -- Protocol constants --------------------------------------------------- */
#define NTP_PORT             123
#define NTP_PACKET_SIZE      48
#define NTP_EPOCH_OFFSET     2208988800UL  /* seconds from 1900-01-01 to 1970-01-01 */
#define NTP_MIN_POLL         4             /* log2 seconds (16s) */
#define NTP_MAX_POLL         17            /* log2 seconds (131072s / ~36h) */
#define NTP_MAX_STRATUM      15            /* maximum valid synchronised stratum */

/* -- ABI ------------------------------------------------------------------ */
uint32_t ntp_abi_version(void);

/* -- Lifecycle ------------------------------------------------------------ */
int      ntp_create(uint8_t version, uint8_t mode, uint8_t stratum);
void     ntp_destroy(int slot);

/* -- State queries -------------------------------------------------------- */
uint8_t  ntp_get_exchange_state(int slot);
uint8_t  ntp_get_discipline_state(int slot);
uint8_t  ntp_get_stratum(int slot);
uint8_t  ntp_get_mode(int slot);
uint8_t  ntp_get_last_error(int slot);
uint32_t ntp_get_exchange_count(int slot);
uint8_t  ntp_get_leap(int slot);

/* -- Exchange lifecycle transitions --------------------------------------- */
uint8_t ntp_receive_request(int slot,
                            uint32_t t1_secs, uint32_t t1_frac,
                            uint32_t t2_secs, uint32_t t2_frac);
uint8_t ntp_calculate(int slot, uint32_t t3_secs, uint32_t t3_frac);
uint8_t ntp_send_response(int slot);
uint8_t ntp_reset_exchange(int slot);

/* -- Timestamp getters ---------------------------------------------------- */
uint8_t ntp_get_offset(int slot, uint32_t *out_secs, uint32_t *out_frac);
uint8_t ntp_get_delay(int slot, uint32_t *out_secs, uint32_t *out_frac);

/* -- Leap indicator ------------------------------------------------------- */
uint8_t ntp_set_leap(int slot, uint8_t leap);

/* -- Kiss-o'-Death -------------------------------------------------------- */
uint8_t ntp_check_kiss(int slot);
uint8_t ntp_set_kiss(int slot, uint8_t kiss);

/* -- Clock discipline ----------------------------------------------------- */
uint8_t ntp_advance_discipline(int slot, uint8_t new_state);

/* -- Stratum management --------------------------------------------------- */
uint8_t ntp_set_stratum(int slot, uint8_t stratum);

/* -- Stateless transition checks ------------------------------------------ */
uint8_t ntp_can_exchange_transition(uint8_t from, uint8_t to);
uint8_t ntp_can_discipline_transition(uint8_t from, uint8_t to);

#ifdef __cplusplus
}
#endif

#endif /* PROVEN_NTP_H */
