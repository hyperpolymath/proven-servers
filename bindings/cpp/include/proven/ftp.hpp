// SPDX-License-Identifier: MPL-2.0
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
/// @file ftp.hpp
/// @brief C++ bindings for proven-ftp (FTP server protocol).
///
/// RAII wrapper. Session lifecycle:
/// Connected -> UserOk -> Authenticated -> (transfers/rename) -> Quit.
/// Transfer sub-state: Idle -> InProgress -> Completed/Aborted.

#ifndef PROVEN_FTP_HPP
#define PROVEN_FTP_HPP

#include "error.hpp"
#include <cstdint>
#include <optional>
#include <string>
#include <string_view>

extern "C" {
    uint32_t ftp_abi_version();
    int ftp_create();
    void ftp_destroy(int slot);
    uint8_t ftp_state(int slot);
    uint8_t ftp_transfer_type(int slot);
    uint8_t ftp_data_mode(int slot);
    uint8_t ftp_transfer_state(int slot);
    uint64_t ftp_bytes_transferred(int slot);
    uint32_t ftp_file_count(int slot);
    uint16_t ftp_last_reply_code(int slot);
    uint32_t ftp_cwd(int slot, uint8_t* buf, uint32_t buf_len);
    uint8_t ftp_user(int slot, const uint8_t* name, uint32_t len);
    uint8_t ftp_pass(int slot, const uint8_t* pass, uint32_t len);
    uint8_t ftp_quit(int slot);
    uint8_t ftp_cwd_cmd(int slot, const uint8_t* path, uint32_t path_len);
    uint8_t ftp_cdup(int slot);
    uint8_t ftp_set_type(int slot, uint8_t type_tag);
    uint8_t ftp_set_passive(int slot);
    uint8_t ftp_set_active(int slot, uint16_t port);
    uint8_t ftp_begin_transfer(int slot);
    uint8_t ftp_add_bytes(int slot, uint64_t count);
    uint8_t ftp_complete_transfer(int slot);
    uint8_t ftp_abort_transfer(int slot);
    uint8_t ftp_begin_rename(int slot);
    uint8_t ftp_complete_rename(int slot);
    uint8_t ftp_can_transfer(uint8_t state_tag);
    uint8_t ftp_can_transition(uint8_t from, uint8_t to);
}

namespace proven {

/// @brief FTP session state. Tags match SessionState in ftp.zig.
enum class FtpSessionState : uint8_t {
    Connected = 0, UserOk = 1, Authenticated = 2, Renaming = 3, Quit = 4
};

/// @brief FTP transfer sub-state.
enum class FtpTransferState : uint8_t {
    Idle = 0, InProgress = 1, Completed = 2, Aborted = 3
};

/// @brief RAII wrapper for an FTP context slot.
class FtpContext {
public:
    FtpContext() : slot_(ProvenError::check_slot(ftp_create())) {}
    ~FtpContext() { if (slot_ >= 0) ftp_destroy(slot_); }

    FtpContext(const FtpContext&) = delete;
    FtpContext& operator=(const FtpContext&) = delete;
    FtpContext(FtpContext&& o) noexcept : slot_(o.slot_) { o.slot_ = -1; }
    FtpContext& operator=(FtpContext&& o) noexcept {
        if (this != &o) { if (slot_ >= 0) ftp_destroy(slot_); slot_ = o.slot_; o.slot_ = -1; }
        return *this;
    }

    [[nodiscard]] std::optional<FtpSessionState> state() const {
        uint8_t t = ftp_state(slot_); return t <= 4 ? std::optional{static_cast<FtpSessionState>(t)} : std::nullopt;
    }

    [[nodiscard]] uint8_t transfer_type() const { return ftp_transfer_type(slot_); }
    [[nodiscard]] uint8_t data_mode() const { return ftp_data_mode(slot_); }

    [[nodiscard]] std::optional<FtpTransferState> transfer_state() const {
        uint8_t t = ftp_transfer_state(slot_); return t <= 3 ? std::optional{static_cast<FtpTransferState>(t)} : std::nullopt;
    }

    [[nodiscard]] uint64_t bytes_transferred() const { return ftp_bytes_transferred(slot_); }
    [[nodiscard]] uint32_t file_count() const { return ftp_file_count(slot_); }
    [[nodiscard]] uint16_t last_reply_code() const { return ftp_last_reply_code(slot_); }

    /// @brief Get the current working directory as a string.
    [[nodiscard]] std::string cwd() const {
        uint8_t buf[1024];
        uint32_t n = ftp_cwd(slot_, buf, sizeof(buf));
        return std::string(reinterpret_cast<char*>(buf), n);
    }

    void user(std::string_view name) {
        ProvenError::check_status(ftp_user(slot_, reinterpret_cast<const uint8_t*>(name.data()), static_cast<uint32_t>(name.size())));
    }

    void pass(std::string_view password) {
        ProvenError::check_status(ftp_pass(slot_, reinterpret_cast<const uint8_t*>(password.data()), static_cast<uint32_t>(password.size())));
    }

    void quit() { ProvenError::check_status(ftp_quit(slot_)); }

    void change_dir(std::string_view path) {
        ProvenError::check_status(ftp_cwd_cmd(slot_, reinterpret_cast<const uint8_t*>(path.data()), static_cast<uint32_t>(path.size())));
    }

    void change_dir_up() { ProvenError::check_status(ftp_cdup(slot_)); }
    void set_type(uint8_t type_tag) { ProvenError::check_status(ftp_set_type(slot_, type_tag)); }
    void set_passive() { ProvenError::check_status(ftp_set_passive(slot_)); }
    void set_active(uint16_t port) { ProvenError::check_status(ftp_set_active(slot_, port)); }
    void begin_transfer() { ProvenError::check_status(ftp_begin_transfer(slot_)); }
    void add_bytes(uint64_t count) { ProvenError::check_status(ftp_add_bytes(slot_, count)); }
    void complete_transfer() { ProvenError::check_status(ftp_complete_transfer(slot_)); }
    void abort_transfer() { ProvenError::check_status(ftp_abort_transfer(slot_)); }
    void begin_rename() { ProvenError::check_status(ftp_begin_rename(slot_)); }
    void complete_rename() { ProvenError::check_status(ftp_complete_rename(slot_)); }

    static bool can_transfer(FtpSessionState state) {
        return ftp_can_transfer(static_cast<uint8_t>(state)) == 1;
    }

    static bool can_transition(FtpSessionState from, FtpSessionState to) {
        return ftp_can_transition(static_cast<uint8_t>(from), static_cast<uint8_t>(to)) == 1;
    }

    static uint32_t abi_version() { return ftp_abi_version(); }

private:
    int slot_;
};

} // namespace proven

#endif // PROVEN_FTP_HPP
