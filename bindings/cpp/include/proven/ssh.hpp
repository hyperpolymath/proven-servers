// SPDX-License-Identifier: MPL-2.0
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
/// @file ssh.hpp
/// @brief C++ bindings for proven-ssh-bastion (SSH bastion protocol).
///
/// RAII wrapper. Session lifecycle:
/// Connected -> KeyExchanged -> Authenticated -> ChannelOpen -> Active -> Closed.
/// Supports channel management, session recording, and audit logging.

#ifndef PROVEN_SSH_HPP
#define PROVEN_SSH_HPP

#include "error.hpp"
#include <cstdint>
#include <optional>

extern "C" {
    uint32_t ssh_bastion_abi_version();
    int ssh_bastion_create(uint8_t kex_method, uint8_t auth_method);
    void ssh_bastion_destroy(int slot);
    uint8_t ssh_bastion_state(int slot);
    uint8_t ssh_bastion_kex_method(int slot);
    uint8_t ssh_bastion_auth_method(int slot);
    uint8_t ssh_bastion_can_transfer(int slot);
    uint8_t ssh_bastion_disconnect_reason(int slot);
    uint8_t ssh_bastion_auth_failures(int slot);
    uint8_t ssh_bastion_complete_kex(int slot);
    uint8_t ssh_bastion_authenticate(int slot, uint16_t user_len);
    uint8_t ssh_bastion_record_auth_failure(int slot);
    int ssh_bastion_open_channel(int slot, uint8_t ch_type);
    uint8_t ssh_bastion_confirm_channel(int slot, uint8_t ch_id);
    uint8_t ssh_bastion_close_channel(int slot, uint8_t ch_id);
    uint8_t ssh_bastion_channel_state(int slot, uint8_t ch_id);
    uint8_t ssh_bastion_channel_type(int slot, uint8_t ch_id);
    uint8_t ssh_bastion_channel_count(int slot);
    uint8_t ssh_bastion_rekey(int slot);
    uint8_t ssh_bastion_disconnect(int slot, uint8_t reason);
    uint8_t ssh_bastion_can_transition(uint8_t from, uint8_t to);
    uint32_t ssh_bastion_audit_count(int slot);
    uint8_t ssh_bastion_audit_entry(int slot, uint32_t entry_idx);
    uint8_t ssh_bastion_audit_entry_to(int slot, uint32_t entry_idx);
    uint8_t ssh_bastion_set_recording(int slot, uint8_t enabled);
    uint8_t ssh_bastion_is_recording(int slot);
}

namespace proven {

/// @brief SSH bastion connection state (tags 0-5).
enum class BastionState : uint8_t {
    Connected = 0, KeyExchanged = 1, Authenticated = 2,
    ChannelOpen = 3, Active = 4, Closed = 5
};

/// @brief SSH key exchange method (tags 0-5).
enum class KexMethod : uint8_t {
    Curve25519 = 0, EcdhSha2P256 = 1, EcdhSha2P384 = 2,
    EcdhSha2P521 = 3, DhGroup14 = 4, DhGroup16 = 5
};

/// @brief SSH authentication method (tags 0-3).
enum class AuthMethod : uint8_t {
    PublicKey = 0, Password = 1, Keyboard = 2, None = 3
};

/// @brief SSH channel type (tags 0-3).
enum class ChannelType : uint8_t {
    Session = 0, Direct = 1, Forwarded = 2, X11 = 3
};

/// @brief SSH per-channel state (tags 0-3).
enum class ChannelState : uint8_t {
    Opening = 0, Open = 1, Closing = 2, Closed = 3
};

/// @brief SSH disconnect reason (tags 0-11).
enum class DisconnectReason : uint8_t {
    ByApp = 0, ProtocolError = 1, KeyExchange = 2, Reserved = 3,
    MacError = 4, Compression = 5, ServiceNotAvailable = 6,
    ProtocolVersion = 7, HostKeyNotVerifiable = 8, ConnectionLost = 9,
    AuthCancelled = 10, TooManyConnections = 11
};

/// @brief RAII wrapper for an SSH bastion context slot.
class SshBastionContext {
public:
    /// @param kex Key exchange method.
    /// @param auth Authentication method.
    SshBastionContext(KexMethod kex, AuthMethod auth)
        : slot_(ProvenError::check_slot(ssh_bastion_create(
            static_cast<uint8_t>(kex), static_cast<uint8_t>(auth)))) {}

    ~SshBastionContext() { if (slot_ >= 0) ssh_bastion_destroy(slot_); }

