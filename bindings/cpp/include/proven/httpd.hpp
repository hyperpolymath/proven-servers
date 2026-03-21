// SPDX-License-Identifier: PMPL-1.0-or-later
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
/// @file httpd.hpp
/// @brief C++ bindings for proven-httpd (HTTP server protocol).
///
/// RAII wrapper around the Zig FFI context pool. Context slots are
/// acquired in the constructor and released in the destructor.
/// All state transitions follow the Idris2 ABI lifecycle:
/// Idle -> Receiving -> HeadersParsed -> Complete -> Responding -> Sent.

#ifndef PROVEN_HTTPD_HPP
#define PROVEN_HTTPD_HPP

#include "error.hpp"
#include <cstdint>
#include <cstring>
#include <optional>
#include <string>
#include <string_view>

// ---------------------------------------------------------------------------
// Zig FFI C-ABI declarations
// ---------------------------------------------------------------------------

extern "C" {
    uint32_t http_abi_version();
    int http_create_context();
    void http_destroy_context(int slot);
    uint8_t http_parse_request(int slot, const uint8_t* data, uint32_t len);
    uint8_t http_get_method(int slot);
    uint32_t http_get_path(int slot, uint8_t* buf, uint32_t len);
    uint32_t http_get_header(int slot, const uint8_t* key, uint32_t klen, uint8_t* buf, uint32_t blen);
    uint32_t http_get_body(int slot, uint8_t* buf, uint32_t len);
    uint8_t http_set_status(int slot, uint8_t status_tag);
    uint8_t http_set_header(int slot, const uint8_t* key, uint32_t klen, const uint8_t* val, uint32_t vlen);
    uint8_t http_set_body(int slot, const uint8_t* data, uint32_t len);
    uint8_t http_send_response(int slot);
    uint8_t http_keep_alive_check(int slot);
    uint8_t http_get_phase(int slot);
    uint8_t http_get_version(int slot);
    uint8_t http_reset_context(int slot);
    uint8_t http_can_transition(uint8_t from, uint8_t to);
}

namespace proven {

/// @brief HTTP request method (RFC 7231). Tags match HTTPABI.Layout.
enum class HttpMethod : uint8_t {
    Get = 0, Post = 1, Put = 2, Delete = 3, Patch = 4,
    Head = 5, Options = 6, Trace = 7, Connect = 8
};

/// @brief HTTP request lifecycle phase. Tags match the Idris2 ABI.
enum class RequestPhase : uint8_t {
    Idle = 0, Receiving = 1, HeadersParsed = 2, BodyReceiving = 3,
    Complete = 4, Responding = 5, Sent = 6
};

/// @brief HTTP version.
enum class HttpVersion : uint8_t {
    Http10 = 0, Http11 = 1
};

/// @brief HTTP status code tag. Tags match HTTPABI.Layout.
enum class HttpStatusCode : uint8_t {
    Ok = 0, Created = 1, NoContent = 2, MovedPermanently = 3,
    Found = 4, NotModified = 5, BadRequest = 6, Unauthorized = 7,
    Forbidden = 8, NotFound = 9, MethodNotAllowed = 10,
    InternalServerError = 11, NotImplemented = 12, BadGateway = 13,
    ServiceUnavailable = 14
};

/// @brief Outcome of feeding raw HTTP data into a context.
enum class ParseResult : uint8_t {
    Complete = 0, Rejected = 1, NeedMore = 2
};

/// @brief RAII wrapper for an HTTP context slot in the Zig FFI pool.
///
/// Non-copyable; movable. Acquires a slot on construction and releases
/// it on destruction.
class HttpContext {
public:
    /// @brief Create a new HTTP context in the Idle phase.
    /// @throws ProvenError if the pool is exhausted.
    HttpContext()
        : slot_(ProvenError::check_slot(http_create_context())) {}

    ~HttpContext() { http_destroy_context(slot_); }

    // Non-copyable
    HttpContext(const HttpContext&) = delete;
    HttpContext& operator=(const HttpContext&) = delete;

