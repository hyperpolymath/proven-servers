/* SPDX-License-Identifier: PMPL-1.0-or-later
 * Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
 *
 * dns.h -- C-ABI header for proven-dns.
 * Generated from DNSABI.Layout.idr tag assignments.
 */

#ifndef PROVEN_DNS_H
#define PROVEN_DNS_H

#include <stdint.h>

#ifdef __cplusplus
extern "C" {
#endif

/* -- RecordType (15 constructors, tags 0-14) ------------------------------ */
#define DNS_RT_A       0
#define DNS_RT_AAAA    1
#define DNS_RT_CNAME   2
#define DNS_RT_MX      3
#define DNS_RT_NS      4
#define DNS_RT_PTR     5
#define DNS_RT_SOA     6
#define DNS_RT_SRV     7
#define DNS_RT_TXT     8
#define DNS_RT_CAA     9
#define DNS_RT_DNSKEY  10
#define DNS_RT_DS      11
#define DNS_RT_RRSIG   12
#define DNS_RT_NSEC    13
#define DNS_RT_NSEC3   14

/* -- QueryClass (4 constructors, tags 0-3) -------------------------------- */
#define DNS_CLASS_IN   0
#define DNS_CLASS_CH   1
#define DNS_CLASS_HS   2
#define DNS_CLASS_ANY  3

/* -- Opcode (5 constructors, tags 0-4) ------------------------------------ */
#define DNS_OP_QUERY   0
#define DNS_OP_IQUERY  1
#define DNS_OP_STATUS  2
#define DNS_OP_NOTIFY  3
#define DNS_OP_UPDATE  4

/* -- ResponseCode (11 constructors, tags 0-10) ---------------------------- */
#define DNS_RCODE_NOERROR   0
#define DNS_RCODE_FORMERR   1
#define DNS_RCODE_SERVFAIL  2
#define DNS_RCODE_NXDOMAIN  3
#define DNS_RCODE_NOTIMP    4
#define DNS_RCODE_REFUSED   5
#define DNS_RCODE_YXDOMAIN  6
#define DNS_RCODE_YXRRSET   7
#define DNS_RCODE_NXRRSET   8
#define DNS_RCODE_NOTAUTH   9
#define DNS_RCODE_NOTZONE   10

/* -- DnsState (5 constructors, tags 0-4) ---------------------------------- */
#define DNS_STATE_IDLE               0
#define DNS_STATE_QUERY_RECEIVED     1
#define DNS_STATE_LOOKUP             2
#define DNS_STATE_RESPONSE_BUILDING  3
#define DNS_STATE_SENT               4

/* -- DnssecState (4 constructors, tags 0-3) ------------------------------- */
#define DNS_DNSSEC_DISABLED   0
#define DNS_DNSSEC_ENABLED    1
#define DNS_DNSSEC_KEY_LOADED 2
#define DNS_DNSSEC_VALIDATED  3

/* -- DnssecAlgorithm (5 constructors, tags 0-4) -------------------------- */
#define DNS_DNSSEC_ALG_RSA_SHA256        0
#define DNS_DNSSEC_ALG_RSA_SHA512        1
#define DNS_DNSSEC_ALG_ECDSA_P256_SHA256 2
#define DNS_DNSSEC_ALG_ECDSA_P384_SHA384 3
#define DNS_DNSSEC_ALG_ED25519           4

/* -- Sentinel values ------------------------------------------------------ */
#define DNS_INVALID 255

/* -- ABI ------------------------------------------------------------------ */
uint32_t dns_abi_version(void);

/* -- Lifecycle ------------------------------------------------------------ */
int      dns_create_context(void);
void     dns_destroy_context(int slot);

/* -- State queries -------------------------------------------------------- */
uint8_t  dns_state(int slot);
uint8_t  dns_dnssec_state(int slot);
uint8_t  dns_rcode(int slot);
uint16_t dns_answer_count(int slot);
uint16_t dns_authority_count(int slot);
uint16_t dns_additional_count(int slot);
uint8_t  dns_query_rtype(int slot);
uint8_t  dns_query_class(int slot);

/* -- Lifecycle transitions ------------------------------------------------ */
uint8_t dns_parse_query(int slot, const uint8_t *buf, uint16_t len);
uint8_t dns_begin_lookup(int slot);
uint8_t dns_begin_response(int slot);

/* -- Record addition ------------------------------------------------------ */
uint8_t dns_add_answer(int slot, uint8_t rtype, uint8_t rclass,
                       uint32_t ttl, const uint8_t *rdata, uint16_t rdlen);
uint8_t dns_add_authority(int slot, uint8_t rtype, uint8_t rclass,
                          uint32_t ttl, const uint8_t *rdata, uint16_t rdlen);
uint8_t dns_add_additional(int slot, uint8_t rtype, uint8_t rclass,
                           uint32_t ttl, const uint8_t *rdata, uint16_t rdlen);
uint8_t dns_set_rcode(int slot, uint8_t rcode);

/* -- Response building ---------------------------------------------------- */
uint8_t dns_build_response(int slot, uint8_t *out, uint16_t *out_len);

/* -- DNSSEC operations ---------------------------------------------------- */
uint8_t dns_enable_dnssec(int slot);
uint8_t dns_load_dnssec_key(int slot, uint8_t algo);
uint8_t dns_sign_response(int slot);
uint8_t dns_validate_dnssec(int slot);

/* -- Stateless transition checks ------------------------------------------ */
uint8_t dns_can_transition(uint8_t from, uint8_t to);
uint8_t dns_can_dnssec_transition(uint8_t from, uint8_t to);

#ifdef __cplusplus
}
#endif

#endif /* PROVEN_DNS_H */
