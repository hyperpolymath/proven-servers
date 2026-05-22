// SPDX-License-Identifier: MPL-2.0
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>

// DNS protocol bindings for proven-servers.
//
// Wraps the C-ABI functions from protocols/proven-dns/ffi/zig/src/dns.zig.
// Lifecycle: create -> parse_query -> begin_lookup -> begin_response ->
// add records -> set_rcode -> build_response -> destroy.
package proven

/*
#cgo LDFLAGS: -lproven_dns
#include <stdint.h>

extern uint32_t dns_abi_version();
extern int dns_create_context();
extern void dns_destroy_context(int slot);
extern uint8_t dns_state(int slot);
extern uint8_t dns_dnssec_state(int slot);
extern uint8_t dns_rcode(int slot);
extern uint16_t dns_answer_count(int slot);
extern uint16_t dns_authority_count(int slot);
extern uint16_t dns_additional_count(int slot);
extern uint8_t dns_query_rtype(int slot);
extern uint8_t dns_query_class(int slot);
extern uint8_t dns_parse_query(int slot, const uint8_t *buf, uint16_t len);
extern uint8_t dns_begin_lookup(int slot);
extern uint8_t dns_begin_response(int slot);
extern uint8_t dns_add_answer(int slot, uint8_t rtype, uint8_t rclass, uint32_t ttl, const uint8_t *rdata, uint16_t rdlen);
extern uint8_t dns_add_authority(int slot, uint8_t rtype, uint8_t rclass, uint32_t ttl, const uint8_t *rdata, uint16_t rdlen);
extern uint8_t dns_add_additional(int slot, uint8_t rtype, uint8_t rclass, uint32_t ttl, const uint8_t *rdata, uint16_t rdlen);
extern uint8_t dns_set_rcode(int slot, uint8_t rcode_tag);
extern uint8_t dns_build_response(int slot, uint8_t *out, uint16_t *out_len);
extern uint8_t dns_enable_dnssec(int slot);
extern uint8_t dns_load_dnssec_key(int slot, uint8_t algo);
extern uint8_t dns_sign_response(int slot);
extern uint8_t dns_validate_dnssec(int slot);
extern uint8_t dns_can_transition(uint8_t from, uint8_t to);
extern uint8_t dns_can_dnssec_transition(uint8_t from, uint8_t to);
*/
import "C"
import "unsafe"

// DnsState represents the DNS query lifecycle state.
// Tags match DnsState in dns.zig.
type DnsState uint8

const (
	DnsIdle             DnsState = iota // Waiting for a query
	DnsQueryReceived                    // Query received and parsed
	DnsLookup                           // Performing DNS lookup
	DnsResponseBuilding                 // Building response message
	DnsSent                             // Response sent (terminal)
)

// DnssecState represents the DNSSEC sub-state machine.
type DnssecState uint8

const (
	DnssecDisabled  DnssecState = iota // DNSSEC disabled
	DnssecEnabled                      // DNSSEC enabled, no key loaded
	DnssecKeyLoaded                    // DNSSEC key loaded
	DnssecValidated                    // Response validated / signed
)

// DnssecAlgorithm represents a DNSSEC signing algorithm.
type DnssecAlgorithm uint8

const (
	DnssecRsaSha256       DnssecAlgorithm = iota // RSA/SHA-256
	DnssecRsaSha512                               // RSA/SHA-512
	DnssecEcdsaP256Sha256                         // ECDSA P-256/SHA-256
	DnssecEcdsaP384Sha384                         // ECDSA P-384/SHA-384
	DnssecEd25519                                  // Ed25519
)

// DnsContext wraps a slot in the proven-dns context pool.
type DnsContext struct {
	slot C.int
}

// DnsABIVersion returns the ABI version of the linked DNS library.
func DnsABIVersion() uint32 {
	return uint32(C.dns_abi_version())
}

// DnsCreateContext allocates a new DNS context in the Idle state.
func DnsCreateContext() (*DnsContext, error) {
	slot := C.dns_create_context()
	s, err := slotError(slot)
	if err != nil {
		return nil, err
	}
	return &DnsContext{slot: C.int(s)}, nil
}

// Close releases the DNS context slot back to the pool.
func (ctx *DnsContext) Close() {
	C.dns_destroy_context(ctx.slot)
}

// State returns the current DNS lifecycle state.
func (ctx *DnsContext) State() (DnsState, bool) {
	tag := C.dns_state(ctx.slot)
	if tag > 4 {
		return 0, false
	}
	return DnsState(tag), true
}

// DnssecState returns the current DNSSEC state.
func (ctx *DnsContext) DnssecState() (DnssecState, bool) {
	tag := C.dns_dnssec_state(ctx.slot)
	if tag > 3 {
		return 0, false
	}
	return DnssecState(tag), true
}

// Rcode returns the response code tag.
func (ctx *DnsContext) Rcode() uint8 {
	return uint8(C.dns_rcode(ctx.slot))
}

// AnswerCount returns the number of answer records.
func (ctx *DnsContext) AnswerCount() uint16 {
	return uint16(C.dns_answer_count(ctx.slot))
}

// AuthorityCount returns the number of authority records.
func (ctx *DnsContext) AuthorityCount() uint16 {
	return uint16(C.dns_authority_count(ctx.slot))
}

