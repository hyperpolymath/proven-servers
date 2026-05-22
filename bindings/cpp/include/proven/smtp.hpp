// SPDX-License-Identifier: MPL-2.0
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
/// @file smtp.hpp
/// @brief C++ bindings for proven-smtp (SMTP server protocol).
///
/// RAII wrapper. Session lifecycle:
/// Connected -> Greeted -> (Auth) -> MailFrom -> RcptTo -> Data -> MessageReceived -> Quit.

#ifndef PROVEN_SMTP_HPP
#define PROVEN_SMTP_HPP

#include "error.hpp"
#include <cstdint>
#include <optional>

extern "C" {
    uint32_t smtp_abi_version();
    int smtp_create_context();
    void smtp_destroy_context(int slot);
    uint8_t smtp_get_state(int slot);
    uint8_t smtp_get_reply_code(int slot);
    uint8_t smtp_get_recipient_count(int slot);
    uint32_t smtp_get_data_size(int slot);
    uint8_t smtp_get_auth_mechanism(int slot);
    uint8_t smtp_is_authenticated(int slot);
    uint8_t smtp_is_tls_active(int slot);
    uint8_t smtp_greet(int slot, uint8_t is_ehlo);
    uint8_t smtp_authenticate(int slot, uint8_t mech);
    uint8_t smtp_auth_complete(int slot, uint8_t success);
    uint8_t smtp_set_sender(int slot);
    uint8_t smtp_add_recipient(int slot);
    uint8_t smtp_start_data(int slot);
    uint8_t smtp_append_data(int slot, uint32_t len);
    uint8_t smtp_finish_data(int slot);
    uint8_t smtp_reset(int slot);
    uint8_t smtp_quit(int slot);
    uint8_t smtp_enable_tls(int slot);
    uint8_t smtp_can_transition(uint8_t from, uint8_t to);
}

namespace proven {

/// @brief SMTP session state.
enum class SmtpSessionState : uint8_t {
    Connected = 0, Greeted = 1, AuthStarted = 2, Authenticated = 3,
    MailFrom = 4, RcptTo = 5, Data = 6, MessageReceived = 7, Quit = 8
};

/// @brief SMTP authentication mechanism.
enum class SmtpAuthMechanism : uint8_t {
    Plain = 0, Login = 1, CramMd5 = 2, XOAuth2 = 3
};

/// @brief RAII wrapper for an SMTP context slot.
class SmtpContext {
public:
    SmtpContext() : slot_(ProvenError::check_slot(smtp_create_context())) {}
    ~SmtpContext() { if (slot_ >= 0) smtp_destroy_context(slot_); }

    SmtpContext(const SmtpContext&) = delete;
    SmtpContext& operator=(const SmtpContext&) = delete;
    SmtpContext(SmtpContext&& o) noexcept : slot_(o.slot_) { o.slot_ = -1; }
    SmtpContext& operator=(SmtpContext&& o) noexcept {
        if (this != &o) { if (slot_ >= 0) smtp_destroy_context(slot_); slot_ = o.slot_; o.slot_ = -1; }
        return *this;
    }

    [[nodiscard]] std::optional<SmtpSessionState> state() const {
        uint8_t t = smtp_get_state(slot_); return t <= 8 ? std::optional{static_cast<SmtpSessionState>(t)} : std::nullopt;
    }

    [[nodiscard]] uint8_t reply_code() const { return smtp_get_reply_code(slot_); }
    [[nodiscard]] uint8_t recipient_count() const { return smtp_get_recipient_count(slot_); }
    [[nodiscard]] uint32_t data_size() const { return smtp_get_data_size(slot_); }

    [[nodiscard]] std::optional<SmtpAuthMechanism> auth_mechanism() const {
        uint8_t t = smtp_get_auth_mechanism(slot_); return t <= 3 ? std::optional{static_cast<SmtpAuthMechanism>(t)} : std::nullopt;
    }

    [[nodiscard]] bool is_authenticated() const { return smtp_is_authenticated(slot_) == 1; }
    [[nodiscard]] bool is_tls_active() const { return smtp_is_tls_active(slot_) == 1; }

    /// @brief HELO/EHLO. ehlo=true selects EHLO.
    void greet(bool ehlo) { ProvenError::check_status(smtp_greet(slot_, ehlo ? 1 : 0)); }

    void authenticate(SmtpAuthMechanism mech) {
        ProvenError::check_status(smtp_authenticate(slot_, static_cast<uint8_t>(mech)));
    }

    void auth_complete(bool success) { ProvenError::check_status(smtp_auth_complete(slot_, success ? 1 : 0)); }
    void set_sender() { ProvenError::check_status(smtp_set_sender(slot_)); }
    void add_recipient() { ProvenError::check_status(smtp_add_recipient(slot_)); }
    void start_data() { ProvenError::check_status(smtp_start_data(slot_)); }
    void append_data(uint32_t len) { ProvenError::check_status(smtp_append_data(slot_, len)); }
    void finish_data() { ProvenError::check_status(smtp_finish_data(slot_)); }
    void reset() { ProvenError::check_status(smtp_reset(slot_)); }
    void quit() { ProvenError::check_status(smtp_quit(slot_)); }
    void enable_tls() { ProvenError::check_status(smtp_enable_tls(slot_)); }

    static bool can_transition(SmtpSessionState from, SmtpSessionState to) {
        return smtp_can_transition(static_cast<uint8_t>(from), static_cast<uint8_t>(to)) == 1;
    }

    static uint32_t abi_version() { return smtp_abi_version(); }

private:
    int slot_;
};

} // namespace proven

#endif // PROVEN_SMTP_HPP
