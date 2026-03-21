// SPDX-License-Identifier: PMPL-1.0-or-later
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
/// @file dns.hpp
/// @brief C++ bindings for proven-dns (DNS server protocol).
///
/// RAII wrapper around the Zig FFI context pool. Lifecycle:
/// Idle -> QueryReceived -> Lookup -> ResponseBuilding -> Sent.
/// DNSSEC sub-state: Disabled -> Enabled -> KeyLoaded -> Validated.

#ifndef PROVEN_DNS_HPP
#define PROVEN_DNS_HPP

#include "error.hpp"
#include <cstdint>
#include <optional>

extern "C" {
    uint32_t dns_abi_version();
    int dns_create_context();
    void dns_destroy_context(int slot);
    uint8_t dns_state(int slot);
    uint8_t dns_dnssec_state(int slot);
    uint8_t dns_rcode(int slot);
    uint16_t dns_answer_count(int slot);
    uint16_t dns_authority_count(int slot);
    uint16_t dns_additional_count(int slot);
    uint8_t dns_query_rtype(int slot);
    uint8_t dns_query_class(int slot);
    uint8_t dns_parse_query(int slot, const uint8_t* buf, uint16_t len);
    uint8_t dns_begin_lookup(int slot);
    uint8_t dns_begin_response(int slot);
    uint8_t dns_add_answer(int slot, uint8_t rtype, uint8_t rclass, uint32_t ttl, const uint8_t* rdata, uint16_t rdlen);
    uint8_t dns_add_authority(int slot, uint8_t rtype, uint8_t rclass, uint32_t ttl, const uint8_t* rdata, uint16_t rdlen);
    uint8_t dns_add_additional(int slot, uint8_t rtype, uint8_t rclass, uint32_t ttl, const uint8_t* rdata, uint16_t rdlen);
    uint8_t dns_set_rcode(int slot, uint8_t rcode_tag);
    uint8_t dns_build_response(int slot, uint8_t* out, uint16_t* out_len);
    uint8_t dns_enable_dnssec(int slot);
    uint8_t dns_load_dnssec_key(int slot, uint8_t algo);
    uint8_t dns_sign_response(int slot);
    uint8_t dns_validate_dnssec(int slot);
    uint8_t dns_can_transition(uint8_t from, uint8_t to);
    uint8_t dns_can_dnssec_transition(uint8_t from, uint8_t to);
}

namespace proven {

/// @brief DNS query lifecycle state. Tags match DnsState in dns.zig.
enum class DnsState : uint8_t {
    Idle = 0, QueryReceived = 1, Lookup = 2, ResponseBuilding = 3, Sent = 4
};

/// @brief DNSSEC sub-state machine.
enum class DnssecState : uint8_t {
    Disabled = 0, Enabled = 1, KeyLoaded = 2, Validated = 3
};

/// @brief DNSSEC signing algorithm.
enum class DnssecAlgorithm : uint8_t {
    RsaSha256 = 0, RsaSha512 = 1, EcdsaP256Sha256 = 2,
    EcdsaP384Sha384 = 3, Ed25519 = 4
};

/// @brief RAII wrapper for a DNS context slot.
class DnsContext {
public:
    /// @throws ProvenError if pool exhausted.
    DnsContext() : slot_(ProvenError::check_slot(dns_create_context())) {}
    ~DnsContext() { if (slot_ >= 0) dns_destroy_context(slot_); }

    DnsContext(const DnsContext&) = delete;
    DnsContext& operator=(const DnsContext&) = delete;
    DnsContext(DnsContext&& o) noexcept : slot_(o.slot_) { o.slot_ = -1; }
    DnsContext& operator=(DnsContext&& o) noexcept {
        if (this != &o) { if (slot_ >= 0) dns_destroy_context(slot_); slot_ = o.slot_; o.slot_ = -1; }
        return *this;
    }

    /// @brief Get the current lifecycle state.
    [[nodiscard]] std::optional<DnsState> state() const {
        uint8_t t = dns_state(slot_); return t <= 4 ? std::optional{static_cast<DnsState>(t)} : std::nullopt;
    }

    /// @brief Get the DNSSEC state.
    [[nodiscard]] std::optional<DnssecState> dnssec_state() const {
        uint8_t t = dns_dnssec_state(slot_); return t <= 3 ? std::optional{static_cast<DnssecState>(t)} : std::nullopt;
    }

    [[nodiscard]] uint8_t rcode() const { return dns_rcode(slot_); }
    [[nodiscard]] uint16_t answer_count() const { return dns_answer_count(slot_); }
    [[nodiscard]] uint16_t authority_count() const { return dns_authority_count(slot_); }
    [[nodiscard]] uint16_t additional_count() const { return dns_additional_count(slot_); }
    [[nodiscard]] uint8_t query_rtype() const { return dns_query_rtype(slot_); }
    [[nodiscard]] uint8_t query_class() const { return dns_query_class(slot_); }

    /// @brief Parse a DNS query. Transitions Idle -> QueryReceived.
    void parse_query(const uint8_t* data, uint16_t len) {
        ProvenError::check_status(dns_parse_query(slot_, data, len));
    }

    void begin_lookup() { ProvenError::check_status(dns_begin_lookup(slot_)); }
    void begin_response() { ProvenError::check_status(dns_begin_response(slot_)); }

    void add_answer(uint8_t rtype, uint8_t rclass, uint32_t ttl, const uint8_t* rdata, uint16_t rdlen) {
        ProvenError::check_status(dns_add_answer(slot_, rtype, rclass, ttl, rdata, rdlen));
    }

    void add_authority(uint8_t rtype, uint8_t rclass, uint32_t ttl, const uint8_t* rdata, uint16_t rdlen) {
        ProvenError::check_status(dns_add_authority(slot_, rtype, rclass, ttl, rdata, rdlen));
    }

    void add_additional(uint8_t rtype, uint8_t rclass, uint32_t ttl, const uint8_t* rdata, uint16_t rdlen) {
        ProvenError::check_status(dns_add_additional(slot_, rtype, rclass, ttl, rdata, rdlen));
    }

    void set_rcode(uint8_t rcode_tag) { ProvenError::check_status(dns_set_rcode(slot_, rcode_tag)); }

    /// @brief Build response. Returns bytes written to out.
    uint16_t build_response(uint8_t* out) {
        uint16_t out_len = 0;
        ProvenError::check_status(dns_build_response(slot_, out, &out_len));
        return out_len;
    }

    void enable_dnssec() { ProvenError::check_status(dns_enable_dnssec(slot_)); }
    void load_dnssec_key(DnssecAlgorithm algo) { ProvenError::check_status(dns_load_dnssec_key(slot_, static_cast<uint8_t>(algo))); }
    void sign_response() { ProvenError::check_status(dns_sign_response(slot_)); }
    [[nodiscard]] bool validate_dnssec() const { return dns_validate_dnssec(slot_) == 0; }

    static bool can_transition(DnsState from, DnsState to) {
        return dns_can_transition(static_cast<uint8_t>(from), static_cast<uint8_t>(to)) == 1;
    }

    static bool can_dnssec_transition(DnssecState from, DnssecState to) {
        return dns_can_dnssec_transition(static_cast<uint8_t>(from), static_cast<uint8_t>(to)) == 1;
    }

    static uint32_t abi_version() { return dns_abi_version(); }

private:
    int slot_;
};

} // namespace proven

#endif // PROVEN_DNS_HPP
