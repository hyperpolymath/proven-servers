// SPDX-License-Identifier: MPL-2.0
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
/// @file firewall.hpp
/// @brief C++ bindings for proven-firewall.
///
/// RAII wrapper around the Zig FFI context pool. Packet lifecycle:
/// Idle -> Classified -> Evaluating -> Decided -> Committed.
/// Conntrack: None -> Tracking -> Established/Related -> Expired.

#ifndef PROVEN_FIREWALL_HPP
#define PROVEN_FIREWALL_HPP

#include "error.hpp"
#include <cstdint>
#include <optional>

extern "C" {
    uint32_t fw_abi_version();
    int fw_create_context();
    void fw_destroy_context(int slot);
    uint8_t fw_packet_state(int slot);
    uint8_t fw_conntrack_state(int slot);
    uint8_t fw_get_decision(int slot);
    uint16_t fw_rule_count(int slot);
    uint8_t fw_packet_proto(int slot);
    uint8_t fw_packet_chain(int slot);
    uint32_t fw_packet_src_ip(int slot);
    uint32_t fw_packet_dst_ip(int slot);
    uint16_t fw_packet_src_port(int slot);
    uint16_t fw_packet_dst_port(int slot);
    uint8_t fw_classify_packet(int slot, uint8_t proto, uint8_t chain, uint32_t src_ip, uint32_t dst_ip, uint16_t src_port, uint16_t dst_port);
    uint8_t fw_begin_chain(int slot);
    uint8_t fw_add_rule(int slot, uint8_t match_type, uint32_t match_value, uint8_t action, uint16_t priority);
    uint8_t fw_set_default_action(int slot, uint8_t action);
    uint8_t fw_evaluate_rules(int slot);
    uint8_t fw_commit(int slot);
    uint8_t fw_begin_tracking(int slot);
    uint8_t fw_complete_tracking(int slot, uint8_t conn_state_tag);
    uint8_t fw_expire_conn(int slot);
    uint8_t fw_can_transition(uint8_t from, uint8_t to);
    uint8_t fw_can_conntrack_transition(uint8_t from, uint8_t to);
}

namespace proven {

/// @brief Firewall rule action. Tags match Action in firewall.zig.
enum class FirewallAction : uint8_t {
    Accept = 0, Drop = 1, Reject = 2, Log = 3,
    Redirect = 4, Dnat = 5, Snat = 6, Masquerade = 7
};

/// @brief Packet lifecycle state.
enum class PacketState : uint8_t {
    Idle = 0, Classified = 1, Evaluating = 2, Decided = 3, Committed = 4
};

/// @brief Connection tracking state.
enum class ConntrackState : uint8_t {
    None = 0, Tracking = 1, Established = 2, Related = 3, Expired = 4
};

/// @brief RAII wrapper for a firewall context slot.
class FirewallContext {
public:
    FirewallContext() : slot_(ProvenError::check_slot(fw_create_context())) {}
    ~FirewallContext() { if (slot_ >= 0) fw_destroy_context(slot_); }

    FirewallContext(const FirewallContext&) = delete;
    FirewallContext& operator=(const FirewallContext&) = delete;
    FirewallContext(FirewallContext&& o) noexcept : slot_(o.slot_) { o.slot_ = -1; }
    FirewallContext& operator=(FirewallContext&& o) noexcept {
        if (this != &o) { if (slot_ >= 0) fw_destroy_context(slot_); slot_ = o.slot_; o.slot_ = -1; }
        return *this;
    }

    [[nodiscard]] std::optional<PacketState> packet_state() const {
        uint8_t t = fw_packet_state(slot_); return t <= 4 ? std::optional{static_cast<PacketState>(t)} : std::nullopt;
    }

    [[nodiscard]] std::optional<ConntrackState> conntrack_state() const {
        uint8_t t = fw_conntrack_state(slot_); return t <= 4 ? std::optional{static_cast<ConntrackState>(t)} : std::nullopt;
    }

    [[nodiscard]] std::optional<FirewallAction> get_decision() const {
        uint8_t t = fw_get_decision(slot_); return t <= 7 ? std::optional{static_cast<FirewallAction>(t)} : std::nullopt;
    }

    [[nodiscard]] uint16_t rule_count() const { return fw_rule_count(slot_); }
    [[nodiscard]] uint8_t packet_proto() const { return fw_packet_proto(slot_); }
    [[nodiscard]] uint8_t packet_chain() const { return fw_packet_chain(slot_); }
    [[nodiscard]] uint32_t packet_src_ip() const { return fw_packet_src_ip(slot_); }
    [[nodiscard]] uint32_t packet_dst_ip() const { return fw_packet_dst_ip(slot_); }
    [[nodiscard]] uint16_t packet_src_port() const { return fw_packet_src_port(slot_); }
    [[nodiscard]] uint16_t packet_dst_port() const { return fw_packet_dst_port(slot_); }

    /// @brief Classify a packet. Transitions Idle -> Classified.
    void classify_packet(uint8_t proto, uint8_t chain, uint32_t src_ip, uint32_t dst_ip, uint16_t src_port, uint16_t dst_port) {
        ProvenError::check_status(fw_classify_packet(slot_, proto, chain, src_ip, dst_ip, src_port, dst_port));
    }

    void begin_chain() { ProvenError::check_status(fw_begin_chain(slot_)); }

    void add_rule(uint8_t match_type, uint32_t match_value, FirewallAction action, uint16_t priority) {
        ProvenError::check_status(fw_add_rule(slot_, match_type, match_value, static_cast<uint8_t>(action), priority));
    }

    void set_default_action(FirewallAction action) {
        ProvenError::check_status(fw_set_default_action(slot_, static_cast<uint8_t>(action)));
    }

    void evaluate_rules() { ProvenError::check_status(fw_evaluate_rules(slot_)); }
    void commit() { ProvenError::check_status(fw_commit(slot_)); }
    void begin_tracking() { ProvenError::check_status(fw_begin_tracking(slot_)); }

    void complete_tracking(ConntrackState conn_state) {
        ProvenError::check_status(fw_complete_tracking(slot_, static_cast<uint8_t>(conn_state)));
    }

    void expire_conn() { ProvenError::check_status(fw_expire_conn(slot_)); }

    static bool can_transition(PacketState from, PacketState to) {
        return fw_can_transition(static_cast<uint8_t>(from), static_cast<uint8_t>(to)) == 1;
    }

    static bool can_conntrack_transition(ConntrackState from, ConntrackState to) {
        return fw_can_conntrack_transition(static_cast<uint8_t>(from), static_cast<uint8_t>(to)) == 1;
    }

    static uint32_t abi_version() { return fw_abi_version(); }

private:
    int slot_;
};

} // namespace proven

#endif // PROVEN_FIREWALL_HPP