    SshBastionContext(const SshBastionContext&) = delete;
    SshBastionContext& operator=(const SshBastionContext&) = delete;
    SshBastionContext(SshBastionContext&& o) noexcept : slot_(o.slot_) { o.slot_ = -1; }
    SshBastionContext& operator=(SshBastionContext&& o) noexcept {
        if (this != &o) { if (slot_ >= 0) ssh_bastion_destroy(slot_); slot_ = o.slot_; o.slot_ = -1; }
        return *this;
    }

    [[nodiscard]] std::optional<BastionState> state() const {
        uint8_t t = ssh_bastion_state(slot_); return t <= 5 ? std::optional{static_cast<BastionState>(t)} : std::nullopt;
    }

    [[nodiscard]] std::optional<KexMethod> kex_method() const {
        uint8_t t = ssh_bastion_kex_method(slot_); return t <= 5 ? std::optional{static_cast<KexMethod>(t)} : std::nullopt;
    }

    [[nodiscard]] std::optional<AuthMethod> auth_method() const {
        uint8_t t = ssh_bastion_auth_method(slot_); return t <= 3 ? std::optional{static_cast<AuthMethod>(t)} : std::nullopt;
    }

    [[nodiscard]] bool can_transfer_data() const { return ssh_bastion_can_transfer(slot_) == 1; }

    [[nodiscard]] std::optional<DisconnectReason> disconnect_reason() const {
        uint8_t t = ssh_bastion_disconnect_reason(slot_); return t <= 11 ? std::optional{static_cast<DisconnectReason>(t)} : std::nullopt;
    }

    [[nodiscard]] uint8_t auth_failures() const { return ssh_bastion_auth_failures(slot_); }

    void complete_kex() { ProvenError::check_status(ssh_bastion_complete_kex(slot_)); }
    void authenticate() { ProvenError::check_status(ssh_bastion_authenticate(slot_, 0)); }

    /// @brief Record a failed auth attempt. Returns true if locked out (3+ failures).
    bool record_auth_failure() { return ssh_bastion_record_auth_failure(slot_) == 1; }

    /// @brief Open a channel. Returns channel ID (0-9).
    uint8_t open_channel(ChannelType ch_type) {
        return static_cast<uint8_t>(ProvenError::check_slot(
            ssh_bastion_open_channel(slot_, static_cast<uint8_t>(ch_type))));
    }

    void confirm_channel(uint8_t ch_id) { ProvenError::check_status(ssh_bastion_confirm_channel(slot_, ch_id)); }
    void close_channel(uint8_t ch_id) { ProvenError::check_status(ssh_bastion_close_channel(slot_, ch_id)); }

    [[nodiscard]] std::optional<ChannelState> channel_state(uint8_t ch_id) const {
        uint8_t t = ssh_bastion_channel_state(slot_, ch_id); return t <= 3 ? std::optional{static_cast<ChannelState>(t)} : std::nullopt;
    }

    [[nodiscard]] std::optional<ChannelType> channel_type(uint8_t ch_id) const {
        uint8_t t = ssh_bastion_channel_type(slot_, ch_id); return t <= 3 ? std::optional{static_cast<ChannelType>(t)} : std::nullopt;
    }

    [[nodiscard]] uint8_t channel_count() const { return ssh_bastion_channel_count(slot_); }

    void rekey() { ProvenError::check_status(ssh_bastion_rekey(slot_)); }

    void disconnect(DisconnectReason reason) {
        ProvenError::check_status(ssh_bastion_disconnect(slot_, static_cast<uint8_t>(reason)));
    }

    [[nodiscard]] uint32_t audit_count() const { return ssh_bastion_audit_count(slot_); }

    [[nodiscard]] std::optional<BastionState> audit_entry_from(uint32_t index) const {
        uint8_t t = ssh_bastion_audit_entry(slot_, index); return t <= 5 ? std::optional{static_cast<BastionState>(t)} : std::nullopt;
    }

    [[nodiscard]] std::optional<BastionState> audit_entry_to(uint32_t index) const {
        uint8_t t = ssh_bastion_audit_entry_to(slot_, index); return t <= 5 ? std::optional{static_cast<BastionState>(t)} : std::nullopt;
    }

    void set_recording(bool enabled) { ProvenError::check_status(ssh_bastion_set_recording(slot_, enabled ? 1 : 0)); }
    [[nodiscard]] bool is_recording() const { return ssh_bastion_is_recording(slot_) == 1; }

    static bool can_transition(BastionState from, BastionState to) {
        return ssh_bastion_can_transition(static_cast<uint8_t>(from), static_cast<uint8_t>(to)) == 1;
    }

    static uint32_t abi_version() { return ssh_bastion_abi_version(); }

private:
    int slot_;
};

} // namespace proven

#endif // PROVEN_SSH_HPP