    // Movable
    HttpContext(HttpContext&& other) noexcept : slot_(other.slot_) { other.slot_ = -1; }
    HttpContext& operator=(HttpContext&& other) noexcept {
        if (this != &other) {
            if (slot_ >= 0) http_destroy_context(slot_);
            slot_ = other.slot_;
            other.slot_ = -1;
        }
        return *this;
    }

    /// @brief Feed raw HTTP data for parsing.
    ParseResult parse_request(const uint8_t* data, uint32_t len) {
        return static_cast<ParseResult>(http_parse_request(slot_, data, len));
    }

    /// @brief Get the HTTP method (std::nullopt if not yet parsed).
    [[nodiscard]] std::optional<HttpMethod> get_method() const {
        uint8_t tag = http_get_method(slot_);
        if (tag == 255) return std::nullopt;
        return static_cast<HttpMethod>(tag);
    }

    /// @brief Copy the request path into buf. Returns bytes written.
    uint32_t get_path(uint8_t* buf, uint32_t len) const {
        return http_get_path(slot_, buf, len);
    }

    /// @brief Get the request path as a string.
    [[nodiscard]] std::string get_path_string() const {
        uint8_t buf[4096];
        uint32_t n = http_get_path(slot_, buf, sizeof(buf));
        return std::string(reinterpret_cast<char*>(buf), n);
    }

    /// @brief Look up a request header by key. Returns bytes written.
    uint32_t get_header(std::string_view key, uint8_t* buf, uint32_t blen) const {
        return http_get_header(slot_,
            reinterpret_cast<const uint8_t*>(key.data()),
            static_cast<uint32_t>(key.size()), buf, blen);
    }

    /// @brief Copy the request body into buf. Returns bytes written.
    uint32_t get_body(uint8_t* buf, uint32_t len) const {
        return http_get_body(slot_, buf, len);
    }

    /// @brief Set the response status code.
    /// @throws ProvenError if in wrong phase.
    void set_status(HttpStatusCode status) {
        ProvenError::check_status(http_set_status(slot_, static_cast<uint8_t>(status)));
    }

    /// @brief Set a response header.
    /// @throws ProvenError on state/capacity error.
    void set_header(std::string_view key, std::string_view value) {
        ProvenError::check_status(http_set_header(slot_,
            reinterpret_cast<const uint8_t*>(key.data()),
            static_cast<uint32_t>(key.size()),
            reinterpret_cast<const uint8_t*>(value.data()),
            static_cast<uint32_t>(value.size())));
    }

    /// @brief Set the response body.
    /// @throws ProvenError on state/capacity error.
    void set_body(const uint8_t* data, uint32_t len) {
        ProvenError::check_status(http_set_body(slot_, data, len));
    }

    /// @brief Send the response. Transitions Responding -> Sent.
    /// @throws ProvenError if not in Responding phase.
    void send_response() {
        ProvenError::check_status(http_send_response(slot_));
    }

    /// @brief Check if the connection uses keep-alive.
    [[nodiscard]] bool keep_alive_check() const {
        return http_keep_alive_check(slot_) == 1;
    }

    /// @brief Get the current request processing phase.
    [[nodiscard]] std::optional<RequestPhase> get_phase() const {
        uint8_t tag = http_get_phase(slot_);
        if (tag > 6) return std::nullopt;
        return static_cast<RequestPhase>(tag);
    }

    /// @brief Get the HTTP version.
    [[nodiscard]] std::optional<HttpVersion> get_version() const {
        uint8_t tag = http_get_version(slot_);
        if (tag > 1) return std::nullopt;
        return static_cast<HttpVersion>(tag);
    }

    /// @brief Reset the context for keep-alive reuse (Sent -> Idle).
    /// @throws ProvenError if not in Sent phase.
    void reset_context() {
        ProvenError::check_status(http_reset_context(slot_));
    }

    /// @brief Stateless: check if a lifecycle transition is valid.
    static bool can_transition(RequestPhase from, RequestPhase to) {
        return http_can_transition(static_cast<uint8_t>(from), static_cast<uint8_t>(to)) == 1;
    }

    /// @brief Return the ABI version of the linked library.
    static uint32_t abi_version() { return http_abi_version(); }

private:
    int slot_;
};

} // namespace proven

#endif // PROVEN_HTTPD_HPP
