// SPDX-License-Identifier: PMPL-1.0-or-later
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
/// @file websocket.hpp
/// @brief C++ bindings for proven-websocket (WebSocket protocol, RFC 6455).
///
/// RAII wrapper. Connection lifecycle:
/// Connecting -> Open -> Closing -> Closed.
/// Opcodes use RFC 6455 wire values directly.

#ifndef PROVEN_WEBSOCKET_HPP
#define PROVEN_WEBSOCKET_HPP

#include "error.hpp"
#include <cstdint>
#include <optional>

extern "C" {
    uint32_t ws_abi_version();
    int ws_create_context();
    void ws_destroy_context(int slot);
    uint8_t ws_state(int slot);
    uint8_t ws_handshake(int slot);
    uint8_t ws_send_frame(int slot, uint8_t opcode, const uint8_t* data, uint32_t len, uint8_t fin);
    uint8_t ws_recv_frame(int slot, uint8_t* opcode_out, uint8_t* buf, uint32_t buf_len, uint32_t* written);
    uint8_t ws_send_close(int slot, uint16_t code);
    uint8_t ws_send_ping(int slot, const uint8_t* data, uint32_t len);
    uint8_t ws_send_pong(int slot, const uint8_t* data, uint32_t len);
    uint16_t ws_close_code(int slot);
    uint8_t ws_is_masked(int slot);
    uint32_t ws_frames_sent(int slot);
    uint32_t ws_frames_received(int slot);
    uint8_t ws_can_transition(uint8_t from, uint8_t to);
}

namespace proven {

/// @brief WebSocket frame opcode (RFC 6455 Section 5.2).
/// Values are the 4-bit wire values from the specification.
enum class WsOpcode : uint8_t {
    Continuation = 0x0, ///< Continuation frame
    Text = 0x1,         ///< Text frame (UTF-8 payload)
    Binary = 0x2,       ///< Binary frame
    Close = 0x8,        ///< Close frame
    Ping = 0x9,         ///< Ping frame (heartbeat request)
    Pong = 0xA          ///< Pong frame (heartbeat response)
};

/// @brief WebSocket connection state.
enum class WsState : uint8_t {
    Connecting = 0, ///< Handshake in progress
    Open = 1,       ///< Connection open
    Closing = 2,    ///< Close frame sent/received
    Closed = 3      ///< Connection closed
};

/// @brief WebSocket close status codes (RFC 6455 Section 7.4).
enum class WsCloseCode : uint16_t {
    Normal = 1000,          ///< Normal closure
    GoingAway = 1001,       ///< Endpoint going away
    ProtocolError = 1002,   ///< Protocol error
    Unsupported = 1003,     ///< Unsupported data type
    NoStatus = 1005,        ///< No status code present
    Abnormal = 1006,        ///< Abnormal closure
    InvalidPayload = 1007,  ///< Invalid frame payload data
    PolicyViolation = 1008, ///< Policy violation
    MessageTooBig = 1009,   ///< Message too big
    MandatoryExt = 1010,    ///< Mandatory extension missing
    InternalError = 1011    ///< Internal server error
};

/// @brief RAII wrapper for a WebSocket context slot.
class WsContext {
public:
    /// @throws ProvenError if pool exhausted.
    WsContext() : slot_(ProvenError::check_slot(ws_create_context())) {}
    ~WsContext() { if (slot_ >= 0) ws_destroy_context(slot_); }

    WsContext(const WsContext&) = delete;
    WsContext& operator=(const WsContext&) = delete;
    WsContext(WsContext&& o) noexcept : slot_(o.slot_) { o.slot_ = -1; }
    WsContext& operator=(WsContext&& o) noexcept {
        if (this != &o) { if (slot_ >= 0) ws_destroy_context(slot_); slot_ = o.slot_; o.slot_ = -1; }
        return *this;
    }

    /// @brief Get the current connection state.
    [[nodiscard]] std::optional<WsState> state() const {
        uint8_t t = ws_state(slot_);
        return t <= 3 ? std::optional{static_cast<WsState>(t)} : std::nullopt;
    }

    /// @brief Complete the WebSocket handshake. Transitions Connecting -> Open.
    void handshake() { ProvenError::check_status(ws_handshake(slot_)); }

    /// @brief Send a WebSocket frame.
    /// @param opcode Frame opcode.
    /// @param data Payload data (may be nullptr if len is 0).
    /// @param len Payload length.
    /// @param fin True if this is the final fragment.
    void send_frame(WsOpcode opcode, const uint8_t* data, uint32_t len, bool fin) {
        ProvenError::check_status(ws_send_frame(slot_,
            static_cast<uint8_t>(opcode), data, len, fin ? 1 : 0));
    }

    /// @brief Receive a WebSocket frame.
    /// @param[out] opcode The frame opcode.
    /// @param[out] buf Buffer for payload data.
    /// @param buf_len Size of the buffer.
    /// @return Number of bytes written to buf.
    uint32_t recv_frame(WsOpcode& opcode, uint8_t* buf, uint32_t buf_len) {
        uint8_t op = 0;
        uint32_t written = 0;
        ProvenError::check_status(ws_recv_frame(slot_, &op, buf, buf_len, &written));
        opcode = static_cast<WsOpcode>(op);
        return written;
    }

    /// @brief Send a close frame with status code. Transitions Open -> Closing.
    void send_close(WsCloseCode code) {
        ProvenError::check_status(ws_send_close(slot_, static_cast<uint16_t>(code)));
    }

    /// @brief Send a ping frame with optional payload.
    void send_ping(const uint8_t* data = nullptr, uint32_t len = 0) {
        ProvenError::check_status(ws_send_ping(slot_, data, len));
    }

    /// @brief Send a pong frame with optional payload.
    void send_pong(const uint8_t* data = nullptr, uint32_t len = 0) {
        ProvenError::check_status(ws_send_pong(slot_, data, len));
    }

    /// @brief Get the close status code received, or 0 if none.
    [[nodiscard]] WsCloseCode close_code() const {
        return static_cast<WsCloseCode>(ws_close_code(slot_));
    }

    /// @brief Check if frames are masked (client-to-server per RFC 6455).
    [[nodiscard]] bool is_masked() const { return ws_is_masked(slot_) == 1; }

    /// @brief Get total frames sent.
    [[nodiscard]] uint32_t frames_sent() const { return ws_frames_sent(slot_); }

    /// @brief Get total frames received.
    [[nodiscard]] uint32_t frames_received() const { return ws_frames_received(slot_); }

    /// @brief Stateless: check if a WebSocket state transition is valid.
    static bool can_transition(WsState from, WsState to) {
        return ws_can_transition(static_cast<uint8_t>(from), static_cast<uint8_t>(to)) == 1;
    }

    /// @brief Return the ABI version of the linked library.
    static uint32_t abi_version() { return ws_abi_version(); }

private:
    int slot_;
};

} // namespace proven

#endif // PROVEN_WEBSOCKET_HPP