// AdditionalCount returns the number of additional records.
func (ctx *DnsContext) AdditionalCount() uint16 {
	return uint16(C.dns_additional_count(ctx.slot))
}

// QueryRtype returns the query record type (255 = unset).
func (ctx *DnsContext) QueryRtype() uint8 {
	return uint8(C.dns_query_rtype(ctx.slot))
}

// QueryClass returns the query class (255 = unset).
func (ctx *DnsContext) QueryClass() uint8 {
	return uint8(C.dns_query_class(ctx.slot))
}

// ParseQuery parses a DNS query from raw bytes. Transitions Idle -> QueryReceived.
func (ctx *DnsContext) ParseQuery(data []byte) error {
	if len(data) == 0 {
		return &ProvenError{Code: 0, Kind: ErrInvalidParameter}
	}
	return statusError(C.dns_parse_query(ctx.slot, (*C.uint8_t)(unsafe.Pointer(&data[0])), C.uint16_t(len(data))))
}

// BeginLookup transitions QueryReceived -> Lookup.
func (ctx *DnsContext) BeginLookup() error {
	return statusError(C.dns_begin_lookup(ctx.slot))
}

// BeginResponse transitions Lookup -> ResponseBuilding.
func (ctx *DnsContext) BeginResponse() error {
	return statusError(C.dns_begin_response(ctx.slot))
}

// AddAnswer adds a resource record to the answer section.
func (ctx *DnsContext) AddAnswer(rtype, rclass uint8, ttl uint32, rdata []byte) error {
	var ptr *C.uint8_t
	if len(rdata) > 0 {
		ptr = (*C.uint8_t)(unsafe.Pointer(&rdata[0]))
	}
	return statusError(C.dns_add_answer(ctx.slot, C.uint8_t(rtype), C.uint8_t(rclass), C.uint32_t(ttl), ptr, C.uint16_t(len(rdata))))
}

// AddAuthority adds a resource record to the authority section.
func (ctx *DnsContext) AddAuthority(rtype, rclass uint8, ttl uint32, rdata []byte) error {
	var ptr *C.uint8_t
	if len(rdata) > 0 {
		ptr = (*C.uint8_t)(unsafe.Pointer(&rdata[0]))
	}
	return statusError(C.dns_add_authority(ctx.slot, C.uint8_t(rtype), C.uint8_t(rclass), C.uint32_t(ttl), ptr, C.uint16_t(len(rdata))))
}

// AddAdditional adds a resource record to the additional section.
func (ctx *DnsContext) AddAdditional(rtype, rclass uint8, ttl uint32, rdata []byte) error {
	var ptr *C.uint8_t
	if len(rdata) > 0 {
		ptr = (*C.uint8_t)(unsafe.Pointer(&rdata[0]))
	}
	return statusError(C.dns_add_additional(ctx.slot, C.uint8_t(rtype), C.uint8_t(rclass), C.uint32_t(ttl), ptr, C.uint16_t(len(rdata))))
}

// SetRcode sets the response code. Only valid in ResponseBuilding state.
func (ctx *DnsContext) SetRcode(rcodeTag uint8) error {
	return statusError(C.dns_set_rcode(ctx.slot, C.uint8_t(rcodeTag)))
}

// BuildResponse builds the DNS response message. Transitions ResponseBuilding -> Sent.
// The output buffer must be at least 512 bytes. Returns the number of bytes written.
func (ctx *DnsContext) BuildResponse(out []byte) (uint16, error) {
	if len(out) < 512 {
		return 0, &ProvenError{Code: 0, Kind: ErrCapacityExceeded}
	}
	var outLen C.uint16_t
	err := statusError(C.dns_build_response(ctx.slot, (*C.uint8_t)(unsafe.Pointer(&out[0])), &outLen))
	return uint16(outLen), err
}

// EnableDnssec enables DNSSEC. Transitions Disabled -> Enabled.
func (ctx *DnsContext) EnableDnssec() error {
	return statusError(C.dns_enable_dnssec(ctx.slot))
}

// LoadDnssecKey loads a DNSSEC signing key. Transitions Enabled -> KeyLoaded.
func (ctx *DnsContext) LoadDnssecKey(algo DnssecAlgorithm) error {
	return statusError(C.dns_load_dnssec_key(ctx.slot, C.uint8_t(algo)))
}

// SignResponse signs the response (DNSSEC). Transitions KeyLoaded -> Validated.
func (ctx *DnsContext) SignResponse() error {
	return statusError(C.dns_sign_response(ctx.slot))
}

// ValidateDnssec checks DNSSEC validation. Returns true if validated.
func (ctx *DnsContext) ValidateDnssec() bool {
	return C.dns_validate_dnssec(ctx.slot) == 0
}

// DnsCanTransition checks whether a DNS lifecycle transition is valid.
func DnsCanTransition(from, to DnsState) bool {
	return C.dns_can_transition(C.uint8_t(from), C.uint8_t(to)) == 1
}

// DnssecCanTransition checks whether a DNSSEC state transition is valid.
func DnssecCanTransition(from, to DnssecState) bool {
	return C.dns_can_dnssec_transition(C.uint8_t(from), C.uint8_t(to)) == 1
}
